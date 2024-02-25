nzu.r

https://github.com/edi-rose/nzu-fork

# remember to "find and replace" "-" with "/" (replace short dashs with backslashs in the csv file "nzu-edited-raw-prices-data.csv"

# in an xterminal run "python3 api.py"

# the csv file "nzu-edited-raw-prices-data.csv" is the output of 'api.py'

# "nzu-edited-raw-prices-data.csv" has the column headers ("date" "price" "reference" "month" "week") as the last row and not the first row..

# load package Ggplot2 for graphs
library("ggplot2")

# check my current working folder
getwd()
[1] "/home/user/R/nzu/nzu-fork-master/apipy"
#setwd("/home/user/R/nzu/nzu-fork-master/apipy")  # if needed

# read in data  reading the .csv file specifying header status as false
data <- read.csv("nzu-edited-raw-prices-data.csv",header=FALSE)
dim(data)
[1] 1774    5
str(data) 
'data.frame':	1774 obs. of  5 variables:
 $ V1: chr  "2010/05/14" "2010/05/21" "2010/05/29" "2010/06/11" ...
 $ V2: chr  "17.75" "17.5" "17.5" "17" ...
 $ V3: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ V4: chr  "2010/05/01" "2010/05/01" "2010/05/01" "2010/06/01" ...
 $ V5: chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...

# after the Python script is run, the last row is the what used to be the column headers 

# look at that last row again
tail(data,1) 
       V1    V2        V3    V4   V5
1774 date price reference month week

# try converting the last row to a character vector
as.character(data[nrow(data),])
[1] "date"      "price"     "reference" "month"     "week" 
# add column names as character formated last row cells
colnames(data) <- as.character(data[nrow(data),])
colnames(data)
[1] "date"      "price"     "reference" "month"     "week" 

head(data,2) 
       date price                                          reference
1 2010/05/14 17.75 http://www.carbonnews.co.nz/story.asp?storyID=4529
2 2010/05/21  17.5 http://www.carbonnews.co.nz/story.asp?storyID=4540
       month     week
1 2010/05/01 2010/W19
2 2010/05/01 2010/W20

# delete last row - the header names
data <- data[-nrow(data),]
tail(data,1)
           date price                                            reference
1773 2024/02/23 67.00 https://www.carbonnews.co.nz/story.asp?storyID=30851
       month     week
1773 2024-02 2024-W08

# change formats of date column and price column
data$date <- as.Date(data$date)
data$price <- as.numeric(data$price)

