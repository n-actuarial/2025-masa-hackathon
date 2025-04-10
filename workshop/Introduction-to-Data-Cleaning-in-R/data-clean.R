# load libraries
library(data.table) # data manipulation
library(readxl) # for reading xls file

# file path
path <- r"(workshop\Introduction-to-Data-Cleaning-in-R\Sample Paid Claims-XYZ.xls)"

# read in xls file
# we are reading sheet 1, colnames are not start from 1st row, so we skip that
# since data are mixed in diff cols, so we read all cols as text first
raw_data <- read_xls(path, sheet = 1L, col_names = FALSE, col_types = "text")

# take a view of dataset, from there we know the actual colnames started from row 7-9

# read in xls file again, skipping first 6 rows
raw_data <- read_xls(path, sheet = 1L, col_names = FALSE, col_types = "text", skip = 6L)
raw_data

# now, we start our data.table cleaning pipelines
# make raw_data as data.table obj
setDT(raw_data)

# Q: identify where is our colnames?
# A: it is row 1 & 3

# Before that, we also observed a bunch of NA rows
# We should get rid of that first

# introduce .SD, .SD is a convention for all cols in data.table
raw_data[1L, .SD]
raw_data[1L, is.na(.SD)]
raw_data[1L, all(is.na(.SD))]

raw_data[2L, .SD]
raw_data[2L, is.na(.SD)]
raw_data[2L, all(is.na(.SD))]

# introduce by operation, we can supplies a vector of unique id to evaluate all cols by each row
raw_data[, .(no_na = complete.cases(.SD)), by = 1L:NROW(raw_data)]

# task 1: remove all NA rows
# your turn (5 mins)
# ...

# my approach
raw_data[, all(is.na(.SD)), by = 1L:NROW(raw_data)]
raw_data[, all_na := all(is.na(.SD)), by = 1L:NROW(raw_data)]
raw_data <- raw_data[all_na == FALSE, ]
raw_data[, all_na := NULL]

# check raw data again, remove unused rows, this only runs 1 time!
raw_data <- raw_data[-.N, ]

# task 2: extract colnames
# your turn (3 mins)
# ...

# my approach
# for more about regex, see https://stringr.tidyverse.org/articles/regular-expressions.html
raw_data[1L, gsub("\\n+", "", na.omit(unlist(.SD, use.names = FALSE)))]
raw_data[2L, gsub("\\n+", "", na.omit(unlist(.SD, use.names = FALSE)))]
col_names <- c(
  raw_data[1L, gsub("\\n+", "", na.omit(unlist(.SD, use.names = FALSE)))],
  raw_data[2L, gsub("\\n+", "", na.omit(unlist(.SD, use.names = FALSE)))]
)
  
# we can't assign the colnames to raw data, why?
# raw data have 31 cols, but we only have 14 colnames
# so we need to 'remove' some cols

# task 3: remove all NA cols
# your turn (5 mins)
# ...

# my approach
na_cols <- raw_data[, which(vapply(.SD, function(x) all(is.na(x)), logical(1L), USE.NAMES = FALSE))]
set(raw_data, j = na_cols, value = NULL)

# from this step onwards, we will clean each individual col
# stay focus!

# we can observe there are ... serial number in total
length(na.omit(raw_data[-c(1L:3L), 1L][[1L]]))

# check out if there are multiple transactions under 1 serial number?
raw_data[, which(...1 == "275")]
raw_data[825L:830L]


