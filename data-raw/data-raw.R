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
  file.path("20160114")

firstYear <- 2013
lastYear <- 2015
epsg_data <- 26910
epsg_analysis <- 3005 # bc albers
tz_data <- "PST8PDT"
tz_analysis <- "Etc/GMT+8"
species <- list("Bull Trout" = "BT", "Lake Trout" = "LT", "Rainbow Trout" = "RB")

section <- readOGR(dsn = file.path(dir, "shape"), layer = "quesarray2015section")
section %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))

section@data %<>% select(Section = SECTIONID, WATERBODY) %>% check_key("Section")

# filter out wanted sections
section <- section[section@data$Section %in% c(1,9:39),]

section@data <- as.data.frame(bind_cols(
  section@data, select(as.data.frame(gCentroid(section, byid = TRUE)),
                       EastingSection = x, NorthingSection = y)))

section <- section[order(section@data$EastingSection,
                         section@data$NorthingSection),]

section@data$Section %<>% sprintf("%02d", .) %>% paste0("S", .) %>%
  factor(., levels = .)

section@data$Habitat <- factor(NA, levels = c("Lentic", "Lotic"))
section@data$Habitat[grepl("Lake", section@data$WATERBODY)] <- "Lentic"
section@data$Habitat[grepl("Creek|River", section@data$WATERBODY)] <- "Lotic"

section$Bounded <- TRUE
section$Bounded[section$Section %in% c("S01", "S39")] <- FALSE
section@data %<>% select(Section, Habitat, Bounded, EastingSection, NorthingSection)
lexr:::plot_section(section)

deployment <- read_csv(file.path(dir, "qryQUESReceiversAnalysis01Jan2016.txt"))

deployment %<>% mutate(Station = VUEStationName,
                       DateTimeReceiverIn = ISOdate(InYear, InMonth, InDay, InHour, InMinute, InSecond, tz = tz_data),
                       DateTimeReceiverOut = ISOdate(OutYear, OutMonth, OutDay, OutHour, OutMinute, OutSecond, tz = tz_data)) %>%
  mutate(DateTimeReceiverIn = with_tz(DateTimeReceiverIn, tz_analysis),
         DateTimeReceiverOut = with_tz(DateTimeReceiverOut, tz_analysis))

deployment %<>% filter(LocType == "Same")

station <- select(deployment, Station, EastingStation = Xn83z10u, NorthingStation = Yn83z10u) %>% unique() %>% check_key("Station") %>%
  as.data.frame()

station <- SpatialPointsDataFrame(select(station, EastingStation, NorthingStation),
                                  station,
                                  proj4string = CRS(paste0("+init=epsg:", epsg_data)))

station %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))
station@data[,c("EastingStation", "NorthingStation")] <- coordinates(station)

station <- bind_cols(station@data, select(sp::over(station, section), Section)) %>%
  filter(!is.na(Section))

station %<>% arrange(Section, EastingStation, NorthingStation)
station$Station %<>% factor(., levels = .)
station %<>%  select(Station, Section, EastingStation, NorthingStation)

use_data(station, overwrite = TRUE)
lexr:::plot_station(station, section)

deployment %<>% filter(Station %in% station$Station)

deployment$Station %<>% factor(., levels = levels(station$Station))
deployment %<>% select(Station, Receiver = RecNbr, DateTimeReceiverIn, DateTimeReceiverOut) %>% as.tbl() %>% verify(DateTimeReceiverIn < DateTimeReceiverOut)

deployment$Receiver %<>% factor()

use_data(deployment, overwrite = TRUE)
lexr:::plot_deployment(deployment)

acoustic_tag <- read_csv(file.path(dir, "qryQUESAcousticTagAnalysis21Dec2015.txt"))
acoustic_tag %<>% filter(!is.na(TagLife))
acoustic_tag %<>% select(AcousticTag = TagIDNbr, TagLife, DepthRangeTag = Range_m) %>%
  mutate(TagLife = as.integer(TagLife))

capture <- read_csv(file.path(dir, "qryQUESCaptureAnalysis21Dec2015.txt"))

