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
#' print(klex)
#' check_lex_data(klex, all = TRUE)
#'
#' x <- lexr:::check_lex_deployment_detection(klex$deployment, klex$detection)
#' plot(klex, all = TRUE)
#'
#' kdetect <- make_detect_data(klex)
#' print(kdetect)
#' check_detect_data(kdetect)
#' plot(kdetect)
#'
#' }
NULL
