#----------------------- Getting started -----------------------
#Install the package "tidyverse"
install.packages("tidyverse")

#Load the package "tidyverse"
library(tidyverse)

#View built-in datasets in R
data()

#Load the dataset 'mtcars'
#The 'mtcars' dataset contains information about various car models, including miles per gallon (mpg), number of cylinders (cyl), and horsepower (hp).
data(mtcars)

#View the dataset 'mtcars'
head(mtcars)

#----------------------- The pipe operator -----------------------
#The pipe operator %>% is used to chain together multiple functions

#Example: 1) filter out mpg > 20 
#         2) select columns mpg & cyl
#Without using pipe:
select(filter(mtcars, mpg > 20), mpg, cyl)

#Using pipe:
mtcars %>% filter(mpg > 20) %>% select(mpg, cyl)

#----------------------- Row manipulation -----------------------
#There are 3 functions used to manipulate rows: filter, arrange, slice 

#1. filter()
#filter() allows you to select rows based on a specified criteria

#filter out rows where mpg is greater than 20
mtcars %>% filter(mpg > 20)

#you can use multiple conditions
mtcars %>% filter(mpg > 20, cyl == 6)

#2. arrange()
#arrange() allows you to sort rows based on a specified column

#sort mtcars by mpg in ascending order
mtcars %>% arrange(mpg)

#to sort in descending order, put a negative sign before the column name
mtcars %>% arrange(-mpg)
#or use desc()
mtcars %>% arrange(desc(mpg))

#providing more than one column will sort it by the first column, then the second column, and so on
mtcars %>% arrange(cyl, mpg)

#3. slice()
#slice() allows you to select rows by their position in the dataset

#select rows 3 through 5
mtcars %>% slice(3:5)

#select the first n rows (e.g., 3 rows)
mtcars %>% slice_head(n = 3)

#select the last n rows (e.g., 3 rows)
mtcars %>% slice_tail(n = 3)

#randomly select n rows (e.g., 3 rows)
mtcars %>% slice_sample(n = 3)

#use option prop to randomly select a proportion of the rows
#for example, randomly select 50% of the rows
mtcars %>% slice_sample(prop = 0.5)

#use replace = TRUE to randomly select rows with replacement
mtcars %>% slice_sample(n = 3, replace = TRUE)

#slice_min() and slice_max() lets you select the rows with the minimum or maximum value of a variable
#for example, select the row with the minimum value of mpg
mtcars %>% slice_min(mpg)
#or select the row with the maximum value of mpg
mtcars %>% slice_max(mpg)
#you can also select the n lowest (or highest) values of a variable
mtcars %>% slice_min(mpg, n = 3)

#----------------------- Column manipulation -----------------------
#There are 4 functions used to manipulate columns: select, mutate, rename, relocate

#1. select()
#select() allows you to select columns based on their names

#select the columns mpg and cyl
mtcars %>% select(mpg, cyl)

#select all columns except for mpg and cyl
mtcars %>% select(-mpg, -cyl)

#select columns between mpg and hp (inclusive)
mtcars %>% select(mpg:hp)

#select all columns except those from mpg to hp (inclusive)
mtcars %>% select(!(mpg:hp))

#you can use helper functions within select() to quickly select columns:
#starts_with(): select all columns starting with the specified string
mtcars %>% select(starts_with("c"))

#ends_with(): select all columns ending with the specified string
mtcars %>% select(ends_with("p"))

#contains(): select all columns containing the specified string
mtcars %>% select(contains("p"))

#matches(): select all columns matching a regular expression
#for example, select all columns that contain either "c" or "p"
mtcars %>% select(matches("c|p"))

#2. mutate()
#mutate() allows you to create new columns based on existing columns

#create a new column called "mpg_per_cyl" that is the result of dividing mpg by cyl
mtcars %>% mutate(mpg_per_cyl = mpg / cyl)

#you can use select() to select only the new variable that you have created
mtcars %>% mutate(mpg_per_cyl = mpg / cyl) %>% select(mpg_per_cyl)

#you can also use mutate() to modify existing columns
#for example, multiply the mpg column by 2
mtcars %>% mutate(mpg = mpg * 2) 

#you can also use mutate() to create multiple new columns at once
mtcars %>% mutate(mpg_per_cyl = mpg / cyl, hp_per_cyl = hp / cyl) %>% select(mpg_per_cyl, hp_per_cyl)

#3. rename()
#rename() allows you to rename columns

#rename the column mpg to miles_per_gallon and hp to horsepower
mtcars %>% rename(miles_per_gallon = mpg, horsepower = hp)

#4. relocate()
#relocate() allows you to change the order of columns

#move the column mpg to the second position
mtcars %>% relocate(mpg, .after = cyl)

#you can move multiple columns at once
mtcars %>% relocate(mpg:hp, .after = drat)

#----------------------- Summarizing data -----------------------
#There are 2 functions frequently used to summarize data: summarise, group_by

#1. summarise()
#summarise() allows you to create summary statistics for a dataset

#calculate the mean of mpg
mtcars %>% summarise(mean(mpg))

#you can also calculate multiple summary statistics at once
mtcars %>% summarise(mean_mpg = mean(mpg), median_mpg = median(mpg), sd_mpg = sd(mpg))

#2. group_by()
#group_by() allows you to convert a dataset into a grouped dataset, you can then summarise the dataset by groups

#group the mtcars dataset by the number of cylinders (cyl)
mtcars %>% group_by(cyl)

#you can then use summarise() to calculate summary statistics for each group
mtcars %>% group_by(cyl) %>% summarise(mean_mpg = mean(mpg), median_mpg = median(mpg), sd_mpg = sd(mpg))

#to convert a grouped dataset back to regular dataset, use ungroup()
mtcars %>% group_by(cyl) %>% ungroup()
