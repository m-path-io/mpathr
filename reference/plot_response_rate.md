# Plots response rate per day (and per participant)

This function returns a ggplot object with the response rate per day (x
axis) and participant (color). Note that instead of using calendar
dates, the function returns a plot grouped by the day inside the study
for the participant.

## Usage

``` r
plot_response_rate(data, valid_col, participant_col, time_col)
```

## Arguments

- data:

  data frame with data

- valid_col:

  name of the column that stores whether the beep was answered or not

- participant_col:

  name of the column that stores the participant id (or equivalent)

- time_col:

  name of the column that stores the time of the beep

## Value

a ggplot object with the response rate per day (x axis) and participant
(color)

## Examples

``` r
# load data
data(example_data)

# make plot with plot_response_rate
plot_response_rate(data = example_data,
time_col = sent,
participant_col = participant,
valid_col = answered)

# The resulting ggplot object can be formatted using ggplot2 functions (see ggplot2
# documentation).
```
