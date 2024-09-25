
# create small meta_data to test warn_meta_changes function
meta_data <- data.frame(columnName = c('"consent_yesno"', '"slider_happy"'),
          fullQuestion = c('"Do you consent to participate in this study?"',
                 '"How happy are you right now?"'),
          typeQuestion = c('"yesno"', '"sliderNegPos"'),
          typeAnswer = c('"int"', '"int"'),
          fullQuestion_mixed = c(0,0),
          typeQuestion_mixed =  c(0,0),
          typeAnswer_mixed =  c(0,0))

meta_data$columnName <- as.character(meta_data$columnName)

test_that('no warnings are printed', {

 expect_no_warning(mpathr:::warn_meta_changes(meta_data))

})

test_that('specific warnings are printed for consent_yesno and
          slider_happy question changes', {


  meta_data[meta_data$columnName == '"consent_yesno"',
            c('fullQuestion_mixed', 'typeQuestion_mixed')] <- 1

  # Test for the specific warning related to the "consent_yesno" question
  expect_warning(
    mpathr:::warn_meta_changes(meta_data),
    regexp = "In question \"consent_yesno\" the following has changed: Question text, Type of question"
  )

  meta_data[meta_data$columnName == '"consent_yesno"',
            c('fullQuestion_mixed', 'typeQuestion_mixed')] <- 0
  meta_data[meta_data$columnName == '"slider_happy"', 'typeAnswer_mixed'] <- 1

  # Test for the specific warning related to the "slider_happy" question
  expect_warning(
    mpathr:::warn_meta_changes(meta_data),
    regexp = "In question \"slider_happy\" the following has changed: Type of answer"
  )

})
