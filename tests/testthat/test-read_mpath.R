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
# (columns that are not in the meta data)
test_that("First columns are read correctly", {

  # character columns
  cols <- data[, c("legacyCode", "code", "alias", "initials", "accountCode", "questionListName")]
  expect_true(all(vapply(
    X = cols,
    FUN = is.character,
    FUN.VALUE = logical(1)
  )))

  # integer columns
  cols <- data[, c(
    "connectionId",
    "scheduledBeepId",
    "sentBeepId",
    "reminderForOriginalSentBeepId",
    "timeStampScheduled",
    "timeStampSent",
    "timeStampStart",
    "timeStampStop",
    "originalTimeStampSent",
    "timeZoneOffset"
  )]

  expect_true(all(vapply(
    X = cols,
    FUN = is.integer,
    FUN.VALUE = logical(1)
  )))

  expect_true(is.numeric(data$deltaUTC))

})

# we will need the meta data to check the rest of the columns:
meta <- read_meta_data(meta_path)

test_that("String columns are read correctly", {

  # What columns should be read as strings?
  meta_string_cols <- meta[meta$typeAnswer == "string",]$columnName

  # Checks that all those columns are strings
  expect_true(all(vapply(
    X = data[, meta_string_cols],
    FUN = is.character,
    FUN.VALUE = logical(1)
  )))

})

test_that("Integer columns are read correctly", {
  meta_int_cols <- meta[meta$typeAnswer == "int",]$columnName

  expect_true(all(vapply(
    X = data[, meta_int_cols],
    FUN = is.integer,
    FUN.VALUE = logical(1)
  )))

})

test_that("Numeric columns aer read correcly", {
  meta_numeric_cols <- meta[meta$typeAnswer == "double",]$columnName

  expect_true(all(vapply(
    X = data[, meta_numeric_cols],
    FUN = is.numeric,
    FUN.VALUE = logical(1)
  )))
})

# List columns
# Get list columns from meta data
meta_list_cols <- meta[meta$typeAnswer %in% c("intList", "doubleList", "stringList"),]$columnName
test_that("List columns are being read as lists", {
  expect_true(all(vapply(
    X = data[, meta_list_cols],
    FUN = is.list,
    FUN.VALUE = logical(1)
  )))
})

# Check that each list is being read as its respective type
test_that("List columns are being read as the correct type", {
  for (col in meta_list_cols) {
    col_type <- meta$typeAnswer[meta$columnName == col]
    col <- data[[col]]

    # This should be a list either way
    expect_type(col, "list")
    col <- unlist(col, use.names = FALSE)

    switch(
      col_type,
      "intList" = expect_type(col, "integer"),
      "doubleList" = expect_type(col, "double"),
      "stringList" = expect_type(col, "character")
    )
  }
})

# Test that problems are being printed when they occur:
# Make small dataset that will result in parsing problems
basic <- data.frame(
  connectionId = 228325.76, # this should be an int
  code = '',
  alias = '"example_alias"',
  questionListName = '"example_questions"',
  timeStampSent = 1722427206,
  consent_yesno = 1,
  slider_happy = 99
)

# Create metadata for the dataset above
meta <- data.frame(
  columnName = c('"consent_yesno"', '"slider_happy"'),
  fullQuestion = c(
    '"Do you consent to participate in this study?"',
    '"How happy are you right now?"'
  ),
  typeQuestion = c('"yesno"', '"sliderNegPos"'),
  typeAnswer = c('"int"', '"int"'),
  fullQuestion_mixed = c(0, 0),
  typeQuestion_mixed =  c(0, 0),
  typeAnswer_mixed =  c(0, 0)
)

basic_file <- tempfile(fileext = ".csv")
meta_file <- tempfile(fileext = ".csv")

write.table(basic, basic_file, row.names = FALSE, sep = ";", quote = FALSE)
write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

test_that("Problem with integer is printed", {
  expect_warning(
    read_mpath(file = basic_file, meta_data = meta_file),
    "In row 2 column 1, expected an integer but got 228325.76."
  )
})

# Clean-up
unlink(basic_file)
unlink(meta_file)

# Problems in meta_data
meta <- data.frame(
  columnName = c('"consent_yesno"', '"slider_happy"'),
  fullQuestion = c(
    '"Do you consent to participate in this study?"',
    '"How happy are you right now?"'
  ),
  typeQuestion = c('"yesno"', '"sliderNegPos"'),
  typeAnswer = c('"int"', '"int"'),
  fullQuestion_mixed = c(0, 0),
  typeQuestion_mixed =  c(10, 0),
  typeAnswer_mixed =  c(0, 0)
)

meta_file <- tempfile(fileext = ".csv")
write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

test_that("Problem with meta_data is printed", {
  expect_warning(
    read_meta_data(meta_file),
    "In row 2 column 6, expected 1/0/T/F/TRUE/FALSE but got 10."
  )
})

# Clean-up
unlink(meta_file)

