# library -----------------------------------------------------------------

library(sp)
library(spdep)
library(rgdal)
library(rgeos)
library(plyr)
library(dplyr)
library(magrittr)
library(lubridate)
library(assertr)
library(devtools)

# section - neighbours -----------------------------------------------------------------

firstYear <- 2008
lastYear <- 2014

dir <- path.expand("~/Dropbox/Data/")
dir %<>% file.path(basename(getwd())) %>%
  file.path("20151118")

section <- readOGR(dsn = file.path(dir, "Shape"), layer = "array2015section")
section %<>% spTransform(CRS("+init=epsg:26911"))

section <- section[section@data$SECTNBR %in% 1:34,]

section@data$SECTDESC %<>% as.character()
section@data$SECTNAME %<>% as.character()
section@data$SECTDESC[section@data$SECTDESC == "KOTL"] <- section@data$SECTNAME[section@data$SECTDESC == "KOTL"]
section@data$SECTDESC[section@data$SECTDESC == "Creston Delta"] <- c("Creston Delta", "Creston Mouth")

section@data$System <- factor(NA, levels = c("North Arm", "South Arm", "West Arm", "Crawford Bay", "Kootenay River", "Duncan River", "Lardeau River"))
section@data$System[substr(section@data$SECTNAME,1,3) == "LAR"] <- "Lardeau River"
section@data$System[substr(section@data$SECTNAME,1,3) == "DUR" & section@data$MINRKM > 61] <- "Duncan River"
section@data$System[substr(section@data$SECTNAME,1,3) == "DUR" & section@data$MINRKM < 61] <- "North Arm"
section@data$System[substr(section@data$SECTNAME,1,3) == "KOR" & section@data$MINRKM < 71] <- "West Arm"
section@data$System[substr(section@data$SECTNAME,1,3) == "KOR" & section@data$MINRKM > 71 & section@data$MINRKM < 120] <- "South Arm"
section@data$System[substr(section@data$SECTNAME,1,3) == "CRA"] <- "Crawford Bay"
section@data$System[substr(section@data$SECTNAME,1,3) == "KOR" & section@data$MINRKM > 120] <- "Kootenay River"

section@data %<>% select(SectionID = SECTNBR, Section = SECTDESC, System)

section <- section[order(section$SectionID),]
section@data %<>% verify(diff(SectionID) == 1) %>% select(-SectionID)

section@data$Section %<>% factor(., levels = as.character(.))

section@data$Area <- gArea(section, byid = TRUE) / 10^6
section@data <- as.data.frame(bind_cols(section@data, select(as.data.frame(gCentroid(section, byid = TRUE)), Easting = x, Northing = y)))
section@data %<>% mutate(Easting = as.integer(round(Easting)), Northing = as.integer(round(Northing)))

plot(section, col = "grey80")
neighbours <- poly2nb(section, row.names = section@data$Section)

summary(neighbours)
plot(neighbours, coordinates(section), col = "red", add = TRUE)
plot(neighbours, coordinates(section), col = "red")

movement <- matrix(FALSE, nrow = nrow(section@data), ncol = nrow(section@data))
for (i in 1:nrow(section@data)) {
  movement[i,neighbours[[i]]] <- TRUE
}
diag(movement) <- TRUE
stopifnot(isSymmetric(movement))

use_data(movement, overwrite = TRUE)

section@data %<>% mutate(Number = as.integer(Section)) %>% select(Section, System, Area, SectionX = Easting, SectionY = Northing)

section_sp <- section
section <- section@data
use_data(section, overwrite = TRUE)
section_sp@data <- select(section_sp@data, Section)
use_data(section_sp, overwrite = TRUE)
section <- section_sp

# fish - recapture -----------------------------------------------------

fish <- read.csv(file.path(dir, "qryCaptureAnalysis05Nov2015v2.txt"), stringsAsFactors = TRUE)
recapture <- read.csv(file.path(dir, "qryRecaptureAnalysis.txt"), stringsAsFactors = TRUE)
tags <- read.csv(file.path(dir, "qryKLESAcousticTag.txt"), stringsAsFactors = TRUE)

is.na(fish$AcousticTag[fish$AcousticTag == ""]) <- TRUE

fish %<>%
  filter(!is.na(fish$AcousticTag) | TBarTag1Reward > 0 | TBarTag2Reward > 0) %>%
  verify(!is.na(TBarTag1)) %>%
  mutate(CaptureDate = as.Date(paste(CapYear, CapMonth, CapDay, sep = "-")),
         Switch = !is.na(TBarTag2) & TBarTag1Reward < TBarTag2Reward) %>%
  dplyr::rename(FishID = CaptureID, Easting = Xn83z11u, Northing = Yn83z11u) %>%
  verify(LengthType == "Measured") %>% verify(CaptureMort != "Yes") %>%
  select(FishID, CaptureDate, Length, Weight, Species, AcousticTag, Switch, TBarTag1, TBarTag1Reward,
TBarTag2, TBarTag2Reward, Easting, Northing)

