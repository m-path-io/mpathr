test_that("timestamps_to_datetime correctly converts UNIX timestamp to datetime", {
  # Simple conversion without offset or force_tz
  result <- timestamps_to_datetime(0)
  expect_equal(result, as.POSIXct("1970-01-01 00:00:00", tz = "UTC"))

  result <- timestamps_to_datetime(86400) # One day after the epoch
  expect_equal(result, as.POSIXct("1970-01-02 00:00:00", tz = "UTC"))
})

test_that("timestamps_to_datetime applies tz_offset correctly", {
  # Convert timestamp with tz_offset (1 hour offset)
  result <- timestamps_to_datetime(0, tz_offset = 3600)
  expect_equal(result, as.POSIXct("1970-01-01 01:00:00", tz = "UTC"))

  # Convert timestamp with tz_offset (-5 hours offset)
  result <- timestamps_to_datetime(0, tz_offset = -18000)
  expect_equal(result, as.POSIXct("1969-12-31 19:00:00", tz = "UTC"))
})

test_that("timestamps_to_datetime applies force_tz correctly", {
  # Convert timestamp and force time zone to "America/New_York"
  result <- timestamps_to_datetime(0, force_tz = "America/New_York")
  expect_equal(
    result,
    as.POSIXct("1970-01-01 00:00:00", tz = "America/New_York")
  )
  expect_equal(attr(result, "tzone"), "America/New_York")
})

test_that("timestamps_to_datetime errors on invalid input types", {
  # Input is not numeric
  expect_error(
    timestamps_to_datetime("string"),
    regexp = "`x` must be a numeric vector."
  )

  # Specifying both tz_offset and force_tz should raise an error
  expect_error(
    timestamps_to_datetime(0, tz_offset = 3600, force_tz = "UTC"),
    regexp = "You cannot specify both `tz_offset` and `force_tz`."
  )
})

test_that("timestamps_to_datetime handles POSIXct input correctly", {
  # Input is already POSIXct
  posix_input <- as.POSIXct("2020-01-01 00:00:00", tz = "UTC")
  result <- timestamps_to_datetime(posix_input)
  expect_equal(result, posix_input)
})
