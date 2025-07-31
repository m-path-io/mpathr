test_that("extract_app_usage works with character vectors", {
  names <- c("foo", "foo,bar", "foo,bar,baz")
  values <- c(
    "1000,2000,1,3000,4000,2", # one app
    "5000,6000,3,7000,8000,4,9000,10000,5,11000,12000,6", # two apps
    paste(1:18 * 1000, collapse = ",") # three apps
  )

  out <- extract_app_usage(names, values)

  expect_length(out, 3)
  expect_true(all(vapply(out, \(x) inherits(x, "tbl_df"), logical(1))))
  expect_equal(nrow(out[[1]]), 1)
  expect_equal(nrow(out[[2]]), 2)
  expect_equal(nrow(out[[3]]), 3)
  expect_named(
    out[[1]],
    c(
      "app",
      "startTimeFar",
      "endTimeFar",
      "usageFar",
      "startTimeNear",
      "endTimeNear",
      "usageNear"
    )
  )
})

test_that("extract_app_usage works with list-columns", {
  names <- list("foo", c("foo", "bar"), c("foo", "bar", "baz"))
  values <- list(
    c(1000, 2000, 1, 3000, 4000, 2),
    c(5000, 6000, 3, 7000, 8000, 4, 9000, 10000, 5, 11000, 12000, 6),
    1000 * (1:18)
  )

  out <- extract_app_usage(names, values)

  expect_length(out, 3)
  expect_equal(nrow(out[[1]]), 1)
  expect_equal(nrow(out[[2]]), 2)
  expect_equal(nrow(out[[3]]), 3)
})

test_that("extract_app_usage returns correct types", {
  names <- c("foo", "foo,bar")
  values <- c(
    "1000,2000,1,3000,4000,2",
    "5000,6000,3,7000,8000,4,9000,10000,5,11000,12000,6"
  )

  out <- extract_app_usage(names, values)

  expect_s3_class(out[[1]]$startTimeFar, "POSIXct")
  expect_type(out[[1]]$usageNear, "integer")
})

test_that("extract_app_usage returns list of tibbles", {
  names <- c("foo", "foo,bar")
  values <- c(
    "1000,2000,1,3000,4000,2",
    "4000,5000,3,6000,7000,4,8000,9000,5,10000,11000,6"
  )
  out <- extract_app_usage(names, values)

  expect_type(out, "list")
  expect_true(all(vapply(out, \(x) inherits(x, "tbl_df"), logical(1))))
})

test_that("each element of output corresponds to input row", {
  names <- c("a", "b", "c")
  values <- rep("1,2,3,4,5,6", 3)
  out <- extract_app_usage(names, values)

  expect_length(out, 3)
})

test_that("single input row returns tibble with one row", {
  names <- "foo"
  values <- "1000,2000,1,3000,4000,2"
  out <- extract_app_usage(names, values)

  expect_equal(nrow(out[[1]]), 1)
})

test_that("multiple app names expands rows", {
  names <- "foo,bar"
  values <- "1000,2000,1,3000,4000,2,4000,5000,3,6000,7000,4"
  out <- extract_app_usage(names, values)

  expect_equal(nrow(out[[1]]), 2)
})

test_that("output has expected column names", {
  names <- "foo"
  values <- "1000,2000,1,3000,4000,2"
  out <- extract_app_usage(names, values)

  expect_named(
    out[[1]],
    c(
      "app",
      "startTimeFar",
      "endTimeFar",
      "usageFar",
      "startTimeNear",
      "endTimeNear",
      "usageNear"
    )
  )
})
