#' Locale to be used for m-Path data
#'
#' @description
#' Hard coded locale to be used for 'm-Path' data
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
#' This function reads an 'm-Path' file into a dataframe.
#'
#' @details
#' Note that this function has been tested with the meta data version v.1.1.
#' So it is advised to use that version of the meta data.
#' (In 'm-Path', change the version in 'Export data' > "export version").
#'
#' @param file A string with the path to the m-Path file
#' @param meta_data A string with the path to the meta data file
#'
#' @returns A \link[tibble]{tibble} with the 'm-Path' data.
#' @export
#'
#' @examples
#'
#' # We can use the function mpath_examples to get the path to the example data
#' basic_path <- mpath_example(file ="example_basic.csv")
#' meta_path <- mpath_example("example_meta.csv")
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

  # Read first line to get names of columns (to be saved in col_names)
  col_names <- readr::read_lines(file, n_max = 1)

  # but first: check if file was opened by Excel
  is_opened_in_excel(col_names)

  # Define the default column names in data files
  # These are not included in the metadata file
  cols_not_in_metadata <- c(
    connectionId = "i",
    legacyCode = "c",
    code = "c",
    alias = "c",
    initials = "c",
    accountCode = "c",
    scheduledBeepId = "i",
    sentBeepId = "i",
    reminderForOriginalSentBeepId = "i",
    questionListName = "c",
    timeStampScheduled = "i",
    timeStampSent = "i",
    timeStampStart = "i",
    timeStampStop = "i",
    originalTimeStampSent = "i",
    timeZoneOffset = "i",
    deltaUTC = "n"
  )

  cols_not_in_metadata <- tibble(
    columnName = names(cols_not_in_metadata),
    type = cols_not_in_metadata
  )

  # Get the column names in the data file
  col_names <- strsplit(col_names, ";")[[1]]

  # Get the type of each column in file to specify column types in readr::read_delim
  type_char <- meta_data |>
    select("columnName", "type") |>
    rbind(cols_not_in_metadata)

  type_char <- dplyr::left_join(
      x = tibble(columnName = col_names),
      y = type_char,
      by = "columnName"
    ) |>
    mutate(type = ifelse(is.na(.data$type), "?", .data$type)) # not in metadata, let R guess the type

  # put the types in one single string (that"s how read_delim expects them)
  type_char <- paste0(type_char$type, collapse = "")

  # Read data
  data <- suppressWarnings(readr::read_delim(
    file = file,
    delim = ";",
    locale = .mpath_locale,
    show_col_types = FALSE,
    col_names = TRUE,
    col_types = type_char
  ))

  # Save potential problems before modifying the data
  problems <- readr::problems(data)

  # handle the list columns
  ## First, storing which columns have to contain lists:
  int_list_cols <- meta_data$columnName[meta_data$typeAnswer == "intList"]
  num_list_cols <- meta_data$columnName[meta_data$typeAnswer == "doubleList"]
  string_list_cols <- meta_data$columnName[meta_data$typeAnswer == "stringList"]
  string_cols <- meta_data$columnName[meta_data$typeAnswer == "string"]

  data <- data |>
    mutate(across(
      .cols = all_of(int_list_cols),
      .fns = .to_int_list
    )) |>
    mutate(across(
      .cols = all_of(num_list_cols),
      .fns = .to_double_list
    )) |>
    mutate(across(
      .cols = all_of(string_list_cols),
      .fns = .to_string_list
    )) |>
    mutate(across(
      .cols = all_of(string_cols),
      .fns = .to_string
    ))

  # Warn about other problems when reading in the data, if any
  problems <- problems[!grepl("columns", problems$expected), ]

  if (nrow(problems) > 0) {
    problems <- paste0(
      "In row ", problems$row,
      " column ", problems$col,
      ", expected ", problems$expected,
      " but got ", problems$actual, "."
    )
    names(problems) <- rep("x", length(problems))

    if (length(problems) > 100) {
      len <- length(problems)
      problems <- problems[1:100]
      problems <- c(problems, paste0("... and ", len - 100, " more problems."))
    }

    cli_warn(c(
      "There were problems when reading in the data:",
      problems
    ))
  }

  data
}