capture %<>% mutate(
  DateTimeCapture = ISOdate(CapYear, CapMonth, CapDay, CapHour, CapMin, CapSec, tz = tz_data)) %>%
  mutate(DateTimeCapture = with_tz(DateTimeCapture, tz_analysis))

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

capture %<>% mutate(CaptureX = Xn83z10u,
                    CaptureY = Yn83z10u,
                    Species = factor(Species),
                    Length = as.integer(Length))

levels(capture$Species) <- species

capture %<>% filter(MortalityYN == "No")
capture %<>% filter(Length > 0)

is.na(capture$Weight[capture$WeigthType != "Measured"]) <- TRUE

capture %<>% select(Capture = CaptureID, DateTimeCapture, Species, AcousticTag,
                    Length, Weight,
                    TBarTag1 = TBarTag01, TBarTag1Reward, TBarTag2 = TBarTag02, TBarTag2Reward,
                    DateTimeTagExpire, DepthRangeTag, CaptureX, CaptureY)

is.na(capture$TBarTag1[capture$TBarTag1 < 0]) <- TRUE
is.na(capture$TBarTag2[capture$TBarTag2 < 0]) <- TRUE
is.na(capture$TBarTag1Reward[capture$TBarTag1Reward < 0]) <- TRUE
is.na(capture$TBarTag2Reward[capture$TBarTag2Reward < 0]) <- TRUE

capture %<>% filter(!is.na(TBarTag1) | !is.na(TBarTag2))

capture %<>% mutate(Switch = !is.na(TBarTag2) & TBarTag1Reward < TBarTag2Reward)

tbartag <- capture$TBarTag2[capture$Switch]
capture$TBarTag2[capture$Switch] <- capture$TBarTag1[capture$Switch]
capture$TBarTag1[capture$Switch] <- tbartag

reward <- capture$TBarTag2Reward[capture$Switch]
capture$TBarTag2Reward[capture$Switch] <- capture$TBarTag1Reward[capture$Switch]
capture$TBarTag1Reward[capture$Switch] <- reward

capture %<>% select(-Switch) %>% verify(!is.na(TBarTag1)) %>% verify(TBarTag1Reward > TBarTag2Reward) %>% as.data.frame()

capture <- SpatialPointsDataFrame(select(capture, CaptureX, CaptureY),
                                  select(capture, -CaptureX, -CaptureY),
                                  proj4string = CRS(paste0("+init=epsg:", epsg_data)))

capture %<>% spTransform(CRS(paste0("+init=epsg:", epsg_analysis)))
capture@data[,c("CaptureX", "CaptureY")] <- coordinates(capture)

capture <- bind_cols(capture@data, select(sp::over(capture, section), Section)) %>%
  filter(!is.na(Section))

recapture <- read_csv(file.path(dir, "qryQUESRecaptureAnalysis21Dec2015.txt"))

recapture %<>% mutate(
  DateTimeRecapture = ISOdate(ReCapYear, ReCapMonth, ReCapDay, tz = tz_analysis))

recapture %<>% select(DateTimeRecapture,
                      Released, TagsRemoved = TagRemoved,
                      TBarTag1Recap, TBarTag2Recap,
                      RecaptureX = Xn83z10u, RecaptureY = Yn83z10u,
                      Capture = CaptureID, RecaptureDBID = ReCaptureID) %>%
  as.data.frame()

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

is.na(recapture$TBarTag1Recap[recapture$TBarTag1Recap < 0]) <- TRUE
is.na(recapture$TBarTag2Recap[recapture$TBarTag2Recap < 0]) <- TRUE

recapture %<>% inner_join(select(capture, -Section), by = "Capture") %>%
  verify(DateTimeRecapture > DateTimeCapture)

recapture$TBarTag1 <- recapture$TBarTag1 %in% c(recapture$TBarTag1Recap, recapture$TBarTag2Recap)
recapture$TBarTag2 <- recapture$TBarTag2 %in% c(recapture$TBarTag1Recap, recapture$TBarTag2Recap)

recapture %<>% arrange(DateTimeRecapture)
recapture %<>% select(DateTimeRecapture, Capture, Section, TBarTag1, TBarTag2,
                      TagsRemoved, Released, Section)

