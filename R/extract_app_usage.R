#' Extract App Usage from Paired Name/Value Columns
#'
#' @description `r lifecycle::badge("experimental")`
#'
#' Parses app names and usage values into structured usage data, with
#' start and end timestamps and usage durations for both "Far" and "Near" windows.
#'
#' The input can be formatted in two ways:
#' \itemize{
#'   \item If the data is in its raw form (e.g. imported from CSV via [read.csv()]), both
#'         `app_names` and `app_values` should be character vectors where
#'         each element is a comma-separated string.
#'   \item If the data was imported via [read_mpath()], then `app_names` should
#'         be a list of character vectors, and `app_values` should be a list of
#'         integer vectors.
#' }
#'
#' The function expects that each app is associated with exactly six values:
#' `startTimeFar`, `endTimeFar`, `usageFar`,
#' `startTimeNear`, `endTimeNear`, `usageNear`.
#'
#' @param app_names Either a character vector (comma-separated strings) or
#'   a list of character vectors, one per row.
#' @param app_values Either a character vector (comma-separated strings) or
#'   a list of numeric vectors, one per row. Each block of 6 values corresponds
#'   to one app's usage record.
#'
#' @section Time windows:
#' Each measurement of app usage includes two time windows: a "near: window that captures recent app
#' activity (typically ending around the time of the ESM beep), and a "far" window that covers the
#' 24 hours prior to the near window. For both windows, Android automatically provides a start time,
#' an end time, and the total usage in seconds during that period. These time ranges are determined
#' by the operating system and may vary across apps and across measurements. Because the start and
#' end times of these app usage windows rarely align exactly with the time between ESM beeps,
#' interpreting the values requires caution as the window may include usage that occurred before the
#' last beep To draw meaningful conclusions about app use between two beeps, it is important to
#' consider which time windows and how much each window overlaps with that interval. Differences in
#' the length and timing of these windows can affect your interpretation and should be accounted for
#' in your analysis.
#'
#' @return A list of tibbles (one per input row). Each tibble contains one or more rows:
#' \itemize{
#'   \item `app`: App name
#'   \item `startTimeFar`, `endTimeFar`: POSIXct timestamps (UTC)
#'   \item `usageFar`: Integer usage during the far window
#'   \item `startTimeNear`, `endTimeNear`: POSIXct timestamps (UTC)
#'   \item `usageNear`: Integer usage during the near window
#' }
#'
#' @examples
#' # Using character input (e.g., raw from CSV)
#' app_names <- c("foo", "foo,bar")
#' app_values <- c(
#'   "1000,2000,1,3000,4000,2",
#'   "4000,5000,3,6000,7000,4,8000,9000,5,10000,11000,6"
#' )
#' extract_app_usage(app_names, app_values)
#'
#' # Using list-column input (e.g., from read_mpath())
#' app_names <- list("foo", c("foo", "bar"))
#' app_values <- list(
#'   c(1000,2000,1,3000,4000,2),
#'   c(4000,5000,3,6000,7000,4,8000,9000,5,10000,11000,6)
#' )
#' extract_app_usage(app_names, app_values)
#'
#' # You can also use this function within a tidyverse pipeline:
#' library(dplyr)
#' tibble(app_name = app_names, app_value = app_values) |>
#'   mutate(usage = extract_app_usage(app_name, app_value))
#'
#' @export
extract_app_usage <- function(app_names, app_values) {
  # Get the unique app names
  if (all(lengths(app_names) == 1)) {
    app_names <- strsplit(app_names, ",")
  }
  app_names <- lapply(app_names, unique)

  # Split the values into 6 lists
  if (all(lengths(app_values) == 1)) {
    app_values <- strsplit(app_values, ",")
  }
  app_values <- lapply(app_values, \(x) {
    split(x, (seq_along(x) - 1) %% 6 + 1)
  })

  # Pluck the values into a list of lists
  .data <- tibble(
    .id = seq_along(app_names),
    app = app_names,
    startTimeFar = lapply(app_values, \(x) x[[1]]),
    endTimeFar = lapply(app_values, \(x) x[[2]]),
    usageFar = lapply(app_values, \(x) x[[3]]),
    startTimeNear = lapply(app_values, \(x) x[[4]]),
    endTimeNear = lapply(app_values, \(x) x[[5]]),
    usageNear = lapply(app_values, \(x) x[[6]])
  )

  .data <- tidyr::unnest(.data, -".id", keep_empty = TRUE)

  # Clean up columns
  .data <- .data |>
    mutate(across(
      .cols = c("startTimeFar", "endTimeFar", "startTimeNear", "endTimeNear"),
      .fns = \(x) as.double(x) / 1000
    )) |>
    mutate(across(
      .cols = c("startTimeFar", "endTimeFar", "startTimeNear", "endTimeNear"),
      .fns = \(x) {
        as.POSIXct(x, tz = "UTC", origin = "1970-01-01")
      }
    )) |>
    mutate(across(
      .cols = c("usageFar", "usageNear"),
      .fns = as.integer
    ))

  # Renest data
  .data <- tidyr::nest(.data, data = -".id")

  .data$data
}
