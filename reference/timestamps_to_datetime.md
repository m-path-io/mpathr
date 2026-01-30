# Convert m-Path timestamps to a date time format

**\[stable\]**

m-Path timestamps are based on the participant's local time zone, and
when converted to R datetime format, they are interpreted as being in
Coordinated Universal Time (UTC), previously known Greenwich Mean Time
(GMT). This function allows for the conversion of m-Path timestamps to
datetime, and optionally allows for the specification of a UTC offset or
a forced time zone.

## Usage

``` r
timestamps_to_datetime(x, tz_offset = NULL, force_tz = NULL)
```

## Arguments

- x:

  A vector of timestamps to be transformed to datetime.

- tz_offset:

  A numeric value to be added to the timestamps before transforming to
  datetime. This is typically derived from the `timeZoneOffset` column
  from m-Path data. This is only useful when you want to compare
  timestamps in an absolute manner or link it to external data sources.

- force_tz:

  A string specifying the time zone to force the timestamps to. This is
  useful when the data is to be compared to other data sources that are
  in a different time zone. Note that this will not change the actual
  time of the timestamp, but only the time zone that is displayed. A
  list of time zones can be used in
  [`OlsonNames()`](https://rdrr.io/r/base/timezones.html).

## Value

A vector of `POSIXct` objects representing the timestamps in the UTC
time zone. The time zone may differ if `force_tz` is specified.

## Details

This function has three use cases:

1.  The most common use case: You have only ESM data and want to work in
    each participant's local time zone. In this case, the `tz_offset`
    and `force_tz` should be left empty. This is likely the right use
    case for you.

2.  You have ESM data and external data (e.g. sensing data or data from
    a multi-lab study) that you want to match based on their time stamp.
    The external data is likely in UTC while m-Path data is in the
    participant's local time zone. In this case, you should specify the
    `tz_offset` argument to convert the local time stamps to true UTC
    time. However, this will change the time stamp to UTC so you will
    **lose the ability to work in the local time zone**.

3.  This is a more specialised version of use case 2, namely when you
    are certain that every participant lives in the same time zone and
    there not been any changes in daylight savings time. In this case,
    you can specify the `force_tz` argument to set the same time zone
    for all participants. This will not change the displayed time (11AM
    will stay 11AM) but will change the underlying time zone.

## Background

Timestamps in m-Path, like those in `timeStampScheduled` and
`timeStampStart`, are a variation on UNIX timestamps, defined as the
number of seconds since January 1, 1970, at 00:00:00. However, unlike
standard UNIX timestamps (which use UTC), m-Path timestamps are based on
the participant's local time zone. This is because we are generally
interested in time from the participant's perspective and not in an
absolute sense compared to other participants. Unfortunately, having
multiple time zones in a single column is a not possible in R, which is
why all time zones are (incorrectly) displayed as UTC.

When converted to `R` datetime format, they may display as UTC, which
could lead to confusion. This typically isn't an issue when analyzing
ESM data within the participant's local context, but it can affect
comparisons with other data sources. For accurate cross-referencing with
other data, consider specifying the UTC offset to correctly adjust for
the participant’s local time. Alternatively, you can force the
timestamps to display in a specific time zone using the `force_tz`
argument.

## Examples

``` r
data <- read_mpath(
  mpath_example("example_basic.csv"),
  mpath_example("example_meta.csv")
)[1:10,]

# The most common use case for this function: Convert
# `timeStampStart` to datetime. Remember that these are in the
# local time zone, but R displays them as being in UTC.
timestamps_to_datetime(data$timeStampStart)
#>  [1] "2024-04-18 09:55:42 UTC" "2024-04-19 08:16:42 UTC"
#>  [3] "2024-04-19 09:00:31 UTC" "2024-04-19 15:24:27 UTC"
#>  [5] "2024-04-19 17:20:04 UTC" "2024-04-19 20:08:40 UTC"
#>  [7] "2024-04-19 21:48:08 UTC" "2024-04-19 22:15:22 UTC"
#>  [9] "2024-04-20 09:32:02 UTC" "2024-04-20 11:26:45 UTC"

# Convert `timeStampStop` to datetime, but as being the correct
# value in UTC.
timestamps_to_datetime(
  x = data$timeStampStop,
  tz_offset = data$timeZoneOffset
)
#>  [1] "2024-04-18 07:57:30 UTC" "2024-04-19 06:17:54 UTC"
#>  [3] "2024-04-19 07:01:08 UTC" "2024-04-19 13:25:11 UTC"
#>  [5] "2024-04-19 15:20:50 UTC" "2024-04-19 18:09:27 UTC"
#>  [7] "2024-04-19 19:48:31 UTC" "2024-04-19 20:16:08 UTC"
#>  [9] "2024-04-20 07:32:35 UTC" "2024-04-20 09:27:11 UTC"

# Let's convert `timeStampSent` to datetime, but this time we want to
# force the time zone to be in "America/New_York" as we know all
# participants were in this time zone and so we can link with other
# data that is also in New York's time zone.
timestamps_to_datetime(
  x = data$timeStampSent,
  force_tz = "America/New_York"
)
#>  [1] "2024-04-18 09:55:41 EDT" "2024-04-19 08:16:36 EDT"
#>  [3] "2024-04-19 09:00:28 EDT" "2024-04-19 15:02:56 EDT"
#>  [5] "2024-04-19 17:17:57 EDT" "2024-04-19 19:44:27 EDT"
#>  [7] "2024-04-19 21:23:23 EDT" "2024-04-19 22:10:01 EDT"
#>  [9] "2024-04-20 09:03:24 EDT" "2024-04-20 11:26:28 EDT"
```