capture %<>% arrange(Species, DateTimeCapture, Capture)
capture$Capture %<>% sprintf("%03d", .) %>% paste0("F", .) %>% factor(., levels = .)
recapture$Capture %<>% sprintf("%03d", .) %>% paste0("F", .) %>% factor(., levels = levels(capture$Capture))

recapture$TagsRemoved[is.na(recapture$TagsRemoved)] <- TRUE
recapture$Released[is.na(recapture$Released)] <- FALSE

recapture %<>% rename(SectionRecapture = Section)

use_data(recapture, overwrite = TRUE)
lexr:::plot_recapture(recapture)

capture %<>% select(Capture, DateTimeCapture, Section, Species, Length, Weight,
                    Reward1 = TBarTag1Reward, Reward2 = TBarTag2Reward,
                    DateTimeTagExpire, DepthRangeTag, AcousticTag)
capture$DepthRangeTag %<>% as.integer()

detection <- read_csv(file.path(dir, "qryQUESVueDetectionsRaw21Dec2015.txt"))

detection %<>% mutate(
  DateTimeDetection = ISOdate(YearLMT, MonthLMT, DatLMT, HourLMT, tz = tz_data)) %>%
  mutate(DateTimeDetection = with_tz(DateTimeDetection, tz_analysis))

detection %<>% rename(AcousticTag = TagIDNbr,
                      Detections = DetectCount,
                      DetectionDBID = VR2WDetectID)

detection %<>% mutate(Receiver = RecNbr)

detection %<>% inner_join(capture, by = "AcousticTag")

detection %<>% filter(DateTimeDetection > DateTimeCapture, DateTimeDetection < DateTimeTagExpire)

detection$Receiver %<>% factor(., levels = levels(deployment$Receiver))
detection %<>% filter(!is.na(Receiver))
detection %<>% inner_join(deployment, by = "Receiver")
detection %<>% filter(DateTimeDetection > DateTimeReceiverIn, DateTimeDetection < DateTimeReceiverOut)

detection %<>% select(DateTimeDetection, Capture, Receiver, Detections)

use_data(detection, overwrite = TRUE)
lexr:::plot_detection(detection)

depth <- read_csv(file.path(dir, "qryQUESVueDepthRaw21Dec2015.txt"))

check_key(depth, c("YearLMT", "MonthLMT", "DatLMT", "HourLMT", "MinLMT", "SecLMT", "CaptureID", "Receiver"))

depth %<>% mutate(
  DateTimeDepth = ISOdate(YearLMT, MonthLMT, DatLMT, HourLMT, MinLMT, SecLMT, tz = tz_data)) %>%
  mutate(DateTimeDepth = with_tz(DateTimeDepth, tz_analysis))

depth %<>% mutate(Receiver = RecNbr) %>%
  rename(AcousticTag = TagIDNbr, Depth = Depth_m)

depth %<>% inner_join(capture, by = "AcousticTag")

depth %<>% filter(DateTimeDepth > DateTimeCapture, DateTimeDepth < DateTimeTagExpire)

depth$Receiver %<>% factor(., levels = levels(deployment$Receiver))
depth %<>% filter(!is.na(Receiver))
depth %<>% inner_join(deployment, by = "Receiver")
depth %<>% filter(DateTimeDepth > DateTimeReceiverIn, DateTimeDepth < DateTimeReceiverOut)

depth %<>% select(DateTimeDepth, Capture, Receiver, Depth)

use_data(depth, overwrite = TRUE)
lexr:::plot_depth(depth)

capture %<>% select(-AcousticTag)
capture %<>% rename(SectionCapture = Section)

use_data(capture, overwrite = TRUE)

section %<>% raster::crop(extent(c(1295000, 1381700, 835000, 894696.5)))

section@data %<>% select(-EastingSection, -NorthingSection)
section@data <- as.data.frame(bind_cols(
  section@data, select(as.data.frame(gCentroid(section, byid = TRUE)),
                       EastingSection = x, NorthingSection = y)))

section <- section[order(section@data$EastingSection,
                         section@data$NorthingSection),]

use_data(section, overwrite = TRUE)
lexr:::plot_section(section)
