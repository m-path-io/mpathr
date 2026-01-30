# Extract App Usage from Paired Name/Value Columns

Parses app names and usage values into structured usage data, with start
and end timestamps and usage durations for both "Far" and "Near"
windows.

## Usage

``` r
extract_app_usage(app_names, app_values)
```

## Arguments

- app_names:

  Either a character vector (comma-separated strings) or a list of
  character vectors, one per row.

- app_values:

  Either a character vector (comma-separated strings) or a list of
  numeric vectors, one per row. Each block of 6 values corresponds to
  one app's usage record.

## Value

A list of tibbles (one per input row). Each tibble contains one or more
rows:

- `app`: App name

- `startTimeFar`, `endTimeFar`: POSIXct timestamps (UTC)

- `usageFar`: Integer usage during the far window

- `startTimeNear`, `endTimeNear`: POSIXct timestamps (UTC)

- `usageNear`: Integer usage during the near window

## Details

The input can be formatted in two ways:

- If the data is in its raw form (e.g. imported from CSV via
  [`read.csv()`](https://rdrr.io/r/utils/read.table.html)), both
  `app_names` and `app_values` should be character vectors where each
  element is a comma-separated string.

- If the data was imported via [`read_mpath()`](read_mpath.md), then
  `app_names` should be a list of character vectors, and `app_values`
  should be a list of integer vectors.

The function expects that each app is associated with exactly six
values: `startTimeFar`, `endTimeFar`, `usageFar`, `startTimeNear`,
`endTimeNear`, `usageNear`.

## Time windows

Each measurement of app usage includes two time windows: a "near: window
that captures recent app activity (typically ending around the time of
the ESM beep), and a "far" window that covers the 24 hours prior to the
near window. For both windows, Android automatically provides a start
time, an end time, and the total usage in seconds during that period.
These time ranges are determined by the operating system and may vary
across apps and across measurements. Because the start and end times of
these app usage windows rarely align exactly with the time between ESM
beeps, interpreting the values requires caution as the window may
include usage that occurred before the last beep To draw meaningful
conclusions about app use between two beeps, it is important to consider
which time windows and how much each window overlaps with that interval.
Differences in the length and timing of these windows can affect your
interpretation and should be accounted for in your analysis.

## Examples

``` r
# Using character input (e.g., raw from CSV)
app_names <- c("foo", "foo,bar")
app_values <- c(
  "1000,2000,1,3000,4000,2",
  "4000,5000,3,6000,7000,4,8000,9000,5,10000,11000,6"
)
extract_app_usage(app_names, app_values)
#> [[1]]
#> # A tibble: 1 × 7
#>   app   startTimeFar        endTimeFar          usageFar startTimeNear      
#>   <chr> <dttm>              <dttm>                 <int> <dttm>             
#> 1 foo   1970-01-01 00:00:01 1970-01-01 00:00:02        1 1970-01-01 00:00:03
#> # ℹ 2 more variables: endTimeNear <dttm>, usageNear <int>
#> 
#> [[2]]
#> # A tibble: 2 × 7
#>   app   startTimeFar        endTimeFar          usageFar startTimeNear      
#>   <chr> <dttm>              <dttm>                 <int> <dttm>             
#> 1 foo   1970-01-01 00:00:04 1970-01-01 00:00:05        3 1970-01-01 00:00:06
#> 2 bar   1970-01-01 00:00:08 1970-01-01 00:00:09        5 1970-01-01 00:00:10
#> # ℹ 2 more variables: endTimeNear <dttm>, usageNear <int>
#> 

# Using list-column input (e.g., from read_mpath())
app_names <- list("foo", c("foo", "bar"))
app_values <- list(
  c(1000,2000,1,3000,4000,2),
  c(4000,5000,3,6000,7000,4,8000,9000,5,10000,11000,6)
)
extract_app_usage(app_names, app_values)
#> [[1]]
#> # A tibble: 1 × 7
#>   app   startTimeFar        endTimeFar          usageFar startTimeNear      
#>   <chr> <dttm>              <dttm>                 <int> <dttm>             
#> 1 foo   1970-01-01 00:00:01 1970-01-01 00:00:02        1 1970-01-01 00:00:03
#> # ℹ 2 more variables: endTimeNear <dttm>, usageNear <int>
#> 
#> [[2]]
#> # A tibble: 2 × 7
#>   app   startTimeFar        endTimeFar          usageFar startTimeNear      
#>   <chr> <dttm>              <dttm>                 <int> <dttm>             
#> 1 foo   1970-01-01 00:00:04 1970-01-01 00:00:05        3 1970-01-01 00:00:06
#> 2 bar   1970-01-01 00:00:08 1970-01-01 00:00:09        5 1970-01-01 00:00:10
#> # ℹ 2 more variables: endTimeNear <dttm>, usageNear <int>
#> 

# You can also use this function within a tidyverse pipeline:
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
tibble(app_name = app_names, app_value = app_values) |>
  mutate(usage = extract_app_usage(app_name, app_value))
#> # A tibble: 2 × 3
#>   app_name  app_value  usage           
#>   <list>    <list>     <list>          
#> 1 <chr [1]> <dbl [6]>  <tibble [1 × 7]>
#> 2 <chr [2]> <dbl [12]> <tibble [2 × 7]>
```
