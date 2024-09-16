library(testthat)

n_participants <- 8
beeps_per_day <- 4
n_days <- 10

# very similar df as in test-response_rate.R but now with multiple beeps per day.
data <- data.frame(
  participant = rep(1:n_participants, each = n_days * beeps_per_day),
  valid = rep(c(TRUE, FALSE), (n_participants * n_days * beeps_per_day)/2),
  dates = rep(seq(as.Date("2023-01-01"), as.Date("2023-01-10"), by = "day"), each = beeps_per_day, n_participants)
)

test_that('plot_response_rates returns a ggplot', {

  # we just expect an error
  result <- plot_response_rates(data = data,
                                valid_col = valid,
                                participant_col = participant,
                                time_col = dates)

  expect_true(ggplot2::is.ggplot(result))
})
