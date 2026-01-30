col_names <- readr::read_lines(
  system.file("testdata", "test_basic.csv", package = "mpathr"),
  n_max = 1
)


test_that('no error is given when col_names is correct', {
  expect_error(is_opened_in_excel(col_names), NA)
})

# manually write bad input
col_names <- "'connectionId;legacyCode;code;alias;initials;accountCode;
scheduledBeepId;sentBeepId;reminderForOriginalSentBeepId;questionListName;
questionListLabel;fromProtocolName;timeStampScheduled;timeStampSent;
timeStampStart"

test_that('Returns error when col_names is not correct', {
  expect_error(
    is_opened_in_excel(col_names),
    'The file was saved and changed by Excel.'
  )
})
