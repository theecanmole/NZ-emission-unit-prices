## New Zealand Unit spot prices from 2010 to 2025.

Theecanmole. (2025). [Data set] https://github.com/theecanmole/NZ-emission-unit-prices/blob/main/ spotpricesinfilled.csv

# remember to "find and replace" "-" with "/" (replace short dashs with backslashs in the dates in the csv file "nzu-edited-raw-prices-data.csv"

# change directory in an xterminal run "python3 api.py"
# user@mx:~/R/nzu/nzu-fork-master/apipy
$ python3 api.py

# the csv file "nzu-edited-raw-prices-data.csv" is the output of 'api.py'

# "nzu-edited-raw-prices-data.csv" has the column headers ("date" "price" "reference" "month" "week") as the last row and not the first row.

# load package Ggplot2 for graphs and zoo for matrix time series
library("ggplot2")
library("zoo")
# check my current working folder
getwd()
"/home/user/R/nzu/nzu-fork-master/apipy"
setwd("/home/user/R/nzu/nzu-fork-master/apipy")  # if needed

# read in data  reading the .csv file specifying header status as false
data <- read.csv("nzu-edited-raw-prices-data.csv",header=FALSE)

dim(data)
[1] 2160    5
str(data) 
'data.frame':	2160 obs. of  5 variables:
 $ V1: chr  "2010/05/14" "2010/05/21" "2010/05/29" "2010/06/11" ...
 $ V2: chr  "17.75" "17.5" "17.5" "17" ...
 $ V3: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ V4: chr  "2010/05/01" "2010/05/01" "2010/05/01" "2010/06/01" ...
 $ V5: chr  "2010/W19" "2010/W20" "2010/W21" "2010/W23" ...

# after the Python script is run, the last row is the what used to be the column headers 

# look at that last 3 rows again
tail(data,3)

# convert the last row to a character vector and  add column names as character formatted last row cells
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

# check the dataframe again
str(data) 
'data.frame':	2159 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 188 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
 $ week     : chr  "2010/W19" "2010/W20" "2010/W21" "2010/W23" ...

tail(data$week)

# Are there any NAs in the date column?
summary(data$date)
        Min.      1st Qu.       Median         Mean      3rd Qu.         Max.
"2010-05-14" "2018-05-12" "2021-01-14" "2020-06-13" "2023-07-11" "2025-12-19"
# No

# Create a .csv formatted data file
write.csv(data, file = "nzu-final-prices-data.csv", row.names = FALSE)

# create dataframe of only the spot prices
spotprices <- data[,1:2]

str(spotprices) 
'data.frame':	2159 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 

