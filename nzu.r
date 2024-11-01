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
[1] 1945    5
str(data) 
'data.frame':	1945 obs. of  5 variables:
 $ V1: chr  "2010/05/14" "2010/05/21" "2010/05/29" "2010/06/11" ...
 $ V2: chr  "17.75" "17.5" "17.5" "17" ...
 $ V3: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ V4: chr  "2010/05/01" "2010/05/01" "2010/05/01" "2010/06/01" ...
 $ V5: chr  "2010/W19" "2010/W20" "2010/W21" "2010/W23" ...

# after the Python script is run, the last row is the what used to be the column headers 

# look at that last 3 rows again
tail(data,3)
             V1    V2                                                   V3
1943 2024/10/31 63.15 https://www.carbonnews.co.nz/story.asp?storyID=32998
1944 2024/11/01 63.24 https://www.carbonnews.co.nz/story.asp?storyID=33006
1945       date price                                            reference
          V4       V5
1943 2024-10 2024-W44
1944 2024-11 2024-W44
1945   month     week

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

# check the dataframe again
str(data) 
'data.frame':	1943 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 175 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
 $ week     : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1

# Create a .csv formatted data file
write.csv(data, file = "nzu-final-prices-data.csv", row.names = FALSE)

# create dataframe of only the spot prices
spotprices <- data[,1:2]

str(spotprices) 
'data.frame':	1944 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 

