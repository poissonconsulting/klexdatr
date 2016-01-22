context("data")

test_that("data", {

  expect_df <- function(x) expect_is(x, "data.frame")

  expect_df(datacheckr::check_data3(
    section@data,
    list(Section = factor(1),
         Habitat = factor(1),
         Bounded = TRUE,
         EastingSection = 1,
         NorthingSection = 1),
    key = "Section"))

  expect_df(datacheckr::check_data3(
    station,
    list(Station = factor(1),
         Section = factor(1),
         EastingStation = 1,
         NorthingStation = 1),
    key = "Station"))

  expect_df(datacheckr::check_join(station, section@data, "Section"))

  expect_df(datacheckr::check_data3(
    deployment,
    list(Station = factor(1),
         Receiver = factor(1),
         DateTimeReceiverIn = Sys.time(),
         DateTimeReceiverOut = Sys.time()),
    key = c("Station", "Receiver", "DateTimeReceiverIn")))

  expect_df(datacheckr::check_join(deployment, station, "Station"))

  expect_df(datacheckr::check_data3(
    capture,
    list(Capture = factor(1),
         DateTimeCapture = Sys.time(),
         SectionCapture = factor(1),
         Species = factor(""),
         Length = c(200L, 1000L),
         Weight = c(0.5, 10, NA),
         Reward1 = c(0L, 10L, 100L),
         Reward2 = c(0L, 10L, 100L, NA),
         DateTimeTagExpire = Sys.time(),
         DepthRangeTag = c(1L, NA)),
    key = c("Capture")))

  expect_df(datacheckr::check_join(capture, section@data, c("SectionCapture" = "Section")))

  expect_df(datacheckr::check_data3(
    recapture,
    list(DateTimeRecapture = Sys.time(),
         Capture = factor(1),
         SectionRecapture = factor(c(1, NA)),
         TBarTag1 = TRUE,
         TBarTag2 = TRUE,
         TagsRemoved = c(TRUE, NA),
         Released = c(TRUE, NA),
         Public = TRUE),
    key = c("DateTimeRecapture", "Capture")))

  expect_df(datacheckr::check_join(recapture, capture, "Capture"))
  expect_df(datacheckr::check_join(recapture, section@data,
                                   c("SectionRecapture" = "Section"),
                                   ignore_nas = TRUE))

  expect_df(datacheckr::check_data3(
    detection,
    list(DateTimeDetection = Sys.time(),
         Capture = factor(1),
         Receiver = factor(1),
         Detections = c(1L, datacheckr::max_integer()))))

  warning("duplicate detections!!")
  #,
  #  key = c("DateTimeDetection", "Capture", "Receiver")))

  expect_df(datacheckr::check_join(detection, capture, "Capture"))

  expect_df(datacheckr::check_data3(
    depth,
    list(DateTimeDepth = Sys.time(),
         Capture = factor(1),
         Receiver = factor(1),
         Depth = c(0L, 255L)),
    key = c("DateTimeDepth", "Capture", "Receiver")))

  expect_df(datacheckr::check_join(depth, capture, "Capture"))
})
