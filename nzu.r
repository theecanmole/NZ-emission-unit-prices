nzu.r

https://github.com/edi-rose/nzu-fork

# remember to "find and replace" "-" with "/" (replace short dashs with backslashs in the csv file "nzu-edited-raw-prices-data.csv"

# change directory in an xterminal run "python3 api.py"

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
[1] 1926    5
str(data) 
'data.frame':	1921 obs. of  5 variables:
 $ V1: chr  "2010/05/14" "2010/05/21" "2010/05/29" "2010/06/11" ...
 $ V2: chr  "17.75" "17.5" "17.5" "17" ...
 $ V3: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ V4: chr  "2010/05/01" "2010/05/01" "2010/05/01" "2010/06/01" ...
 $ V5: chr  "2010/W19" "2010/W20" "2010/W21" "2010/W23" ...

# after the Python script is run, the last row is the what used to be the column headers 

# look at that last 3 rows again
tail(data,3)
             V1    V2                                                   V3
1924 2024/10/03 62.84 https://www.carbonnews.co.nz/story.asp?storyID=32750
1925 2024/10/04 63.10 https://www.carbonnews.co.nz/story.asp?storyID=32763
1926       date price                                            reference
          V4       V5
1924 2024-10 2024-W40
1925 2024-10 2024-W40
1926   month     week

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

# change formats of date column and price column
data$date <- as.Date(data$date)
data$price <- as.numeric(data$price)

