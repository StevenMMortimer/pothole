
options(stringsAsFactors=FALSE)

library(forecast)
library(rjson)
library(lubridate)

# load historical data
json_data <- rjson::fromJSON(file='http://dashboard.edmonton.ca/resource/i3wp-57z9.json') 
formatted_data <- ldply(json_data, .fun = function(x) as.data.frame(x))
dat <- as.data.frame(lapply(formatted_data, function(x) type.convert(x, as.is=T)))
dat <- dat[order(dat$datetime),]

# convert to time series
dat$report_month <- match(gsub(' ', '', dat$report_month), month.name)
time_series <- ts(data=dat$number_of_potholes, 
                  start=c(head(dat$report_year,1), head(dat$report_month,1)), 
                  end=c(tail(dat$report_year,1), tail(dat$report_month,1)), 
                  frequency=12)

# build model
pothole_model <- ets(time_series, lambda=.0001)

pothole_data <- dat[,c('report_year', 'report_month', 'number_of_potholes')]
pothole_data$month_as_date <- as.Date(ymd(paste0(pothole_data$report_year, '-', pothole_data$report_month, '-1')))

save(file='./data/pothole_model.rda', list=c('pothole_model'))
save(file='./data/pothole_data.rda', list=c('pothole_data'))
