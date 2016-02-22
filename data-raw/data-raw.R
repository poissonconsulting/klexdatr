library(sp)
library(spdep)
library(spa)
library(rgdal)
library(rgeos)
library(raster)
library(readr)
library(plyr)
library(dplyr)
library(magrittr)
library(lubridate)
library(assertr)
library(devtools)
library(datacheckr)
library(lexr)

rm(list = ls())

dir <- path.expand("~/Dropbox/Data")
dir %<>% file.path(basename(getwd())) %>%
  file.path("20160201")

epsg_data <- 26911
epsg_analysis <- 26911 # UTM Zone 11U
tz_data <- "PST8PDT"
tz_analysis <- "Etc/GMT+8"
species <- list("Bull Trout" = "BT", "Rainbow Trout" = "RB")

firstDateTime <- as.POSIXct("2008-04-01 00:00:00", tz = tz_analysis)
lastDateTime <- as.POSIXct("2013-12-31 23:59:59", tz = tz_analysis)

section <- readOGR(dsn = file.path(dir, "Shape"), layer = "array2015section")
section %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))

section@data %<>% select(SectionNumber = SECTNBR) %>% check_key("SectionNumber")

section@data %<>% mutate(Section = paste0("S", sprintf("%02d", SectionNumber)))

# combine sections
#section@data$Section[section@data$SectionNumber %in% 1:6] <- "S06"
section@data$Section[section@data$SectionNumber %in% 33:38] <- "S33"

section@data <- as.data.frame(bind_cols(
  section@data, select(as.data.frame(gCentroid(section, byid = TRUE)),
                       EastingSection = x, NorthingSection = y)))

section <- section[order(section@data$EastingSection,
                         section@data$NorthingSection),]

section@data$Section %<>% factor(levels = unique(.))

lexr:::plot_lex_section(section)

deployment <- read_csv(file.path(dir, "qryKLESReceiversAnalysis22Dec2015.txt"))

deployment %<>% mutate(Station = SiteName2015,
                       DateTimeReceiverIn = ISOdate(InYear, InMonth, InDay, tz = tz_data),
                       DateTimeReceiverOut = ISOdate(OutYear, OutMonth, OutDay, , tz = tz_data)) %>%
  mutate(DateTimeReceiverIn = with_tz(DateTimeReceiverIn, tz_analysis),
         DateTimeReceiverOut = with_tz(DateTimeReceiverOut, tz_analysis))

deployment$Reliable <- TRUE
message("no data several deployments 2008")
deployment$Reliable[deployment$Station %in% c(
  "Fry Creek", "South of Kaslo - West", "South of Kaslo - East")
  & deployment$InYear == 2008] <- FALSE

message("several apparently failed deployments")
deployment$Reliable[deployment$Station %in% c(
  "Woodbury Point")
  & deployment$InYear == 2009] <- FALSE

deployment$Reliable[deployment$Station %in% c(
  "Redman Point W")
  & deployment$InYear == 2010] <- FALSE

deployment$Reliable[deployment$Station == "South of Kaslo - West" & InYear == 2008 & InMonth == 5] <- FALSE

deployment %<>% filter(Reliable)

deployment %<>% filter((DateTimeReceiverIn >= firstDateTime & DateTimeReceiverIn <= lastDateTime) | (DateTimeReceiverOut >= firstDateTime & DateTimeReceiverOut <= lastDateTime))

station <- select(deployment, Station, EastingStation = Xn83z11u, NorthingStation = Yn83z11u)

station %<>% group_by(Station) %>% summarise(EastingStation = mean(EastingStation), NorthingStation = mean(NorthingStation)) %>% ungroup()

station %<>% check_key("Station") %>% as.data.frame()

station <- SpatialPointsDataFrame(select(station, EastingStation, NorthingStation),
                                  station,
                                  proj4string = CRS(paste0("+init=epsg:", epsg_data)))

station %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))
station@data[,c("EastingStation", "NorthingStation")] <- coordinates(station)

station <- bind_cols(station@data, select(sp::over(station, section), Section)) %>%
  filter(!is.na(Section))

# filter stations
station %<>% filter(!Section %in% c("S01", "S04", "S05", "S06", "S19", "S33"))

station %<>% arrange(Section, NorthingStation, EastingStation)
station$Station %<>% factor(., levels = .)
station %<>%  select(Station, Section, EastingStation, NorthingStation)

lexr:::plot_lex_station(station, section)
lexr:::check_lex_station(station)
use_data(station, overwrite = TRUE)

