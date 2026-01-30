test_that(".unlist_col unpacks data correctly", {
  input <- c("1,2,3", "4,5", "6", "", NA)
  output <- .unlist_col(input)

  expect_equal(nrow(output), 8)
  expect_equal(output$vec, c("1", "2", "3", "4", "5", "6", NA, NA))
  expect_equal(output$.id, c(1, 1, 1, 2, 2, 3, 4, 5))
})

test_that(".relist_col repacks data correctly", {
  input <- tibble(.id = c(1, 1, 1, 2, 2, 3, 4), vec = c(as.character(1:6), NA))
  output <- .relist_col(input)

  expect_type(output, "list")
  expect_equal(length(output), 4)
  expect_equal(output[[1]], c("1", "2", "3"))
  expect_equal(output[[2]], c("4", "5"))
  expect_equal(output[[3]], "6")
  expect_equal(output[[4]], NA_character_)
})

test_that(".to_int_list works correctly", {
  input <- c("1,2,3", "4,5", "6", NA)
  output <- .to_int_list(input)

  # is everything an integer?
  expect_type(output, "list")
  expect_equal(length(output), 4)
  expect_identical(output[[1]], c(1L, 2L, 3L))
  expect_identical(output[[2]], c(4L, 5L))
  expect_identical(output[[3]], 6L)
  expect_identical(output[[4]], NA_integer_)
})

test_that(".to_int_list can handle vectors of NA", {
  input <- rep(NA, 5)
  output <- .to_int_list(input)

  expect_type(output, "list")
  expect_equal(length(output), 5)
  expect_identical(output, as.list(rep(NA_integer_, 5)))
})

test_that(".to_int_list handles integer overflow correctly", {
  input <- c("1,2,3", "4,5", "6", "2147483647,2147483648", NA)
  output <- .to_int_list(input)

  # Since there was an integer overflow, everything should now be a double
  expect_type(output, "list")
  expect_equal(length(output), 5)
  expect_identical(output[[1]], c(1, 2, 3))
  expect_identical(output[[2]], c(4, 5))
  expect_identical(output[[3]], 6)
  expect_identical(output[[4]], c(2147483647, 2147483648))
  expect_identical(output[[5]], NA_real_)
})

test_that(".to_double_list works correctly", {
  input <- c("1.1,2.2,3.3", "4.4,5.5", "6.6", NA)
  output <- .to_double_list(input)

  expect_equal(length(output), 4)
  expect_equal(output[[1]], as.double(c(1.1, 2.2, 3.3)))
  expect_equal(output[[2]], as.double(c(4.4, 5.5)))
  expect_equal(output[[3]], 6.6)
  expect_equal(output[[4]], NA_real_)
})

test_that(".to_double_list can handle vectors of NA", {
  input <- rep(NA, 5)
  output <- .to_double_list(input)

  expect_type(output, "list")
  expect_equal(length(output), 5)
  expect_identical(output, as.list(rep(NA_real_, 5)))
})

test_that(".to_string works correctly", {
  input <- c("\"neck\"", "\"right leg\"", NA)
  output <- .to_string(input)

  expect_type(output, "character")
  expect_equal(length(output), 3)
  expect_equal(output[1], "neck")
  expect_equal(output[2], "right leg")
  expect_equal(output[3], NA_character_)
})

test_that(".to_string can handle empty strings and quotes", {
  # An empty string, a single quote, a double quote, and a triple quote
  input <- c("", '"', '""', '"""', NA)
  output <- .to_string(input)

  expect_type(output, "character")
  expect_equal(length(output), length(input))
  expect_equal(output[1], "")
  expect_equal(output[2], '"')
  expect_equal(output[3], '""')
  expect_equal(output[4], '"""')
  expect_equal(output[5], NA_character_)
})

test_that(".to_string can handle a vector of only empty strings", {
  input <- rep("", 5)
  output <- .to_string(input)

  expect_type(output, "character")
  expect_equal(length(output), 5)
  expect_equal(output, rep("", 5))
})

