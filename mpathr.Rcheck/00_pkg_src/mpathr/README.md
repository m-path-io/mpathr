
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mpathr <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/m-path-io/mpathr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/m-path-io/mpathr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

The goal of `mpathr` is to provide with a few utility functions to read
and perform some common operations in data from Experience Sampling
Methodology (ESM) studies collected through the ‘m-Path’ platform
(<https://m-path.io/landing/>). The package provides functions to read
data from ‘m-Path’, and to calculate response rate in data from
Experience Sampling studies.

## Installation

``` r
install.packages("mpathr")
library(mpathr)
```

## Example

This is a basic example which shows you how to read data gathered from
m-Path into R using the `mpathr` package. For this, we use the example
data included in the package:

``` r
# loads package
library(mpathr)

# find paths to example basic and meta data:
basic_path <- mpath_example(file ='example_basic.csv')
meta_path <- mpath_example(file = 'example_meta.csv')

# read the data
data <- read_mpath(
  file = basic_path,
  meta_data = meta_path
)

print(data)
#> # A tibble: 2,221 × 100
#>   connectionId legacyCode  code       alias initials accountCode scheduledBeepId sentBeepId
#>          <int> <chr>       <chr>      <chr> <chr>    <chr>                 <int>      <int>
#> 1       234609 !9v48@jp7a7 !byyo kjyt abc   Ver      jp7a7                    -1   19355815
#> 2       234609 !9v48@jp7a7 !byyo kjyt abc   Ver      jp7a7              28626776   19369681
#> 3       234609 !9v48@jp7a7 !byyo kjyt abc   Ver      jp7a7              28626777   19370288
#> 4       234609 !9v48@jp7a7 !byyo kjyt abc   Ver      jp7a7              28626781   19375253
#> 5       234609 !9v48@jp7a7 !byyo kjyt abc   Ver      jp7a7              28626782   19377280
#> # ℹ 2,216 more rows
#> # ℹ 92 more variables: reminderForOriginalSentBeepId <int>, questionListName <chr>,
#> #   questionListLabel <lgl>, fromProtocolName <chr>, timeStampScheduled <int>, timeStampSent <int>,
#> #   timeStampStart <int>, timeStampStop <int>, originalTimeStampSent <int>, timeZoneOffset <int>,
#> #   deltaUTC <dbl>, consent_yesno_yesno <int>, gender_multipleChoice_index <int>,
#> #   gender_multipleChoice_string <chr>, gender_multipleChoice_likert <int>, age_open <chr>,
#> #   SWLS_intro_basic <int>, SWLS_1_multipleChoice_index <int>, …
```

## Getting help

If you encounter a clear bug or need help getting a function to run,
please file an issue with a minimal reproducible example on
[Github](https://github.com/m-path-io/mpathr/issues).

## Code of Conduct

Please note that the mpathr project is released with a [Contributor Code
of
Conduct](https://github.com/m-path-io/mpathr/blob/master/CODE_OF_CONDUCT.md).
By contributing to this project you agree to abide by its terms.