fish$AcousticTag %<>% droplevels()
levels(fish$Species) <- list("Bull Trout" = "BT", "Rainbow Trout" = "RB")

tbartag <- fish$TBarTag2[fish$Switch]
fish$TBarTag2[fish$Switch] <- fish$TBarTag1[fish$Switch]
fish$TBarTag1[fish$Switch] <- tbartag

reward <- fish$TBarTag2Reward[fish$Switch]
fish$TBarTag2Reward[fish$Switch] <- fish$TBarTag1Reward[fish$Switch]
fish$TBarTag1Reward[fish$Switch] <- reward

fish %<>% select(-Switch) %>% verify(!is.na(TBarTag1))

fish %<>% filter(!is.na(AcousticTag))

summary(fish)

message("filter 3 BT from flip bucket because not consistently checked")
recapture %<>% filter(CaptureMethod == "Angling")

recapture %<>%
  mutate(RecaptureDate = as.Date(paste(ReCapYear, ReCapMonth, ReCapDay, sep = "-"))) %>%
  mutate(Released = Released == "Yes") %>%
  select(FishID = CaptureID, RecaptureDate, Released, TagLoss, TBarTag1Recap = TBarTag1,
         TBarTag2Recap = TBarTag2, Reward, Comments)

levels(recapture$Reward) <- list("0" = c("No", "No Tags", "Non Reward"), "10" = "Paid $10", "100" = "Paid $100", "110" = "Paid $110")
recapture$Reward %<>% as.character() %>% as.integer()
levels(recapture$TagLoss) <- list("TRUE" = "Confirmed", "FALSE" = "No")
recapture$TagLoss %<>% as.logical()

message("discard recaps not in filtered captures table")
recapture %<>% inner_join(fish, by = "FishID") %>% verify(!is.na(Reward)) %>% verify(RecaptureDate > CaptureDate)

recapture$Tag1 <- recapture$TBarTag1 %in% c(recapture$TBarTag1Recap, recapture$TBarTag2Recap)
recapture$Tag2 <- recapture$TBarTag2 %in% c(recapture$TBarTag1Recap, recapture$TBarTag2Recap)
recapture %<>% verify(!TagLoss == (Tag1 & Tag2))

recapture$TBarTag1Reward[!recapture$Tag1] <- 0
recapture$TBarTag2Reward[is.na(recapture$TBarTag2Reward) | !recapture$Tag2] <- 0

message("Fish 142 was released with all tags")
recapture$TagsRemoved <- !recapture$FishID == 142

recapture %<>% select(Fish = FishID, RecaptureDate, TBar1 = Tag1, TBar2 = Tag2, TagsRemoved, Released)

tags %<>%
  select(Transmitter, AcousticTag = TagNumber, TransmitterLife = TagLife)
tags$AcousticTag %<>% as.character()
fish$AcousticTag %<>% as.character()

fish %<>% left_join(tags, by = "AcousticTag") %>% select(-AcousticTag) %>% verify(!is.na(FishID))

transmitterlife <- function(x) {
  if (is.na(x$Transmitter[1])) {
    x$TransmitterLife <- -1
    return(x)
  }
  if (nrow(x) == 1)
    return(x)
  x %<>% arrange(CaptureDate, Transmitter)
  x$TransmitterLife %<>% subtract(x$CaptureDate - x$CaptureDate[1]) %>% as.integer()
  x
}

fish %<>% ddply(.(Transmitter), transmitterlife)

fish %<>% select(FishID, CaptureDate, Species, FishLength = Length, FishWeight = Weight,
                    Reward1 = TBarTag1Reward, Reward2 = TBarTag2Reward,
                    Transmitter, TransmitterLife, Easting, Northing)

fish <- SpatialPointsDataFrame(select(fish, Easting, Northing),
                                  select(fish, -Easting, -Northing),
                                  proj4string = CRS("+init=epsg:26911"))

fish <- bind_cols(fish@data, select(sp::over(fish, section), Section))
fish %<>% as.data.frame() %>% verify(!is.na(Section))

fish %<>% select(Fish = FishID, CaptureDate, Section, Species, Length = FishLength, Weight = FishWeight, Reward1, Reward2, Transmitter, TransmitterLife)

fish %<>% mutate(ExpirationDate = CaptureDate + TransmitterLife) %>% select(-TransmitterLife)

fish %<>% left_join(recapture, by = "Fish")

bol <- !is.na(fish$Released) & !fish$Released & fish$RecaptureDate < fish$ExpirationDate
fish$ExpirationDate[bol] <- fish$RecaptureDate[bol] - 1

fish$Acoustic <- !is.na(fish$Transmitter)

fish %<>% select(Fish, CaptureDate, Section, Species, Length, Weight, Reward1, Reward2, Acoustic, ExpirationDate, Transmitter)

fish %<>% filter(Length >= 500)
recapture %<>% filter(Fish %in% fish$Fish)
stopifnot(year(recapture$RecaptureDate) %in% firstYear:lastYear)

fish %<>% arrange(Species, CaptureDate, Fish)
fish$Fish <- factor(fish$Fish, levels = fish$Fish)

