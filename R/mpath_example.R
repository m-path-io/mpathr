#' Get path to m-Path example data
#'
#' This function provides an easy way to access the m-Path example files.
#'
#' @param file the name of the file to be accessed. If `NULL`, the function
#' will return a list of all the example files.
#'
#' @returns a character string with the path to the m-Path example data
#' @export
#'
#' @examples
#' # Example 1: access 'example_basic.csv' data
#'
#' mpath_example('example_basic.csv') # returns the full path to the file
#' 'example_basic.csv'
#'
#' # Example 2: list all the example files
#'
#' mpath_example() # returns the example files as a vector
#'
mpath_example <- function(file = NULL) {
  all_files <- list.files(system.file('extdata', package = "mpathr"))

  # Just return all files, without their directories
  if (is.null(file)) {
    return(all_files)
  }

  data_path <- file.path("extdata", file)
  path <- system.file(data_path, package = "mpathr")

  if (!file.exists(path)) {
    cli_abort(c(
      paste0("File `", file, "` could not be found."),
      i = paste0(
        "Please select one of the following files: ",
        paste0("`", all_files, "`", collapse = ", "),
        "."
      )
    ))
  }

  path
}
