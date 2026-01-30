n_participants <- 8
n_rows_per_participant <- 10

data <- data.frame(
  participant = rep(1:n_participants, each = n_rows_per_participant),
  valid = rep(c(TRUE, FALSE), (n_participants * n_rows_per_participant) / 2),
  dates = rep(
    seq(as.Date("2023-01-01"), as.Date("2023-01-10"), by = "day"),
    n_participants
  )
)

test_that('no period end or start', {
  expect_message(
    result <- response_rate(
      data = data,
      valid_col = valid,
      participant_col = participant,
      time_col = dates
    ),
    "Calculating response rates for the entire duration of the study."
  )

  # is it a df?
  expect_true(is.data.frame(result))

  # not necessarily always like this but should be in this case
  expect_true(nrow(result) == n_participants)

  expect_true(all(result$response_rate == rep(0.5, n_participants)))
})

test_that('period_end and start but no time variable', {
  # we just expect an error
  expect_error(
    response_rate(
      data = data,
      valid_col = valid,
      participant_col = participant,
      period_start = '2023-01-01',
      period_end = '2023-01-05'
    )
  )
})

test_that('only period_end given', {
  expect_message(
    result <- response_rate(
      data = data,
      valid_col = valid,
      participant_col = participant,
      time_col = dates,
      period_end = '2023-01-06'
    ),
    "Calculating response rates up to date: 2023-01-06"
  )

  # is it a df?
  expect_true(is.data.frame(result))

  # 1 row per participant
  expect_true(nrow(result) == n_participants)

  expect_true(all(result$response_rate == rep(0.5, n_participants)))
})

test_that('only period_start given', {
  expect_message(
    result <- response_rate(
      data = data,
      valid_col = valid,
      participant_col = participant,
      time_col = dates,
      period_start = '2023-01-05'
    ),
    "Calculating response rates starting from date: 2023-01-05"
  )

  # is it a df?
  expect_true(is.data.frame(result))

  # 1 row per participant
  expect_true(nrow(result) == n_participants)

  expect_true(all(result$response_rate == rep(0.5, n_participants)))
})

test_that('period_start and end given', {
  expect_message(
    result <- response_rate(
      data = data,
      valid_col = valid,
      participant_col = participant,
      time_col = dates,
      period_start = '2023-01-02',
      period_end = '2023-01-07'
    ),
    "Calculating response rates between date: 2023-01-02 and 2023-01-07"
  )

  # is it a df?
  expect_true(is.data.frame(result))

  # 1 row per participant
  expect_true(nrow(result) == n_participants)

  expect_true(all(result$response_rate == rep(0.5, n_participants)))
})