deployment %<>% filter(Station %in% station$Station)

deployment$Station %<>% factor(., levels = levels(station$Station))
deployment %<>% select(Station, Receiver = RecNbr, DateTimeReceiverIn, DateTimeReceiverOut) %>% as.tbl() %>% verify(DateTimeReceiverIn < DateTimeReceiverOut)

# filter overlapping deployments
deployment %<>% filter(!Receiver %in% c(0,2:5)) %>% filter(!Receiver %in% 3228:3231)
deployment$Receiver %<>% factor()

lexr:::plot_lex_deployment(deployment)
lexr:::check_lex_deployment(deployment)
use_data(deployment, overwrite = TRUE)

acoustic_tag <- read_csv(file.path(dir, "qryKLESAcousticTag22Dec2015.txt"))
acoustic_tag %<>% filter(!is.na(TagLife))
acoustic_tag %<>% select(AcousticTag = TagIDNbr, TagLife, DepthRangeTag = Range_m) %>%
  mutate(TagLife = as.integer(TagLife))

capture <- read_csv(file.path(dir, "qryKLESCaptureAnalysis22Dec2015.txt"))

capture %<>% mutate(
  DateTimeCapture = ISOdate(CapYear, CapMonth, CapDay, CapHour, CapMinute, tz = tz_data)) %>%
  mutate(DateTimeCapture = with_tz(DateTimeCapture, tz_analysis))

capture %<>% filter(DateTimeCapture >= firstDateTime & DateTimeCapture <= lastDateTime)

capture %<>% rename(AcousticTag = TagIDNbr) %>%
  inner_join(acoustic_tag, by = "AcousticTag")

adjust_taglife <- function(x) {
  if (is.na(x$AcousticTag[1])) {
    x$TagLife <- -1
    return(x)
  }
  if (nrow(x) == 1)
    return(x)
  x %<>% arrange(DateTimeCapture)
  print(x)
  x$TagLife %<>% subtract(as.Date(x$DateTimeCapture) - as.Date(x$DateTimeCapture[1])) %>%
    as.integer()
  x
}

capture %<>% ddply(.(AcousticTag), adjust_taglife)

capture %<>% mutate(DateTimeTagExpire = DateTimeCapture + days(TagLife))

capture %<>% mutate(CaptureX = Xn83z11u,
                    CaptureY = Yn83z11u,
                    Species = factor(Species),
                    Length = as.integer(Length))

levels(capture$Species) <- species

capture %<>% filter(MortalityYN != "Yes")
capture %<>% filter(Length > 0)

is.na(capture$Weight[capture$WeigthType != "Measured"]) <- TRUE

capture %<>% select(Capture = CaptureID, DateTimeCapture, Species, AcousticTag,
                    Length, Weight,
                    TBarTag1, TBarTag1Reward, TBarTag2, TBarTag2Reward,
                    DateTimeTagExpire, DepthRangeTag, CaptureX, CaptureY)

is.na(capture$TBarTag1[capture$TBarTag1 < 0]) <- TRUE
is.na(capture$TBarTag2[!is.na(capture$TBarTag2) & capture$TBarTag2 < 0]) <- TRUE
is.na(capture$TBarTag1Reward[capture$TBarTag1Reward < 0]) <- TRUE
is.na(capture$TBarTag2Reward[!is.na(capture$TBarTag2Reward) & capture$TBarTag2Reward < 0]) <- TRUE

capture %<>% filter(!is.na(TBarTag1) | !is.na(TBarTag2))

capture %<>% mutate(Switch = !is.na(TBarTag2) & TBarTag1Reward < TBarTag2Reward)

tbartag <- capture$TBarTag2[capture$Switch]
capture$TBarTag2[capture$Switch] <- capture$TBarTag1[capture$Switch]
capture$TBarTag1[capture$Switch] <- tbartag

reward <- capture$TBarTag2Reward[capture$Switch]
capture$TBarTag2Reward[capture$Switch] <- capture$TBarTag1Reward[capture$Switch]
capture$TBarTag1Reward[capture$Switch] <- reward

capture %<>% select(-Switch) %>% verify(!is.na(TBarTag1)) %>% verify(is.na(TBarTag2Reward) | TBarTag1Reward >= TBarTag2Reward) %>% as.data.frame()

capture <- SpatialPointsDataFrame(select(capture, CaptureX, CaptureY),
                                  select(capture, -CaptureX, -CaptureY),
                                  proj4string = CRS(paste0("+init=epsg:", epsg_data)))

