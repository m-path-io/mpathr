#' Read an m-Path file into a tibble
#'
#' @description `r lifecycle::badge("experimental")`
#' This function reads an m-Path file into a tibble.
#'
#' @details
#' Some more details...
#'
#' @param file A string with the path to the m-Path file
#' @param meta_data A string with the path to the meta data file
#'
#' @return A \link[tibble]{tibble} with the contents of the m-Path file.
#' @export
#'
#' @examples
#' # TODO: create working examples
#' read_mpath("path/to/file")
read_mpath <- function(
    file,
    meta_data
) {
  file
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
    file
) {
  # Hard coded locate to be used for m-Path meta data
  mpath_locale <- locale(
    date_names = "en",
    date_format = "%AD",
    time_format = "%AT",
    decimal_mark = ",",
    grouping_mark = ".",
    tz = "UTC",
    encoding = "UTF-8",
    asciify = FALSE
  )

  # Check if the first character of the file is not a quote. If it is, this is likely because it was
  # openend in Excel and saved again. This is because Excel will treat it as a string which means
  # adding quotes both to the entire line as well as inner quotes for the values. This will cause
  # issues when reading in the data and should be avoided.
  first_char <- readr::read_lines(file, n_max = 1)
  first_char <- substr(first_char, 1, 1)
  if (first_char == '"') {
    cli_abort(c(
      "The file was saved and changed by Excel.",
      i = "Please download the file from the m-Path website again."
    ))
  }

  meta_data <- readr::read_delim(
    file = file,
    delim = ";",
    locale = mpath_locale,
    show_col_types = FALSE
  ) |>
    suppressWarnings()

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

  # Transform the file to a long format if required
  meta_data <- meta_data |>
    pivot_longer(
      cols = -"columnName",
      names_to = "item_label",
      values_to = "values"
    ) |>
    pivot_wider(
      names_from = "columnName",
      values_from = "values"
    )

  # Convert the "_mixed" columns to a logical (i.e. boolean) value
  meta_data <- meta_data |>
    mutate(
      across(
        .cols = dplyr::ends_with("_mixed"),
        .fns = \(x) x == "1" # Dirty but fast
      )
    )

  meta_data
}
