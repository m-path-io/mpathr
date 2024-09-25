#' Locale to be used for m-Path data
#'
#' @description
#' Hard coded locale to be used for m-Path data
#'
#' @returns Return a locale to be used in [readr::read_delim()] or friends.
#' @keywords internal
.mpath_locale <- readr::locale(
  date_names = "en",
  date_format = "%AD",
  time_format = "%AT",
  decimal_mark = ",",
  grouping_mark = ".",
  tz = "UTC",
  encoding = "UTF-8",
  asciify = FALSE
)

#' Read m-Path data
#'
#' @description `r lifecycle::badge("experimental")`
#' This function reads an m-Path file into a dataframe.
#'
#' @details
#' Note that this function has been tested only with the version v.1.1. of the meta_data.
#' So it is advised to use that version of the meta_data file
#' (you can change the meta data version under "export version" in "Export data").
#'
#' @param file A string with the path to the m-Path file
#' @param meta_data A string with the path to the meta data file
#'
#' @return A \link[tibble]{tibble} with the contents of the m-Path file.
#' @export
#'
#' @examples
#'
#' # We can use the function mpath_examples to get the path to the example data
#' basic_path <- mpath_example(file ='example_basic.csv')
#' meta_path <- mpath_example('example_meta.csv')
#'
#' data <- read_mpath(file = basic_path,
#'                 meta_data = meta_path)
#'
read_mpath <- function(
    file,
    meta_data
) {

  # Read in the meta data
  meta_data <- read_meta_data(meta_data)

  # give warnings from last 3 cols of metadata
  rows_with_changes <- meta_data[rowSums(meta_data[, c('fullQuestion_mixed', 'typeQuestion_mixed', 'typeAnswer_mixed')]) > 0, ]

  # instead of just typing the name of the error, I will print these other messages (easier to read):
  labels_to_changes <- c(fullQuestion_mixed = 'Question text',
                         typeQuestion_mixed = 'Type of question',
                         typeAnswer_mixed = 'Type of answer')

  if (nrow(rows_with_changes) > 0){ # if there are any rows with changes
    for (i in 1:nrow(rows_with_changes)){
      row <- rows_with_changes[i,] # get the row

      changes_made <- colnames(row)[row[,]==TRUE] # gets the name of the columns that contain TRUE

      # print warning message
      # in case there's more than 1 change in one row, outputting the different changes separated by a comma
      warning(paste('In question', row['columnName'], 'the following has changed:',
                    paste(labels_to_changes[changes_made], collapse = ", ")))
    }
  }

  # Create mapping from the values in meta_data$typeAnswer (that specifies how that column should be saved)
  # to the values that readr::read_delim expects (i, c, ?...)
  type_mapping <- c("int" = "i",
                    "string" = "c",
                    "double" = "n",
                    "stringList" = "c", # the lists are read as strings and then converted to their respective types
                    "intList" = "c",
                    "doubleList" = "c",
                    "basic" = "i")

  # Create new column in meta_data with the type that readr::read_delim expects
  meta_data$type <- type_mapping[as.character(meta_data$typeAnswer)]

  # Special case for appUsage intList row: it should be read as a double List, even though it is an intList
  meta_data[meta_data$typeQuestion == 'appUsage' & meta_data$typeAnswer == 'intList',]$typeAnswer <- 'doubleList'

  meta_data[is.na(meta_data$type), "type"] <- "?" # if type is NA (because it is not in type_mapping), then R will guess the type

  cols_not_in_metadata <- c(
    connectionId = 'i',
    legacyCode = 'c',
    code = 'c',
    alias = 'c',
    initials = 'c',
    accountCode = 'c',
    scheduledBeepId = 'i',
    sentBeepId = 'i',
    reminderForOriginalSentBeepId = 'i',
    questionListName = 'c',
    timeStampScheduled = 'i',
    timeStampSent = 'i',
    timeStampStart = 'i',
    timeStampStop = 'i',
    originalTimeStampSent = 'i',
    timeZoneOffset = 'i',
    deltaUTC = 'n'
  )

  # Read first line to get names of columns (to be saved in col_names)
  col_names <- readr::read_lines(file, n_max = 1)

  # but first: check if file was opened by Excel #JORDAN: As this check is reused in two functions, maybe create a new function for it
  first_char <- substr(col_names, 1, 1)
  if (first_char == '"') {
    cli_abort(c(
      "The file was saved and changed by Excel.",
      i = "Please download the file from the m-Path website again."
    ))
  }

  col_names <- strsplit(col_names, ";")[[1]] # returns list of col_names

  # Get the type of each column in file to specify column types in readr::read_delim
  type_char <- sapply(col_names, function(col_name) {
    if (col_name %in% meta_data$columnName) { # if col is present in meta data
      return(meta_data$type[meta_data$columnName == col_name]) # then return type as specified in meta_data$type
    } else if (col_name %in% names(cols_not_in_metadata)){
      return(cols_not_in_metadata[col_name])
    } else {
      return("?") # otherwise, R will guess the type
    }
  })

  type_char <- paste0(type_char, collapse = "") # put the types in one single string (that's how read_delim expects them)

  # Read data
  suppressWarnings(data <- readr::read_delim(
    file = file,
    delim = ";",
    locale = .mpath_locale,
    show_col_types = FALSE,
    col_names = TRUE,
    col_types = c(type_char) # this line specifies types
  ))

  # handle the list columns
  ## First, storing which columns have to contain lists:
  int_list_cols <- meta_data$columnName[meta_data$typeAnswer == 'intList']
  num_list_cols <- meta_data$columnName[meta_data$typeAnswer == 'doubleList']
  string_list_cols <- meta_data$columnName[meta_data$typeAnswer == 'stringList']
  string_cols <- meta_data$columnName[meta_data$typeAnswer == 'string']

  # # convert the cells to lists
  # # Integer cols:
  data_int_lists <- data %>%
    mutate(across(all_of(int_list_cols), ~ lapply(., function(x) {
      tryCatch({
        # Attempt to split, unlist, and convert to integers
        as.integer(unlist(strsplit(.x, ",")))
      }, warning = function(w) {
        # Handle warning about 'NAs introduced by coercion to integer range'
        if (grepl("NAs introduced by coercion to integer range", conditionMessage(w))) {
          return(as.numeric(unlist(strsplit(.x, ",")))) # Fallback to numeric if integer fails
        }
      })
    })))

  data[,int_list_cols] <- data_int_lists[,int_list_cols]

  # Numeric:
  data_num_lists <- data %>%
    mutate(across(all_of(num_list_cols), ~ I(lapply(.x, function(x) as.numeric(strsplit(x, ",")[[1]])))))

  data[,num_list_cols] <- data_num_lists[,num_list_cols]

  # for string lists: now reading them as json lists
  data_string_list_cols <- data %>%
    mutate(across(all_of(string_list_cols),
                  ~ I(lapply(., function(cell) {
                    if (!is.na(cell)) {
                      fromJSON(paste0('[', cell, ']'))
                    } else {
                      cell  # Return NA as is
                    }
                  }))
    ))

  data[,string_list_cols] <- data_string_list_cols[,string_list_cols]

  # for string cols: we can get rid of the \" using fromJSON
  data_strings <- data %>%
    mutate(across(all_of(string_cols),
                  ~ sapply(.x, function(cell) {
                    if (!is.na(cell)) {
                      unlist(fromJSON(cell))
                    } else {
                      cell  # Return NA as is
                    }
                  })
    ))

  data[,string_cols] <- data_strings[,string_cols]

  # Catch problems
  problems <- readr::problems(data)
  problems <- problems[!grepl("columns", problems$expected), ]

  if (nrow(problems) > 0) {
    problems <- paste0(
      "In row ", problems$row,
      " column ", problems$col,
      ", expected ", problems$expected,
      " but got ", problems$actual, "."
    )
    names(problems) <- rep("x", length(problems))

    cli_warn(c(
      "There were problems when reading in the data:",
      problems[1:100]
    ))
  }

  return(data) # return data
}

