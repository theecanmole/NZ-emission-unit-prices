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
[1] 1719    5
str(data) 
'data.frame':	1719 obs. of  5 variables:
 $ V1: chr  "2010/05/14" "2010/05/21" "2010/05/29" "2010/06/11" ...
 $ V2: chr  "17.75" "17.5" "17.5" "17" ...
 $ V3: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ V4: chr  "2010/05/01" "2010/05/01" "2010/05/01" "2010/06/01" ...
 $ V5: chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...

# after the Python script is run, the last row is the what used to be the column headers 

# look at that last row again
tail(data,1) 
       V1    V2        V3    V4   V5
1719 date price reference month week

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
1718 2023/11/29 73.15 https://www.carbonnews.co.nz/story.asp?storyID=29381
       month     week
1718 2023-11 2023-W48

# change formats of date column and price column
data$date <- as.Date(data$date)
data$price <- as.numeric(data$price)

# add month variable/factor to data
data$month <- as.factor(format(data$date, "%Y-%m"))
# create dataframe of only the spot prices
spotprices <- data[,1:2]
str(spotprices) 
'data.frame':	1718 obs. of  2 variables:
 $ date : Date, format: "2010-05-14" "2010-05-21" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ... 
# write the spot prices dataframe to a .csv file 
write.table(spotprices, file = "spotprices.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE) 

## load package aweek which deals with week  
# Kamvar Z (2022). _aweek: Convert Dates to Arbitrary Week Definitions_. R package version 1.0.3, <https://CRAN.R-project.org/package=aweek>
library("aweek")
# make aweek vector (with Monday being day 1 - the default) from date format column and overwrite contents of week column   
data$week <- as.aweek(data$date) 
str(data) 
'data.frame':	1718 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 163 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
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
'data.frame':	163 obs. of  2 variables:
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
'data.frame':	613 obs. of  3 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 17 17.8 ...
 $ week : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1
  
# write the mean price per week dataframe to a .csv file 
write.table(weeklyprice, file = "weeklymeanprice.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

## Missing values and interpolation in week series
# Fill in the missing values in the weekly prices data series - as there are no prices for at least 95 weeks
# load package xts (Ryan JA, Ulrich JM (2023). _xts: eXtensible Time Series_. R package version 0.13.1)
library("xts") 
# load package zoo (# Zeileis A, Grothendieck G (2005). “zoo: S3 Infrastructure for Regular and Irregular Time Series.” Journal of Statistical Software, 14(6), 1–27. doi:10.18637/jss.v014.i06.)
library("zoo")  

# How many weeks should be included if there were prices for all weeks?
weeklypriceallDates <- seq.Date(min(weeklyprice$date), max(weeklyprice$date), "week")
length(weeklypriceallDates) 
[1] 708 
# How many weeks were there in weekly prices dataframe which omits the weeks with missing prices?
nrow(weeklyprice)
[1] 613
# So 708 - 613 = 95 missing weeks out of 708 weeks since May 2010 

# create dataframe of all the weeks with missing weeks of prices as NA
weeklypricemissingprices <- merge(x= data.frame(date = weeklypriceallDates),  y = weeklyprice,  all.x=TRUE)
# check dataframes
str(weeklypricemissingprices)
'data.frame':	708 obs. of  3 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 NA 17 ...
 $ week : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" NA ...
  ..- attr(*, "week_start")= int 1 
  
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
‘zoo’ series from 2010-05-10 to 2023-11-27
  Data: num [1:708] 17.8 17.5 17.5 NA 17 ...
  Index:  Date[1:708], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07" ...
# look at first nine values/dates
head(weeklypricemissingpriceszoo,9)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 2010-06-21 
     17.75      17.50      17.50         NA      17.00         NA      17.75 
2010-06-28 2010-07-05 
     17.50      18.00 

# calculate the missing values with zoo na.approx which uses linear interpolation to fill in the NA values     
na.approx(weeklypricemissingpriceszoo)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 2010-06-21 
   17.7500    17.5000    17.5000    17.2500    17.0000    17.3750    17.7500 
2010-06-28 2010-07-05 2010-07-12 2010-07-19 2010-07-26 2010-08-02 2010-08-09 
   17.5000    18.0000    18.3000    18.3125    18.3250    18.3375    18.3500 
2010-08-16 
   18.3500 
# fill in the missing prices with linear interpolation via zoo package and save output  
weeklypricefilled <- na.approx(weeklypricemissingpriceszoo)
# check first 6 values
head(weeklypricefilled)
2010-05-10 2010-05-17 2010-05-24 2010-05-31 2010-06-07 2010-06-14 
    17.750     17.500     17.500     17.250     17.000     17.375
# check the new dataframe
str(weeklypricefilled)
‘zoo’ series from 2010-05-10 to 2023-11-20
  Data: num [1:707] 17.8 17.5 17.5 17.2 17 ...
  Index:  Date[1:707], format: "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" "2010-06-07"
# Convert  the zoo vector to a data frame
weeklypricefilleddataframe <- as.data.frame(weeklypricefilled)   
# check dataframe 
str(weeklypricefilleddataframe) 
'data.frame':	708 obs. of  1 variable:
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

weeklypricefilleddataframe[["weeklypricefilled"]] 
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
'data.frame':	708 obs. of  2 variables:
 $ weeklypricefilled: num  17.8 17.5 17.5 17.2 17 ...
 $ date             : chr  "2010-05-10" "2010-05-17" "2010-05-24" "2010-05-31" ...

# change date from character to date format 
weeklypricefilleddataframe$date <- as.Date(weeklypricefilleddataframe$date)
# check dataframe
str(weeklypricefilleddataframe)
'data.frame':	708 obs. of  2 variables:
 $ weeklypricefilled: num  17.8 17.5 17.5 17.2 17 ...
 $ date             : Date, format: "2010-05-10" "2010-05-17" ... 
# make the date column the left column and the price the right or second column 
weeklypricefilleddataframe <- weeklypricefilleddataframe[,c(2,1)]  
# round mean prices to whole cents
weeklypricefilleddataframe[["weeklypricefilled"]] = round(weeklypricefilleddataframe[["weeklypricefilled"]], digits = 2)
# change column names
colnames(weeklypricefilleddataframe) <-c("date","price") 
str(weeklypricefilleddataframe)
'data.frame':	708 obs. of  2 variables:
 $ date : Date, format: "2010-05-10" "2010-05-17" ...
 $ price: num  17.8 17.5 17.5 17.2 17 ... 
 
# write the infilled mean price per week dataframe to a .csv file 
write.table(weeklypricefilleddataframe, file = "weeklypricefilled.csv", sep = ",", col.names = TRUE, qmethod = "double",row.names = FALSE)

# create a time series object for average monthly prices
weekts <- ts(weeklypricefilleddataframe[["price"]],frequency=52,start = c(2010,19))
# check the time series
str(weekts) 
Time-Series [1:708] from 2010 to 2024: 17.8 17.5 17.5 17.2 17 ... 
 # check the dataframe again
str(data) 
'data.frame':	1718 obs. of  5 variables:
 $ date     : Date, format: "2010-05-14" "2010-05-21" ...
 $ price    : num  17.8 17.5 17.5 17 17.8 ...
 $ reference: chr  "http://www.carbonnews.co.nz/story.asp?storyID=4529" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4540" "http://www.carbonnews.co.nz/story.asp?storyID=4588" ...
 $ month    : Factor w/ 163 levels "2010-05","2010-06",..: 1 1 1 2 2 2 3 3 4 4 ...
 $ week     : 'aweek' chr  "2010-W19" "2010-W20" "2010-W21" "2010-W23" ...
  ..- attr(*, "week_start")= int 1
# Create a .csv formatted data file
write.csv(data, file = "nzu-final-prices-data.csv", row.names = FALSE)

# check the structure of the average monthly price data
str(monthprice) 
'data.frame':	163 obs. of  2 variables:
 $ date : Date, format: "2010-05-01" "2010-06-01" ...
 $ price: num  17.6 17.4 18.1 18.4 20.1 ... 

# read back in to R the price data in three formats
monthprice <- read.csv("nzu-month-price.csv", colClasses = c("Date","numeric"))
weeklyprice <- read.csv("weeklymeanprice.csv", colClasses = c("Date","numeric","character")) 
data <- read.csv("nzu-final-prices-data.csv", colClasses = c("Date","numeric","character","character","character")) 

## Graphs
# what is the most recent month? (maximum extent of date or x axis)
max(monthprice[["date"]]) 
[1] "2023-11-15" 

# This is the month data in a format closest to my preferred base R chart - it is in the Ggplot2 theme 'black and white' with x axis at 10 grid and y axis at 1 year
svg(filename="NZU-monthprice-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-monthprice-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(monthprice, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "year", date_labels = "%Y") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit mean monthly prices 2010 - 2023", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
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
labs(title="New Zealand Unit mean weekly prices 2010 - 2023", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
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
labs(title="New Zealand Unit spot prices 2010 - 2023", x ="Years", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(spotprices[["date"]]), y = min(spotprices[["price"]]), size = 3, angle = 0, hjust = 1, label=R.version.string)
dev.off()

help(scale_x_date)

d1 <- data[1450:1715,1:2]
head(d1,1)
          date price
1450 2022-09-29    80 

# subset a dataframe of spot prices from 9/11/2023 to 24/11/2023
d2 <- data[1478:1718,1:2]
head(d2,1)
           date price
1478 2022-11-09  87.1
# vertical lines at x axis or date ticks
geom_vline(xintercept = as.numeric(19563)) 
geom_vline(xintercept = as.numeric(monthprice[["month"]][50])) 
head(d1,1)
          date price
1550 2023-03-21 65.75

d1[["date"]][50] 
[1] "2023-06-09"

d1[["date"]][79] 
[1] "2023-07-25" 

as.numeric(d1[["date"]][79]) 
[1] 19563 

https://www.youtube.com/watch?v=DLn-gs626Ts 

https://www.youtube.com/watch?v=tRTo9p2nL88
ggp ＜- ggplot(data, aes(x, y)) +    # Create plot without line
  geom_point()
ggp                                 # Draw plot without line

h_line ＜- 8.7                       # Position of horizontal line

ggp +                               # Add horizontal line & label
  geom_hline(aes(yintercept = h_line)) +
  geom_text(aes(0, h_line, label = h_line, vjust = - 1))

# Nov 2022 to Nov 2023 spot prices theme black and white  - bw
svg(filename="NZU-spotprice2023-720by540-ggplot-theme-bw.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
png("NZU-spotprice2023-720by540-ggplot-theme-bw.png", bg="white", width=720, height=540)
ggplot(d1, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_bw(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices November 2022 to November 2023", x ="Months", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(d1[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
annotate("text", x= d1[["date"]][74], y = 2, size = 3, angle = 90, hjust = 0, label="the ETS Prices & Settings announcement") +
geom_vline(xintercept = as.numeric(19563))  

+     # add vertical line at 25 July 2023 the ETS Prices & Settings 2024 announcement 25/07/2023

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

dev.off()

# 2023 spot prices theme black and white  - bw
d2[["date"]][28]
[1] "2022-12-16"
as.numeric(d2[["date"]][28]) 
[1] 19342
d2[["date"]][151] 
[1] "2023-07-25"
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
annotate("text", x= d2[["date"]][151]-10, y = 2, size = 3, angle = 90, hjust = 0, label="25/07/2023 ETS Prices & Settings 2024 announcement") +
geom_vline(xintercept = as.numeric(19563),colour="blue",linetype ="dashed")    +
annotate("text", x= d2[["date"]][130]-10, y = 2, size = 3, angle = 90, hjust = 0, label="19/06/2023 ETS gross emissions vs forestry removals consultation") +
geom_vline(xintercept = as.numeric(19530),colour="blue",linetype ="dashed") +
annotate("text", x= d2[["date"]][28]-10, y = 2, size = 3, angle = 90, hjust = 0, label="16/12/2023 Cabinet rejects Commission ETS 2023 price recommendations") +
geom_vline(xintercept = as.numeric(d2[["date"]][28]),colour="blue",linetype ="dashed") # date 16/12/23
#geom_vline(xintercept = as.numeric(19342),colour="blue",linetype ="dashed")    
dev.off()

# 2023 spot prices theme classic so no gridlines to obscure the vertical lines
svg(filename="NZU-spotprice2023-720by540-ggplot-theme-classic.svg", width = 8, height = 6, pointsize = 16, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
#png("NZU-spotprice22023-720by540-ggplot-theme-classic.png", bg="white", width=720, height=540)
ggplot(d2, aes(x = date, y = price)) +  geom_line(colour = "#ED1A3B") +
theme_classic(base_size = 14) +
scale_y_continuous(breaks = c(0,10,20,30,40,50,60,70,80))  +
scale_x_date(date_breaks = "month", date_labels = "%b") +
theme(plot.title = element_text(size = 20, hjust = 0.5,vjust= -8 )) +
theme(plot.caption = element_text( hjust = 0.5 )) +
labs(title="New Zealand Unit spot prices 2022 - 2023", x ="Months", y ="Price $NZD", caption="Data: https://github.com/theecanmole/NZ-emission-unit-prices") +
annotate("text", x= max(d2[["date"]]), y = 2, size = 3, angle = 0, hjust = 1, label=R.version.string) +
annotate("text", x= d2[["date"]][151]-10, y = 2, size = 3, angle = 90, hjust = 0, label="2024 ETS Prices & Settings announcement") +
geom_vline(xintercept = as.numeric(19563),colour="darkgray",linetype ="dashed")    +
annotate("text", x= d2[["date"]][130]-10, y = 2, size = 3, angle = 90, hjust = 0, label="ETS gross emissions vs forestry removals consultation") +
geom_vline(xintercept = as.numeric(19530),colour="darkgray",linetype ="dashed") +
annotate("text", x= d2[["date"]][28]-10, y = 2, size = 3, angle = 90, hjust = 0, label="Cabinet rejects Commission ETS 2023 price recommendations") +
geom_vline(xintercept = as.numeric(19342),colour="darkgray",linetype ="dashed")    
dev.off() 

# first vertical line should be at 16/12/2022 (x intercept)
d2[["date"]][28] 
[1] "2022-12-16"
as.numeric(d2[["date"]][28]) 
[1] 19342

# add 2nd vertical line at 22 June 2023 the ETS
d2[["date"]][130] 
[1] "2023-06-22" 
as.numeric(d2[["date"]][130]) 
[1] 19530

# add vertical line at 25 July 2023 the ETS Prices & Settings announcement
 d2[["date"]][151] 
[1] "2023-07-25" 
as.numeric(d2[["date"]][151]) 
[1] 19563 

#F32424 name is pomegranate which is 'creamy tomato' actually
#ED1A3B is crimson

# monthly price chart in Base R, 720 by 540,  
svg(filename="NZU-monthly-spot-prices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
par(mar=c(2.7,2.7,1,1)+0.1)
plot(monthprice[["date"]],monthprice[["price"]],tck=0.01,axes=TRUE,ann=TRUE, las=1,col="#F32424",lwd=2,type='l',lty=1) # color is Pomegranate not 'red'.
grid(col="darkgray",lwd=1)
axis(side=4, tck=0.01, las=0,tick=TRUE,labels = FALSE)
mtext(side=1,cex=0.9,line=-1.3,"Data: 'NZU monthly prices' https://github.com/theecanmole/nzu")
mtext(side=3,cex=1.2, line=-2.2,expression(paste("New Zealand Unit mean monthly spot prices 2010 - 2023")) )
mtext(side=2,cex=1, line=-1.3,"$NZ Dollars/tonne")
mtext(side=4,cex=0.75, line=0.05,R.version.string)
dev.off()  

ggplot(vw, aes(x = weeks, y = values)) +  geom_line(colour = "#ED1A3B")

--------------------------------------------------------------------------
xts 
str(weeklyprice)
'data.frame':	611 obs. of  3 variables:
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

# create an xts timeseries from the weekly mean prices dataframe
spotpricexts <- xts(spotprices$price, spotprices$date)
str(spotpricexts) 
An xts object on 2010-05-14 / 2023-11-29 containing: 
  Data:    double [1718, 1]
  Index:   Date [1718] (TZ: "UTC") 

# create a XTS plot from the spot price 'xts' object

svg(filename="NZU-spotXTStimeseriesprices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
plot(spotpricexts,type='l',lwd=0.5,las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit spot prices")
dev.off()

# create a XTS plot from the weekly 'xts' object

svg(filename="NZU-weeklyXTStimeseriesprices-720by540.svg", width = 8, height = 6, pointsize = 14, onefile = FALSE, family = "sans", bg = "white", antialias = c("default", "none", "gray", "subpixel"))  
plot(weeklyprice_ts,type='l',las=1,col="#F32424",ylab="$NZ unit", main ="New Zealand Unit mean weekly spot prices")
dev.off()

plot(spotpricexts[c('2023-10','2023-11')])

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

https://www.nbr.co.nz/politics/judicial-review-helps-drive-ets-unit-prices-up/

user@wgtnadmin:~
$ uname -a && lsb_release -a
Linux wgtnadmin 4.19.0-25-amd64 #1 SMP Debian 4.19.289-2 (2023-08-08) x86_64 GNU/Linux
No LSB modules are available.
Distributor ID:	Debian
Description:	Debian GNU/Linux 10 (buster)
Release:	10
Codename:	buster
user@wgtnadmin:~
$ 
