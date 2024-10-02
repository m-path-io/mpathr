basic_path <- system.file("testdata", "test_basic.csv", package = "mpathr")
meta_path <- system.file("testdata", "test_meta.csv", package = "mpathr")

data <- read_mpath(
  file = basic_path,
  meta_data = meta_path
)

test_that("Data is imported with no warnings", {
  expect_no_warning(
    read_mpath(
      file = basic_path,
      meta_data = meta_path
    )
  )
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
# (columns that are not in the meta data, and they should always be read in the same way)
test_that("First columns are read correctly", {

  # character columns
  expect_true(all(sapply(data[, c('legacyCode',
                                  'code',
                                  'alias',
                                  'initials',
                                  'accountCode',
                                  'questionListName')],
                         is.character)))

  # integer columns
  expect_true(all(sapply(data[, c('connectionId',
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
                         is.integer)))


  expect_true(is.numeric(data$deltaUTC))

})

# we will need the meta data to check the rest of the columns:
meta <- read_meta_data(meta_path)

test_that("String columns are read correctly", {

  # What columns should be read as strings?
  meta_string_cols <- meta[meta$typeAnswer == 'string',]$columnName

  # Checks that all those columns are strings
  expect_true(all(sapply(data[, meta_string_cols], is.character)))

})

test_that("Integer columns are read correctly", {

  meta_int_cols <- meta[meta$typeAnswer == 'int',]$columnName

  expect_true(all(sapply(data[, meta_int_cols], is.integer)))

})

test_that("Numeric columns aer read correcly", {

  meta_numeric_cols <- meta[meta$typeAnswer == 'double',]$columnName

  expect_true(all(sapply(data[, meta_numeric_cols], is.numeric)))
})

# List columns
# Get list columns from meta data
meta_list_cols <- meta[meta$typeAnswer %in% c('intList', 'doubleList', 'stringList'),]$columnName

test_that('List columns are being read as lists', {

  expect_true(all(sapply(data[, meta_list_cols], is.list)))
})

# Check that each list is being read as its respective type

test_that('List columns are being read as the correct type', {
  for (col in meta_list_cols) {
    col_type <- meta[meta$columnName == col,]$typeAnswer
    if (col_type == 'intList') {
      expect_true(all(sapply(data[[col]], function(x) is.integer(x) || is.numeric(x))))
    } else if (col == 'doubleList') {
      expect_true(all(sapply(data[[col]], is.numeric)))
    } else if (col == 'stringList') {
      expect_true(all(sapply(data[[col]], is.character)))
    }
  }
})

















