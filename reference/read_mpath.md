# Read m-Path data

**\[stable\]**

This function reads an m-Path CSV file into a
[tibble](https://tibble.tidyverse.org/reference/tibble.html), an
extension of a `data.frame`.

## Usage

``` r
read_mpath(file, meta_data, warn_changed_columns = TRUE)
```

## Arguments

- file:

  A string with the path to the m-Path file.

- meta_data:

  A string with the path to the meta data file.

- warn_changed_columns:

  Warn if the question text, type of question, or type of answer has
  changed during the study. Default is `TRUE` and may print up to 50
  warnings.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with the
m-Path data.

## Details

Note that this function has been tested with the meta data version
v.1.1, so it is advised to use that version of the meta data. In the
m-Path dashboard, change the version in 'Export data' \> "export
version".

## See also

[`write_mpath()`](write_mpath.md) for saving the data back to a CSV
file.

## Examples

``` r
# We can use the function mpath_examples to get the path to the example data
basic_path <- mpath_example(file ="example_basic.csv")
meta_path <- mpath_example("example_meta.csv")

data <- read_mpath(file = basic_path,
                meta_data = meta_path)
```
