% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/timestamps_to_datetime.R
\name{timestamps_to_datetime}
\alias{timestamps_to_datetime}
\title{Convert m-Path timestamps to a date time format}
\usage{
timestamps_to_datetime(x, tz_offset = NULL, force_tz = NULL)
}
\arguments{
\item{x}{A vector of timestamps to be transformed to datetime.}

\item{tz_offset}{A numeric value to be added to the timestamps before transforming to datetime.
This is typically derived from the \code{timeZoneOffset} column from m-Path data. This is only
useful when you want to compare timestamps in an absolute manner or link it to external data
sources.}

\item{force_tz}{A string specifying the time zone to force the timestamps to. This is useful when
the data is to be compared to other data sources that are in a different time zone. Note that
this will not change the actual time of the timestamp, but only the time zone that is
displayed. A list of time zones can be used in \code{\link[=OlsonNames]{OlsonNames()}}.}
}
\value{
A vector of \code{POSIXct} objects representing the timestamps in the UTC time zone. The time
zone may differ if \code{force_tz} is specified.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

m-Path timestamps are based on the participant's local time zone, and when converted to R
datetime format, they are interpreted as being in Coordinated Universal Time (UTC),
previously known Greenwich Mean Time (GMT). This function allows for the conversion of m-Path
timestamps to datetime, and optionally allows for the specification of a UTC offset or a forced
time zone.
}
\details{
This function has three use cases:
\enumerate{
\item The most common use case: You have only ESM data and want to work in each participant's
local time zone. In this case, the \code{tz_offset} and \code{force_tz} should be left empty. This is
likely the right use case for you.
\item You have ESM data and external data (e.g. sensing data or data from a multi-lab study) that
you want to match based on their time stamp. The external data is likely in UTC while m-Path data
is in the participant's local time zone. In this case, you should specify the \code{tz_offset}
argument to convert the local time stamps to true UTC time. However, this will change the time
stamp to UTC so you will \strong{lose the ability to work in the local time zone}.
\item This is a more specialised version of use case 2, namely when you are certain that every
participant lives in the same time zone and there not been any changes in daylight savings time.
In this case, you can specify the \code{force_tz} argument to set the same time zone for all
participants. This will not change the displayed time (11AM will stay 11AM) but will change the
underlying time zone.
}
}
\section{Background}{


Timestamps in m-Path, like those in \code{timeStampScheduled} and \code{timeStampStart}, are a variation on
UNIX timestamps, defined as the number of seconds since January 1, 1970, at 00:00:00. However,
unlike standard UNIX timestamps (which use UTC), m-Path timestamps are based on the participant's
local time zone. This is because we are generally interested in time from the participant's
perspective and not in an absolute sense compared to other participants. Unfortunately, having
multiple time zones in a single column is a not possible in R, which is why all time zones are
(incorrectly) displayed as UTC.

When converted to \code{R} datetime format, they may display as UTC, which could lead
to confusion. This typically isn't an issue when analyzing ESM data within the participant's
local context, but it can affect comparisons with other data sources. For accurate
cross-referencing with other data, consider specifying the UTC offset to correctly adjust for the
participant’s local time. Alternatively, you can force the timestamps to display in a specific
time zone using the \code{force_tz} argument.
}

\examples{
data <- read_mpath(
  mpath_example("example_basic.csv"),
  mpath_example("example_meta.csv")
)[1:10,]

# The most common use case for this function: Convert
# `timeStampStart` to datetime. Remember that these are in the
# local time zone, but R displays them as being in UTC.
timestamps_to_datetime(data$timeStampStart)

# Convert `timeStampStop` to datetime, but as being the correct
# value in UTC.
timestamps_to_datetime(
  x = data$timeStampStop,
  tz_offset = data$timeZoneOffset
)

# Let's convert `timeStampSent` to datetime, but this time we want to
# force the time zone to be in "America/New_York" as we know all
# participants were in this time zone and so we can link with other
# data that is also in New York's time zone.
timestamps_to_datetime(
  x = data$timeStampSent,
  force_tz = "America/New_York"
)
}
