# Calculate response rate

Calculate response rate

## Usage

``` r
response_rate(
  data,
  valid_col,
  participant_col,
  time_col = NULL,
  period_start = NULL,
  period_end = NULL
)
```

## Arguments

- data:

  data frame with data

- valid_col:

  name of the column that stores whether the beep was answered or not

- participant_col:

  name of the column that stores the participant id (or equivalent)

- time_col:

  optional: name of the column that stores the time of the beep, as a
  'POSIXct' object.

- period_start:

  string representing the starting date to calculate response rates
  (optional). Accepts dates in the following formats: `yyyy-mm-dd`
  or`yyyy/mm/dd`.

- period_end:

  period end to calculate response rates (optional).

## Value

a data frame with the response rate for each participant, and the number
of beeps used to calculate the response rate

## Examples

``` r
# Example 1: calculate response rates for the whole study
# Get example data
data(example_data)

# Calculate response rate for each participant

# We don't specify time_col, period_start or period_end.
# Response rates will be based on all the participant's data
response_rate <- response_rate(data = example_data,
                               valid_col = answered,
                               participant_col = participant)
#> Calculating response rates for the entire duration of the study.

# Example 2: calculate response rates for a specific time period
data(example_data)

# Calculate response rate for each participant between dates
response_rate <- response_rate(data = example_data,
                               valid_col = answered,
                               participant_col = participant,
                               time_col = sent,
                               period_start = '2024-05-15',
                               period_end = '2024-05-31')
#> Calculating response rates between date: 2024-05-15 and 2024-05-31

# Get participants with a response rate below 0.5
response_rate[response_rate$response_rate < 0.5,]
#> # A tibble: 2 × 3
#>   participant number_of_beeps response_rate
#>         <int>           <int>         <dbl>
#> 1          16              55        0.0364
#> 2          20              77        0.494 
```
