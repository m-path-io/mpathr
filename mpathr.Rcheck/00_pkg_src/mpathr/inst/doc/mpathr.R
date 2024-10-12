## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(mpathr)

## ----show m-Path example data-------------------------------------------------
mpath_example()

## ----use read_mpath-----------------------------------------------------------
# find paths to example basic and meta data:
basic_path <- mpath_example(file = "example_basic.csv")
meta_path <- mpath_example("example_meta.csv")

# read the data
data <- read_mpath(
  file = basic_path,
  meta_data = meta_path
)

## ----write data as csv, eval = FALSE------------------------------------------
#  write_mpath(
#    x = data,
#    file = "data.csv"
#  )

## ----write data as an R object, eval = FALSE----------------------------------
#  save(
#    data,
#    file = 'data.RData'
#  )

## ----calculate response rate--------------------------------------------------
example_data

response_rates <- response_rate(
  data = example_data,
  valid_col = answered,
  participant_col = participant
)

## ----show low response rates--------------------------------------------------
response_rates[response_rates$response_rate < 0.5,]

## ----calculate response rate after 15th of May 2024---------------------------
response_rates_after_15 <- response_rate(
  data = example_data,
  valid_col = answered,
  participant_col = participant,
  time_col = sent,
  period_start = '2024-05-15'
)

## ----show low response rates after 15th of May 2024---------------------------
response_rates_after_15

## ----plot response rate, fig.width=7, fig.height=5----------------------------
plot_response_rate(
  data = example_data,
  time_col = sent,
  participant_col = participant,
  valid_col = answered
)

## ----customize plot response rate plot, fig.width=7, fig.height=5-------------
library(ggplot2)

plot_response_rate(
  data = example_data,
  time_col = sent,
  participant_col = participant,
  valid_col = answered
) +
  theme_minimal() +
  ggtitle('Response rate over time') +
  xlab('Day in study')