test_that(".to_string can handle numbers that start with 0 without returning the input", {
  # If the test fails because the quotes "\"\"" were different, it means the JSON in .to_string
  # was invalid due to the other values, and the input was simply returned unparsed.
  input <- c(
    "\"0\"",
    "\"01\"",
    "\"012\"",
    "\"0123\"",
    "\"0123\\n\"",
    "\"0123 \"",
    "\"\"",
    NA
  )
  output <- .to_string(input)

  expect_type(output, "character")
  expect_equal(length(output), length(input))
  expect_equal(output[1], "0")
  expect_equal(output[2], "01")
  expect_equal(output[3], "012")
  expect_equal(output[4], "0123")
  expect_equal(output[5], "0123\n")
  expect_equal(output[6], "0123 ")
  expect_equal(output[7], "")
  expect_equal(output[8], NA_character_)
})

test_that(".to_string_list with JSON-like input works correctly", {
  input <- c("\"neck\"", "\"right leg\"", "\"left hand\", \"right hand\"", NA)
  output <- .to_string_list(input)

  expect_type(output, "list")
  expect_equal(length(output), 4)
  expect_equal(output[[1]], "neck")
  expect_equal(output[[2]], "right leg")
  expect_equal(output[[3]], c("left hand", "right hand"))
  expect_equal(output[[4]], NA_character_)
})

test_that(".to_string falls back to .to_string_list if it detects a list structure", {
  input <- c("\"neck\"", "\"right leg\"", "\"left hand\", \"right hand\"", NA)
  output <- .to_string(input)

  expect_type(output, "list")
  expect_equal(length(output), 4)
  expect_equal(output[[1]], "neck")
  expect_equal(output[[2]], "right leg")
  expect_equal(output[[3]], c("left hand", "right hand"))
  expect_equal(output[[4]], NA_character_)
})

test_that(".to_string_list can handle incorrect JSON", {
  # If the test fails because the quotes "\"\"" were different, it means the JSON in .to_string_list
  # was invalid due to the other values, and the input was simply returned unparsed.
  input <- c("\"neck\"", "\"right leg\"", "\"left hand\", \"right hand", NA)
  output <- .to_string_list(input)

  expect_type(output, "list")
  expect_equal(length(output), 4)
  expect_equal(output[[1]], "\"neck\"")
  expect_equal(output[[2]], "\"right leg\"")
  expect_equal(output[[3]], "\"left hand\", \"right hand")
  expect_equal(output[[4]], NA_character_)
})

test_that(".to_string_list can handle empty strings and quotes", {
  # An empty string, a single quote, a double quote, and a triple quote
  input <- c("", '"', '""', '"""', NA)
  output <- .to_string_list(input)

  expect_type(output, "list")
  expect_equal(length(output), length(input))
  expect_equal(output[[1]], "")
  expect_equal(output[[2]], '"')
  expect_equal(output[[3]], '""')
  expect_equal(output[[4]], '"""')
  expect_equal(output[[5]], NA_character_)
})

test_that(".to_string_list can handle a vector of only empty strings", {
  input <- rep("", 5)
  output <- .to_string_list(input)

  expect_type(output, "list")
  expect_equal(length(output), 5)
  expect_equal(output, as.list(rep("", 5)))
})

test_that(".to_string_list can handle numbers that start with 0 without returning the input", {
  # If the test fails because the quotes "\"\"" were different, it means the JSON in .to_string
  # was invalid due to the other values, and the input was simply returned unparsed.
  input <- c(
    "\"0\"",
    "\"01\"",
    "\"012\"",
    "\"0123\"",
    "\"0123\\n\"",
    "\"0123 \"",
    "\"\"",
    NA
  )
  output <- .to_string_list(input)

  expect_type(output, "list")
  expect_equal(length(output), length(input))
  expect_equal(output[[1]], "0")
  expect_equal(output[[2]], "01")
  expect_equal(output[[3]], "012")
  expect_equal(output[[4]], "0123")
  expect_equal(output[[5]], "0123\n")
  expect_equal(output[[6]], "0123 ")
  expect_equal(output[[7]], "")
  expect_equal(output[[8]], NA_character_)
})
