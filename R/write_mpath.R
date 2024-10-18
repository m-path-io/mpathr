#' Write m-Path data to a CSV file
#'
#' @description `r lifecycle::badge("experimental")`
#'
#'   Save a data frame or tibble to a CSV file in the same format as the downloaded data from the
#'   m-Path website. This function is useful when you have made modifications to the original data
#'   and would like to save it in the same format. Note that reading back the data using
#'   [read_mpath()] may not always work, as the data may no longer be in line with the meta data of
#'   the original data file.
#'
#' @details
#'
#' Even though saving a data frame to a CSV file may seem trivial, there are several issues that
#' need to be addressed when saving m-Path data. The main issue is that m-Path data contains list
#' columns that need to be "collapsed" to a single string before they can be saved to a CSV file.
#' This function collapses most list columns to a single string using [paste()] with commas as a
#' delimiter of the values. However, for columns that contain strings, this is not possible as the
#' strings themselves may contains commas as well. To address this, the function converts all
#' character columns to JSON strings using [jsonlite::toJSON()] before saving them to disk.
#'
#' While `write_mpath()` aims to provide a similar CSV file as the m-Path dashboard, we cannot
#' provide any guarantees that the data can be read back using [read_mpath()], especially when the
#' data has been modified. If you want to save the data to use it at a later point in R (even when
#' transferring it to another computer), we recommend using [saveRDS()] or [save()] instead.
#'
#' Note that the resulting data file may not exactly be equal to the original, even if it was not
#' modified after reading it with [read_mpath()]. The main reason is that CSV files from the m-Path
#' dashboard do not contain all necessary file delimiters corresponding to the number of rows in the
#' data. This function, however, does contain the correct number of file delimiters which makes the
#' files slightly bigger compared to the original file.
#'
#' @param x A data frame or tibble to write to disk.
#' @param file File or connection to write to.
#' @param .progress Logical indicating whether to show a progress bar. Default is `TRUE`.
#'
#' @seealso [read_mpath()] to read m-Path data into R.
#'
#' @returns Returns `x` invisibly.
#' @export
#'
#' @examples
#' data <- read_mpath(
#'   mpath_example("example_basic.csv"),
#'   mpath_example("example_meta.csv")
#' )
#' \dontshow{
#' .old_wd <- setwd(tempdir())
#' }
#' write_mpath(data, "data.csv")
#' \dontshow{
#' setwd(.old_wd)
#' }
write_mpath <- function(
    x,
    file,
    .progress = TRUE
) {

  # These are default columns part of any m-Path file, and are not parsed to JSON
  default_cols <- c(
    "legacyCode",
    "code",
    "alias",
    "initials",
    "accountCode",
    "questionListName",
    "questionListLabel",
    "fromProtocolName"
  )

  # Find which columns are lists of strings
  string_list_cols <- vapply(x, \(x) is.list(x) & all(is.character(unlist(x))), logical(1))
  string_list_cols <- colnames(x)[string_list_cols]

  # Other string columns
  string_cols <- vapply(x, \(x) is.character(x), logical(1))
  string_cols <- colnames(x)[string_cols]
  string_cols <- setdiff(string_cols, string_list_cols)
  string_cols <- setdiff(string_cols, default_cols)

  p_bar <- if (.progress) {
    # Only use a progress bar for converting columns to JSON, as the rest of this function is very
    # fast.
    cli::cli_progress_bar(
      name = "Writing to CSV...",
      total = length(string_list_cols) + length(string_cols)
    )
  } else NULL

  # Collapse string list columns to JSONs to escape characters
  data <- x |>
    mutate(across(
      .cols = all_of(string_list_cols),
      .fns = \(x) .string_to_json(x, .progress = p_bar)
    ))

  # Escape all other character columns by parsing them to JSON, except the string columns we already
  # parsed.
  data <- data |>
    mutate(across(
      .cols = all_of(string_cols),
      .fns = \(x) .string_to_json(x, .progress = p_bar)
    ))

  # Collapse all other list columns to a string with a delimiter of ","
  data <- data |>
    mutate(across(
      .cols = where(is.list) & !all_of(string_list_cols),
      .fns = .collapse_col
    ))

  # Escape quotes by doubling them
  data <- data |>
    mutate(across(
      .cols = where(is.character),
      .fns = \(x) gsub("\"", "\"\"", x)
    ))

  # Quote all character columns
  data <- data |>
    mutate(across(
      .cols = where(is.character),
      .fns = \(x) ifelse(is.na(x), NA, paste0("\"", x, "\""))
    ))

  # Finish the progress bar
  if (.progress) {
    cli::cli_progress_done()
  }

  readr::write_delim(
    x = data,
    file = file,
    delim = ";",
    na = "",
    quote = "none",
    escape = "none"
  )
}

.collapse_col <- function(vec) {
  # Only perform this function for non-missing values
  idx_na <- is.na(vec)

  # Collapse the list to a single string
  collapsed <- vapply(vec[!idx_na], paste0, collapse = ",", character(1))

  # Merge with the full data
  vec[!idx_na] <- collapsed
  vec <- as.character(vec)

  # Replace NA strings with actual NAs
  vec <- ifelse(vec == "NA", NA, vec)

  vec
}

.string_to_json <- function(vec, .progress = NULL) {
  # Only perform this function for non-missing values
  idx_na <- is.na(vec)
  parsed <- vec[!idx_na]

  # Parse the string to JSON
  parsed <- vapply(parsed, toJSON, character(1))

  # But remove the square brackets from the JSON string
  parsed <- gsub("^\\[", "", parsed)
  parsed <- gsub("\\]$", "", parsed)

  # Merge with the full data
  vec[!idx_na] <- parsed
  vec <- as.character(vec)

  # Replace NA strings with actual NAs
  vec <- ifelse(vec == "NA", NA, vec)

  # Update the progress bar, if it exists
  if (!is.null(.progress)) {
    cli::cli_progress_update(id = .progress)
  }
  vec
}