# write the spot prices dataframe to a .csv file 
write.table(spotprices, file = "spotprices.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 
#spotprices <- read.csv("spotprices.csv")

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
'data.frame':	174 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ...

# write the mean monthly price dataframe to a .csv file 
write.table(monthprice, file = "nzu-month-price.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# Convert the data frame price and date columns to a zoo time series object,
monthpricezoo <- zoo(monthprice[["price"]], monthprice[["date"]])

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

## Missing values and interpolation in the spot price series
# Fill in the missing values in the spot prices data series - as there are no prices for all week days
# load package xts (Ryan JA, Ulrich JM (2023). _xts: eXtensible Time Series_. R package version 0.13.1)
library("xts") 
# load package zoo (# Zeileis A, Grothendieck G (2005). “zoo: S3 Infrastructure for Regular and Irregular Time Series.” Journal of Statistical Software, 14(6), 1–27. doi:10.18637/jss.v014.i06.)
library("zoo")  

# How many days of dates should be included if there were prices for all days from May 2010 to today?
spotpricealldates <- seq.Date(min(spotprices$date), max(spotprices$date), "day")
length(spotpricealldates) 
[1] 5286
# how many missing values are there?
length(spotpricealldates) - nrow(spotprices) 
[1] 3342

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
spotpricealldatesmissingpriceszoo <- zoo(x = spotpricealldatesmissingprices[["price"]], order.by= spotpricealldatesmissingprices[["date"]])

# check the object's structure
str(spotpricealldatesmissingpriceszoo)
‘zoo’ series from 2010-05-14 to 2024-04-05
  Data: num [1:5286] 17.8 NA NA NA NA ...
  Index:  Date[1:5286], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

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
  Data: num [1:5286] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5286], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ...

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
5279 2024-10-25 62.93    Friday
5282 2024-10-28 62.99    Monday
5283 2024-10-29 63.01   Tuesday
5284 2024-10-30 62.93 Wednesday
5285 2024-10-31 63.15  Thursday
5286 2024-11-01 63.24    Friday

str(spotpricefilleddataframe)
'data.frame':	3776 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ...

# omit the days of week 
spotpricefilleddataframe <- spotpricefilleddataframe[,1:2] 
 
# write the spot prices dataframe to a .csv file 
write.table(spotpricefilleddataframe, file = "spotpricesinfilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

# create second zoo series that has same nrow as 'spotpricefilleddataframe'
spotfilledzoo <- zoo(x = spotpricefilleddataframe[["price"]], order.by = spotpricefilleddataframe[["date"]])

str(spotfilledzoo)
‘zoo’ series from 2010-05-14 to 2024-11-01
  Data: num [1:3776] 17.8 17.6 17.6 17.6 17.5 ...
  Index:  Date[1:3776], format: "2010-05-14" "2010-05-17" "2010-05-18" "2010-05-19" "2010-05-20" ...

# create a base R plot of infilled spot prices  
svg(filename="spotpricefilled-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotpricefilled-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spotfilledzoo,tck=0.01,axes=T,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
mtext(side=3,cex=1.3, line=-2.2,expression(paste("New Zealand Unit spot prices")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off() 

# includes Saturdays and Sundays
dim(spotprices)
[1] 1944    2
dim(spotpricefilleddataframe)
[1] 3776    2

# This is a Ggplot2 chart of the infilled spot price data in the theme 'black and white' with x axis at 10 grid and y axis at 1 year
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

# spot prices n= 1944 theme black and white  - bw
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

## Generic functions for computing rolling means, maximums, medians, and sums of ordered observations.

Usage
rollmean(x, k, fill = if (na.pad) NA, na.pad = FALSE, align = c("center", "left", "right"), ...)
# align right means that the 12 month periods start from the last month, align left means periods start from first month..
# average over 20 or 21 days is roughly the same as monthly given that the filled time series has a price for every week day i.e. 20 or 21 days per calendar month


spot <- read.csv(file = "spotpricesinfilled.csv", colClasses = c("Date","numeric"))

# create 21 day (a month) rolling average
spot$spotroll31 <- rollmean(spot[["price"]], k =21,  fill = NA, align = c("center"))

str(spot) 
'data.frame':	3776 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...
 $ spotroll31: num  NA NA NA NA NA NA NA NA NA NA ... 

# round the rolling mean values to cents
spot$spotroll31 <- round(spot$spotroll31,2)

# create dataframe of only the 21 day rolling mean values and dates
spotrollmean31  <-spot[,c(1,3)] 

# write over column names
colnames(spotrollmean31) <- c("date","price") 

# examine dataframe
str(spotrollmean31) 
'data.frame':	3776 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  NA NA NA NA NA NA NA NA NA NA ...

# write the spot prices dataframe to a .csv file 
write.table(spotrollmean31, file = "spotrollmean31.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# This is a chart of the 21 day rolling mean of the infilled spot price data in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year

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

# read back in to R the price data in three formats
monthprice <- read.csv("nzu-month-price.csv", colClasses = c("Date","numeric"))
weeklyprice <- read.csv("weeklymeanprice.csv", colClasses = c("Date","numeric","character")) 
data <- read.csv("nzu-final-prices-data.csv", colClasses = c("Date","numeric","character","character","character")) 
spotprices <- read.csv("spotprices.csv", colClasses = c("Date","numeric"))

str(spotprices) 
'data.frame':	1944 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 

## weekly mean price via zoo aggregate

# Splits a "zoo" object into subsets along a coarser index grid, computes summary statistics for each, and returns the reduced "zoo" object. 

# aggregate(x, as.yearmon, mean)

# aggregate week day zoo to week average zoo  - uses cut
weekpricezoo <- aggregate(spotfilledzoo, as.Date(cut(time(spotfilledzoo), "week")), mean) 

str(weekpricezoo)
‘zoo’ series from 2010-05-10 to 2024-10-28
  Data: num [1:756] 17.8 17.6 17.5 17.3 17.1 ...
  Index:  Date[1:756], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...

# Convert  the zoo vector to a data frame
weeklypricefilleddataframe <- data.frame(date=index(weekpricezoo),price = coredata(weekpricezoo))

# write the mean price per week dataframe to a .csv file 
write.table(weeklypricefilleddataframe, file = "weeklymeanprice.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

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
annotate("text", x= max(weeklypricefilleddataframe[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off() 


## 2024 infilled spot prices
str(spotpricefilleddataframe)
'data.frame':	3776 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
#spotfilled <- spotpricefilleddataframe[,1:2]

spot2024 <- spotpricefilleddataframe[spotpricefilleddataframe$date > as.Date("2024-01-01"),]
str(spot2024) 
'data.frame':	219 obs. of  2 variables:
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

# second chart of 2024 unit prices after 15 March & 19 June 2024 auction
# 19/06/2024 auction https://www.etsauctions.govt.nz/public/auction_noticeboard/52

# what x axis value for the 19 June auction?  
as.numeric(as.Date("2024-06-19"))
[1] 19893
# what is x axis value for 21 August 2024, the date of announcement of ets price & settings update? https://www.beehive.govt.nz/release/updated-settings-restore-ets-market-confidence https://environment.govt.nz/what-government-is-doing/areas-of-work/climate-change/ets/nz-ets-market/annual-updates-to-emission-unit-limits-and-price-control-settings/
as.numeric(as.Date("2024-08-21"))
[1] 19956 

https://www.etsauctions.govt.nz/public/auction_noticeboard/54 04/09/2024 
# The September 2024 auction produced no clearing price because there were no bids. As a result, all available units will be rolled over to the next auction on 4 December 2024.
as.numeric(as.Date("2024-09-04"))
[1] 19970 

svg(filename="spotprice2024c-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("spotprice2024c-560by420.png", bg="white", width=560, height=420,pointsize = 14)
par(mar=c(2.7,2.7,1,1)+0.1)
plot(spot2024,ylim=c(40,85),tck=0.01,ann=T, las=1,col="red",lwd=1,type='l',lty=1,xlab ="",ylab="")
grid(col="darkgray",lwd=1)
abline(v=19802,col='blue',lwd=2,lty=2)
abline(h=64,col='blue',lwd=2,lty=2)
points(spot2024[1:53,],col="red",pch=19,cex=0.7)
points(spot2024[54:nrow(spot2024),],col="red",pch=19,cex=0.7)
#text(19820,62,cex=0.85,expression(paste("$64 NZU auction reserve price 2024")) )
text(19880,65,cex=0.85,expression(paste("$64 NZU auction reserve price 2024")) )
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=1,line=-1.1,"Data https://github.com/theecanmole/NZ-emission-unit-prices")
#mtext(side=3,cex=1.2, line=-2.8,expression(paste("The August ETS settings update bumped the NZU price by $5\nbut spot prices are still less than the 2024 auction reserve price")) )
mtext(side=2,cex=1, line=-1.3,"$NZD")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
text(19802,48,cex=0.9, labels = "Auction\n15 March")
# what x axis value for the 19 June auction?  as.numeric(as.Date("2024-06-19"))  [1] 19893 
abline(v=19893,col='blue',lwd=2,lty=2)
text(19893,45,cex=0.9, labels = "Auction\n19 June")
abline(v=19956,col='blue',lwd=2,lty=2)
text(19956,60,adj=1,cex=0.9, labels = "Annual update ETS settings\n21 Aug")
abline(v=19970,col='blue',lwd=2,lty=2)
text(19970,45,adj=1,cex=0.9, labels = "Auction\n4 Sept")
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

str(spotpricealldatesmissingprices)
'data.frame':	5286 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-15" ...
 $ price: num  17.8 NA NA NA NA ...

str(spot)
'data.frame':	3776 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ...
 $ spotroll31: num  NA NA NA NA NA NA NA NA NA NA ...

str(spotpricefilleddataframe)
'data.frame':	3776 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ... 
 
str(spot)
'data.frame':	3776 obs. of  3 variables:
 $ date      : Date, format: "2010-05-14" "2010-05-17" ...
 $ price     : num  17.8 17.6 17.6 17.6 17.5 ... 
 
str(monthprice) 
'data.frame':	174 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 .. 
str(spotrollmean31) 
'data.frame':	3776 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  NA NA NA NA NA NA NA NA NA NA ... 


# chart of zoo object "spotpricefilled"
str(spotpricefilled)
‘zoo’ series from 2010-05-14 to 2024-10-25
  Data: num [1:5286] 17.8 17.7 17.7 17.6 17.6 ...
  Index:  Date[1:5286], format: "2010-05-14" "2010-05-15" "2010-05-16" "2010-05-17" "2010-05-18" ... 
class(spotpricefilled)
[1] "zoo" 
# compare to the smilar named dataframe where Sats and Sundays removed
str(spotpricefilleddataframe)
'data.frame':	3776 obs. of  3 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...
 $ day  : chr  "Friday" "Monday" "Tuesday" "Wednesday" ... 
 
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

str(monthpricezoo) 
‘zoo’ series from 2010-05-15 to 2024-10-15
  Data: num [1:174] 17.6 17.4 18.1 18.4 20.1 ...
  Index:  Date[1:174], format: "2010-05-15" "2010-06-15" "2010-07-15" "2010-08-15" "2010-09-15" ... 

# the index doesn't match. can't graph them on same chart??

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
    
# create chart - its the same as chart of dataframe of date and price
svg(filename="NZUpriceZoov2-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthpricezoo,tck=0.01,xlab="",ylab="",ann=TRUE, las=1,col='red',lwd=1,type='p',lty=1)
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
'data.frame':	3771 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-17" ...
 $ price: num  17.8 17.6 17.6 17.6 17.5 ...


# are the infilled prices even per year?
table(format(spot[["date"]], "%Y")) 

2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 
 166  260  261  261  261  261  261  260  261  261  262  261  260  260  215 
# Answer. Yes very even. 
# make a zoo matrix

# create zoo time series object
library(zoo)
# Convert the data frame price and date columns to a zoo time series object

spotfilledzoo <- zoo(x = spot[["price"]], order.by = spot[["date"]])

str(spotfilledzoo)
‘zoo’ series from 2010-05-14 to 2024-10-25
  Data: num [1:3771] 17.8 17.6 17.6 17.6 17.5 ...
  Index:  Date[1:3771], format: "2010-05-14" "2010-05-17" "2010-05-18" "2010-05-19" "2010-05-20" ... 

# basic Ggplot using zoo and fortify
svg(filename="NZUpriceFortifyZoo-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
ggplot(aes(x = Index, y = Value), data = fortify(spotfilledzoo, melt = TRUE)) +  geom_line() + xlab("Date") + ylab("Price $NZD") + geom_smooth(se = TRUE) + labs(title="New Zealand Unit prices 2010 to 2024", caption="Data: 'NZU monthly prices https://github.com/theecanmole/nzu")
dev.off() 

autoplot(spotfilledzoo) 
# very basic ggplot

# my preferred Ggplot using zoo and fortify
svg(filename="NZU-spotpriceFORTIFY-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotpriceFORTIFY-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot( aes(x = Index, y = Value), data = fortify(spotfilledzoo, melt = TRUE) ) +  geom_line(colour = "#ED1A3B",size = 0.5) + 
theme_bw(base_size = 14) +
#geom_smooth(se = TRUE) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices", x ="Date", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(index(spotfilledzoo)), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) 
dev.off() 

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
  Data: num [1:174] 17.5 17.4 18.1 18.5 19.9 ...
  Index:  Date[1:174], format: "2010-05-01" "2010-06-01" "2010-07-01" "2010-08-01" "2010-09-01" ...

# aggregate zoo to zoo  - uses cut
weekpricezoocut <- aggregate(spotfilledzoo, as.Date(cut(time(spotfilledzoo), "week")), mean) 

str(weekpricezoocut) 
‘zoo’ series from 2010-05-10 to 2024-10-21
  Data: num [1:755] 17.8 17.6 17.5 17.3 17.1 ...
  Index:  Date[1:755], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...

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

,xlab="",ylab=""

plot(coredata(monthpricezoocut),coredata(monthpricezoo))

svg(filename="Monthmeanpricecorrelation-720by540.svg", width = 8, height = 6, pointsize = 12, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(coredata(monthpricezoocut),coredata(monthpricezoo),tck=0.01,ann=TRUE, las=1,col='red',lwd=1,type='p',lty=1)
#points(monthpricezoo,col='red',pch=19,cex=0.5)
#grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
#mtext(side=1,cex=0.8,line=-1.1,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.5, line=-2.2,expression(paste("Correlation of mean month methods 2010 - 2024")) )
mtext(side=1,cex=1, line=-1.3,"month prices from infilled spot prices (n = 3771)")
mtext(side=2,cex=1, line=-1.3,"month prices from raw spot prices (n = 1940)")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()

monthpricecut2df <- data.frame(date = as.Date(monthprice[["date"]]), price = coredata(monthpricezoocut))
str(monthpricecut2df)
'data.frame':	174 obs. of  2 variables:
 $ date : Date, format: "2010-05-15" "2010-06-15" ...
 $ price: num  17.5 17.4 18.1 18.5 19.9 ... 

# are the 2 mean month series identical? 
identical(monthprice,monthpricecut2df)
[1] FALSE 

# How different are the 2 data sets?
all.equal(monthprice,monthpricecut2df)
[1] "Component “price”: Mean relative difference: 0.004244527"
# Are the prices highly correlated?
cor(monthpricecut2df[["price"]] , monthprice[["price"]]  )
[1] 0.9999403

# create a R base time series
monthpricets <-  ts(monthprice[["price"]], start = c(2010,5), frequency =12)

str(monthpricets)
 Time-Series [1:174] from 2010 to 2025: 17.6 17.4 18.1 18.4 20.1 ...

# what does fortify do to input of a time series?
monthpricefortify <- fortify(monthpricets, melt = FALSE) 
Error in `fortify()`:
! `data` must be a <data.frame>, or an object coercible by `fortify()`,
  not a <ts> object.
Run `rlang::last_trace()` to see where the error occurred.

monthpricefortify <- fortify(monthpricezoo, melt = FALSE) 
str(monthpricefortify) 
'data.frame':	174 obs. of  2 variables:
 $ Index        : Date, format: "2010-05-15" "2010-06-15" ...
 $ monthpricezoo: num  17.6 17.4 18.1 18.4 20.1 ... 

# Is monthprice identical, the same or correlated with monthpricefortify? 

# are the 2 mean month series identical? 
identical(monthprice,monthpricefortify)
[1] FALSE 

# How different are the 2 data sets?
all.equal(monthprice,monthpricefortify)
[1] "Names: 2 string mismatches" 

# Are the prices highly correlated?
cor(monthprice[["price"]] , monthpricefortify[["monthpricezoo"]]  )
[1] 1 
# The prices are the same
head(monthprice)
        date price
1 2010-05-15 17.58
2 2010-06-15 17.42
3 2010-07-15 18.15
4 2010-08-15 18.35
5 2010-09-15 20.10
6 2010-10-15 19.96
head(monthpricefortify)
        Index monthpricezoo
1 2010-05-15         17.58
2 2010-06-15         17.42
3 2010-07-15         18.15
4 2010-08-15         18.35
5 2010-09-15         20.10
6 2010-10-15         19.96

autoplot(monthpricefortify)
Error in `autoplot()`:
! Objects of class <data.frame> are not supported by autoplot.
ℹ have you loaded the required package?
Run `rlang::last_trace()` to see where the error occurred.
autoplot(monthprice)
Error in `autoplot()`:
! Objects of class <data.frame> are not supported by autoplot.
ℹ have you loaded the required package?
Run `rlang::last_trace()` to see where the error occurred. 

Old default colors
piecolors2 <- c("black","red","green","blue","cyan","magenta","yellow","gray")

pie(c(1,1,1,1,1,1,1,1),col=piecolors, labels =  piecolors)

new default colors
piecolors2 <- c(1,2,3,4,5,6,7,8) 

pie(c(1,1,1,1,1,1,1,1),col=piecolors2, labels =  piecolors2)
