test_that(".unlist_col unpacks data correctly", {
  input <- c("1,2,3", "4,5", "6", "")
  output <- .unlist_col(input)

  expect_equal(nrow(output), 7)
  expect_equal(output$vec, c("1", "2", "3", "4", "5", "6", NA))
  expect_equal(output$.id, c(1, 1, 1, 2, 2, 3, 4))
})

test_that(".relist_col repacks data correctly", {
  input <- tibble(.id = c(1, 1, 1, 2, 2, 3), vec = as.character(1:6))
  output <- .relist_col(input)

  expect_type(output, "list")
  expect_equal(length(output), 3)
  expect_equal(output[[1]], c("1", "2", "3"))
  expect_equal(output[[2]], c("4", "5"))
  expect_equal(output[[3]], "6")
})

test_that(".to_int_list works correctly", {
  input <- c("1,2,3", "4,5", "6")
  output <- .to_int_list(input)

  # is everything an integer?
  expect_type(output, "list")
  expect_equal(length(output), 3)
  expect_identical(output[[1]], c(1L, 2L, 3L))
  expect_identical(output[[2]], c(4L, 5L))
  expect_identical(output[[3]], 6L)
})

test_that(".to_int_list handles integer overflow correctly", {
  input <- c("1,2,3", "4,5", "6", "2147483647,2147483648")
  output <- .to_int_list(input)

  # Since there was an integer overflow, everything should now be a double
  expect_type(output, "list")
  expect_equal(length(output), 4)
  expect_identical(output[[1]], c(1, 2, 3))
  expect_identical(output[[2]], c(4, 5))
  expect_identical(output[[3]], 6)
  expect_identical(output[[4]], c(2147483647, 2147483648))
})

test_that(".to_double_list works correctly", {
  input <- c("1.1,2.2,3.3", "4.4,5.5", "6.6")
  output <- .to_double_list(input)

  expect_equal(length(output), 3)
  expect_equal(output[[1]], as.double(c(1.1, 2.2, 3.3)))
  expect_equal(output[[2]], as.double(c(4.4, 5.5)))
  expect_equal(output[[3]], 6.6)
})

test_that(".to_string_list works correctly", {
  input <- c("a,b,c", "d,e", "f")
  output <- .to_string_list(input)

  expect_equal(length(output), 3)
  expect_equal(output[[1]], c("a", "b", "c"))
  expect_equal(output[[2]], c("d", "e"))
  expect_equal(output[[3]], "f")
})

test_that(".to_string works correctly", {
  input <- c("{\"key\": \"value\"}", "{\"key2\": \"value2\"}", NA)
  output <- .to_string(input)

  expect_equal(length(output), 3)
  expect_equal(output[1], "{\"key\": \"value\"}")
  expect_equal(output[2], "{\"key2\": \"value2\"}")
  expect_equal(output[3], NA_character_)
})

test_that(".to_string_list with JSON-like input works correctly", {
  input <- c("{\"key\": \"value\"}", "{\"key2\": \"value2\"}", NA)
  output <- .to_string_list(input)

  expect_equal(length(output), 3)
  expect_equal(output[[1]], "{\"key\": \"value\"}")
  expect_equal(output[[2]], "{\"key2\": \"value2\"}")
  expect_equal(output[[3]], NA_character_)
})
