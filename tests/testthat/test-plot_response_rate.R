# n_participants <- 5
# beeps_per_day <- 10
# n_days <- 5

n_participants <- 10
beeps_per_day <- 10
n_days <- 4

valid <- unlist(lapply(1:n_participants, function(participant) {
       rep(c(rep(TRUE, participant),
             rep(FALSE, beeps_per_day - participant)),
            n_days)
   }))
# building the valid col so that each participant has a different response rate,
# participant 1 should have response rate 0.1, participant 2 = 0.2, etc.

# similar df as in test-response_rate.R but now with multiple beeps per day.
data <- data.frame(
  participant = rep(1:n_participants, each = n_days * beeps_per_day),
  valid = valid,
  dates = rep(seq(as.Date("2023-01-01"),
                  as.Date("2023-01-01") + (n_days-1),
                  by = "day"),
              each = beeps_per_day, n_participants)
)

# plot_response_rate depends on this function returning the correct df
test_that('response_rate_per_day works correctly', {
  data_plot <- response_rate_per_day(
    data = data,
    valid_col = valid,
    participant_col = participant,
    time_col = dates
  )

  for(participant in 1:n_participants){
    expected_rate <- participant * 0.1

    expect_equal(unique(data_plot
                        [data_plot$participant == participant, ]$response_rate),
                 expected_rate)
  }
})

test_that('plot_response_rate returns a ggplot', {

  # we just expect an error
  result <- plot_response_rate(data = data,
                                valid_col = valid,
                                participant_col = participant,
                                time_col = dates)

  expect_true(ggplot2::is_ggplot(result))
})