recapture$Fish %<>% factor(levels = levels(fish$Fish))
use_data(recapture, overwrite = TRUE)

# receiver ----------------------------------------------------------------

receiver <- read.csv(file.path(dir, "qryMOEReceiversAnalysis18Nov2015.txt"), stringsAsFactors = TRUE)

receiver$Receiver <- receiver$RecSerial
receiver %<>% mutate(DateIn = as.Date(paste(InYear, InMonth, InDay, sep = "-")),
                      DateOut = as.Date(paste(OutYear, OutMonth, OutDay, sep = "-")))

receiver %<>% filter(Xn83z11u != 0)
receiver %<>% filter(year(DateOut) >= 2007)

receiver %<>% select(Receiver, Location = SiteName2015, DateIn, DateOut, Easting = as.integer(round(Xn83z11u)), Northing = as.integer(round(Yn83z11u)))

receiver <- SpatialPointsDataFrame(select(receiver, Easting, Northing),
                                  receiver,
                                  proj4string = CRS("+init=epsg:26911"))

receiver <- bind_cols(receiver@data, select(sp::over(receiver, section), Section))
receiver %<>% as.data.frame() %>% filter(!is.na(Section)) %>% filter(Section != "Kootenay River-CAN")

receiver %<>% ddply(.(Location), function (x) {if (nrow(x) < 3) return(NULL); x })
receiver$Location %<>% droplevels()

location <- group_by(receiver, Location) %>% dplyr::summarise(Easting = as.integer(round(mean(Easting))), Northing = as.integer(round(mean(Northing))), Section = first(Section)) %>%
  as.data.frame()

location %<>% arrange(-Northing, Easting) %>% select(Location, Section, ReceiverX = Easting, ReceiverY = Northing)

receiver2 <- receiver
receiver <- location
receiver %<>% dplyr::rename(Receiver = Location)

use_data(receiver, overwrite = TRUE)

receiver <- receiver2
receiver %<>% select(Location, Receiver, DateIn, DateOut)

# detection ---------------------------------------------------------------

detection <- read.csv(file.path(dir, "tblKLESVueExportRaw18Nov2015.txt"), stringsAsFactors = TRUE)

detection$Receiver <- detection$RecSerial

detection %<>%
  mutate(DateTime = with_tz(parse_date_time(DateTimeUTC, "%Y-%m-%d %H:%M:%S"), tz = "Etc/GMT-8")) %>%
  mutate(Year = year(DateTime), Month = month(DateTime), Day = day(DateTime), Hour = hour(DateTime))

detection %<>% group_by(Year, Month, Day, Hour, Receiver, Transmitter) %>%
  summarise(Detections = sum(DetectCount)) %>% filter(Detections >= 3)

detection %<>% group_by(Year, Month, Day, Receiver, Transmitter) %>%
  summarise(Hours = n()) %>% verify(Hours %in% 1:24)

detection %<>% ungroup() %>% mutate(DateDetected = as.Date(paste(Year, Month, Day, sep = "-"))) %>%
  select(DateDetected, Receiver, Transmitter, Hours)

fish$Transmitter %<>% as.character()
detection$Transmitter %<>% as.character()

detection %<>% inner_join(fish, by = "Transmitter")
detection %<>% filter(DateDetected >= CaptureDate & DateDetected <= ExpirationDate) %>%
  verify(CaptureDate != ExpirationDate)

fish %<>% select(-Transmitter, -Acoustic)
stopifnot(year(fish$CaptureDate) %in% firstYear:lastYear)
stopifnot(year(fish$ExpirationDate) %in% firstYear:lastYear)

use_data(fish, overwrite = TRUE)

detection %<>% select(DateDetected, Fish, Receiver, Hours)

receiver$Receiver %<>% as.character()
detection$Receiver %<>% as.character()
receiver %<>% unique()
detection %<>% inner_join(receiver, by = "Receiver")

receiver %<>% select(-Receiver)
receiver %<>% dplyr::rename(DeploymentDate = DateIn, RetrievalDate = DateOut)
receiver %<>% unique()
deployment <- receiver
deployment %<>% dplyr::rename(Receiver = Location)

deployment %<>% plyr::ddply(.(Receiver, DeploymentDate), function(x) {
    data.frame(DeploymentDate = seq(from = x$DeploymentDate, to = x$RetrievalDate, by = "day"))
  })
deployment %<>% unique()
deployment %<>% dplyr::arrange(Receiver, DeploymentDate)

deployment %<>% filter(year(DeploymentDate) %in% firstYear:lastYear)
use_data(deployment, overwrite = TRUE)

detection %<>% filter(DateDetected >= DateIn & DateDetected <= DateOut)

detection %<>% group_by(DateDetected, Fish, Location) %>% summarise(Hours = max(Hours))

detection %<>% dplyr::rename(DetectionDate = DateDetected)
detection %<>% dplyr::rename(Receiver = Location)
detection %<>% filter(year(DetectionDate) %in% firstYear:lastYear)
use_data(detection, overwrite = TRUE)

