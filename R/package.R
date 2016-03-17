#' Kootenay Lake Exploitation Study Data
#'
#' Data from the Kootenay Lake Large Trout Exploitation Study.
#'
#' For a list of the available data sets type \code{data(package = "klexdatr")}.
#'
#' For information on a particular dataset type \code{?dataset}.
#'
#' All spatial coordinates are for UTM Zone 11U, i.e., EPSG: 26911, and all times are
#' in Pacific Standard, i.e. Etc/GMT+8.
#'
#' @docType package
#' @name klexdatr
#' @examples
#' library(dplyr) # so tbl data frames print nice
#'
#' data(list = c("section", "station", "deployment", "capture",
#'   "recapture", "detection"))
#'
#' print(section)
#' print(station)
#' print(deployment)
#' print(capture)
#' print(recapture)
#' print(detection)
NULL
