#' Kootenay Lake Exploitation Study Data
#'
#' For a description of the available data sets type \code{data(package = "klexdatr")}.
#'
#' @docType package
#' @name klexdatr
#' @examples
#' \dontrun{
#' library(dplyr) # so tbl data frames print nice
#' library(klexdatr) # data set for example
#' library(lexr)
#'
#' klex <- input_lex_data("klexdatr")
#' check_lex_data(klex)
#' print(klex)
#' plot(klex, all = TRUE)
#'
#' kdetect <- make_detect_data(klex)
#' check_detect_data(kdetect)
#' print(kdetect)
#' plot(kdetect)
#' }
NULL