# add month variable/factor to data
data$month <- as.factor(format(data$date, "%Y-%m"))
# create dataframe of only the spot prices
spotprices <- data[,1:2]
str(spotprices) 
'data.frame':	1925 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 
# write the spot prices dataframe to a .csv file 
write.table(spotprices, file = "spotprices.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 
#spotprices <- read.csv("spotprices.csv")

## load package aweek which deals with week  
# Kamvar Z (2022). _aweek: Convert Dates to Arbitrary Week Definitions_. R package version 1.0.3, <https://CRAN.R-project.org/package=aweek>
library("aweek")
# make aweek vector (with Monday being day 1 - the default) from date format column and overwrite contents of week column   
data$week <- as.aweek(data$date) 
str(data) 
'data.frame':	1925 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 174 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
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
'data.frame':	174 obs. of  2 variables:
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
'data.frame':	657 obs. of  3 variables:
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
[1] 752 
# How many weeks were there in weekly prices dataframe which omits the weeks with missing prices?
nrow(weeklyprice)
[1] 657

# How many weeks will need to be filled since May 2010
length(weeklypriceallDates) - nrow(weeklyprice)
[1] 95

# create dataframe of all the weeks with missing weeks of prices added as price = NA
weeklypricemissingprices <- merge(x= data.frame(date = weeklypriceallDates),  y = weeklyprice,  all.x=TRUE)
# check dataframes
str(weeklypricemissingprices)
'data.frame':	752 obs. of  3 variables:
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
‘zoo’ series from 2010-05-10 to 2024-04-01
  Data: num [1:751] 17.8 17.5 17.5 NA 17 ...
  Index:  Date[1:751], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...
# look at first nine values/dates
head(weeklypricemissingpriceszoo,9)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 2010-06-21 
     17.75      17.50      17.50         NA      17.00         NA      17.75 
2010-06-28 2010-07-05 
     17.50      18.00 

# calculate the missing values with zoo na.approx which uses linear interpolation to fill in the NA values     
head(na.approx(weeklypricemissingpriceszoo))
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 2010-06-21 
   17.7500    17.5000    17.5000    17.2500    17.0000    17.3750    17.7500 
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
# check the new object
str(weeklypricefilled)
‘zoo’ series from 2010-05-10 to 2024-04-11
  Data: num [1:752] 17.8 17.5 17.5 17.2 17 ...
  Index:  Date[1:752], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...
  
# Convert  the zoo vector to a data frame
weeklypricefilleddataframe <- data.frame(date=index(weeklypricefilled),price = coredata(weeklypricefilled))   
# check dataframe 
str(weeklypricefilleddataframe) 
'data.frame':	752 obs. of  2 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 17.2 17 ...

# look at first 6 values 
head(weeklypricefilleddataframe) 
           weeklypricefilled
2010-05-10            17.750
2010-05-17            17.500
2010-05-24            17.500
2010-05-31            17.250
2010-06-07            17.000
2010-06-14            17.375
 
# write the infilled mean price per week dataframe to a .csv file 
write.table(weeklypricefilleddataframe, file = "weeklypricefilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# create a time series object for average monthly prices
weekts <- ts(weeklypricefilleddataframe[["price"]],frequency=52,start = c(2010,19))
# check the time series
str(weekts) 
Time-Series [1:752] from 2010 to 2024: 17.8 17.5 17.5 17.2 17 ... 

# check the dataframe again
str(data) 
'data.frame':	1925 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 174 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
 $ week     : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1
# Create a .csv formatted data file
write.csv(data, file = "nzu-final-prices-data.csv", row.names = FALSE)

# check the structure of the average monthly price data
str(monthprice) 
'data.frame':	174 obs. of  2 variables:
 $ date : Date, format: "2010-05-01" "2010-06-01" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ... 

# create svg format chart with 14 pt text font and grid lines via 'grid'
# Convert the data frame price and date columns to a zoo time series object,
monthpricezoo <- zoo(monthprice[["price"]], monthprice[["date"]])
# [["date"]],monthprice[["price"]]
# create chart - its the same as chart of dataframe of date and price
svg(filename="NZUpriceZoo-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthpricezoo,tck=0.01,xlab="",ylab="",ann=TRUE, las=1,col='red',lwd=1,type='l',lty=1)
points(monthpricezoo,col='red',pch=19,cex=0.5)
#grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("New Zealand Unit mean month prices 2010 - 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

# create a time series object for average monthly prices chart
monthts <- ts(monthprice[["price"]],frequency=12,start = c(2010,5))
monthts
monthzoo <- zoo(x = monthprice[["price"]], order.by = monthprice[["date"]])
str(monthpricezoo) 
‘zoo’ series from 2010-05-15 to 2024-10-15
  Data: num [1:174] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  Date[1:174], format: "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" "2010-09-15" ... 

# chart
svg(filename="NZUprice-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthpricezoo,tck=0.01,xlab="",ylab="",ann=TRUE, las=1,col='red',lwd=1,type='l',lty=1)
points(monthpricezoo,col='red',pch=19,cex=0.5)
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("New Zealand Unit prices 2010 - 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

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
'data.frame':	1925 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 

# How many days of dates should be included if there were prices for all days from May 2010 to today?
spotpricealldates <- seq.Date(min(spotprices$date), max(spotprices$date), "day")
length(spotpricealldates) 
[1] 5258
# how many missing values are there?
length(spotpricealldates) - nrow(spotprices) 
[1] 3333

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
‘zoo’ series from 2010-05-14 to 2024-04-05
  Data: num [1:5258] 17.8 NA NA NA NA ...
  Index:  Date[1:5258], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...
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
‘zoo’ series from 2010-05-14 to 2024-08-30
  Data: num [1:5258] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5258], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

# Create a data frame from the zoo vector
spotpricefilleddataframe <- data.frame(date=index(spotpricefilled),price= coredata(spotpricefilled))   

head(spotpricefilleddataframe) 
        date price
1 2010-05-14 17.75
2 2010-05-15 17.71
3 2010-05-16 17.68
4 2010-05-17 17.64
5 2010-05-18 17.61
6 2010-05-19 17.57

str(spotpricefilleddataframe) 


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
tail(spotpricefilleddataframe)
           date price       day
5251 2024-09-27 62.23    Friday
5254 2024-09-30 62.40    Monday
5255 2024-10-01 62.17   Tuesday
5256 2024-10-02 62.43 Wednesday
5257 2024-10-03 62.84  Thursday
5258 2024-10-04 63.10    Friday

str(spotpricefilleddataframe)
'data.frame':	3756 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ...

# write the spot prices dataframe to a .csv file 
write.table(spotpricefilleddataframe, file = "spotpricesinfilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

## create rolling mean time series

# read in the infilled spot prices data if needed
spotpricefilleddataframe <- read.csv("spotpricesinfilled.csv",colClasses = c("Date","numeric"))
# confirm date format of date column if needed
#spotpricesinfilled[["date"]] <- as.Date(spotpricesinfilled[["date"]]) 

spotfilled <- spotpricefilleddataframe[,1:2]
str(spotfilled) 
'data.frame':	3756 obs. of  2 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...

# write the spot prices dataframe to a .csv file 
write.table(spotfilled, file = "spotpricesinfilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 


## Generic functions for computing rolling means, maximums, medians, and sums of ordered observations.

Usage
rollmean(x, k, fill = if (na.pad) NA, na.pad = FALSE, align = c("center", "left", "right"), ...)

spot <- read.csv(file = "spotpricesinfilled.csv", colClasses = c("Date","numeric"))

# create 21 day (a month) rolling average
spot$spotroll31 <- rollmean(spot[["price"]], k =21,  fill = NA, align = c("center"))

str(spot) 
'data.frame':	3756 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...
 $ spotroll31: num  NA NA NA NA NA NA NA NA NA NA ... 
# round the rolling mean values to cents
spot$spotroll31 <- round(spot$spotroll31,2)

# create dataframe of only the 21 day rolling mean values and dates
spotrollmean31  <-spot[,c(1,3)] 
colnames(spotrollmean31) <- c("date","price") 
# examine dataframe
str(spotrollmean31) 
'data.frame':	3756 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  NA NA NA NA NA NA NA NA NA NA ...

# write the spot prices dataframe to a .csv file 
write.table(spotrollmean31, file = "spotrollmean31.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)  
 
# Draw ggplot2 plot, two dataframes spot and spotrollmean31 

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

table(format(spot[["date"]], "%Y")) 

2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 
 166  260  261  261  261  261  261  260  261  261  262  261  260  260  200

# select 2024 infilled spot prices
spot2024 <- spotfilled[spotfilled$date > as.Date("2024-01-01"),1:2]
str(spot2024) 
'data.frame':	199 obs. of  2 variables:
 $ date : Date, format: "2024-01-02" "2024-01-03" ...
 $ price: num  69.6 69.7 71 70 70 ...

# This is a chart of the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year
svg(filename="NZU-spotpriceinfilled2024-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceinfilled2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
#png("NZU-spotpriceinfilled2024-540by405-ggplot-theme-bw.png", bg="white", width=540, height=405)
ggplot(spot2024, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") + geom_point(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80,90))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2024", x ="2024", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spot2024[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off() 

dim(spot2024)
[1] 199   2

# second chart of 2024 unit prices after 15 March & 19 June 2024 auction
# 19/06/2024 auction https://www.etsauctions.govt.nz/public/auction_noticeboard/52
# what x axis value for the 19 June auction?  
as.numeric(as.Date("2024-06-19"))
[1] 19893
# what is x axis value for 21 August 2024, the date of announcement of ets price & settings update? https://www.beehive.govt.nz/release/updated-settings-restore-ets-market-confidence https://environment.govt.nz/what-government-is-doing/areas-of-work/climate-change/ets/nz-ets-market/annual-updates-to-emission-unit-limits-and-price-control-settings/
as.numeric(as.Date("2024-08-21"))
[1] 19956 

svg(filename="spotprice2024c-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotprice2024c-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spot2024,ylim=c(40,85),tck=0.01,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
abline(v=19802,col='blue',lwd=2,lty=2)
abline(h=64,col='blue',lwd=2,lty=2)
points(spot2024[1:53,],col="red",pch=16)
points(spot2024[54:nrow(spot2024),],col="red",pch=16)
text(19820,62,cex=0.85,expression(paste("$64 NZU auction reserve price 2024")) )
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.2, line=-2.8,expression(paste("The August ETS settings update bumped the NZU price\nbut the spot prices are still less than the 2024 auction reserve price")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
text(19802,48,cex=0.9, labels = "Auction\n15 March")
# what x axis value for the 19 June auction?  as.numeric(as.Date("2024-06-19"))  [1] 19893 
abline(v=19893,col='blue',lwd=2,lty=2)
text(19893,45,cex=0.9, labels = "Auction\n19 June")
abline(v=19956,col='blue',lwd=2,lty=2)
text(19956,60,adj=1,cex=0.9, labels = "Annual update ETS settings\n21 Aug")
dev.off()

head(spotrollmean31,25)
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


# align right means that the 12 month periods start from the last month, align left means periods start from first month..
# average over 20 or 21 days is roughly the same as monthly given that the filled time series has a price for every week day i.e. 20 or 21 days per calendar month
  
## Graphs

# This is the month data in a format closest to my preferred base R chart - it is in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year

svg(filename="NZU-monthprice-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-monthprice-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(monthprice, aes(x = date, y = price)) +  
geom_line(colour = "#ED1A3B") + 
#geom_point(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit mean monthly prices 2010 - 2024", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(monthprice[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

 # "#D55E00" is  Vermillion

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
ggplot(spotprices, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B", linewidth = 0.5) +
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
[1] 1805
d2 <- data[1494:1735,1:2]
str(d2)
'data.frame':	242 obs. of  2 variables:
 $ date : Date, format: "2022-12-01" "2022-12-02" ...
 $ price: num  83.5 82.5 81 81 82 ... 

d3 <- data[nrow(data)-313:nrow(data),1:2]
str(d3) 
'data.frame':	1479 obs. of  2 variables:
 $ date : Date, format: "2022-11-10" "2022-11-09" ...
 $ price: num  88.2 87.1 86.5 85 85 ... 
 
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
"#ED1A3B"   # crimson
"#D55E00"  # Vermillion

#svg(filename="NZU-spotprice2023-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
png("NZU-spotprice22023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(d2, aes(x = date, y = price)) +  geom_line(colour = "#CC79A7") +  # reddishpurple
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
## just 9 months

svg(filename="NZU-spotprice2024-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotprice2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(d3, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B",size = 1) + 
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2023 - 2024", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(d3[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) 
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
png("NZU-auctions-2023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
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


svg(filename="NZU-spotpricesAug2023c-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpriceAugNovdataframe1,type='l',lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit Aug Nov 2023 spot prices")
abline(v = 19643,col = 4,lwd =2,lty =2) 
dev.off()
ls()

# weekly infilled by interpolation time series price chart in Base R, 720 by 540,  
svg(filename="NZU-week-time-series-prices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(weekts,tck=0.01,axes=TRUE,ann=TRUE, las=1,col="#F32424",lwd=2,type='l',lty=1) # color is Pomegranate not 'red'.
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.9,line=-1.3,"Data: 'NZU prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.2, line=-2.2,expression(paste("New Zealand Unit mean weekly spot prices 2010 - 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 

length(weekts) 
745
plot(weekts,col='blue')

ls()
user@wgtnadmin:~
$  uname -a && lsb_release -a


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
#points(monthprice[["date"]],monthprice[["price"]],pch=19,col=1,cex=1)   # "#9F116D"
lines(spotrollmean31[["date"]],spotrollmean31[["price"]],lwd=0.5,col=4)
lines(spot[["date"]],spot[["price"]],lwd=0.5, col="#ED1A3B")
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit (NZU) spot prices 2010 - 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

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

=================================================
library("xts")
getwd()
[1] "/home/user/R/nzu/nzu-fork-master/apipy"

monthprice <- read.csv("nzu-month-price.csv", colClasses = c("Date","numeric"))
spotprices <- read.csv("spotprices.csv", colClasses = c("Date","numeric"))
spotrollmean31 <- read.csv("spotrollmean31.csv", colClasses = c("Date","numeric"))  
str(spotprices)
'data.frame':	1905 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ...length
 
# create zoo time series object
monthzoo <- zoo(monthprice[["price"]], order.by = monthprice[["date"]])
str(monthzoo)
‘zoo’ series from 2010-05-15 to 2024-03-15
  Data: num [1:173] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  Date[1:173], format: "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" "2010-09-15" ...

spotzoo <- zoo(spotprices[["price"]], order.by = spotprices[["date"]])
str(spotzoo)
‘zoo’ series from 2010-05-14 to 2024-09-06
  Data: num [1:1905] 17.8 17.5 17.5 17 17.8 ...
  Index:  chr [1:1905] "2010-05-14" "2010-05-21" "2010-05-29" "2010-06-11" ...


rollmeanzoo <- zoo(spotrollmean31[["price"]], order.by = spotrollmean31[["date"]])

spotzoo20March <- zoo(64, order.by = as.Date("2024/03/10"))  

str(spotzoo20March) 
‘zoo’ series from 2024-03-10 to 2024-03-10
  Data: num 64
  Index:  Date[1:1], format: "2024-03-10" 
  
plot(spotzoo)  # zoo uses Base R plot just like for 'ts' object

# Select all of 2016 from xts
plot(spotzoo,ylab="$NZD",main="NZU spot prices",col='2')
lines(monthzoo)
# select ALL 2024 spot prices including 15 March auction
spot2024 <- spotprices[1738:nrow(spotprices),] 
str(spot2024) 
'data.frame':	92 obs. of  2 variables:
 $ date : Date, format: "2023-12-29" "2024-01-03" ...
 $ price: num  69.2 69.7 71 70 70 ... 
 
# check prices after auction
spotprices[1791:1805,]

# the prices after the auction
spot2024b[54:68,]
# the auction date
spot2024b[50:50,]
           date price
1787 2024-03-15    65
spot2024b[50:54,]
           date price
1787 2024-03-15  65.0
1788 2024-03-18  64.5
1789 2024-03-19  65.2
1790 2024-03-20  65.4
1791 2024-03-21  51.0 
as.numeric(as.Date(2024-03-20))
# col="#CD0BBC"



str(auction)
Date[1:1], format: "2024-03-15"

points(64,
as.numeric(as.Date("2024-03-20"))
[1] 19802


lastyear <- last(spotzoo, "1 year")
lastyear
2024-01-03 2024-01-04 2024-01-05 2024-01-08 2024-01-09 2024-01-10 2024-01-11 
     69.74      71.00      70.00      70.00      68.85      69.00      69.00 
2024-01-12 2024-01-15 2024-01-16 2024-01-17 2024-01-22 2024-01-23 2024-01-24 
     67.70      67.50      67.85      67.50      68.00      68.00      69.00 
2024-01-25 2024-01-26 2024-01-29 2024-01-30 2024-01-31 2024-02-01 2024-02-02 
     71.00      70.70      70.90      71.25      71.45      73.85      73.70 
2024-02-05 2024-02-07 2024-02-08 2024-02-09 2024-02-12 2024-02-13 2024-02-14 
     73.25      73.15      72.70      72.45      72.40      72.15      71.70 
2024-02-15 2024-02-16 2024-02-19 2024-02-20 2024-02-21 2024-02-22 2024-02-23 
     71.45      69.75      69.25      69.25      69.25      66.50      67.00 
2024-02-26 2024-02-27 2024-02-28 2024-03-01 2024-03-04 2024-03-05 2024-03-06 
     67.50      67.15      66.50      66.75      66.25      66.05      67.25 
2024-03-07 2024-03-08 
     68.70      69.00  
plot(last(spotzoo, "2 years"),ylab="$NZD",las=1,main="NZU spot price 2023 2024",col='2')
points(last(monthzoo, "2 years"),col='4',pch=19,cex=1.2)
lines(last(rollmeanzoo, "2 years"),col='red')

plot(lastyear,ylab="$NZD",las=1,main="NZU spot price 2024",col='2')

lastyears <- last(spotzoo, "2 year")
plot(lastyears,ylab="$NZD",las=1,main="NZU spot price 2024",col='2')

# chart of zoo object "lastyears"
svg(filename="spotprice2023-2024-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
png("spotprice2023-2024-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(lastyear,ylim=c(0,75),tck=0.01,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
points(spotzoo20March,pch=21)
abline(h=64)
points(64,19792,pch=21,col='navyblue')
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices 2023 to 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 

# Convert the data frame price and date columns to a zoo time series object

help(zoo)

mpzoo <- zoo(x = monthprice[["price"]], order.by = monthprice[["date"]]) 

head(mpzoo) 
2010-05-15 2010-06-15 2010-07-15 2010-08-15 2010-09-15 2010-10-15 
     17.58      17.42      18.15      18.35      20.10      19.96  
str(mpzoo) 
‘zoo’ series from 2010-05-15 to 2024-09-15
  Data: num [1:173] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  Date[1:173], format: "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" "2010-09-15" ...
dim(mpzoo) 
NULL
class(mpzoo) 
[1] "zoo" 
plot(mpzoo)
# plots normal
is.regular(mpzoo)
[1] TRUE

x.date <- as.Date(paste(2003, rep(1:4, 4:1), seq(1,20,2), sep = "-"))
x.date
 [1] "2003-01-01" "2003-01-03" "2003-01-05" "2003-01-07" "2003-02-09"
 [6] "2003-02-11" "2003-02-13" "2003-03-15" "2003-03-17" "2003-04-19"
x <- zoo(matrix(rnorm(20), ncol = 2), x.date)
is.regular(x)
[1] TRUE
class(x)
[1] "zoo"
x
                                  
2003-01-01 -0.71391489  0.36274121
2003-01-03  1.00630630  0.83758712
2003-01-05 -0.23471288 -1.24647375
2003-01-07  0.63132063  0.08370262
2003-02-09  0.04500258  0.21896533
2003-02-11  0.38634313  1.57832734
2003-02-13 -0.67001484  0.17954204
2003-03-15  1.30217347  1.25151833
2003-03-17  1.77797084 -1.12360919
2003-04-19  0.18213480 -0.47228130
coredata(x)
             [,1]        [,2]
 [1,] -0.71391489  0.36274121
 [2,]  1.00630630  0.83758712
 [3,] -0.23471288 -1.24647375
 [4,]  0.63132063  0.08370262
 [5,]  0.04500258  0.21896533
 [6,]  0.38634313  1.57832734
 [7,] -0.67001484  0.17954204
 [8,]  1.30217347  1.25151833
 [9,]  1.77797084 -1.12360919
[10,]  0.18213480 -0.47228130

spotzoo <- zoo(x = spotprices[["price"]], order.by = spotprices[["date"]]) 
head(spotzoo) 
2010-05-14 2010-05-21 2010-05-29 2010-06-11 2010-06-25 2010-06-30 
     17.75      17.50      17.50      17.00      17.75      17.50 
class(spotzoo)
[1] "zoo" 
str(spotzoo)
‘zoo’ series from 2010-05-14 to 2024-09-06
  Data: num [1:1910] 17.8 17.5 17.5 17 17.8 ...
  Index:  Date[1:1910], format: "2010-05-14" "2010-05-21" "2010-05-29" "2010-06-11" "2010-06-25" ... 
is.ts(spotzoo) 
[1] FALSE 
is.xts(spotzoo) 
[1] FALSE
is.zoo(spotzoo) 
[1] TRUE 
spotxts <- xts(x = spotprices[["price"]], order.by = spotprices[["date"]]) 
str(spotxts) 
An xts object on 2010-05-14 / 2024-09-06 containing: 
  Data:    double [1905, 1]
  Index:   Date [1905] (TZ: "UTC") 
head(spotxts) 
            [,1]
2010-05-14 17.75
2010-05-21 17.50
2010-05-29 17.50
2010-06-11 17.00
2010-06-25 17.75
2010-06-30 17.50 
colnames(spotxts)
  
help(ts)  
# chart of zoo object "spotprice" the irregular series
svg(filename="spotprice-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotprice-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spotzoo,tck=0.01,axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 
help(xts)

# chart of xts object "spotprice" the irregular series
plot(spotxts,tck=0.01,axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="Date",ylab="$NZD")

svg(filename="spotpricexts-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotprice-560by420.png", bg="white", width=560, height=420,pointsize = 14)
#par(mar=c(2.7,2.7,1,1)+0.1)
plot(spotxts,tck=0.01,axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="SNZD")
dev.off() 

help(xts)

zoo2024 <- last(spotzoo, "1 year")
zoo2024[1:2,]
2024-01-03 2024-01-04 
     69.74      71.00  
str(zoo2024)
‘zoo’ series from 2024-01-03 to 2024-09-06
  Data: num [1:167] 69.7 71 70 70 68.8 ...
  Index:  Date[1:167], format: "2024-01-03" "2024-01-04" "2024-01-05" "2024-01-08" "2024-01-09" ...  

svg(filename="spotprice2024-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotprice2024-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(zoo2024,tck=0.01,ylim=c(0,75),axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 

zoo2023_2024 <- last(spotzoo, "2 years") 
plot(zoo2023_2024,tck=0.01,ylim=c(0,75),axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices 2023 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)

help(xts)

# the beginning of the data through 2007
ls() 
str(spotxts) 
An xts object on 2010-05-14 / 2024-09-06 containing: 
  Data:    double [1905, 1]
  Index:   Date [1905] (TZ: "UTC") 
spotxts2zoo <- Reclass(spotxts)
str(spotxts2zoo) 
An xts object on 2010-05-14 / 2024-09-06 containing: 
  Data:    double [1905, 1]
  Index:   Date [1905] (TZ: "UTC") 
head(spotxts2zoo) 
            [,1]
2010-05-14 17.75
2010-05-21 17.50
2010-05-29 17.50
2010-06-11 17.00
2010-06-25 17.75
2010-06-30 17.50  
 
class(spotxts2zoo) 
[1] "xts" "zoo"  
is.zoo(spotxts2zoo) 
[1] TRUE
is.xts(spotxts2zoo) 
[1] TRUE
plot(spotxts2zoo) 
# plots the same as xts  

head(spotzoo)
2010-05-14 2010-05-21 2010-05-29 2010-06-11 2010-06-25 2010-06-30 
     17.75      17.50      17.50      17.00      17.75      17.50 
tail(spotzoo)
2024-09-06 2024-09-09 2024-09-10 2024-09-11 2024-09-12 2024-09-13 
     61.83      61.25      61.72      61.83      61.80      61.49 
dim(spotzoo)
NULL
spotzoo[1:100]
2010-05-14 2010-05-21 2010-05-29 2010-06-11 2010-06-25 2010-06-30 2010-07-09 
     17.75      17.50      17.50      17.00      17.75      17.50      18.00 
     
str(spotzoo)
‘zoo’ series from 2010-05-14 to 2024-09-13
  Data: num [1:1910] 17.8 17.5 17.5 17 17.8 ...
  Index:  Date[1:1910], format: "2010-05-14" "2010-05-21" "2010-05-29" "2010-06-11" "2010-06-25" ...
summary(spotzoo)
     Index               spotzoo     
 Min.   :2010-05-14   Min.   : 1.60  
 1st Qu.:2018-01-31   1st Qu.:20.63  
 Median :2020-05-20   Median :28.91  
 Mean   :2019-10-26   Mean   :38.28  
 3rd Qu.:2022-08-31   3rd Qu.:61.79  
 Max.   :2024-09-13   Max.   :88.50   

plot(spotzoo[1700:1910,1])
# what dates are the last day of 2023 and first price of 2024?
spotzoo[1738:1739,1]
2023-12-29 2024-01-03 
     69.15      69.74

plot(spotzoo[1400:1514,1])     
