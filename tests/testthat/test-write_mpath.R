test_that("write_mpath can handle basic files", {
  basic_path <- system.file("testdata", "test_basic.csv", package = "mpathr")
  meta_path <- system.file("testdata", "test_meta.csv", package = "mpathr")

  data <- read_mpath(
    file = basic_path,
    meta_data = meta_path
  )

  out <- tempfile(fileext = ".csv")
  write_mpath(
    x = data,
    file = out
  )

  # Read it back in
  data_out <- read_mpath(
    file = out,
    meta_data = meta_path
  )

  # Compare
  expect_equal(data, data_out)

  # clean-up
  unlink(out)
})

test_that("write_mpath can write and preserve empty strings", {
  basic <- tibble(
    connectionId = 1L,
    code = "foo",
    alias = "example_alias",
    questionListName = "example_questions",
    timeStampSent = 1722427206L,
    consent_yesno = NA_character_,
    slider_happy = 99L,
    some_empty_string = "",
    some_string = list("")
  )

  # Create metadata for the dataset above
  meta <- tibble(
    columnName = c(
      "consent_yesno",
      "slider_happy",
      "some_empty_string",
      "some_string"
    ),
    fullQuestion = "Do you consent to participate in this study?",
    typeQuestion = c("yesno", "sliderNegPos", "string", "stringList"),
    typeAnswer = c("string", "integer", "string", "stringList"),
    fullQuestion_mixed = 0,
    typeQuestion_mixed = 0,
    typeAnswer_mixed = 0
  )

  basic_file <- tempfile(fileext = ".csv")
  meta_file <- tempfile(fileext = ".csv")

  write_mpath(
    x = basic,
    file = basic_file
  )

  readr::write_csv2(
    x = meta,
    file = meta_file
  )

  # Read it
  data_out <- read_mpath(
    file = basic_file,
    meta_data = meta_file
  )

  expect_identical(data_out, basic)

  # clean-up
  unlink(basic_file)
  unlink(meta_file)
})

test_that("write_mpath can handle NA as character", {
  basic <- tibble(
    connectionId = 1L,
    code = "foo",
    alias = "example_alias",
    questionListName = "example_questions",
    timeStampSent = 1722427206L,
    consent_yesno = NA_character_,
    some_na = "NA"
  )

  # Create metadata for the dataset above
  meta <- tibble(
    columnName = c("consent_yesno", "some_na"),
    fullQuestion = "Do you consent to participate in this study?",
    typeQuestion = c("yesno", "sliderNegPos"),
    typeAnswer = c("string", "string"),
    fullQuestion_mixed = 0,
    typeQuestion_mixed = 0,
    typeAnswer_mixed = 0
  )

  basic_file <- tempfile(fileext = ".csv")
  meta_file <- tempfile(fileext = ".csv")

  write_mpath(
    x = basic,
    file = basic_file
  )

  readr::write_csv2(
    x = meta,
    file = meta_file
  )

  # Read it
  data_out <- read_mpath(
    file = basic_file,
    meta_data = meta_file
  )

  expect_identical(data_out, basic)

  # clean-up
  unlink(basic_file)
  unlink(meta_file)
})
