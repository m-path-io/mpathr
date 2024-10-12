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

  # TODO: Escape empty strings, otherwise they are converted to NA
  # data <- data |>
  #   mutate(across(
  #     .cols = where(is.character),
  #     .fns = \(x) ifelse(x == "", '\\', x)
  #   ))

  # Write the data to csv
  readr::write_csv2(data, file = file)
}
