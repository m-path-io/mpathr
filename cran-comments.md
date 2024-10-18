## Resubmission
This is a resubmission. In this version I have:

* Omitted quotes around the acronym ESM in the DESCRIPTION file.

* Unwrapped \dontrun from an example in `write_mpath()`. It now writes
to a temporary file.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

There is also a message that is neither an error, warning, or note:

Possibly misspelled words in DESCRIPTION:
  ESM (13:13, 15:31, 18:46)
  
This is due to the omission of the quotes around the acronym, as 
suggested by CRAN.