basic <- data.frame(
  connectionId = 228325,
  code = '',
  alias = '"example_alias"',
  questionListName = '"example_questions"',
  timeStampSent = 1722427206,
  consent_yesno = 1,
  slider_happy = 99
)

# create small meta_data to test warnings in changed meta data
test_that('specific warnings are printed for consent_yesno and slider_happy question changes', {

  meta$typeQuestion_mixed <- c(1, 1)
  meta$fullQuestion_mixed <- c(1, 1)

  basic_file <- tempfile(fileext = ".csv")
  meta_file <- tempfile(fileext = ".csv")

  write.table(basic, basic_file, row.names = FALSE, sep = ";", quote = FALSE)
  write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

  # Test for the basic structure of the warning message
  expect_warning(
    read_mpath(
      file = basic_file,
      meta_data = meta_file
    ),
    paste0(
      "(.*consent_yesno.*)(.*Question text.*)",
      "(.*consent_yesno.*)(.*Type of question.*)",
      "(.*slider_happy.*)(.*Question text*)",
      "(.*slider_happy.*)(.*Type of question.*)"
    )
  )

    # Clean-up
    unlink(basic_file)
    unlink(meta_file)
})

test_that("no warnings are printen when warn_changed_columns is false", {
  meta$typeQuestion_mixed <- c(1, 1)
  meta$fullQuestion_mixed <- c(1, 1)

  basic_file <- tempfile(fileext = ".csv")
  meta_file <- tempfile(fileext = ".csv")

  write.table(basic, basic_file, row.names = FALSE, sep = ";", quote = FALSE)
  write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

  expect_no_warning(
    read_mpath(
      file = basic_file,
      meta_data = meta_file,
      warn_changed_columns = FALSE
    )
  )

  # Clean-up
  unlink(basic_file)
  unlink(meta_file)
})

test_that("meta_data changed columns warnings are limited to 50", {
  meta <- data.frame(
    columnName = paste0('"consent_yesno_', 1:101, '"'),
    fullQuestion = paste0('"Do you consent to participate in this study?_', 1:101, '"'),
    typeQuestion = '"yesno"',
    typeAnswer = '"int"',
    fullQuestion_mixed = 1,
    typeQuestion_mixed =  0,
    typeAnswer_mixed =  0
  )

  meta_file <- tempfile(fileext = ".csv")
  write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

  out <- NULL
  suppressWarnings(
    foo <- withCallingHandlers(
      read_meta_data(meta_file),
      warning = \(w) out <<- w$message
    )
  )

  # Bullet points are used to delimit the warnings
  out <- strsplit(out, "\\*")[[1]]

  # 100 warnings + "The following questions have been changed"
  expect_length(out, 51)

  # Clean-up
  unlink(meta_file)
})

test_that("meta_data limits warnings from reading in meta data files to 50", {
  meta <- data.frame(
    columnName = paste0('"consent_yesno_', 1:101, '"'),
    fullQuestion = paste0('"Do you consent to participate in this study?_', 1:101, '"'),
    typeQuestion = '"yesno"',
    typeAnswer = '\nil',
    fullQuestion_mixed = 1,
    typeQuestion_mixed =  0,
    typeAnswer_mixed =  0
  )

  meta_file <- tempfile(fileext = ".csv")
  write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

  out <- NULL
  suppressWarnings(
    foo <- withCallingHandlers(
      read_meta_data(meta_file),
      warning = \(w) out <<- w$message
    )
  )

  # Bullet points are used to delimit the warnings
  out <- strsplit(out, "\nx")[[1]]

  # 100 warnings + "The following questions have been changed"
  expect_length(out, 51)

  # Clean-up
  unlink(meta_file)
})

test_that("read_mpath limits warnings from reading in data files to 50", {
  basic <- data.frame(
    connectionId = 228325,
    code = '',
    alias = rep('"example_alias"', 51),
    questionListName = '"example_questions"',
    timeStampSent = 1722427206,
    consent_yesno = "foo"
  )

  # create small meta_data to test warnings in changed meta data
  meta <- data.frame(
    columnName = paste0('"consent_yesno"'),
    fullQuestion = paste0('"Do you consent to participate in this study?"'),
    typeQuestion = '"yesno"',
    typeAnswer = '"int"',
    fullQuestion_mixed = 0,
    typeQuestion_mixed =  0,
    typeAnswer_mixed =  0
  )

  basic_file <- tempfile(fileext = ".csv")
  meta_file <- tempfile(fileext = ".csv")

  write.table(basic, basic_file, row.names = FALSE, sep = ";", quote = FALSE)
  write.table(meta, meta_file, row.names = FALSE, sep = ";", quote = FALSE)

  out <- NULL
  suppressWarnings(
    foo <- withCallingHandlers(
      read_mpath(
        file = basic_file,
        meta_data = meta_file
      ),
      warning = \(w) out <<- w$message
    )
  )

  # Bullet points are used to delimit the warnings
  out <- strsplit(out, "\\nx")[[1]]

  # 50 warnings + "The following questions have been changed"
  expect_length(out, 51)

  # Clean-up
  unlink(basic_file)
  unlink(meta_file)
})


