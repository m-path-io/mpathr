# Changelog

## mpathr 1.0.4

CRAN release: 2026-02-05

- Add a new function
  [`extract_app_usage()`](../reference/extract_app_usage.md) to extract
  app usage data collected with mobile sensing lite.
- We now use the new
  [`dplyr::recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html)
  in favor of
  [`dplyr::case_match()`](https://dplyr.tidyverse.org/reference/case_match.html)
  if your `dplyr` version is 1.2.0 or greater.

## mpathr 1.0.3

CRAN release: 2025-05-15

### Minor changes

- Bump minimum R version to 4.1.0 due to the new pipe `|>` being used.
- Fix the `tz_offset` argument of
  [`timestamps_to_datetime()`](../reference/timestamps_to_datetime.md)
  that was being incorrectly calculated.
- Further refined the documentation of
  [`timestamps_to_datetime()`](../reference/timestamps_to_datetime.md)
  to clarify how it should be used.

## mpathr 1.0.2

CRAN release: 2024-11-22

This is a hotfix release to address some issues that may occur when
reading in data files that have non-standard column names.

### Minor changes

- Added link to m-Path manual in the README file.
- Added a light switch to the package website.

### Bug fixes

- Data files that had column names that needed escaping (e.g. a quote)
  are now being read in correctly.
- `mpathr` now attempts to convert string columns to string lists when
  it detects that each entry in the CSV file contains multiple entries.
- Fixed a locale issue where a comma was used as a decimal separator
  instead of a period.

## mpathr 1.0.1

CRAN release: 2024-10-21

- Resubmission of package to CRAN after making requested changes

## mpathr 1.0.0

- Initial CRAN submission.