# write the spot prices dataframe to a .csv file 
write.table(spotprices, file = "spotprices.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

#spotprices <- read.csv("spotprices.csv",colClasses = c("Date","numeric"))
# write.table and csv from a dataframe is still the best

## mean price each month

# create new dataframe of monthly mean of raw spot price 
monthprice<-aggregate(price ~ month, data, mean)
# round mean prices to whole cents
monthprice[["price"]] = round(monthprice[["price"]], digits = 2)
# replace month factor with mid-month 15th of month date-formatted string
monthprice[["month"]] = seq(as.Date('2010-05-15'), by = 'months', length = nrow(monthprice)) 
# rename columns
colnames(monthprice) <- c("date","price")
# check structure of dataframe
str(monthprice) 
'data.frame':	188 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ...

# write the mean monthly price dataframe to a .csv file 
write.table(monthprice, file = "nzu-month-price.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)
#monthprice <- read.csv("nzu-month-price.csv", colClasses = c("Date","numeric"))

# Convert the data frame price and date columns to a zoo time series object,
monthpricezoo <- zoo(x = monthprice[["price"]], order.by = monthprice[["date"]])

# create chart of the zoo time series matrix - its the same as chart of dataframe of date and price
svg(filename="NZUpriceZoo-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthpricezoo,tck=0.01,xlab="",ylab="",ann=TRUE, las=1,col='red',lwd=1,type='l',lty=1)
points(monthpricezoo,col='red',pch=19,cex=0.75)
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("New Zealand Unit monthly mean prices 2010 - 2025")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/unit")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

# This is the month data in a format closest to my preferred base R chart - it is in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 

svg(filename="NZU-monthprice-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-monthprice-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(monthprice, aes(x = date, y = price)) +  
geom_line(colour = "#ED1A3B") + 
#geom_point(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5, vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit mean monthly prices 2010 - 2025", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(monthprice[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

## Missing values and interpolation (infilling) in the spot price series

# Fill in the missing values in the spot prices data series - as there are no prices for all week days
# load package xts (Ryan JA, Ulrich JM (2023). _xts: eXtensible Time Series_. R package version 0.13.1)
library("xts") 
# load package zoo (# Zeileis A, Grothendieck G (2005). “zoo: S3 Infrastructure for Regular and Irregular Time Series.” Journal of Statistical Software, 14(6), 1–27. doi:10.18637/jss.v014.i06.)
library("zoo")  
summary(spotprices$date)
# no NAs detected

# last date in a time series
spotprices$date[nrow(spotprices)]
[1] "2025-12-19"
max(spotprices$date)
[1] "2025-12-19"
# How many days of dates should be included if there were prices for all days from May 2010 to today?
#spotpricealldates <- seq.Date(from=spotprices$date[1], to=spotprices$date[nrow(spotprices)], by="day")
spotpricealldates <- seq.Date(min(spotprices$date), max(spotprices$date), "day")
length(spotpricealldates) 
[1] 5699
str(spotpricealldates)
 Date[1:5699], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

# compared to the sequence of all dates, how many missing dates are there?
length(spotpricealldates) - nrow(spotprices)
[1] 3540

# create a dataframe of "all the days" or 'x' including days with missing prices added as NA
spotpricealldatesmissingprices <- merge(x= data.frame(date = spotpricealldates),  y = spotprices,  all.x=TRUE)

str(spotpricealldatesmissingprices) 
'data.frame':	5699 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-15" ...
 $ price: num  17.8 NA NA NA NA ...

head(spotpricealldatesmissingprices) 
        date price
1 2010-05-14 17.75
2 2010-05-15    NA
3 2010-05-16    NA
4 2010-05-17    NA
5 2010-05-18    NA
6 2010-05-19    NA

# Convert the data frame price and date columns to a zoo time series object
spotpricealldatesmissingpriceszoo <- zoo(x = spotpricealldatesmissingprices[["price"]], order.by= spotpricealldatesmissingprices[["date"]])

# check the object's structure
str(spotpricealldatesmissingpriceszoo)
‘zoo’ series from 2010-05-14 to 2025-12-19
  Data: num [1:5699] 17.8 NA NA NA NA ...
  Index:  Date[1:5699], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

# look a first 6 lines/rows
head(spotpricealldatesmissingpriceszoo) 
2010-05-14 2010-05-15 2010-05-16 2010-05-17 2010-05-18 2010-05-19 
     17.75         NA         NA         NA         NA         NA

# create a zoo time series matrix with the missing prices filled in with linear interpolation via zoo package and save output
spotpricefilled <- na.approx(spotpricealldatesmissingpriceszoo)
#spotpricefilledspline <- na.spline(spotpricealldatesmissingpriceszoo)

# round infilled values to cents
spotpricefilled <- round(spotpricefilled,2)

head(spotpricefilled) 
2010-05-14 2010-05-15 2010-05-16 2010-05-17 2010-05-18 2010-05-19 
     17.75      17.71      17.68      17.64      17.61      17.57
tail(spotpricefilled)
2025-12-14 2025-12-15 2025-12-16 2025-12-17 2025-12-18 2025-12-19
     39.36      39.26      39.17      38.00      38.00      40.00

str(spotpricefilled) 
‘zoo’ series from 2010-05-14 to 2025-12-19
  Data: num [1:5699] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5699], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

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
'data.frame':	5699 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-15" ...
 $ price: num  17.8 17.7 17.7 17.6 17.6 ...
# check for NAs, none found
summary(spotpricefilleddataframe)
      date                price


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
# 5000 + records

# leave out the Saturdays
spotpricefilleddataframe <- spotpricefilleddataframe[!idSat, ]

# Where are the Sundays ? logical indexing
idSun <- spotpricefilleddataframe$day == "Sunday"  
idSun

# leave out the Sundays
spotpricefilleddataframe <- spotpricefilleddataframe[!idSun, ] 
str(spotpricefilleddataframe)
'data.frame':	4071 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ...

# load qlcal package for holidays and business days
library(qlcal)
citation("qlcal")
Eddelbuettel D, QuantLib Authors (2025). _qlcal: R Bindings to the
  Calendaring Functionality of 'QuantLib'_. R package version 0.0.17,
  <https://CRAN.R-project.org/package=qlcal>.

# set calendar to New Zealand
setCalendar("NewZealand")

# Get the business days and holidays and add to dateframe
spotpricefilleddataframe$businessday <- isBusinessDay(spotpricefilleddataframe[["date"]])

str(spotpricefilleddataframe)
'data.frame':	4071 obs. of  4 variables:
 $ date       : Date, format: "2010-05-14" "2010-05-17" ...
 $ price      : num  17.8 17.6 17.6 17.6 17.5 ...
 $ day        : chr  "Friday" "Monday" "Tuesday" "Wednesday" ...
 $ businessday: logi  TRUE TRUE TRUE TRUE TRUE TRUE ...

table(spotpricefilleddataframe$businessday)
FALSE  TRUE
  170  3901


idHoliday <- spotpricefilleddataframe$businessday == "FALSE"
table(idHoliday)
idHoliday
FALSE  TRUE
 3901   170

str(idHoliday)
 logi [1:4071] FALSE FALSE FALSE FALSE FALSE FALSE ...
# I want to save the holiday dates to a .RDS file and a .RData file to use on Dell notebook with MX18/R.3.3.3
saveRDS(idHoliday,"idHoliday.rds")
save(idHoliday,file = "idHoliday.RData")

# I want to write the holidays dates to a .csv file to use on Dell notebook with MX18/R.3.3.3

# use dput and copy paste it's output directly into file 'idHolidaydates.r'
#idHolidaydatesdput <-
dput(idHoliday)

# write the holidays dates to a .r file to use on Dell notebook with MX18/R.3.5.2

# leave out the holidays
spotpricefilleddataframe <- spotpricefilleddataframe[!idHoliday, ]

str(spotpricefilleddataframe)
'data.frame':	3901 obs. of  4 variables:
 $ date       : Date, format: "2010-05-14" "2010-05-17" ...
 $ price      : num  17.8 17.6 17.6 17.6 17.5 ...
 $ day        : chr  "Friday" "Monday" "Tuesday" "Wednesday" ...
 $ businessday: logi  TRUE TRUE TRUE TRUE TRUE TRUE ...

head(spotpricefilleddataframe)
        date price       day businessday
1 2010-05-14 17.75    Friday        TRUE
4 2010-05-17 17.64    Monday        TRUE
5 2010-05-18 17.61   Tuesday        TRUE
6 2010-05-19 17.57 Wednesday        TRUE
7 2010-05-20 17.54  Thursday        TRUE
8 2010-05-21 17.50    Friday        TRUE

# check the dates are only business days
table(spotpricefilleddataframe$businessday)
TRUE
3901
# check the dates are week days
table(spotpricefilleddataframe$day)

   Friday    Monday  Thursday   Tuesday Wednesday
      787       722       800       792       800

# omit the days of week and business day columns ## not today 09/12/2025
# spotpricefilleddataframe <- spotpricefilleddataframe[,1:2]
 
# write the spot prices dataframe to a .csv file 
write.table(spotpricefilleddataframe, file = "spotpricefilleddataframe.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)
# read back into R if needed
#
#spotpricefilleddataframe <- read.csv("spotpricesfilleddataframe.csv", colClasses = c("Date","numeric"))

tail(spotpricefilleddataframe)

# create second zoo series that has same nrow as 'spotpricefilleddataframe'
spotfilledzoo <- zoo(x = spotpricefilleddataframe[["price"]], order.by = spotpricefilleddataframe[["date"]])

#spotfilledzoo <- zoo(x = spotpricesinfilled[["price"]], order.by = spotpricesinfilled[["date"]])

tail(spotfilledzoo) 


# create a base R plot of infilled spot prices      #  axes=T,
svg(filename="spotpricefilled-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotpricefilled-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spotfilledzoo,tck=0.01,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("New Zealand Unit spot prices 2010 2025")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 

# does not include Saturdays and Sundays or statutory hoildays

# the dimensions of the dataframe of infilled prices that includes holidays and weekends.
dim(spotpricefilleddataframe)
[1] 3901    4

# This is a Ggplot2 chart of the infilled spot price data for business days in the theme 'black and white' with x axis at 10 grid and y axis at 1 year
svg(filename="NZU-spotpriceinfilled-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceinfilled-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotpricefilleddataframe, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2010 - 2025", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotpricefilleddataframe[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

## Generic functions for computing rolling means, maximums, medians, and sums of ordered observations zoo package

Usage
rollmean(x, k, fill = if (na.pad) NA, na.pad = FALSE, align = c("center", "left", "right"), ...)
# x an object (representing a series of observations). a zoo objext
# align right means that the 12 month periods start from the last month, align left means periods start from first month..
# average over 20 or 21 days is roughly the same as monthly given that the filled time series has a price for every week day i.e. 20 or 21 days per calendar month

#spot <- read.csv(file = "spotpricefilleddataframe", colClasses = c("Date","numeric"))
# create another copy of prices
spot <- spotpricefilleddataframe
spot <- spot[,1:2]

# create 21 day (a month) rolling average of the zoo timeseries object
spotroll31 <- rollmean(spotfilledzoo, k =21,  fill = NA, align = c("center"))

str(spot) 

spotroll31 <- rollmean(spotfilledzoo, k =21,  fill = NA, align = c("center"))

summary(spotroll31)
     Index              spotroll31
 Min.   :2010-05-14   Min.   : 1.750
 1st Qu.:2014-03-31   1st Qu.: 7.984
 Median :2018-02-21   Median :21.033
 Mean   :2018-02-21   Mean   :29.692
 3rd Qu.:2022-01-12   3rd Qu.:51.801
 Max.   :2025-12-08   Max.   :86.946
                      NAs   :20
str(spotroll31)
‘zoo’ series from 2010-05-14 to 2025-12-08
  Data: num [1:3892] NA NA NA NA NA NA NA NA NA NA ...
  Index:  Date[1:3892], format: "2010-05-14" "2010-05-17" "2010-05-18" "2010-05-19" "2010-05-20" ...

# Create a data frame from the zoo vector
spotroll31dataframe <- data.frame(date=index(spotroll31),price= coredata(spotroll31))

# round the rolling mean values to cents
spotroll31dataframe[["price"]] <- round(spotroll31dataframe[["price"]],2)

str(spotroll31dataframe)
'data.frame':	3901 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  NA NA NA NA NA NA NA NA NA NA ...

summary(spotroll31dataframe)
      date                price
 Min.   :2010-05-14   Min.   : 1.75
 1st Qu.:2014-04-03   1st Qu.: 8.00
 Median :2018-02-28   Median :21.06
 Mean   :2018-02-27   Mean   :29.72
 3rd Qu.:2022-01-21   3rd Qu.:51.71
 Max.   :2025-12-19   Max.   :86.95
                      NAs   :20
# NB ten NAs at start and ten NAs at end


# write the spot prices dataframe to a .csv file 
write.table(spotroll31dataframe, file = "spotroll31dataframe.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# This is a chart of the 21 day rolling mean of the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year

svg(filename="NZU-spotpriceinfilledrollingmean-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceinfilledrollingmean-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotroll31dataframe, aes(x = date, y = price)) +  geom_line(colour = "#9F116D") + # colour is  Jazzberry Jam dark purple)
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit rolling mean spot prices 2010 - 2025", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotroll31dataframe[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()


# read back in to R the price data in three formats
monthprice <- read.csv("nzu-month-price.csv", colClasses = c("Date","numeric"))
weeklyprice <- read.csv("weeklymeanprice.csv", colClasses = c("Date","numeric","character")) 
data <- read.csv("nzu-final-prices-data.csv", colClasses = c("Date","numeric","character","character","character")) 
spotprices <- read.csv("spotprices.csv", colClasses = c("Date","numeric"))
spotpricesinfilled <- read.csv("spotpricesinfilled.csv", colClasses = c("Date","numeric"))
tail(weeklyprice)

str(spotprices) 

#str(spotpricesinfilled)

 
## weekly mean price via zoo aggregate

# Splits a "zoo" object into subsets along a coarser index grid, computes summary statistics for each, and returns the reduced "zoo" object. 

# aggregate(x, as.yearmon, mean)

# aggregate by day zoo to week average zoo  - uses cut
weekpricezoo <- aggregate(spotfilledzoo, as.Date(cut(time(spotfilledzoo), "week")), mean) 

str(weekpricezoo)
‘zoo’ series from 2010-05-10 to 2025-12-15
  Data: num [1:815] 17.8 17.6 17.5 17.3 17.1 ...
  Index:  Date[1:815], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...

# round to cents i.e 2 decimal places
coredata(weekpricezoo) <- round(coredata(weekpricezoo),2)
summary(coredata(weekpricezoo))
Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  1.640   8.185  21.110  29.727  51.672  88.240

# Convert  the zoo vector to a data frame
weeklypricefilleddataframe <- data.frame(date=index(weekpricezoo),price = coredata(weekpricezoo))

# write the mean price per week dataframe to a .csv file 
write.table(weeklypricefilleddataframe, file = "weeklymeanprice.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# colour = "#ED1A3B" and "#E7298A" is the purple from Dark accent, "#984EA3" is 'Affair' or purple
# weekly mean prices x axis years annual
svg(filename="NZU-weeklypriceYr-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-weeklypriceYr-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(weeklypricefilleddataframe, aes(x = date, y = price)) +  geom_line(colour = "#984EA3") +
theme_bw(base_size = 12) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit mean weekly prices 2010 - 2025", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(weeklypricefilleddataframe[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off() 

## subset 2025 prices
spot2025 <- spotpricefilleddataframe[spotpricefilleddataframe$date > as.Date("2024-12-31"),]
spot2025 <- spot2025[,c(1,2)]
str(spot2025)
'data.frame':	243 obs. of  2 variables:
 $ date : Date, format: "2025-01-03" "2025-01-06" ...
 $ price: num  62.4 62.6 62.7 62.7 62.8 ...

# add end of 2025 date and a NA price to allow the x axis to be for full year
spot2025 <- rbind(spot2025, c(as.Date("2025-12-31"),NA))
str(spot2025)
'data.frame':	244 obs. of  2 variables:
 $ date : Date, format: "2025-01-03" "2025-01-06" ...
 $ price: num  62.4 62.6 62.7 62.7 62.8 ...

summary(spot2025)
      date                price
 Min.   :2025-01-03   Min.   :38.00
 1st Qu.:2025-04-01   1st Qu.:54.41
 Median :2025-07-02   Median :56.73
 Mean   :2025-06-30   Mean   :55.40
 3rd Qu.:2025-09-25   3rd Qu.:58.50
 Max.   :2025-12-31   Max.   :64.73
                      NAs   :1
# the one NA is for 31/12/2025

# This is a chart of 2025 prices using the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year

svg(filename="NZU-spotpriceinfilled2025-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))
#png("NZU-spotpriceinfilled2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spot2025, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
#geom_point(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80,90))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -11 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="NZU spot prices 2025", x ="2025", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spot2025[["date"]]), y = 2, size = 4, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = as.Date("2025-01-30"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-01-30")+5, y = 20, size = 4, angle = 90, hjust = 0, label="Paris NDC2 Target announced") +
geom_vline(xintercept = as.Date("2025-03-19"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-03-19")+5, y = 20, size = 4, angle = 90, hjust = 0, label="Auction 0 units sold") +
geom_vline(xintercept = as.Date("2025-04-23"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-04-23")+5, y = 10, size = 4, angle = 90, hjust = 0, label="CCC ETS Prices Settings Advice") +
geom_vline(xintercept = as.Date("2025-06-18"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-06-18")+5, y = 20, size = 4, angle = 90, hjust = 0, label="Auction 0 units sold") +
geom_vline(xintercept = as.Date("2025-08-19"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-08-19")+5, y = 20, size = 4, angle = 90, hjust = 0, label="MfE ETS Prices Settings Adopted") +
geom_vline(xintercept = as.Date("2025-09-10"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-09-10")+5, y = 20, size = 4, angle = 90, hjust = 0, label="Auction 0 units sold") +
geom_vline(xintercept = as.Date("2025-10-12"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-10-12")+5, y = 20, size = 4, angle = 90, hjust = 0, label="Government sets methane targets for 2050") +
geom_vline(xintercept = as.Date("2025-11-05") ,colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2025-11-04")+7, y = 10, size = 4, angle = 90, hjust = 0, label="Improving New Zealand’s climate change act") +
geom_hline(yintercept = 68, colour="blue",linetype ="dashed") +
geom_vline(xintercept = as.Date("2025-12-03"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-12-03")+5, y = 20, size = 4, angle = 90, hjust = 0, label="Auction 0 units sold") +
annotate("text", x= spot2025[["date"]][5], y = 70, size = 4, angle = 0, hjust = 0, label="2025 NZU auction floor price $68")
dev.off()



--------------------------------------------------------------------------------
## 2024 infilled spot prices

str(spotpricefilleddataframe)

# subset 2024 and 2025 prices
spot2024 <- spotpricefilleddataframe[spotpricefilleddataframe$date > as.Date("2024-01-01"),]
#spot2024 <- spot[spot$date > as.Date("2024-01-01"),]

# subset 2024 prices by excluding 2025 prices
spot2024 <- spot2024[spot2024$date < as.Date("2025-01-01"),]
str(spot2024)
'data.frame':	261 obs. of  2 variables:
 $ date : Date, format: "2024-01-02" "2024-01-03" ...
 $ price: num  69.6 69.7 71 70 70 ...

tail(spot2024,1)
           date price
5346 2024-12-31 62.16

# best chart of 2024 price responses to policy announcements and quarterly auctions

svg(filename="NZU-auctions-2024-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-auctions-2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spot2024, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit auctions and spot prices 2024", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
#annotate("text", x= max(spot2024[["date"]]), y = 0, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = spot2024[["date"]][58] ,colour="blue",linetype ="dashed") +
annotate("text", x= spot2024[["date"]][58]+5, y = 2, size = 3, angle = 90, hjust = 0, label="20/03/2024 ETS Auction 2,974,300 units sold") +
geom_vline(xintercept = as.Date("2024-06-19") ,colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-06-19")+5, y = 2, size = 3, angle = 90, hjust = 0, label="19/06/2024 ETS Auction reserve not met 0 units sold") +
geom_vline(xintercept = as.Date("2024-08-21"),colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-08-21")+5, y = 2, size = 3, angle = 90, hjust = 0, label="21/08/2024 Annual update ETS settings") +
geom_vline(xintercept = as.Date("2024-09-04"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2024-09-04")+5, y = 2, size = 3, angle = 90, hjust = 0, label="4/09/2024 ETS Auction reserve not met 0 units sold") + 
geom_vline(xintercept = as.Date("2024-12-04"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2024-12-04")+5, y = 2, size = 3, angle = 90, hjust = 0, label="4/12/2024 ETS Auction reserve part met 4,032,500 units sold") +
geom_hline(yintercept = 64, colour="blue",linetype ="dashed")    +
annotate("text", x= spot2024[["date"]][85], y = 62, size = 3, angle = 0, hjust = 0, label="2024 ETS Auction floor price $64")
dev.off()

-------------------------------------------------------------------------- 
# subset prices for the last year to date i.e. the last year defined in working days 261 work days = 1 year

spotlastyear <- tail(spotpricefilleddataframe,261)
str(spotlastyear)
'data.frame':	261 obs. of  2 variables:
 $ date : Date, format: "2024-03-08" "2024-03-11" ...
 $ price: num  69 69.5 68.4 68 66 65 64.5 65.2 65.4 51 ...
tail(spotlastyear)
           date price
3861 2025-02-28 63.23
3862 2025-03-03 63.22
3863 2025-03-04 63.01
3864 2025-03-05 62.75
3865 2025-03-06 62.55
3866 2025-03-07 62.20

# chart of the last years price responses to policy announcements and quarterly auctions

svg(filename="NZU-lastyear-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))
#png("NZU-lastyear-2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotlastyear, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotlastyear[["date"]]), y = 0, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = as.Date("2024-03-20") ,colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-03-20")+5, y = 2, size = 3, angle = 90, hjust = 0, label="20/03/2024 ETS Auction 2,974,300 units sold") +
geom_vline(xintercept = as.Date("2024-06-19") ,colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-06-19")+5, y = 2, size = 3, angle = 90, hjust = 0, label="19/06/2024 ETS Auction reserve not met 0 units sold") +
geom_vline(xintercept = as.Date("2024-08-21"),colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-08-21")+5, y = 2, size = 3, angle = 90, hjust = 0, label="21/08/2024 Annual update ETS settings") +
geom_vline(xintercept = as.Date("2024-09-04"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2024-09-04")+5, y = 2, size = 3, angle = 90, hjust = 0, label="4/09/2024 ETS Auction reserve not met 0 units sold") +
geom_vline(xintercept = as.Date("2024-12-04"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2024-12-04")-5, y = 2, size = 3, angle = 90, hjust = 0, label="4/12/2024 ETS Auction reserve part met 4,032,500 units sold") +
geom_vline(xintercept = as.Date("2024-12-11"), colour="blue",linetype ="dashed") +
geom_vline(xintercept = as.Date("2024-12-12"), colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-12-11")+9, y = 30, size = 4, angle = 90, hjust = 0, label="December policy announcements") +
geom_hline(yintercept = 64, colour="blue",linetype ="dashed")    +
annotate("text", x= spotlastyear[["date"]][85], y = 62, size = 3, angle = 0, hjust = 0, label="2024 ETS Auction floor price $64") +
geom_vline(xintercept = as.Date("2025-01-30"), colour="blue",linetype ="dashed")    +
annotate("text", x= as.Date("2025-01-30")+9, y = 30, size = 4, angle = 90, hjust = 0, label="Paris NDC2 Target 30/01/2025")
dev.off()

---------------------------------------------------------------------------------------------------------------------
# This is a chart of the December 2024 policy announcements using the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year

svg(filename="NZU-spotpriceinfilled2024-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceinfilled2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
#png("NZU-spotpriceinfilled2024-540by405-ggplot-theme-bw.png", bg="white", width=540, height=405)
ggplot(spot2024, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
#geom_point(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80,90))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="NZU spot prices 2024", x ="2024", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spot2024[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = as.Date("2024-12-04"), colour="blue",linetype ="dashed") +
geom_vline(xintercept = as.Date("2024-12-05"), colour="blue",linetype ="dashed") +
geom_vline(xintercept = as.Date("2024-12-11"), colour="blue",linetype ="dashed") +
geom_vline(xintercept = as.Date("2024-12-12"), colour="blue",linetype ="dashed") +
annotate("text", x= as.Date("2024-12-11")+9, y = 30, size = 4, angle = 90, hjust = 0, label="December policy announcements") +
geom_hline(yintercept = 64, colour="blue",linetype ="dashed") +
annotate("text", x= spot2024[["date"]][85], y = 62, size = 3, angle = 0, hjust = 0, label="2024 ETS Auction floor price $64") +
annotate("text", x= spot2024[["date"]][45], y = 35, size = 4, angle = 0, hjust = 0, label="December announcements jolted the NZU price by $4\n04/12/2024 Methane target report,\n04/12/2024 ETS carbon forestry limits\n05/12/2024 Commission: Net negative 2050 target\n05/12/2024 Commission: 4th Emissions Budget\n11/12/2024 Second Emissions Reduction Plan")
dev.off() 


5 December 2024
https://www.climatecommission.govt.nz/news/commission-delivers-first-review-of-the-2050-target-and-advice-on-the-fourth-emissions-budget/ summary
Commission on negative 2050 CO2 target https://www.climatecommission.govt.nz/our-work/advice-to-government-topic/review-of-the-2050-emissions-target/2024-review-of-the-2050-emissions-target/final-report/
Commission on 4th emission budget https://www.climatecommission.govt.nz/our-work/advice-to-government-topic/preparing-advice-on-emissions-budgets/advice-on-the-fourth-emissions-budget/final-report/


svg(filename="spotprice2024c-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotprice2024c-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spot2024,ylim=c(40,75),xlab ="",ylab="",tck=0.01, ann=T, las=1, type='l',lty=1, col="red",lwd=1)
grid(col="darkgray",lwd=1)
abline(v=19802,col='blue',lwd=1,lty=2)
abline(h=64,col='blue',lwd=1,lty=2)
points(spot2024[1:53,],col="red",pch=19,cex=0.7)
points(spot2024[54:nrow(spot2024),],col="red",pch=19,cex=0.7)
text(19880,65,cex=0.85,expression(paste("$64 NZU auction reserve price 2024")) )
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.2, line=-2.8,expression(paste("Price bumps at March and June auctions and the August \nETS settings update but not the September auction")) )
#mtext(side=3,cex=1.2, line=-2.8,expression(paste("NZU prices 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
text(19802,48,adj=0,cex=0.9, labels = "Auction\n20 March")
# what x axis value for the 19 June auction?  as.numeric(as.Date("2024-06-19"))  [1] 19893 
abline(v=19893,col='blue',lwd=1,lty=2)
text(19893,45,adj=0,cex=0.9, labels = "Auction\n19 June")
abline(v=19956,col='blue',lwd=1,lty=2)
text(19956,60,adj=1,cex=0.9, labels = "Annual update\nETS settings\n21 Aug")
abline(v=19970,col='blue',lwd=1,lty=2)
text(19970,45,adj=0,cex=0.9, labels = "Auction\n4 Sept")
dev.off()
  
## subset a dataframe of spot prices from 1/12/2022 to 11/11/2023

spotd2 <- spotpricesinfilled[spotpricesinfilled$date > as.Date("2022-12-01"),]
str(spotd2) 
'data.frame':	591 obs. of  2 variables:
 $ date : Date, format: "2022-12-02" "2022-12-05" ...
 $ price: num  82.5 81 81 82 82.5 .. 
spotd2[242,]
           date price
3517 2023-11-06    70 

spotd2 <- spotd2[1:242,]
str(spotd2) 
'data.frame':	242 obs. of  2 variables:
 $ date : Date, format: "2022-12-02" "2022-12-05" ...
 $ price: num  82.5 81 81 82 82.5 
 
nrow(spot)
[1] 3786
#[1] 1805
#d2 <- spot[1494:1735,1:2]
#str(d2)
'data.frame':	242 obs. of  2 variables:
 $ date : Date, format: "2022-12-01" "2022-12-02" ...
 $ price: num  83.5 82.5 81 81 82 ... 

d3 <- data[nrow(data)-313:nrow(data),1:2]
str(d3) 
'data.frame':	1479 obs. of  2 variables:
 $ date : Date, format: "2022-11-10" "2022-11-09" ...
 $ price: num  88.2 87.1 86.5 85 85 ... 

spotd3 <- spot[spot$date > as.Date("2022-11-09"),] 
str(spotd3)
'data.frame':	527 obs. of  2 variables:
 $ date : Date, format: "2022-11-10" "2022-11-11" ...
 $ price: num  88.2 88.2 87.9 88.5 88.2 ... 
 
https://www.youtube.com/watch?v=DLn-gs626Ts 
#  Align Text to Line in ggplot2 Plot in R (Example) | geom_vline & annotate | Vertical & Horizontal
Statistics Globe

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


svg(filename="NZU-spotprice2023-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))
#png("NZU-spotprice22023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotd2, aes(x = date, y = price)) +  geom_line(colour = "#CC79A7") +  # reddishpurple
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2022 - 2023", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotd2[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = as.numeric(19342),colour="blue",linetype ="dashed") +
annotate("text", x= spotd2[["date"]][12]-10, y = 2, size = 3, angle = 90, hjust = 0, label="16/12/2023 Cabinet rejects Commission ETS 2023 price recommendations") +
geom_vline(xintercept = as.numeric(spotd2[["date"]][111]),colour="blue",linetype ="dashed") +
annotate("text", x= spotd2[["date"]][111]-10, y = 2, size = 3, angle = 90, hjust = 0, label="19/06/2023 ETS gross emissions vs forestry removals consultation") +
geom_vline(xintercept = spotd2[["date"]][135], colour="blue",linetype ="dashed")    +
annotate("text", x= spotd2[["date"]][135]-10, y = 2, size = 3, angle = 90, hjust = 0, label="25/07/2023 ETS Prices & Settings 2024 announcement") 
dev.off()

## just 9 months

svg(filename="NZU-spotprice2024-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotprice2024-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(spotd3, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B",size = 1) + 
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2023 - 2024", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotd3[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) 
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
ggplot(spotd2, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit auctions and spot prices 2023", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotd2[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
geom_vline(xintercept = spotd2[["date"]][5] ,colour="blue",linetype ="dashed") +
annotate("text", x= spotd2[["date"]][5]+5, y = 2, size = 3, angle = 90, hjust = 0, label="7/12/2022 ETS Auction 4,825,000 units sold") +
geom_vline(xintercept = spotd2[["date"]][53] ,colour="blue",linetype ="dashed") +
annotate("text", x= spotd2[["date"]][53]+5, y = 2, size = 3, angle = 90, hjust = 0, label="15/03/2023 ETS Auction reserve not met") +
geom_vline(xintercept = as.numeric(spotd2[["date"]][109]),colour="blue",linetype ="dashed") +
annotate("text", x= spotd2[["date"]][109]+5, y = 2, size = 3, angle = 90, hjust = 0, label="14/06/2023 ETS Auction reserve not met") +
geom_vline(xintercept = spotd2[["date"]][166], colour="blue",linetype ="dashed")    +
annotate("text", x= spotd2[["date"]][166]+5, y = 2, size = 3, angle = 90, hjust = 0, label="25/09/2023 ETS Auction reserve not met") + 
geom_vline(xintercept = spotd2[["date"]][230], colour="blue",linetype ="dashed")    +
annotate("text", x= spotd2[["date"]][230]+5, y = 2, size = 3, angle = 90, hjust = 0, label="6/12/2023 ETS Auction reserve not met") 
dev.off()

spot2024[["date"]][54]
pot2024[["price"]][57]
[1] 65.4
spot2024[["price"]][58]
[1] 51
spot2024[["date"]][58]
[1] "2024-03-21"

svg(filename="NZU-spotpricesAug2023c-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel")) 
plot(spotpriceAugNovdataframe1,type='l',lwd=1,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit Aug Nov 2023 spot prices")
abline(v = 19643,col = 4,lwd =2,lty =2) 
dev.off()
ls()
 
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

spotzoo <- zoo(spotprices[["price"]], order.by = spotprices[["date"]])

str(spotzoo)
‘zoo’ series from 2010-05-14 to 2024-09-06
  Data: num [1:1905] 17.8 17.5 17.5 17 17.8 ...
  Index:  chr [1:1905] "2010-05-14" "2010-05-21" "2010-05-29" "2010-06-11" ...

# select ALL 2024 spot prices including 20 March auction
spot2024 <- spotprices[1738:nrow(spotprices),] 
spot[1738:nrow(spot),]
2022-12-20 77.17 
spot[nrow(spot),]
           date price
3786 2024-11-15 63.78 

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

lastyear <- last(spotzoo, "1 year")
lastyear <- last(spotfilledzoo, "1 year")
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
autoplot(lastyear) 

plot(last(spotfilledzoo, "2 years"),ylab="$NZD",las=1,main="NZU spot price 2023 2024",col='4')

points(last(monthzoo, "2 years"),col='4',pch=19,cex=1.2)

lines(last(rollmeanzoo, "2 years"),col='red')

plot(lastyear,ylab="$NZD",las=1,main="NZU spot price 2024",col='red')

lastyears <- last(spotzoo, "2 year")

plot(lastyears,ylab="$NZD",las=1,main="NZU spot price 2024",col='2')

plot(last(spotfilledzoo, "1 years"),ylab="$NZD",las=1,main="NZU spot price 2024",col='4')

plot(first(spotfilledzoo, "24 months"),ylab="$NZD",las=1,main="NZU spot price 2024",col='blue')

plot(last(spotfilledzoo, "6 months"),ylab="$NZD",las=1,main="NZU spot price 2024",col='blue')

# chart of zoo object "lastyears"
svg(filename="spotprice2023-2024-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
png("spotprice2023-2024-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(lastyear,ylim=c(0,75),tck=0.01,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
points(spotzoo20March,pch=21)
abline(h=64, lty=2,col='blue' )
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

# are the 2 mean month series identical? 
identical(monthzoo, mpzoo)
[1] TRUE 
ls() 



x.date <- as.Date(paste(2003, rep(1:4, 4:1), seq(1,20,2), sep = "-"))
x.date
 [1] "2003-01-01" "2003-01-03" "2003-01-05" "2003-01-07" "2003-02-09"
 [6] "2003-02-11" "2003-02-13" "2003-03-15" "2003-03-17" "2003-04-19"
x <- zoo(matrix(rnorm(20), ncol = 2), x.date)
is.regular(x)
[1] TRUE
class(x)
[1] "zoo"

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
  Data:    double [1944, 1]
  Index:   Date [1944] (TZ: "UTC") 
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

zoo2024 <- last(spotzoo, "1 year")
zoo2024[1:2,]
2024-01-03 2024-01-04 
     69.74      71.00  
str(zoo2024)
‘zoo’ series from 2024-01-03 to 2024-09-06
  Data: num [1:206] 69.7 71 70 70 68.8 ...
  Index:  Date[1:206], format: "2024-01-03" "2024-01-04" "2024-01-05" "2024-01-08" "2024-01-09" ...  

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

#plot(zoo2023_2024,tck=0.01,ylim=c(0,75),axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
plot(spot20232024,tck=0.01,ylim=c(0,75),axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices 2023 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)

## zoo aggregate

Splits a "zoo" object into subsets along a coarser index grid, computes summary statistics for each, and returns the reduced "zoo" object. 

aggregate(x, as.yearmon, mean)

str(spotpricefilled)
‘zoo’ series from 2010-05-14 to 2024-10-25
  Data: num [1:5286] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5286], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ... 
  
monthpricezooag <- aggregate(spotpricefilled, as.yearmon, mean)  

str(monthpricezooag)
‘zoo’ series from May 2010 to Oct 2024
  Data: num [1:174] 17.5 17.4 18.1 18.5 19.9 ...
  Index:  'yearmon' num [1:174] May 2010 Jun 2010 Jul 2010 Aug 2010 ... 

# create zoo time series object
monthzoo <- zoo(monthprice[["price"]], order.by = monthprice[["date"]])

str(monthzoo)
‘zoo’ series from 2010-05-15 to 2024-03-15
  Data: num [1:175] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  Date[1:175], format: "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" "2010-09-15" ...

# graph to compare month mean of raw spot prices to zoo aggregate month from infilled spot prices
plot(monthzoo[125:175],type='l',col='4')
lines(monthpricezoocut[125:175],col='red')
# monthpricezoocut is red and is 1st of month and can be seen as different from monthzoo in blue which is 15th of month


str(monthpricezoo) 
‘zoo’ series from 2010-05-15 to 2024-10-15
  Data: num [1:174] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  Date[1:174], format: "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" "2010-09-15" ... 

# the index doesn't match. can't graph them on same chart?? No.

# create chart - its the same as chart of dataframe of date and price
svg(filename="NZUpriceZoov2-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthpricezooag,tck=0.01,xlab="",ylab="",ann=TRUE, las=1,col='red',lwd=1,type='l',lty=1)
points(monthpricezoo,col='black',pch=19,cex=0.5)
lines(monthpricezoo,col='black',lty=2)
#grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("New Zealand Unit mean month prices 2010 - 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

# aggregate zoo to zoo  - uses cut
monthpricezoocut <- aggregate(spotpricefilled, as.Date(cut(time(spotpricefilled), "month")), mean)

str(monthpricezoocut) 
‘zoo’ series from 2010-05-01 to 2024-10-01
  Data: num [1:174] 17.5 17.4 18.1 18.5 19.9 ...
  Index:  Date[1:174], format: "2010-05-01" "2010-06-01" "2010-07-01" "2010-08-01" "2010-09-01" ... 

# note that the index date is "01" first day of month when the month prices are all 15th of month.

autoplot(monthzoo) 
autoplot(monthpricezoocut,col='red')

# create chart - its the same as chart of dataframe of date and price
svg(filename="NZUpriceZoov2-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthzoo,tck=0.01,xlab="",ylab="",ann=TRUE, las=1,col='red',lwd=1,type='p',lty=1)
points(monthpricezoocut,col='black')
lines(monthpricezoocut,col='black',lty=2)
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("New Zealand Unit mean month prices 2010 - 2024")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()  

sub("-01","-15","2010-05-01")
gsub("-01","-15","2010-05-01")
[1] "2010-05-15" 
sub("-01","-15","2010-05-01")
[1] "2010-05-15"
gsub("-01","-15","2010-05-01")
[1] "2010-05-15" 

ls()
[1] "spotpricefilleddataframe" "str"
class(spotpricefilleddataframe)

str(spotpricefilleddataframe)
'data.frame':	3771 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...  

 
spot <- read.csv(file = "spotpricesinfilled.csv", colClasses = c("Date","numeric")) 
str(spot)
'data.frame':	3776 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...

# subset 2024 prices
spot20232024 <- spot[spot$date > as.Date("2023-01-01"),]
 
ggplot(aes(x = Index, y = Value), data = fortify(spotfilledzoo, melt = TRUE)) +  geom_line() + xlab("Date") + ylab("Price $NZD") + geom_smooth(se = TRUE) + labs(title="New Zealand Unit prices 2010 to 2024", caption="Data: 'NZU monthly prices https://github.com/theecanmole/nzu") 

# are the infilled prices even per year?
table(format(spot[["date"]], "%Y")) 

2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 
 166  260  261  261  261  261  261  260  261  261  262  261  260  260  230 
# Answer. Yes very even. 
# make a zoo matrix

# create zoo time series object
library(zoo)
# Convert the data frame price and date columns to a zoo time series object

spotfilledzoo <- zoo(x = spot[["price"]], order.by = spot[["date"]])

spot2023zoo <- zoo(x = spot20232024[["price"]], order.by = spot20232024[["date"]])

str(spotfilledzoo)
‘zoo’ series from 2010-05-14 to 2024-10-25
  Data: num [1:3776] 17.8 17.6 17.6 17.6 17.5 ...
  Index:  Date[1:3776], format: "2010-05-14" "2010-05-17" "2010-05-18" "2010-05-19" "2010-05-20" ... 

tail(spotfilledzoo)
2024-10-25 2024-10-28 2024-10-29 2024-10-30 2024-10-31 2024-11-01 
     62.93      62.99      63.01      62.93      63.15      63.24 


# my preferred Ggplot for 2024 using zoo and fortify
svg(filename="NZU-spotprice2023FORTIFY-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotprice2023FORTIFY-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot( aes(x = Index, y = Value), data = fortify(spot2023zoo, melt = TRUE) ) +  geom_line(colour = "#ED1A3B",size = 0.5) + 
theme_bw(base_size = 14) +
#geom_smooth(se = TRUE) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot 2023 2024 prices", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(index(spot2023zoo)), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) 
dev.off()  

# my preferred Ggplot for 2023
svg(filename="NZU-spotprice2023-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
png("NZU-spotprice2023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(aes(x = date, y = price, data = spot20232024) +  geom_line(colour = "#ED1A3B",size = 0.5) + 
theme_bw(base_size = 14) +
geom_smooth(se = TRUE) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= 20042, y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
annotate("text", x= max(spot20232024[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off() 

as.numeric(max(spot20232024[["date"]]))
[1] 20042
help("ggplot2")

# what does fortify do to input of a time series?
spotfilledzoofortify <- fortify(spotfilledzoo, melt = FALSE)

str(spotfilledzoofortify)
'data.frame':	3771 obs. of  3 variables:
 $ Index : Date, format: "2010-05-14" "2010-05-17" ...
 $ Value : num  17.8 17.6 17.6 17.6 17.5 ... 

head(spotfilledzoofortify)
       Index        Series Value
1 2010-05-14 spotfilledzoo 17.75
2 2010-05-17 spotfilledzoo 17.64
3 2010-05-18 spotfilledzoo 17.61
4 2010-05-19 spotfilledzoo 17.57
5 2010-05-20 spotfilledzoo 17.54
6 2010-05-21 spotfilledzoo 17.50 

autoplot(spotfilledzoo) 

# aggregate zoo to zoo  - uses cut
monthprice <- read.csv("nzu-month-price.csv")  

monthprice$date <- as.Date(monthprice[["date"]])

monthpricezoocut <- aggregate(spotfilledzoo, as.Date(cut(time(spotfilledzoo), "month")), mean)

str(monthpricezoocut)
‘zoo’ series from 2010-05-01 to 2024-10-01
  Data: num [1:175] 17.5 17.4 18.1 18.5 19.9 ...
  Index:  Date[1:175], format: "2010-05-01" "2010-06-01" "2010-07-01" "2010-08-01" "2010-09-01" ...
head(monthpricezoocut)
2010-05-01 2010-06-01 2010-07-01 2010-08-01 2010-09-01 2010-10-01 
  17.54417   17.35955   18.12909   18.46818   19.88455   19.98286 
tail(monthpricezoocut)
2024-06-01 2024-07-01 2024-08-01 2024-09-01 2024-10-01 2024-11-01 
  51.13350   52.13522   56.08227   61.67857   62.84217   63.24000 
# Note the dates for each month are 1st of month

# Is the month zoo aggregated from the infilled spot price series identical to the month means of raw spot prices?
identical(monthzoo, monthpricezoocut)  
[1] FALSE 

# Is the month zoo aggregated from the infilled spot price series equal to the month means of raw spot prices?
all.equal(monthzoo, monthpricezoocut)
[1] "Attributes: < Component “index”: Mean relative difference: 0.0008049228 >"
[2] "Mean relative difference: 0.004243957"  

# What is the correlation of the data?
cor(coredata(monthpricezoocut),coredata(monthzoo))
[1] 0.999941

plot(coredata(monthpricezoocut),coredata(monthzoo),col='red')


# aggregate zoo to zoo  - uses cut
weekpricezoocut <- aggregate(spotfilledzoo, as.Date(cut(time(spotfilledzoo), "week")), mean) 

str(weekpricezoocut) 
‘zoo’ series from 2010-05-10 to 2024-10-21
  Data: num [1:756] 17.8 17.6 17.5 17.3 17.1 ...
  Index:  Date[1:756], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...

# Convert the data frame price and date columns to a zoo time series object

monthpricezoo <- zoo(monthprice[["price"]], order.by = monthprice[["date"]]) 

str(monthpricezoo)
‘zoo’ series from 2010-05-15 to 2024-10-15
  Data: num [1:174] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  chr [1:174] "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" ...
colnames(monthpricezoo)
NULL

# are the 2 mean month series identical? 
identical(monthpricezoocut,monthpricezoo)
[1] FALSE 

# mean month price has dates all 15th of month, zoo aggregate month has 1st of month
all.equal(monthpricezoocut,monthpricezoo)
[1] "Attributes: < Component “index”: Modes: numeric, character >"                           
[2] "Attributes: < Component “index”: Attributes: < Modes: list, NULL > >"                   
[3] "Attributes: < Component “index”: Attributes: < Lengths: 1, 0 > >"                       
[4] "Attributes: < Component “index”: Attributes: < names for target but not for current > >"
[5] "Attributes: < Component “index”: Attributes: < current is not list-like > >"            
[6] "Attributes: < Component “index”: target is Date, current is character >"                
[7] "Mean relative difference: 0.004248104"                                                  

# query just the data values (prices)
all.equal(coredata(monthpricezoocut),coredata(monthpricezoo))
[1] "Mean relative difference: 0.004248104"

cor(coredata(monthpricezoocut),coredata(monthpricezoo))
[1] 0.9999403

So the month mean of raw prices with omissions (n = 1940) is 99.99403 % the same as the month mean price aggregated via zoo of the infilled spot prices (n = 3771) 

sessionInfo()
R version 4.4.2 (2024-10-31)
Platform: x86_64-pc-linux-gnu
Running under: Debian GNU/Linux 12 (bookworm)

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.21.so;  LAPACK version 3.11.0

locale:
 [1] LC_CTYPE=en_NZ.UTF-8          LC_NUMERIC=C
 [3] LC_TIME=en_NZ.UTF-8           LC_COLLATE=en_NZ.UTF-8
 [5] LC_MONETARY=en_NZ.UTF-8       LC_MESSAGES=en_NZ.UTF-8
 [7] LC_PAPER=en_NZ.UTF-8          LC_NAME=en_NZ.UTF-8
 [9] LC_ADDRESS=en_NZ.UTF-8        LC_TELEPHONE=en_NZ.UTF-8
[11] LC_MEASUREMENT=en_NZ.UTF-8    LC_IDENTIFICATION=en_NZ.UTF-8

time zone: Pacific/Auckland
tzcode source: system (glibc)

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
[1] zoo_1.8-12    ggplot2_3.5.1 rkward_0.7.5

loaded via a namespace (and not attached):
 [1] R6_2.5.1         tidyselect_1.2.1 lattice_0.22-6   farver_2.1.2
 [5] magrittr_2.0.3   gtable_0.3.6     glue_1.8.0       tibble_3.2.1
 [9] pkgconfig_2.0.3  generics_0.1.3   dplyr_1.1.4      lifecycle_1.0.4
[13] cli_3.6.3        scales_1.3.0     grid_4.4.2       vctrs_0.6.5
[17] withr_3.0.2      compiler_4.4.2   tools_4.4.2      munsell_0.5.1
[21] pillar_1.10.1    colorspace_2.1-1 rlang_1.1.5
