#' Write m-Path data to a CSV file
#'
#' @param x A data frame or tibble to write to disk.
#' @param file File or connection to write to.
#'
#' @returns Returns `x` invisibly.
#' @export
#'
#' @examples
#'
#' data <- read_mpath(
#'   mpath_example("example_basic.csv"),
#'   mpath_example("example_meta.csv")
#' )
#'
#' \dontrun{
#'   write_mpath(data, "data.csv")
#' }
write_mpath <- function(
    x,
    file
) {

  # Collapse list columns to a string with a delimiter of ","
  data <- data |>
    dplyr::rowwise() |>
    mutate(across(
      .cols = dplyr::where(is.list),
      .fns = \(x) paste0(x, collapse = ",")
    )) |>
    ungroup()

  string_cols <- data %>%
    select(where(is.character)) %>%
    colnames()

  # escape empty strings
  data <- data |>
    mutate(across(
      .cols = where(is.character),
      .fns = \(x) {
        # find empty vals index
        NA_idx = x == ""
        # escape empty strings
        x <- ifelse(NA_idx, '""', x)
      }
    ))
  # TODO: maybe quote all strings so that we can implement lists in read_mpath for reread data

  # Write the data to csv
  readr::write_csv2(data, file = file, na = 'NA', escape = 'double')
}
