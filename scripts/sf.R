library(tidyverse)
library(magrittr)
library(klexdatr)

rm(list = ls())

section %<>% sf::st_as_sf()
section %<>% select(Section, Habitat, Bounded)

station %<>% poisspatial::ps_coords_to_sfc(coords = c("EastingStation", "NorthingStation"),
                                           crs = 26911)

section %<>% tibble::as_tibble()
station %<>% tibble::as_tibble()
detection %<>% tibble::as_tibble()
deployment %<>% tibble::as_tibble()
capture %<>% tibble::as_tibble()
recapture %<>% tibble::as_tibble()

if(FALSE) {
use_data(deployment, overwrite = TRUE)
use_data(detection, overwrite = TRUE)
use_data(station, overwrite = TRUE)
use_data(section, overwrite = TRUE)
use_data(capture, overwrite = TRUE)
use_data(recapture, overwrite = TRUE)
}

