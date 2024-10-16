#' Convert m-Path timestamps to a date time format
#'
#' @description `r lifecycle::badge("stable")`
#'
#'   m-Path timestamps are based on the participant's local time zone, and when converted to R
#'   datetime format, they may display as UTC. This function allows for the conversion of m-Path
#'   timestamps to datetime, and optionally allows for the specification of a UTC offset or a forced
#'   time zone.
#'
#' @details
#'
#' Timestamps in m-Path, like those in `timeStampScheduled` and `timeStampStart`, are a variation on
#' UNIX timestamps, defined as the number of seconds since January 1, 1970, at 00:00:00. However,
#' unlike standard UNIX timestamps (which use UTC), m-Path timestamps are based on the participant's
#' local time zone. When converted to `R` datetime format, they may display as UTC, which could lead
#' to confusion. This typically isn't an issue when analyzing ESM data within the participant's
#' local context, but it can affect comparisons with other data sources. For accurate
#' cross-referencing with other data, consider specifying the UTC offset to correctly adjust for the
#' participant’s local time. Alternatively, you can force the timestamps to display in a specific
#' time zone using the `force_tz` argument.
#'
#'
#' @param x A vector of timestamps to be transformed to datetime.
#' @param tz_offset A numeric value to be added to the timestamps before transforming to datetime.
#'   This is typically derived from the `timeZoneOffset` column from m-Path data. This is only
#'   useful when you want to compare timestamps in an absolute manner or link it to external data
#'   sources.
#' @param force_tz A string specifying the time zone to force the timestamps to. This is useful when
#'   the data is to be compared to other data sources that are in a different time zone. Note that
#'   this will not change the actual time of the timestamp, but only the time zone that is
#'   displayed. The `lubridate` package is required to be installed for this argument to work.
#'
#' @return A vector of `POSIXct` objects representing the timestamps in the UTC time zone. The time
#'   zone may differ if `force_tz` is specified.
#' @export
#'
#' @examples
#' data <- read_mpath(
#'   mpath_example("example_basic.csv"),
#'   mpath_example("example_meta.csv")
#' )[1:10,]
#'
#' # The most common use case for this function: Convert
#' # `timeStampStart` to datetime. Remember that these are in the
#' # local time zone, but R displays them as being in UTC.
#' timestamps_to_datetime(data$timeStampStart)
#'
#' # Convert `timeStampStop` to datetime, but as being the correct
#' # value in UTC.
#' timestamps_to_datetime(
#'   x = data$timeStampStop,
#'   tz_offset = data$timeZoneOffset
#' )
#'
#' # Let's convert `timeStampSent` to datetime, but this time we want to
#' # force the time zone to be in "America/New_York" as we know all
#' # participants were in this time zone and so we can link with other
#' # data that is also in New York's time zone.
#' timestamps_to_datetime(
#'   x = data$timeStampSent,
#'   force_tz = "America/New_York"
#' )
timestamps_to_datetime <- function(x, tz_offset = NULL, force_tz = NULL) {
  if (inherits(x, "POSIXt")) {
    return(x)
  }

  if (!rlang::is_integerish(x)) {
    cli_abort(c(
      "`x` must be a numeric vector.",
      x = paste0("You provided a vector of ", class(x)[length(class(x))], "s.")
    ))
  }

  if (!is.null(tz_offset) && !is.null(force_tz)) {
    cli_abort("You cannot specify both `tz_offset` and `force_tz`.")
  }

  if (!is.null(tz_offset)) {
    x <- x + tz_offset
  }

  out <- as.POSIXct(x, origin = "1970-01-01", tz = "UTC")

  if (!is.null(force_tz)) {
    out <- lubridate::force_tz(out, tzone = force_tz)
  }
  out
}
