# Write m-Path data to a CSV file

**\[experimental\]**

Save a data frame or tibble to a CSV file in the same format as the
downloaded data from the m-Path website. This function is useful when
you have made modifications to the original data and would like to save
it in the same format. Note that reading back the data using
[`read_mpath()`](read_mpath.md) may not always work, as the data may no
longer be in line with the meta data of the original data file.

## Usage

``` r
write_mpath(x, file, .progress = TRUE)
```

## Arguments

- x:

  A data frame or tibble to write to disk.

- file:

  File or connection to write to.

- .progress:

  Logical indicating whether to show a progress bar. Default is `TRUE`.

## Value

Returns `x` invisibly.

## Details

Even though saving a data frame to a CSV file may seem trivial, there
are several issues that need to be addressed when saving m-Path data.
The main issue is that m-Path data contains list columns that need to be
"collapsed" to a single string before they can be saved to a CSV file.
This function collapses most list columns to a single string using
[`paste()`](https://rdrr.io/r/base/paste.html) with commas as a
delimiter of the values. However, for columns that contain strings, this
is not possible as the strings themselves may contains commas as well.
To address this, the function converts all character columns to JSON
strings using
[`jsonlite::toJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
before saving them to disk.

While `write_mpath()` aims to provide a similar CSV file as the m-Path
dashboard, we cannot provide any guarantees that the data can be read
back using [`read_mpath()`](read_mpath.md), especially when the data has
been modified. If you want to save the data to use it at a later point
in R (even when transferring it to another computer), we recommend using
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) or
[`save()`](https://rdrr.io/r/base/save.html) instead.

Note that the resulting data file may not exactly be equal to the
original, even if it was not modified after reading it with
[`read_mpath()`](read_mpath.md). The main reason is that CSV files from
the m-Path dashboard do not contain all necessary file delimiters
corresponding to the number of rows in the data. This function, however,
does contain the correct number of file delimiters which makes the files
slightly bigger compared to the original file.

## See also

[`read_mpath()`](read_mpath.md) to read m-Path data into R.

## Examples

``` r
data <- read_mpath(
  mpath_example("example_basic.csv"),
  mpath_example("example_meta.csv")
)
write_mpath(data, "data.csv")
```