capture %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))
capture@data[,c("CaptureX", "CaptureY")] <- coordinates(capture)

capture <- bind_cols(capture@data, select(sp::over(capture, section), Section)) %>%
  filter(!is.na(Section))

recapture <- read_csv(file.path(dir, "qryKLESRecaptureAnalysis26Jan2016.txt"))

recapture %<>% mutate(
  DateTimeRecapture = ISOdate(ReCapYear, ReCapMonth, ReCapDay, tz = tz_analysis))

recapture %<>% filter(DateTimeRecapture >= firstDateTime & DateTimeRecapture <= lastDateTime)

recapture %<>% select(DateTimeRecapture,
                      Released, TagsRemoved,
                      TBarTag1Recap, TBarTag2Recap, Public = RecapType,
                      RecaptureX = Xn83z11u, RecaptureY = Yn83z11u,
                      Capture = CaptureID, RecaptureDBID = RecaptureID) %>%
  as.data.frame()

recapture$RecaptureX[is.na(recapture$RecaptureX)] <- 0
recapture$RecaptureY[is.na(recapture$RecaptureY)] <- 0

recapture <- SpatialPointsDataFrame(select(recapture, RecaptureX, RecaptureY),
                                    recapture,
                                    proj4string = CRS(paste0("+init=epsg:", epsg_data)))

recapture %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))
recapture@data[,c("RecaptureX", "RecaptureY")] <- coordinates(recapture)

recapture <- bind_cols(recapture@data, select(sp::over(recapture, section), Section))

recapture$Released %<>% factor()
levels(recapture$Released) <- list("FALSE" = "No", "TRUE" = "Yes")
recapture$Released %<>% as.logical()

recapture$TagsRemoved %<>% factor()
levels(recapture$TagsRemoved) <- list("FALSE" = "No", "TRUE" = "Yes")
recapture$TagsRemoved %<>% as.logical()

recapture$Public %<>% factor()
levels(recapture$Public) <- list("FALSE" = "Researcher", "TRUE" = "Public")
recapture$Public %<>% as.logical()

is.na(recapture$TBarTag1Recap[!is.na(recapture$TBarTag1Recap) & recapture$TBarTag1Recap < 0]) <- TRUE
is.na(recapture$TBarTag2Recap[!is.na(recapture$TBarTag2Recap) & recapture$TBarTag2Recap < 0]) <- TRUE

recapture %<>% inner_join(select(capture, -Section), by = "Capture") %>%
  verify(DateTimeRecapture > DateTimeCapture)

recapture$TBarTag1 <- recapture$TBarTag1 %in% c(recapture$TBarTag1Recap, recapture$TBarTag2Recap)
recapture$TBarTag2 <- recapture$TBarTag2 %in% c(recapture$TBarTag1Recap, recapture$TBarTag2Recap)

recapture %<>% arrange(DateTimeRecapture)
recapture %<>% select(DateTimeRecapture, Capture, SectionRecapture = Section,
                      TBarTag1, TBarTag2,
                      TagsRemoved, Released, Public)

capture %<>% arrange(Species, DateTimeCapture, Capture)
capture$Capture %<>% sprintf("%03d", .) %>% paste0("F", .) %>% factor(., levels = .)
recapture$Capture %<>% sprintf("%03d", .) %>% paste0("F", .) %>% factor(., levels = levels(capture$Capture))

fillin_missing <- function(x, bol) {
  x_name <- deparse(substitute(x))
  message("replacing ", sum(is.na(x)), " missing values in ", x_name, " with ", bol)
  x[is.na(x)] <- bol
  x
}

recapture$TagsRemoved <- fillin_missing(recapture$TagsRemoved, TRUE)
recapture$Released <- fillin_missing(recapture$Released, FALSE)
recapture$Public <- fillin_missing(recapture$Public, TRUE)

lexr:::plot_lex_recapture(recapture)
lexr:::check_lex_recapture(recapture)
use_data(recapture, overwrite = TRUE)

capture %<>% left_join(select(filter(recapture, !Released), DateTimeRecapture, Capture), by = c("Capture"))
capture %<>% mutate(CurtailTagExpire = !is.na(DateTimeRecapture) & DateTimeRecapture < DateTimeTagExpire)
capture$DateTimeTagExpire[capture$CurtailTagExpire] <-  capture$DateTimeRecapture[capture$CurtailTagExpire]

capture %<>% select(Capture, DateTimeCapture, Section, Species, Length, Weight,
                    Reward1 = TBarTag1Reward, Reward2 = TBarTag2Reward,
                    DateTimeTagExpire, DepthRangeTag, AcousticTag)
