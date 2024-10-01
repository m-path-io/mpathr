#' Get path to m-Path example data
#'
#' This function provides an easy way to access the m-Path example files.
#'
#' @param file the name of the file to be accessed. If `NULL`, the function
#' will return a list of all the example files.
#'
#' @return a character string with the path to the m-Path example data
#' @export
#'
#' @examples
#'
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

  data_path <- paste('extdata/', file, sep = '')

  path <- system.file(data_path, package = "mpathr")

  if(is.null(file)){

    example_path <- system.file('extdata', package = "mpathr")

    cat('Returning m-Path example files...\n')

    return(list.files(example_path))

  } else if (!is.null(file) & file.exists(path)) {

    return(path)

  } else {

    message('File not found. Make sure that you wrote the file name correctly.')

  }
}
