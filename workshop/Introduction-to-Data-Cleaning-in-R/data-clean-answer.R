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

# remove unused rows, row 1-3
raw_data <- raw_data[-c(1L:3L), ]
  
# we can't assign the colnames to raw data, why?
# raw data have 31 cols, but we only have 14 colnames
# so we need to 'remove' some cols

# task 3: remove all NA cols
# your turn (5 mins)
# ...

# my approach
na_cols <- raw_data[, which(vapply(.SD, function(x) all(is.na(x)), logical(1L), USE.NAMES = FALSE))]
set(raw_data, j = na_cols, value = NULL)

# oh, but even removed NA cols, the col number and colnames still doesnt match!
length(col_names)
NCOL(raw_data)

# from this step onwards, we will clean each individual col
# stay focus!

# we can observe there are ... serial number in total
sn_len <- length(na.omit(raw_data[, 1L][[1L]]))

# check out if there are multiple transactions under 1 serial number?
raw_data[, which(...1 == "275")]
raw_data[823L:827L]

# so we first have to split and sum up the transactions by S/N

# split the rows into list of data.tables
sn_row_ids <- which(!is.na(raw_data$...1))
raw_data_split <- lapply(seq_along(sn_row_ids), function(i) {
  if (i == sn_len) {
    return(raw_data[sn_row_ids[i]:.N, ])
  }
  raw_data[sn_row_ids[i]:(sn_row_ids[i + 1L] - 1L), ]
})

# task 4: filter out those lists with > 1 transactions
# your turn (3 mins)
# ...

# my approach
mult_trans <- which(
  vapply(
    raw_data_split, 
    function(x) x[, length(na.omit(...3)) > 2L], 
    logical(1L), 
    USE.NAMES = FALSE
  )
)

# sum up those multiple transactions, so we get an aggregate per reported claim
for (i in mult_trans) {
  # Payment Voucher No: substitute with '-'
  set(raw_data_split[[i]], i = 2L, j = "...5", value = "-")
  # Claim Paid: aggregate paid claims
  set(raw_data_split[[i]], i = 3L, j = "...11", value = raw_data_split[[i]][-1L, sum(as.numeric(...11), na.rm = TRUE)])
  # Cheque No: substitute with '-'
  set(raw_data_split[[i]], i = 3L, j = "...17", value = "-")
  # Cheque Date: substitute with NA
  set(raw_data_split[[i]], i = 3L, j = "...19", value = NA_real_)
  # other cols are good!
}

# noticed we have some mixed cols which consist of 2 independent cols. 
# now, we properly split those cols to new separate cols
for (i in seq_along(raw_data_split)) {
  # create new cols
  set(raw_data_split[[i]], j = c("Payment Voucher No.", "Claim Paid", "Payee"), 
      value = list(NA_character_, NA_real_, NA_character_))
  # assign "Payment Voucher No"
  set(raw_data_split[[i]], i = 1L, j = "Payment Voucher No.", value = raw_data_split[[i]][2L, (...5)])
  # assign "Claim Paid"
  set(raw_data_split[[i]], i = 1L, j = "Claim Paid", value = raw_data_split[[i]][3L, as.numeric(...11)])
  # assign "Payee"
  set(raw_data_split[[i]], i = 1L, j = "Payee", value = raw_data_split[[i]][3L, (...28)])
  # move "Cheque No" to 1st row
  set(raw_data_split[[i]], i = 1L, j = "...17", value = raw_data_split[[i]][3L, (...17)])
  # move "Cheque Date" to 1st row
  set(raw_data_split[[i]], i = 1L, j = "...19", value = raw_data_split[[i]][3L, (...19)])
  # move "Company Name" to 1st row
  set(raw_data_split[[i]], i = 1L, j = "...29", value = raw_data_split[[i]][3L, (...29)])
}

# now, we have all cols separated nicely
raw_data_split[[275L]]

# only 1st row is what we want, we can now discard the rest of the rows 
# task 5: keep only 1st row, discard the rest
# your turn (3 mins)
# ...

# my approach
for (i in seq_along(raw_data_split)) {
  raw_data_split[[i]] <- raw_data_split[[i]][1L, ]
}

# merge all lists into 1 data.table
raw_data <- rbindlist(raw_data_split, use.names = FALSE)

# check the col position and match with respective col names
dput(col_names)
setnames(raw_data, c(
  "S/N", "Trans. Date", "Our Claim No.", "Policy No.", "Client", "Cheque No",  
  "Cheque Date", "Your Claim No.", "Date of Loss", "Loss Details", "Company Name", 
  "Payment Voucher No.", "Claim Paid", "Payee"
))

# be aware of data type!
# clean the data type as well, eg integer, Date, numeric, etc

# convert "S/N" to integer
set(raw_data, j = "S/N", value = raw_data[, as.integer(`S/N`)])

# convert "Trans. Date" to Date
set(raw_data, j = "Trans. Date", value = raw_data[, as.Date(as.numeric(`Trans. Date`), origin = "1899-12-30")])

# convert "Cheque Date" to Date
set(raw_data, j = "Cheque Date", value = raw_data[, as.Date(as.numeric(`Cheque Date`), origin = "1899-12-30")])

# convert "Date of Loss" to Date
set(raw_data, j = "Date of Loss", value = raw_data[, as.Date(as.numeric(`Date of Loss`), origin = "1899-12-30")])

# lastly, rearrange the cols to our desired col order
setcolorder(raw_data, col_names)

# write to csv for checking
fwrite(raw_data, "workshop\\Introduction-to-Data-Cleaning-in-R\\clean_data.csv")
