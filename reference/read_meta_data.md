# Read m-Path meta data

Internal function to read the meta data file for an m-Path file.

## Usage

``` r
read_meta_data(meta_data, warn_changed_columns = TRUE)
```

## Arguments

- meta_data:

  A string with the path to the meta data file.

- warn_changed_columns:

  Warn if the question text, type of question, or type of answer has
  changed during the study. Default is `TRUE` and may print up to 50
  warnings.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with the
contents of the meta data file.