#' Check if an m-Path CSV file was opened in Excel
#'
#' @description
#' This function checks if an m-Path data file has previously been opened in Excel, in which case
#' the whole file is wrapped in quotation marks. Actual quotation marks will then also be quoted,
#' which is why we can't simply remove the outer quotes. Also, this function takes a single string
#' as input (the first line of the file) instead of the file itself, because this would mean the
#' file would have to be read twice. One time for this function, and then another time to get the
#' column names.
#'
#' @param line The first line of the file to check if it was opened in Excel.
#' @param call The environment from which the function was called to display in the error message.
#'
#' @returns Returns `TRUE` if the line is opened by Excel, otherwise an error informing the user of
#'   this problem.
#' @keywords internal
is_opened_in_excel <- function(line, call = rlang::caller_env()) {
  first_char <- substr(line, 1, 1)
  if (first_char == "'") {
    cli_abort(
      c(
        "The file was saved and changed by Excel.",
        i = "Please download the file from the m-Path website again."
      ),
      call = call
    )
  }

  invisible(TRUE)
}

#' Read m-Path meta data
#'
#' Internal function to read the meta data file for an m-Path file.
#'
#' @param meta_data A string with the path to the meta data file
#'
#' @returns A \link[tibble]{tibble} with the contents of the meta data file.
#' @keywords internal
read_meta_data <- function(
    meta_data
) {
  # Check if the first character of the file is not a quote. If it is, this is likely because it was
  # opened in Excel and saved again. This is because Excel will treat it as a string which means
  # adding quotes both to the entire line as well as inner quotes for the values. This will cause
  # issues when reading in the data and should be avoided.
  first_line <- readr::read_lines(meta_data, n_max = 1)
  is_opened_in_excel(first_line)

  meta_data <- suppressWarnings(readr::read_delim(
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

  # give warnings from last 3 cols of metadata
  rows_with_changes <- meta_data |>
    pivot_longer("fullQuestion_mixed":"typeAnswer_mixed") |>
    filter(.data$value)

  if (nrow(rows_with_changes) > 0){
    rows_with_changes <- rows_with_changes |>
      mutate(name = case_match(
        .data$name,
        "fullQuestion_mixed" ~ "{.fullq Question text}",
        "typeQuestion_mixed" ~ "{.typeq Type of question}",
        "typeAnswer_mixed" ~ "{.typea Type of answer}"
      ))

    # Create a new coloured theme to use in the warning
    cli::cli_div(
      theme = list(
        span.fullq = list(color = "red"),
        span.typeq = list(color = "blue"),
        span.typea = list(color = "green")
      )
    )

    # Generate the warning messages for the questions
    problems <- paste0("In `", rows_with_changes$columnName, "`: ",rows_with_changes$name)

    # Generate bullet points
    names(problems) <- rep("*", length(problems))

    cli_warn(c(
      "!" = "The following questions were changed during the study:",
      problems
    ))
  }

  # Create mapping from the values in meta_data$typeAnswer (that specifies how that column should be saved)
  # to the values that readr::read_delim expects (i, c, ?...)
  meta_data <- meta_data |>
    mutate(type = case_match(
      .data$typeAnswer,
      "basic" ~ "i",
      "int" ~ "i",
      "string" ~ "c",
      "stringList" ~ "c", # the lists are read as strings and then converted to their respective types
      "intList" ~ "c",
      "doubleList" ~ "c",
      "double" ~ "n"
    ))

  # Special case for appUsage intList row: it should be read as a double List, even though it is an
  # intList
  meta_data <- meta_data |>
    mutate(typeAnswer = ifelse(
      .data$typeQuestion == "appUsage" & .data$typeAnswer == "intList",
      "doubleList",
      .data$typeAnswer
    ))

  # if type is NA (because it is not in type_mapping), then R will guess the type
  meta_data[is.na(meta_data$type), "type"] <- "?"

  meta_data
}