capture$DepthRangeTag %<>% as.integer()

detection <- read_csv(file.path(dir, "qryKLESVueDetectionRaw01Feb2016.txt"))

detection %<>% mutate(
  DateTimeDetection = ISOdate(YearUTC, MonthUTC, DayUTC, HourUTC, tz = "UTC")) %>%
  mutate(DateTimeDetection = with_tz(DateTimeDetection, tz_analysis))

detection %<>% filter(DateTimeDetection >= firstDateTime)

detection %<>% rename(AcousticTag = TagIDNbr,
                      Detections = DetectCount,
                      DetectionDBID = VR2WDetectID)

detection %<>% mutate(Receiver = RecNbr)

detection %<>% inner_join(capture, by = "AcousticTag")

detection %<>% filter(DateTimeDetection > DateTimeCapture, DateTimeDetection < DateTimeTagExpire)

detection %<>% filter(Detections >= 3)

detection$Receiver %<>% factor(., levels = levels(deployment$Receiver))
detection %<>% filter(!is.na(Receiver))
detection %<>% inner_join(deployment, by = "Receiver")
detection %<>% filter(DateTimeDetection > DateTimeReceiverIn, DateTimeDetection < DateTimeReceiverOut)

detection %<>% select(DateTimeDetection, Capture, Receiver, Detections)

# filter duplicate detections
detection <- detection[!duplicated(detection[c("DateTimeDetection", "Capture", "Receiver", "Detections")]),]

lexr:::plot_lex_detection(detection)
lexr:::check_lex_detection(detection)
use_data(detection, overwrite = TRUE)

depth <- read_csv(file.path(dir, "qryKLESVueDepthRaw01Feb2016.txt"))

depth %<>% mutate(
  DateTimeDepth = ISOdate(YearUTC, MonthUTC, DayUTC, HourUTC, MinUTC, SecUTC, tz = "UTC")) %>%
  mutate(DateTimeDepth = with_tz(DateTimeDepth, tz_analysis), Depth_m = as.numeric(Depth_m))

depth %<>% filter(DateTimeDepth >= firstDateTime & DateTimeDepth <= lastDateTime)

depth %<>% mutate(Receiver = RecNbr) %>%
  rename(AcousticTag = TagIDNbr, Depth = Depth_m)

depth %<>% inner_join(capture, by = "AcousticTag")

depth %<>% filter(DateTimeDepth > DateTimeCapture, DateTimeDepth < DateTimeTagExpire)

depth$Receiver %<>% factor(., levels = levels(deployment$Receiver))
depth %<>% filter(!is.na(Receiver))
depth %<>% inner_join(deployment, by = "Receiver")
depth %<>% filter(DateTimeDepth > DateTimeReceiverIn, DateTimeDepth < DateTimeReceiverOut)

depth %<>% select(DateTimeDepth, Capture, Receiver, Depth)

lexr:::plot_lex_depth(depth)
lexr:::check_lex_depth(depth)
use_data(depth, overwrite = TRUE)

capture %<>% select(-AcousticTag)
capture %<>% rename(SectionCapture = Section)

lexr:::plot_lex_capture(capture)
lexr:::check_lex_capture(capture)
use_data(capture, overwrite = TRUE)

# filter sections
# section <- section[!section@data$SectionNumber %in% 1:5,]
section <- section[!section@data$SectionNumber %in% 34:38,]

# crop sections
#section %<>% raster::crop(extent(c(1642500, 1690000, 500000, 625000)))

section@data %<>% select(-EastingSection, -NorthingSection)
section@data <- as.data.frame(bind_cols(
  section@data, select(as.data.frame(gCentroid(section, byid = TRUE)),
                       EastingSection = x, NorthingSection = y)))

section <- section[order(section@data$EastingSection,
                         section@data$NorthingSection),]

section@data$Habitat <- factor("Lentic", levels = c("Lentic", "Lotic"))
section@data$Habitat[section@data$SectionNumber %in% c(1:2, 5:6, 19:20, 33:38)] <- "Lotic"

section@data$Bounded <- TRUE
section@data$Bounded[section@data$SectionNumber %in% c(6, 19, 33)] <- FALSE

section@data %<>% select(Section, Habitat, Bounded, EastingSection, NorthingSection)
row.names(section) <- as.character(section@data$Section)

lexr:::plot_lex_section(section)
lexr:::check_lex_section(section)
use_data(section, overwrite = TRUE)
