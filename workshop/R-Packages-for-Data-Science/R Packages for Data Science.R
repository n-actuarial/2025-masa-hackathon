##### Getting started #####
#Install the package "dplyr"
install.packages("dplyr")

#Load the package "dplyr"
library(dplyr)

#Built-in Datasets in R
data()

#Load the dataset mtcars
data(mtcars)

#View the dataset mtcars
head(mtcars)

##### The pipe operator #####
#The pipe operator %>% is used to chain together multiple functions
#Example: filter out mpg > 20, then select only columns mpg & cyl
mtcars %>% filter(mpg > 20) %>% select(mpg, cyl)

#Same example, but without using pipe operator %>%
select(filter(mtcars, mpg > 20), mpg, cyl)

##### Row manipulation #####
#1. filter()
#filter() allows you to select rows based on a specified criteria
mtcars %>% filter(mpg > 20)

#You can also use multiple conditions
mtcars %>% filter(mpg > 20, cyl == 6)

#2. arrange()
#arrange() allows you to sort rows based on a specified column
#sort mtcars by mpg in ascending order
mtcars %>% arrange(mpg)

#to sort in descending order, put a negative sign before the column name
mtcars %>% arrange(-mpg)
#or use desc()
mtcars %>% arrange(desc(mpg))

#if you provide more than one column, it will sort by the first column, then the second column, and so on
mtcars %>% arrange(cyl, mpg)




