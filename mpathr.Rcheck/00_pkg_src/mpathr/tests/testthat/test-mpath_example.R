# Case 1: function returns a specific file path
test_that("Function returns specific file path", {

  expect_equal(mpath_example('example_basic.csv'),
               system.file('extdata/example_basic.csv', package = "mpathr"))

  expect_equal(mpath_example('example_meta.csv'),
               system.file('extdata/example_meta.csv', package = "mpathr"))

})

# Case 2: function returns all the example files
test_that("Function returns all the example files", {

  expect_equal(mpath_example(),
               list.files(system.file('extdata', package = "mpathr")))

})

# Case 3: function returns a message if the file is not found
test_that("Function returns a message if the file is not found", {
  expect_error(
    mpath_example('file_not_there.csv'),
  )

})