# add month variable/factor to data
data$month <- as.factor(format(data$date, "%Y-%m"))
# create dataframe of only the spot prices
spotprices <- data[,1:2]
str(spotprices) 
'data.frame':	1773 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 
# write the spot prices dataframe to a .csv file 
write.table(spotprices, file = "spotprices.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 
# spotprices <- read.csv(spotprices.csv)

## load package aweek which deals with week  
# Kamvar Z (2022). _aweek: Convert Dates to Arbitrary Week Definitions_. R package version 1.0.3, <https://CRAN.R-project.org/package=aweek>
library("aweek")
# make aweek vector (with Monday being day 1 - the default) from date format column and overwrite contents of week column   
data$week <- as.aweek(data$date) 
str(data) 
'data.frame':	1774 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 166 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
 $ week     : 'aweek' chr  "2010-W19-5" "2010-W20-5" "2010-W21-6" "2010-W23-5" ...
  ..- attr(*, "week_start")= int 1
 
# create new dataframe of monthly mean price 
monthprice<-aggregate(price ~ month, data, mean)
# round mean prices to whole cents
monthprice[["price"]] = round(monthprice[["price"]], digits = 2)
# replace month factor with mid-month 15th of month date-formatted string
monthprice[["month"]] = seq(as.Date('2010-05-15'), by = 'months', length = nrow(monthprice)) 
# rename columns
colnames(monthprice) <- c("date","price")
# check structure of dataframe
str(monthprice) 
'data.frame':	166 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ...
# write the mean monthly price dataframe to a .csv file 
write.table(monthprice, file = "nzu-month-price.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

## weekly time series 
# remove week day part from aweek week and stay in aweek format
data$week <- trunc(data$week) 
  
# create new dataframe of weekly mean price using 'aweek' variable 
weeklyprice <- aggregate(price ~ week, data, mean)

# round mean prices to whole cents
weeklyprice[["price"]] = round(weeklyprice[["price"]], digits = 2)

# add date column from aweek week & change to date format 
weeklyprice[["date"]] <- as.Date(weeklyprice[["week"]]) 
  
# change order of columns
weeklyprice <- weeklyprice[,c(3,2,1)]

# check dataframe
str(weeklyprice)
'data.frame':	625 obs. of  3 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ...
 $ week : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1
  
# write the mean price per week dataframe to a .csv file 
write.table(weeklyprice, file = "weeklymeanprice.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

## Missing values and interpolation in the week series
# Fill in the missing values in the weekly prices data series - as there are no prices for at least 95 weeks
# load package xts (Ryan JA, Ulrich JM (2023). _xts: eXtensible Time Series_. R package version 0.13.1)
library("xts") 
# load package zoo (# Zeileis A, Grothendieck G (2005). “zoo: S3 Infrastructure for Regular and Irregular Time Series.” Journal of Statistical Software, 14(6), 1–27. doi:10.18637/jss.v014.i06.)
library("zoo")  

# How many weeks should be included if there were prices for all weeks?
weeklypriceallDates <- seq.Date(min(weeklyprice$date), max(weeklyprice$date), "week")
length(weeklypriceallDates) 
[1] 720 
# How many weeks were there in weekly prices dataframe which omits the weeks with missing prices?
nrow(weeklyprice)
[1] 625

# How many weeks will need to be filled since May 2010
length(weeklypriceallDates) - nrow(weeklyprice)
[1] 95

# create dataframe of all the weeks with missing weeks of prices added as NA
weeklypricemissingprices <- merge(x= data.frame(date = weeklypriceallDates),  y = weeklyprice,  all.x=TRUE)
# check dataframes
str(weeklypricemissingprices)
'data.frame':	720 obs. of  3 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 NA 17 ...
 $ week : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" NA ...
  ..- attr(*, "week_start")= int 1 
class(weeklypricemissingprices)  
[1] "data.frame"
head(weeklypricemissingprices,9)
       date price     week
1 2010-05-10 17.75 2010-W19
2 2010-05-17 17.50 2010-W20
3 2010-05-24 17.50 2010-W21
4 2010-05-31    NA     <NA>
5 2010-06-07 17.00 2010-W23
6 2010-06-14    NA     <NA>
7 2010-06-21 17.75 2010-W25
8 2010-06-28 17.50 2010-W26
9 2010-07-05 18.00 2010-W27

# Convert the data frame price and date columns to a zoo time series object
weeklypricemissingpriceszoo <- zoo(weeklypricemissingprices[["price"]], weeklypricemissingprices[["date"]])

# check structure of zoo object
str(weeklypricemissingpriceszoo)
‘zoo’ series from 2010-05-10 to 2023-12-18
  Data: num [1:720] 17.8 17.5 17.5 NA 17 ...
  Index:  Date[1:720], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ... 
# look at first nine values/dates
head(weeklypricemissingpriceszoo,9)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 2010-06-21 
     17.75      17.50      17.50         NA      17.00         NA      17.75 
2010-06-28 2010-07-05 
     17.50      18.00 

# calculate the missing values with zoo na.approx which uses linear interpolation to fill in the NA values     
na.approx(weeklypricemissingpriceszoo)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 2010-06-21 
   17.7500    17.500m0    17.5000    17.2500    17.0000    17.3750    17.7500 
2010-06-28 2010-07-05 2010-07-12 2010-07-19 2010-07-26 2010-08-02 2010-08-09 
   17.5000    18.0000    18.3000    18.3125    18.3250    18.3375    18.3500 
2010-08-16 
   18.3500 
# create a zoo time series vector with filled in the missing prices with linear interpolation via zoo package and save output  
weeklypricefilled <- na.approx(weeklypricemissingpriceszoo)

# check first 6 values
head(weeklypricefilled)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 
    17.750     17.500     17.500     17.250     17.000     17.375
# check the new dataframe
str(weeklypricefilled)
‘zoo’ series from 2010-05-10 to 2023-12-04
  Data: num [1:720] 17.8 17.5 17.5 17.2 17 ...
  Index:  Date[1:720], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ... 
  
# Convert  the zoo vector to a data frame
weeklypricefilleddataframe <- as.data.frame(weeklypricefilled)   
# check dataframe 
str(weeklypricefilleddataframe) 
'data.frame':	719 obs. of  1 variable:
 $ weeklypricefilled: num  17.8 17.5 17.5 17.2 17 ... 
# look at first 6 values 
head(weeklypricefilleddataframe) 
           weeklypricefilled
2010-05-10            17.750
2010-05-17            17.500
2010-05-24            17.500
2010-05-31            17.250
2010-06-07            17.000
2010-06-14            17.375

str(weeklypricefilleddataframe[["weeklypricefilled"]] )
num [1:720] 17.8 17.5 17.5 17.2 17 ...
# Convert row names to a column called date
weeklypricefilleddataframe$date <- rownames(weeklypricefilleddataframe)    
# check first 6 values
head(weeklypricefilleddataframe,2)
           weeklypricefilled       date
2010-05-10            17.750 2010-05-10
2010-05-17            17.500 2010-05-17 
# Reset row names
rownames(weeklypricefilleddataframe) <- NULL           
# check first 6 values
head(weeklypricefilleddataframe,3)
  weeklypricefilled       date
1             17.75 2010-05-10
2             17.50 2010-05-17
3             17.50 2010-05-24 
# check dataframe
str(weeklypricefilleddataframe)
'data.frame':	720 obs. of  2 variables:
 $ weeklypricefilled: num  17.8 17.5 17.5 17.2 17 ...
 $ date             : chr  "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" ...

# change date from character to date format 
weeklypricefilleddataframe$date <- as.Date(weeklypricefilleddataframe$date)
# check dataframe
str(weeklypricefilleddataframe)
'data.frame':	720 obs. of  2 variables:
 $ weeklypricefilled: num  17.8 17.5 17.5 17.2 17 ...
 $ date             : Date, format: "2010-05-10" "2010-05-17" ... 
# make the date column the left column and the price the right or second column 
weeklypricefilleddataframe <- weeklypricefilleddataframe[,c(2,1)]  
# round mean prices to whole cents
weeklypricefilleddataframe[["weeklypricefilled"]] = round(weeklypricefilleddataframe[["weeklypricefilled"]], digits = 2)
# change column names
colnames(weeklypricefilleddataframe) <-c("date","price") 
str(weeklypricefilleddataframe)
'data.frame':	720 obs. of  2 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 17.2 17 ...
 
# write the infilled mean price per week dataframe to a .csv file 
write.table(weeklypricefilleddataframe, file = "weeklypricefilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# create a time series object for average monthly prices
weekts <- ts(weeklypricefilleddataframe[["price"]],frequency=52,start = c(2010,19))
# check the time series
str(weekts) 
Time-Series [1:720] from 2010 to 2024: 17.8 17.5 17.5 17.2 17 ... 
 # check the dataframe again

str(data) 
'data.frame':	1773 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 166 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
 $ week     : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1
# Create a .csv formatted data file
write.csv(data, file = "nzu-final-prices-data.csv", row.names = FALSE)

# check the structure of the average monthly price data
str(monthprice) 
'data.frame':	166 obs. of  2 variables:
 $ date : Date, format: "2010-05-01" "2010-06-01" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ... 

# read back in to R the price data in three formats
monthprice <- read.csv("nzu-month-price.csv", colClasses = c("Date","numeric"))
weeklyprice <- read.csv("weeklymeanprice.csv", colClasses = c("Date","numeric","character")) 
data <- read.csv("nzu-final-prices-data.csv", colClasses = c("Date","numeric","character","character","character")) 
spotprices <- read.csv("spotprices.csv", colClasses = c("Date","numeric"))

## fill in missing values in week day spot prices
library("xts")
library("zoo")
library("ggplot2")

spotprices <- read.csv("spotprices.csv", colClasses = c("Date","numeric"))

str(spotprices) 
'data.frame':	1773 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 

# How many days of dates should be included if there were prices for all days from May 2010 to Dec 2023?
spotpricealldates <- seq.Date(min(spotprices$date), max(spotprices$date), "day")
length(spotpricealldates) 
[1] 5034
# how many missing values are there?
length(spotpricealldates) - nrow(spotprices) 
[1] 3261

# create dataframe of all the days with missing prices added as NA
spotpricealldatesmissingprices <- merge(x= data.frame(date = spotpricealldates),  y = spotprices,  all.x=TRUE)

head(spotpricealldatesmissingprices) 
        date price
1 2010-05-14 17.75
2 2010-05-15    NA
3 2010-05-16    NA
4 2010-05-17    NA
5 2010-05-18    NA
6 2010-05-19    NA

# Convert the data frame price and date columns to a zoo time series object
spotpricealldatesmissingpriceszoo <- zoo(spotpricealldatesmissingprices[["price"]], spotpricealldatesmissingprices[["date"]])
# check the object's structure
str(spotpricealldatesmissingpriceszoo)
‘zoo’ series from 2010-05-14 to 2023-12-22
  Data: num [1:5034] 17.8 NA NA NA NA ...
  Index:  Date[1:5034], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...
# look a first 6 lines/rows
head(spotpricealldatesmissingpriceszoo) 
2010-05-14 2010-05-15 2010-05-16 2010-05-17 2010-05-18 2010-05-19 
     17.75         NA         NA         NA         NA         NA

# create a zoo matrix with filled in the missing prices with linear interpolation via zoo package and save output  
spotpricefilled <- na.approx(spotpricealldatesmissingpriceszoo)
# round infilled values to cents
spotpricefilled <- round(spotpricefilled,2)

head(spotpricefilled) 
2010-05-14 2010-05-15 2010-05-16 2010-05-17 2010-05-18 2010-05-19 
     17.75      17.71      17.68      17.64      17.61      17.57

str(spotpricefilled) 
‘zoo’ series from 2010-05-14 to 2023-12-08
  Data: num [1:5034] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5034], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ... 
  
# Convert  the zoo vector to a data frame
spotpricefilleddataframe <- as.data.frame(spotpricefilled)   

# Convert row names to a column called date
spotpricefilleddataframe$date <- rownames(spotpricefilleddataframe)     

# Reset row names
rownames(spotpricefilleddataframe) <- NULL           

# change date from character to date format 
spotpricefilleddataframe$date <- as.Date(spotpricefilleddataframe$date)

# make the date column the left column and the price the right or second column 
spotpricefilleddataframe <- spotpricefilleddataframe[,c(2,1)] 

head(spotpricefilleddataframe) 
         date spotpricefilled
1 2010-05-14        17.75000
2 2010-05-15        17.71429
3 2010-05-16        17.67857
4 2010-05-17        17.64286
5 2010-05-18        17.60714
6 2010-05-19        17.57143

# rename column
colnames(spotpricefilleddataframe)[2] <- c("price")

head(spotpricefilleddataframe) 
        date price
1 2010-05-14 17.75
2 2010-05-15 17.71
3 2010-05-16 17.68
4 2010-05-17 17.64
5 2010-05-18 17.61
6 2010-05-19 17.57

# round mean prices to whole cents
#spotpricefilleddataframe[["price"]] = round(spotpricefilleddataframe[["price"]], digits = 2)

str(spotpricefilleddataframe) 
'data.frame':	5034 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-15" ...
 $ price: num  17.8 17.7 17.7 17.6 17.6 ... 

# Get the days of week and add to dateframe
spotpricefilleddataframe$day <- format(as.Date(spotpricefilleddataframe$date), "%A")

head(spotpricefilleddataframe)  
        date price       day
1 2010-05-14 17.75    Friday
2 2010-05-15 17.71  Saturday
3 2010-05-16 17.68    Sunday
4 2010-05-17 17.64    Monday
5 2010-05-18 17.61   Tuesday
6 2010-05-19 17.57 Wednesday 

# Where are the Saturdays ? use Logical indexing
idSat <- spotpricefilleddataframe$day == "Saturday"  
idSat
[1] FALSE FALSE  TRUE FALSE ....
# 5010 records
# leave out the Saturdays
spotpricefilleddataframe <- spotpricefilleddataframe[!idSat, ]

# Where are the Sundays ? logical indexing
idSun <- spotpricefilleddataframe$day == "Sunday"  
idSun
# leave out the Sundays
spotpricefilleddataframe <- spotpricefilleddataframe[!idSun, ] 

head(spotpricefilleddataframe)
       date price       day
1 2010-05-14 17.75    Friday
4 2010-05-17 17.64    Monday
5 2010-05-18 17.61   Tuesday
6 2010-05-19 17.57 Wednesday
7 2010-05-20 17.54  Thursday
8 2010-05-21 17.50    Friday 

str(spotpricefilleddataframe)
'data.frame':	3596 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ... 

# write the spot prices dataframe to a .csv file 
write.table(spotpricefilleddataframe, file = "spotpricesinfilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

## create rolling mean time series
# read in the infilled spot prices data if needed
#spotpricefilleddataframe <- read.csv("spotpricesinfilled.csv")
# confirm date format of date column if needed
#spotpricesinfilled[["date"]] <- as.Date(spotpricesinfilled[["date"]]) 

spot <- spotpricefilleddataframe[,1:2]
str(spot) 
'data.frame':	3596 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...

# write the spot prices dataframe to a .csv file 
# write.table(spot, file = "spotpricesinfilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

## Generic functions for computing rolling means, maximums, medians, and sums of ordered observations.

Usage
rollmean(x, k, fill = if (na.pad) NA, na.pad = FALSE, align = c("center", "left", "right"), ...)

# create 31 day (a month) rolling average
spot$spotroll31 <- rollmean(spot[["price"]], k =31,  fill = NA, align = c("center"))

str(spot) 
'data.frame':	3596 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...
 $ spotroll31: num  NA NA NA NA NA NA NA NA NA NA ... 
# round the rolling mean values to cents
spot$spotroll31 <- round(spot$spotroll31,2)

# create dataframe of only the 31 day rolling mean values and dates
spotrollmean31  <-spot[,c(1,3)] 
colnames(spotrollmean31) <- c("date","price") 
str(spotrollmean31) 
'data.frame':	3596 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  NA NA NA NA NA NA NA NA NA NA ...

# write the spot prices dataframe to a .csv file 
write.table(spotrollmean31, file = "spotrollmean31.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)  
 
# Draw ggplot2 plot, two dataframes spot and spotrollmean31 
3596 - (52 * 5)
3336
str(monthprice)
'data.frame':	166 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ...
plot(spot[["date"]][3336:3596],spot$price[3336:3596], type='n',col=4,lwd=1) 

points(spot[["date"]][3336:3596],spot$price[3336:3596],col = 4,pch=16,cex= 1) 
lines(spot[["date"]][3336:3596],spot$spotroll31[3336:3596],col = "#ED1A3B",lwd=1)  
points(monthprice[["date"]][154:166],monthprice$price[154:166],col = 1,pch=16,cex= 2) 
#lines(monthpricetimeseries,col=5, lwd=0.5)

format(spot[["date"]][1:100], "%Y")  
  [1] "2010" "2010" "2010" "2010" "2010" "2010" "2010" "2010" "2010" "2010"

format(spot[["date"]][3000:3546], "%Y")  
  [1] "2021" "2021" "2021" "2021" "2021" "2021" "2021" "2021" "2021" "2021"
 [11] "2021" "2021" "2021" "2021" "2021" "2021" "2021" "2021" "2021" "2021"  
 
format(spot[["date"]][3540:3546], "%b")

# This is a chart of the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year
svg(filename="NZU-spotpriceinfilled-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceinfilled-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotpricefilleddataframe, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2010 - 2024", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotpricefilleddataframe[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off() 

# This is a chart of the 31 day rolling mean of the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year
svg(filename="NZU-spotpriceinfilledrollingmean-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceinfilledrollingmean-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotrollmean31, aes(x = date, y = price)) +  geom_line(colour = 4) +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit rolling mean spot prices 2010 - 2024", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotrollmean31[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off() 

str(spotpricesinfilled)

str(spotpricealldatesmissingpriceszoo)
‘zoo’ series from 2010-05-14 to 2023-12-08
  Data: num [1:5025] 17.8 NA NA NA NA ...
  Index:  Date[1:5025], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

str(spotpricefilled)
‘zoo’ series from 2010-05-14 to 2023-12-08
  Data: num [1:5025] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5025], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ... 

# align right means that the 12 month periods start from the last month, align left means periods start from first month..
# average over 20 or 21 days is roughly the same as monthly given that the filled time series has a price for every week day i.e. 20 or 21 days per calendar month
  
## Graphs
# what is the most recent month? (maximum extent of date or x axis)
max(monthprice[["date"]]) 
[1] "2023-12-15" 

# This is the month data in a format closest to my preferred base R chart - it is in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year
svg(filename="NZU-monthprice-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-monthprice-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(monthprice, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit mean monthly prices 2010 - 2024", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(monthprice[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

# weekly mean prices x axis years annual
svg(filename="NZU-weeklypriceYr-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-weeklypriceYr-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(weeklypricefilleddataframe, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 12) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit mean weekly prices 2010 - 2024", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(weeklyprice[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

# spot price theme black and white  - bw
svg(filename="NZU-spotprice-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotprice-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotprices, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2010 - 2024", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotprices[["date"]]), y = min(spotprices[["price"]]), size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

## subset a dataframe of spot prices from 1/12/2023 to 24/11/2023
nrow(data)
[1] 1735
d2 <- data[1494:1735,1:2]

https://www.youtube.com/watch?v=DLn-gs626Ts 

https://www.carbonnews.co.nz/story.asp?storyID=26749
Price of carbon plummets in response to Cabinet rejection of Climate Change Commission recommendations
Friday 16 Dec 22 10:00am    By Jeremy Rose
Cabinet has ignored a Climate Change Commission recommendation to significantly increase the trigger price of the cost containment reserve and failed to reduce the number of credits available at auction by as much as the commission proposed. 
The decision, announced just after 5pm yesterday, has seen the price of carbon plummet on the secondary market from $86.00 at the close of trade yesterday to $75.00 as Carbon News goes to press.

https://www.carbonnews.co.nz/story.asp?storyID=28019
Carbon price plummets: what does ETS review mean for future prices? Thursday 22 Jun 23 10:30am
The carbon price on the secondary market has slumped to its lowest point since 2021 in the wake of the government’s ETS announcement, after rallying briefly following last week’s failed Emissions Trading Scheme auction.
# another vertical line at 22/06/2023
https://consult.environment.govt.nz/climate/nzets-review/ Opened 19 Jun 2023  
https://environment.govt.nz/news/nz-ets-review-consultation-now-closed/ New Zealanders were invited to have their say on a review of the design of the New Zealand Emissions Trading Scheme (NZ ETS) and its permanent forestry category. Last updated: 19 June 2023 
# reduce gross emissions or rely on forestry removals in ETS


svg(filename="NZU-spotprice2023-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotprice22023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(d2, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2022 - 2023", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(d2[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = as.numeric(19342),colour="blue",linetype ="dashed") +
annotate("text", x= d2[["date"]][12]-10, y = 2, size = 3, angle = 90, hjust = 0, label="16/12/2023 Cabinet rejects Commission ETS 2023 price recommendations") +
geom_vline(xintercept = as.numeric(d2[["date"]][111]),colour="blue",linetype ="dashed") +
annotate("text", x= d2[["date"]][111]-10, y = 2, size = 3, angle = 90, hjust = 0, label="19/06/2023 ETS gross emissions vs forestry removals consultation") +
geom_vline(xintercept = d2[["date"]][135], colour="blue",linetype ="dashed")    +
annotate("text", x= d2[["date"]][135]-10, y = 2, size = 3, angle = 90, hjust = 0, label="25/07/2023 ETS Prices & Settings 2024 announcement") 
dev.off()

https://www.etsauctions.govt.nz/public/auction_noticeboard      07/12/2022
d2[["date"]][5]
[1] "2022-12-07"            d2[["date"]][5]
https://environment.govt.nz/what-government-is-doing/areas-of-work/climate-change/ets/nz-ets-market/where-to-buy-new-zealand-emissions-units/#the-government-is-now-auctioning-nzus
Four auctions are scheduled for 2023, as shown below:
Date            Volume available*
15 March        4.475 million NZUs
d2[["date"]][53]
14 June         4.475 million NZUs
d2[["date"]][109]
6 September     4.475 million NZUs
d2[["date"]][166]
6 December      4.475 million NZUs
d2[["date"]][230]

svg(filename="NZU-auctions-2023-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-auctions-2023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(d2, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit auctions and spot prices 2023", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(d2[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = d2[["date"]][5] ,colour="blue",linetype ="dashed") +
annotate("text", x= d2[["date"]][5]+5, y = 2, size = 3, angle = 90, hjust = 0, label="7/12/2022 ETS Auction 4,825,000 units sold") +
geom_vline(xintercept = d2[["date"]][53] ,colour="blue",linetype ="dashed") +
annotate("text", x= d2[["date"]][53]+5, y = 2, size = 3, angle = 90, hjust = 0, label="15/03/2023 ETS Auction reserve not met") +
geom_vline(xintercept = as.numeric(d2[["date"]][109]),colour="blue",linetype ="dashed") +
annotate("text", x= d2[["date"]][109]+5, y = 2, size = 3, angle = 90, hjust = 0, label="14/06/2023 ETS Auction reserve not met") +
geom_vline(xintercept = d2[["date"]][166], colour="blue",linetype ="dashed")    +
annotate("text", x= d2[["date"]][166]+5, y = 2, size = 3, angle = 90, hjust = 0, label="25/09/2023 ETS Auction reserve not met") + 
geom_vline(xintercept = d2[["date"]][230], colour="blue",linetype ="dashed")    +
annotate("text", x= d2[["date"]][230]+5, y = 2, size = 3, angle = 90, hjust = 0, label="6/12/2023 ETS Auction reserve not met") 
dev.off()
--------------------------------------------------------------------------
xts 
str(weeklyprice)
'data.frame':	616 obs. of  3 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ...
 $ week : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1 
  
# create an xts timeseries from the weekly mean prices dataframe
weeklyprice_ts <- xts(weeklyprice$price, weeklyprice$date)
# look at first 6 rows of time series
head(weeklyprice_ts)
            [,1]
2010-05-10 17.75
2010-05-17 17.50
2010-05-24 17.50
2010-06-07 17.00
2010-06-21 17.75
2010-06-28 17.50 

# create an xts format (irregular) timeseries from the spot prices dataframe
spotpricexts <- xts(spotprices$price, spotprices$date)
str(spotpricexts) 
An xts object on 2010-05-14 / 2023-12-22 containing: 
  Data:    double [1735, 1]
  Index:   Date [1735] (TZ: "UTC")

# create a XTS plot from the spot price 'xts' object

svg(filename="NZU-spotXTStimeseriesprices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
plot(spotpricexts,type='l',lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit spot prices")
dev.off()

# create a XTS plot from the weekly 'xts' object

svg(filename="NZU-weeklyXTStimeseriesprices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
plot(weeklyprice_ts,type='l',las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit mean weekly spot prices")
dev.off()

svg(filename="NZU-spotprices2023-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpricexts['2023'],ylim=c(0,77),lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit 2023 spot prices")
dev.off()
# plot without specifying 0 as y axis limit
svg(filename="NZU-spotprices2023a-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpricexts['2023'], lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit 2023 spot prices")
dev.off()
# create July to Nov 2023 prices xts matrix
spotpricextsJulyNov <- spotpricexts[c('2023-07','2023-08','2023-09','2023-10','2023-11')]
# create aug to Dec  Nov 2023 prices xts matrix
spotpricextsAugNov <- spotpricexts[c('2023-08','2023-09','2023-10','2023-11','2023-12')]
# ,ylim=c(0,75)
svg(filename="NZU-spotpricesAug2023-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpricextsAugNov,lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit Aug Nov 2023 spot prices")
dev.off()

svg(filename="NZU-spotpricesAug2023a-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpricextsAugNov,lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit August to Dec2023 spot prices")
#abline(v = as.numeric(index(spotpricextsAugNov[54] )),col = 4,lwd =2,lty =2)  # didn't work
dev.off()

spotpriceAugNovdataframe <- as.data.frame(spotpricextsAugNov)  
str(spotpriceAugNovdataframe) 
'data.frame':	87 obs. of  1 variable:
 $ V1: num  59.8 57.5 57 58 58 ...  
head(rownames(spotpriceAugNovdataframe)) 
[1] "2023-08-01" "2023-08-02" "2023-08-03" "2023-08-04" "2023-08-07"
[6] "2023-08-08" 
head(spotpriceAugNovdataframe[,1]) 
[1] 59.75 57.50 57.00 58.00 58.00 59.90

spotpriceAugNovdataframe1 <- data.frame(date = rownames(spotpriceAugNovdataframe),price = spotpriceAugNovdataframe[,1]) 
str(spotpriceAugNovdataframe1 ) 
'data.frame':	87 obs. of  2 variables:
 $ date : chr  "2023-08-01" "2023-08-02" "2023-08-03" "2023-08-04" ...
 $ price: num  59.8 57.5 57 58 58 ... 

svg(filename="NZU-spotpricesAug2023c-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpriceAugNovdataframe1,type='l',lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit Aug Nov 2023 spot prices")
abline(v = 19643,col = 4,lwd =2,lty =2) 
dev.off()
ls()

svg(filename="NZU-spotpricesxts2010-2023-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpricexts,type='l',lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit spot prices")
dev.off()

dim(spotpricexts)
[1] 1718    1 
plot(spotpricexts[1600:1718])
str(spotpricextsJulynov)
An xts object on 2023-07-03 / 2023-11-29 containing: 
  Data:    double [105, 1]
  Index:   Date [105] (TZ: "UTC") 
max(spotpricextsJulynov)

plot(spotpricextsJulynov,ylim=c(0,75), col="#F32424",lwd=1)
spotpricexts[1595:1596]
            [,1]
2023-06-01 54.75
2023-06-02 55.00

# weekly infilled by interpolation time series price chart in Base R, 720 by 540,  
svg(filename="NZU-week-time-series-prices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(weekts,tck=0.01,axes=TRUE,ann=TRUE, las=1,col="#F32424",lwd=2,type='l',lty=1) # color is Pomegranate not 'red'.
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.9,line=-1.3,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.2, line=-2.2,expression(paste("New Zealand Unit mean weekly spot prices 2010 - 2023")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()  
ls()
user@wgtnadmin:~
$ uname -a && lsb_release -a


str(spotpricealldatesmissingprices)
'data.frame':	4971 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-15" ...
 $ price: num  17.8 NA NA NA NA ...
str(spot)
'data.frame':	3551 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...
 $ spotroll31: num  NA NA NA NA NA NA NA NA NA NA ...

str(spotpricefilleddataframe)
'data.frame':	3551 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ... 
spotpricefilleddataframe <- spotpricefilleddataframe[,c(1:2)]
str(spot)
'data.frame':	3551 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ... 
str(monthprice) 
'data.frame':	164 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 .. 
str(spotrollmean31) 
'data.frame':	3551 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  NA NA NA NA NA NA NA NA NA NA ... 
str(spotpricefilleddataframe)
'data.frame':	3551 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ... 
 
# Base R graph of prices series
svg(filename="NZU-ts-price-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spotpricefilleddataframe[["date"]], spotpricefilleddataframe[["price"]] ,tck=0.01,axes=TRUE,ann=TRUE, las=1,col="#9F116D",lwd=0.5,type='l',lty=1) #ED1A3B" = crimson #9F116D = purple
grid(col="darkgray",lwd=1)
points(monthprice[["date"]],monthprice[["price"]],pch=16,cex=0.25)
lines(spotrollmean31[["date"]],spotrollmean31[["price"]],lwd=0.5)
lines(spot[["date"]],spot[["price"]],lwd=0.5, col="#ED1A3B")

axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Mean Monthly Unit Prices 2010 - 2023")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

spotall <- rbind( spotrollmean31, spotpricefilleddataframe)
str(spotall) 

# most basic line chart code from help file geom_line
ggplot(spotpricealldatesmissingprices, aes(date, price)) + geom_line() +
geom_line(aes(yintercept = h_line, )) +

str(spotpricealldatesmissingprices)
'data.frame':	4971 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-15" ...
 $ price: num  17.8 NA NA NA NA ... 
 
# geom_path lets you explore how two variables are related over time,
# e.g. unemployment and personal savings rate
m <- ggplot(economics, aes(unemploy/pop, psavert))
m + geom_path()
m + geom_path(aes(colour = as.numeric(date)))

ggplot(spot, aes(x=date, y = price)) +  geom_line(colour = "#ED1A3B", linewidth=0.5) + 
geom_line(aes( x=date ,y = spotroll31), color = "black", linetype = "dotted", linewidth=0.5) 
geom_line(aes( x=date ,y = spotroll31), color = "steelblue", linetype = "twodash", linewidth=0.5) 

# chart of zoo object "spotpricefilled"
svg(filename="spotpricefilled-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotpricefilled-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spotpricefilled,tck=0.01,axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 
