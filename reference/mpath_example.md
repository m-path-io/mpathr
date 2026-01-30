# Get path to m-Path example data

This function provides an easy way to access the m-Path example files.

## Usage

``` r
mpath_example(file = NULL)
```

## Arguments

- file:

  the name of the file to be accessed. If `NULL`, the function will
  return a list of all the example files.

## Value

a character string with the path to the m-Path example data

## Examples

``` r
# Example 1: access 'example_basic.csv' data

mpath_example('example_basic.csv') # returns the full path to the file
#> [1] "/home/runner/work/_temp/Library/mpathr/extdata/example_basic.csv"
'example_basic.csv'
#> [1] "example_basic.csv"

# Example 2: list all the example files

mpath_example() # returns the example files as a vector
#> [1] "example_basic.csv" "example_meta.csv" 
```
