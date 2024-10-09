# Function for unlisting columns by splitting the strings
.unlist_col <- function(vec) {
  .data <- data.frame(
    .id = seq_along(vec),
    vec = vec
  )
  .data$vec <- strsplit(.data$vec, ",")
  tidyr::unnest(.data, "vec", keep_empty = TRUE)
}

.relist_col <- function(data) {
  unname(split(data$vec, data$.id))
}

.to_int_list <- function(vec) {
  .data <- .unlist_col(vec)
  # Try to convert to integers, as they should be able to. However, in rare scenarios the integer
  # value is too large for R (integer overflow) in which case we will use double values.
  .data$vec <- tryCatch({
    as.integer(.data$vec)
  }, warning = function(w) {
    if (grepl("NAs introduced by coercion to integer range", conditionMessage(w))) {
      as.double(.data$vec)
    }
  })
  .relist_col(.data)
}

.to_double_list <- function(vec) {
  .data <- .unlist_col(vec)
  .data$vec <- as.double(.data$vec)
  .relist_col(.data)
}

.to_string <- function(vec) {
  # In case the file was written back to csv using [write_mpath()], the strings are not in JSON
  # format and thus do not need conversion.
  if (!any(grepl("\"", vec), na.rm = TRUE)) {
    return(vec)
  }

  # Only unjson strings that are not NA, so find them first
  idx_na <- is.na(vec)

  # Build the JSON string for the values that are not NA
  unjson <- paste0("[", paste0(vec[!idx_na], collapse = ","), "]")

  # Parse the JSON string
  unjson <- jsonlite::fromJSON(unjson, simplifyVector = TRUE)

  # Fill in the unjsoned values
  vec[!idx_na] <- unjson
  vec
}

.to_string_list <- function(vec) {
  if (!any(grepl("\"", vec), na.rm = TRUE)) {
    # In case the file was written back to csv using [write_mpath()], the strings are not in JSON
    # format and thus do not need JSON conversion.
    vec <- .unlist_col(vec)
    vec <- .relist_col(vec)
    return(vec)
  }

  # Only unjson strings that are not NA, so find them first
  idx_na <- is.na(vec)

  # Define every non-NA entry to be a JSON array
  unjson <- paste0("[", vec[!idx_na], "]", collapse = ",")

  # Put the string between square brackets to complete the JSON object
  unjson <- paste0("[", unjson, "]")

  unjson <- jsonlite::fromJSON(unjson, simplifyVector = FALSE)

  # The JSON is now parsed to a lists of lists of lists. We want to unlist in such a way that we
  # have a list of vectors. So loop over the outer list and collapse everything into a single
  # vector.
  unjson <- lapply(unjson, \(x) unlist(x, use.names = FALSE))

  # Merge with the NAs
  vec <- as.list(vec)
  vec[!idx_na] <- unjson

  vec
}
