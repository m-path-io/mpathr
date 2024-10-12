pkgname <- "mpathr"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('mpathr')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("mpath_example")
### * mpath_example

flush(stderr()); flush(stdout())

### Name: mpath_example
### Title: Get path to m-Path example data
### Aliases: mpath_example

### ** Examples

# Example 1: access 'example_basic.csv' data

mpath_example('example_basic.csv') # returns the full path to the file
'example_basic.csv'

# Example 2: list all the example files

mpath_example() # returns the example files as a vector




cleanEx()
nameEx("plot_response_rate")
### * plot_response_rate

flush(stderr()); flush(stdout())

### Name: plot_response_rate
### Title: Plots response rate per day (and per participant)
### Aliases: plot_response_rate

### ** Examples

# load data
data(example_data)

# make plot with plot_response_rate
plot_response_rate(data = example_data,
time_col = sent,
participant_col = participant,
valid_col = answered)
# The resulting ggplot object can be formatted using ggplot2 functions (see ggplot2
# documentation).




cleanEx()
nameEx("read_mpath")
### * read_mpath

flush(stderr()); flush(stdout())

### Name: read_mpath
### Title: Read m-Path data
### Aliases: read_mpath

### ** Examples


# We can use the function mpath_examples to get the path to the example data
basic_path <- mpath_example(file ="example_basic.csv")
meta_path <- mpath_example("example_meta.csv")

data <- read_mpath(file = basic_path,
                meta_data = meta_path)




cleanEx()
nameEx("response_rate")
### * response_rate

flush(stderr()); flush(stdout())

### Name: response_rate
### Title: Calculate response rate
### Aliases: response_rate

### ** Examples

# Example 1: calculate response rates for the whole study
# Get example data
data(example_data)

# Calculate response rate for each participant

# We don't specify time_col, period_start or period_end.
# Response rates will be based on all the participant's data
response_rate <- response_rate(data = example_data,
                               valid_col = answered,
                               participant_col = participant)

# Example 2: calculate response rates for a specific time period
data(example_data)

# Calculate response rate for each participant between dates
response_rate <- response_rate(data = example_data,
                               valid_col = answered,
                               participant_col = participant,
                               time_col = sent,
                               period_start = '2024-05-15',
                               period_end = '2024-05-31')

# Get participants with a response rate below 0.5
response_rate[response_rate$response_rate < 0.5,]




cleanEx()
nameEx("write_mpath")
### * write_mpath

flush(stderr()); flush(stdout())

### Name: write_mpath
### Title: Write m-Path data to a CSV file
### Aliases: write_mpath

### ** Examples


data <- read_mpath(
  mpath_example("example_basic.csv"),
  mpath_example("example_meta.csv")
)

## Not run: 
##D   write_mpath(data, "data.csv")
## End(Not run)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
