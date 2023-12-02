## New Zealand emission unit (NZU) prices

This repository features prices of the [New Zealand emission unit](https://www.al.nz/new-zealand-units-the-basics/) or NZU. The NZU is the "the primary domestic unit of trade" in the [New Zealand Emissions Trading Scheme](https://www.climatecommission.govt.nz/get-involved/new-content-page/what-is-the-nz-ets/). 

The prices are web-scraped via a Python script [api.py](https://github.com/theecanmole/nz-emission-unit-prices/blob/main/api.py) and saved to a .csv file [nzu-edited-raw-prices-data.csv](https://github.com/theecanmole/NZ-emission-unit-prices/blob/main/nzu-edited-raw-prices-data.csv).

The prices are then processed in the [R programming language](https://www.r-project.org/) via a R script file [nzu.r](https://github.com/theecanmole/NZ-emission-unit-prices/blob/main/nzu.r) into data sets of;

* [average monthly prices](https://github.com/theecanmole/NZ-emission-unit-prices/blob/main/nzu-month-price.csv) 
* [average weekly prices (with missing values)](https://github.com/theecanmole/NZ-emission-unit-prices/blob/main/weeklymeanprice.csv) 
* [average weekly prices (with the missing values filled by linear interpolation)](https://github.com/theecanmole/NZ-emission-unit-prices/blob/main/weeklypricefilled.csv) 
* [spot prices](https://github.com/theecanmole/nz-emission-unit-prices/blob/main/nzu-final-prices-data.csv).

The price data is then charted in R Ggplot2 and in R with an 'xts' object.

This graph is the mean price for each calendar month.
![](NZU-monthprice-720by540-ggplot-theme-bw.svg)

This graph is the mean price for each week. It includes missing values infilled via linear interpolation
![](NZU-weeklypriceYr-720by540-ggplot-theme-bw.svg)

This graph is the spot prices of trading on week days. It is an irregular time series.
![](NZU-spotprice-720by540-ggplot-theme-bw.svg)

This graph is the spot prices from November 2022 to November 2023. I have marked with blue dashed horizontal lines three dates where Government announcements 'surprised'the market and the price changed sharply. On 16 December 2022, [Price of carbon plummets in response to Cabinet rejection of Climate Change Commission recommendations](https://www.carbonnews.co.nz/story.asp?storyID=26749)  
![](NZU-spotprice2023-720by540-ggplot-theme-bw.svg)

This is the plot of the spot prices when expressed in the 'xts' format. It has interesting defaults for the price axis and the date axis and title.
![](NZU-spotXTStimeseriesprices-720by540.svg)

### License

#### ODC-PDDL-1.0

This data package and these datasets and the R scripts are made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/. You are free to share, to copy, distribute and use the data, to create or produce works from the data and to adapt, modify, transform and build upon the data, without restriction.
