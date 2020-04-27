library(tidyverse)
library(dm)

pkgload::load_all()

dm <-
  dm(
    station,
    section =
      section %>%
      sf::st_as_sf() %>%
      as_tibble(),
    capture,
    deployment,
    detection,
    recapture
  )

dm %>%
  dm_add_pk(capture, Capture) %>%
  dm_add_pk(deployment, c(Station, Receiver, DateTimeReceiverIn)) %>%
  dm_add_pk(detection, c(DateTimeDetection, Capture, Receiver)) %>%
  dm_add_pk(recapture, c(DateTimeRecapture, Capture)) %>%
  dm_add_pk(section, Section) %>%
  dm_add_pk(station, Station) %>%
  dm_draw(rankdir = "TB", view_type = "all")


dm_keyed <-
  dm %>%
  dm_add_pk(capture, Capture) %>%
  dm_add_pk(deployment, c(Station, Receiver, DateTimeReceiverIn)) %>%
  dm_add_pk(detection, c(DateTimeDetection, Capture, Receiver)) %>%
  dm_add_pk(recapture, c(DateTimeRecapture, Capture)) %>%
  dm_add_pk(section, Section) %>%
  dm_add_pk(station, Station) %>%
  dm_add_fk(detection, Capture, capture) %>%
  dm_add_fk(recapture, Capture, capture) %>%
  dm_add_fk(recapture, SectionRecapture, section) %>%
  dm_add_fk(capture, SectionCapture, section) %>%
  dm_add_fk(deployment, Station, station) %>%
  dm_add_fk(station, Section, section)

dm_keyed %>%
  dm_draw()

dm_keyed %>%
  dm_flatten_to_tbl(deployment)
