# Function for unlisting columns by splitting the strings
.unlist_col <- function(vec) {
  # Generate a data frame with instance IDs to keep track of what goes where
  # Then unsplit the vector to a list column and unpack that column to a long format
  .data <- data.frame(
    .id = seq_along(vec),
    vec = vec
  )
  .data$vec <- strsplit(.data$vec, ",")
  tidyr::unnest(.data, "vec", keep_empty = TRUE)
}

# Given a data frame with a vec(tor) and id, "split" the data frame into lists with each list
# having the instance belonging to that ID
.relist_col <- function(data) {
  unname(split(data$vec, data$.id))
}

.to_int_list <- function(vec) {
  if (all(is.na(vec))) {
    return(as.list(rep(NA_integer_, length(vec))))
  }

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
  if (all(is.na(vec))) {
    return(as.list(rep(NA_real_, length(vec))))
  }

  .data <- .unlist_col(vec)
  .data$vec <- as.double(.data$vec)
  .relist_col(.data)
}

.to_string <- function(vec) {
  if (all(is.na(vec)) || !any(vec != "", na.rm = TRUE)) {
    return(vec)
  }

  # Only unjson strings that are not NA, so find them first
  idx_na <- is.na(vec)
  unjson <- vec[!idx_na]

  # Weird bug: If there are only "NA" values (not missing, but the text NA), it will convert it
  # to missing values.
  if (all(unjson == "\"NA\"")) {
    return(gsub("\"NA\"", "NA", vec))
  }

  # Build the JSON string for the values that are not NA
  unjson <- paste0("[", paste0(unjson, collapse = ","), "]")

  # Ensure the JSON is valid, otherwise return the input
  # This should normally not happen, except when there is a column in the meta data that we had to
  # guess, which turned out to be a character, and is then not JSON after all.
  if (isFALSE(jsonlite::validate(unjson))) {
    return(vec)
  }

  # Parse the JSON string
  unjson <- fromJSON(unjson, simplifyVector = TRUE)

  # If the length of the unjsoned values is longer than the original vector (without missing
  # values), it means that each entry contained multiple components and was thus not a string but a
  # stringList.
  if (length(unjson) > length(vec[!idx_na])) {
    return(.to_string_list(vec))
  }

  # Fill in the unjsoned values
  vec[!idx_na] <- unjson
  vec
}

.to_string_list <- function(vec) {
  if (all(is.na(vec)) || !any(vec != "", na.rm = TRUE)) {
    return(as.list(vec))
  }

  # Only unjson strings that are not NA, so find them first
  idx_na <- is.na(vec)

  # Define every non-NA entry to be a JSON array
  unjson <- paste0("[", vec[!idx_na], "]", collapse = ",")

  # Put the string between square brackets to complete the JSON object
  unjson <- paste0("[", unjson, "]")

  # Ensure the JSON is valid, otherwise return the input as a list
  # This should normally not happen, except when there is a column in the meta data that we had to
  # guess, which turned out to be a character, and is then not JSON after all.
  if (isFALSE(jsonlite::validate(unjson))) {
    return(as.list(vec))
  }

  unjson <- fromJSON(unjson, simplifyVector = FALSE)

  # The JSON is now parsed to a lists of lists of lists. We want to unlist in such a way that we
  # have a list of vectors. So loop over the outer list and collapse everything into a single
  # vector.
  unjson <- lapply(unjson, \(x) unlist(x, use.names = FALSE))

  # Merge with the NAs
  vec <- as.list(vec)
  vec[!idx_na] <- unjson

  vec
}
