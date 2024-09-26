
library(testthat)

basic_path <- "../testdata/test_basic.csv"
meta_path <- "../testdata/test_meta.csv"

data <- read_mpath(file = basic_path,
                   meta_data = meta_path)

# Data is read without warnings or errors:

test_that("Data is exported with no warnings", {

  expect_no_warning(read_mpath(file = basic_path,
                     meta_data = meta_path))
})

# Check that the data is being read as a dataframe
test_that("Data is a dataframe", {

  expect_true(is.data.frame(data))

})

# Check that the correct number of rows and columns are read

test_that("Data has correct dimensions", {

  col_names <- readr::read_lines(basic_path, n_max = 1, skip_empty_rows = TRUE)

  # The number of columns should be the number of ; in the header + 1
  n_cols <- 1 + lengths(regmatches(col_names, gregexpr(';', col_names)))

  n_rows <- length(count.fields(basic_path, sep = ";")) - 1

  expect_equal(dim(data), c(n_rows, n_cols))

})

# Data types are correct

# Check data types of first columns
# (columns that are not in the meta data)
test_that("First columns are read correctly", {

  # character columns
  expect_true(all(vapply(data[, c('legacyCode',
                                  'code',
                                  'alias',
                                  'initials',
                                  'accountCode',
                                  'questionListName')],
                         is.character,
                         FUN.VALUE = logical(1)
                         )))

  # integer columns
  expect_true(all(vapply(data[, c('connectionId',
                                  'scheduledBeepId',
                                  'sentBeepId',
                                  'reminderForOriginalSentBeepId',
                                  'timeStampScheduled',
                                  'timeStampSent',
                                  'timeStampStart',
                                  'timeStampStop',
                                  'originalTimeStampSent',
                                  'timeZoneOffset'
                                  )],
                         is.integer,
                         FUN.VALUE = logical(1)
                         )))

  expect_true(is.numeric(data$deltaUTC))

})

# we will need the meta data to check the rest of the columns:
meta <- mpathr:::read_meta_data(meta_path)

test_that("String columns are read correctly", {

  # What columns should be read as strings?
  meta_string_cols <- meta[meta$typeAnswer == 'string',]$columnName

  # Checks that all those columns are strings
  expect_true(all(vapply(data[, meta_string_cols],
                         is.character,
                         FUN.VALUE = logical(1)))) # specify for vapply()

})

test_that("Integer columns are read correctly", {

  meta_int_cols <- meta[meta$typeAnswer == 'int',]$columnName

  expect_true(all(vapply(data[, meta_int_cols],
                         is.integer,
                         FUN.VALUE = logical(1))))

})

test_that("Numeric columns aer read correcly", {

  meta_numeric_cols <- meta[meta$typeAnswer == 'double',]$columnName

  expect_true(all(vapply(data[, meta_numeric_cols],
                         is.numeric,
                         FUN.VALUE = logical(1))))
})

# List columns
# Get list columns from meta data
meta_list_cols <- meta[meta$typeAnswer %in% c('intList',
                                              'doubleList',
                                              'stringList'),]$columnName

test_that('List columns are being read as lists', {

  expect_true(all(vapply(data[, meta_list_cols],
                         is.list,
                         FUN.VALUE = logical(1))))
})

# Check that each list is being read as its respective type

test_that('List columns are being read as the correct type', {
  for (col in meta_list_cols) {
    col_type <- meta[meta$columnName == col,]$typeAnswer
    if (col_type %in% c('intList', 'doubleList')) {
      expect_true(all(vapply(data[[col]],
                             function(x) is.numeric(x),
                             FUN.VALUE = logical(1))))
    } else if (col == 'stringList') {
      expect_true(all(vapply(data[[col]],
                             is.character,
                             FUN.VALUE = logical(1))))
    }
  }
})

# Test that problems are being printed when they occur:
# Make small dataset that will result in parsing problems
basic <- data.frame(connectionId = 228325.76, # this should be an int
          code = '',
          alias = '"example_alias"',
          questionListName = '"example_questions"',
          timeStampSent = 1722427206,
          consent_yesno = 1,
          slider_happy = 99)

# Create metadata for the dataset above
meta <- data.frame(columnName = c('"consent_yesno"', '"slider_happy"'),
          fullQuestion = c('"Do you consent to participate in this study?"',
                 '"How happy are you right now?"'),
          typeQuestion = c('"yesno"', '"sliderNegPos"'),
          typeAnswer = c('"int"', '"int"'),
          fullQuestion_mixed = c(0,0),
          typeQuestion_mixed =  c(0,0),
          typeAnswer_mixed =  c(0,0))

basic_file <- tempfile(fileext = ".csv")
meta_file <- tempfile(fileext = ".csv")

write.table(basic, basic_file, row.names = FALSE, sep = ";", quote = FALSE)
write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

test_that("Problem with integer is printed", {

  expect_warning(read_mpath(file = basic_file,
                            meta_data = meta_file),
                 "In row 2 column 1, expected an integer but got 228325.76.")

})

# Problems in meta_data
meta <- data.frame(columnName = c('"consent_yesno"', '"slider_happy"'),
                   fullQuestion =
                     c('"Do you consent to participate in this study?"',
                     '"How happy are you right now?"'),
                   typeQuestion = c('"yesno"', '"sliderNegPos"'),
                   typeAnswer = c('"int"', '"int"'),
                   fullQuestion_mixed = c(0,0),
                   typeQuestion_mixed =  c(10,0),
                   typeAnswer_mixed =  c(0,0))

meta_file <- tempfile(fileext = ".csv")
write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

test_that("Problem with meta_data is printed", {

  expect_warning(mpathr:::read_meta_data(meta_file),
                 "In row 2 column 6, expected 1/0/T/F/TRUE/FALSE but got 10.")

})

