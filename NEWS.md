# mpathr 1.0.2
This is a hotfix release to address some issues that may occur when reading in data files that have
non-standard column names. 

## Minor changes
* Added link to m-Path manual in the README file.
* Added a light switch to the package website.

## Bug fixes
* Data files that had column names that needed escaping (e.g. a quote) are now being read in 
correctly.
* `mpathr` now attempts to convert string columns to string lists when it detects that each entry in
the CSV file contains multiple entries.
* Fixed a locale issue where a comma was used as a decimal separator instead of a period.

# mpathr 1.0.1
* Resubmission of package to CRAN after making requested changes

# mpathr 1.0.0
* Initial CRAN submission.
