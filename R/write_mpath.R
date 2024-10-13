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

  # escape empty strings and char columns
  data <- data |>
    mutate(across(
      .cols = where(is.character),
      .fns = \(x) {

        # # find NAs
        # NA_idx <- is.na(x)
        #
        # # everything that is not NA, wrap in quotes
        # x <- ifelse(!NA_idx, paste0('"', x, '"'), x) #!NA_idx & grepl(',', x), paste0('"', x, '"'), x)

        # find empty vals index
        NA_idx = x == ""
        # escape empty strings
        x <- ifelse(NA_idx, '""', x)

      }
    ))

  string_cols <- data %>%
    select(where(is.character)) %>%
    colnames()

  #print(str(data[,string_cols]))

  # Collapse list columns to a string with a delimiter of ","
  list_cols_all <- data %>%
    select(where(is.list))

  # Separate into string columns and other list columns
  string_cols <- list_cols_all %>%
    select(where(function(col) all(sapply(col, typeof) == "character"))) %>%
    colnames()

  non_string_cols <- list_cols_all %>%
    select(-where(function(col) all(sapply(col, typeof) == "character"))) %>%
    colnames()

  data <- data |>
    dplyr::rowwise() |>
    mutate(across(
      .cols = non_string_cols,
      .fns = \(x) paste0(x, collapse = ",")
    )) |>
    mutate(across(
      .cols = string_cols,
      .fns = \(x) {
          # Remove NAs and wrap remaining elements in quotes
          # since the NAs are inside lists doing is.na will not find them, solution:
          # non_na_elements <- x[!sapply(x, function(inner_list) all(is.na(inner_list)))]
          #
          # paste0(paste0("\"", unlist(non_na_elements), "\""), collapse = ",")
          # non_na_elements <- x[!sapply(x, function(inner_list) {
          #   length(inner_list) == 1 && is.na(inner_list)  # Check for single NA
          # })]
          #
          # combined <- c(unlist(non_na_elements), rep(NA, length(x) - length(non_na_elements)))
          # # Return the concatenated result as a character string, while keeping NAs as NAs
          # return(paste0(paste0("\"", combined[!is.na(combined)], "\""), collapse = ","))
          lapply(x, function(cell) {if(!is.na(cell[[1]])){
            paste0(paste0("\"", unlist(cell), "\""), collapse = ",")}
            else{cell}
          }) |>
            unlist() |>
            paste0(collapse = ",")
          #paste0(paste0("\"", x, "\""), collapse = ",")
        }
    )) |>
    ungroup()

  # Write the data to csv
  readr::write_csv2(data, file = file, na = 'NA', escape = 'double', eol = '\r\n', quote = 'needed')
}