#' Read m-Path meta data
#'
#' Internal function to read the meta data file for an m-Path file.
#'
#' @param file A string with the path to the meta data file
#'
#' @return A \link[tibble]{tibble} with the contents of the meta data file.
#' @keywords internal
read_meta_data <- function(
    meta_data # JORDAN: Change variable to meta_data to be coherent with the rest of the code
) {
  # Check if the first character of the file is not a quote. If it is, this is likely because it was
  # openend in Excel and saved again. This is because Excel will treat it as a string which means
  # adding quotes both to the entire line as well as inner quotes for the values. This will cause
  # issues when reading in the data and should be avoided.
  first_char <- readr::read_lines(meta_data, n_max = 1)
  first_char <- substr(first_char, 1, 1)
  if (first_char == '"') {
    cli_abort(c(
      "The file was saved and changed by a Excel.",
      i = "Please download the file from the m-Path website again."
    ))
  }

  suppressWarnings(meta_data <- readr::read_delim(
    file = meta_data,
    delim = ";",
    locale = .mpath_locale,
    show_col_types = FALSE,
    col_names = TRUE,
    col_types = c("cccclll")
  ))

  # Check for warnings with reading in the meta data. There should be none
  problems <- readr::problems(meta_data)
  if (nrow(problems) > 0) {
    problems <- paste0(
      "In row ", problems$row,
      " column ", problems$col,
      ", expected ", problems$expected,
      " but got ", problems$actual, "."
    )
    names(problems) <- rep("x", length(problems))

    cli_warn(c(
      "There were problems when reading in the meta data:",
      problems
    ))
  }

  meta_data
}
