.unlist_col <- function(vec) {
    tibble(
      .id = seq_along(vec),
      vec = vec
    ) |>
      mutate(vec = strsplit(.data$vec, ",")) |>
      tidyr::unnest("vec", keep_empty = TRUE)
}

.relist_col <- function(data) {
  data <- summarise(data, vec = list(.data$vec), .by = ".id")
  data$vec
}

.to_int_list <- function(vec) {
  .data <- .unlist_col(vec)
  # Try to convert to integers, as they should be able to. However, in rare scenarios the integer
  # value is too large for R (integer overflow) in which case we will use double values.
  tryCatch({
    .data$vec <- as.integer(.data$vec)
  }, warning = function(w) {
    if (grepl("NAs introduced by coercion to integer range", conditionMessage(w))) {
      .data$vec <- as.double(.data$vec)
    }
  })
  .relist_col(.data)
}

.to_double_list <- function(vec) {
  .data <- .unlist_col(vec)
  .data$vec <- as.double(.data$vec)
  .relist_col(.data)
}

.to_string_list <- function(vec) {
  .data <- .unlist_col(vec)
  .data$vec <- as.character(.data$vec)
  .relist_col(.data)
}

.to_string <- function(vec) {
  unjson <- ifelse(is.na(vec), "null", vec)
  unjson <- paste0("[", paste0(unjson, collapse = ","), "]")
  unjson <- jsonlite::fromJSON(unjson)
  as.character(unjson)
}

.to_string_list <- function(vec) {
  .data <- .unlist_col(vec)
  .data$vec <- .to_string(.data$vec)
  .relist_col(.data)
}
