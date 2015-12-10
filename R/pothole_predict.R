#' Predict Potholes filled Monthly in Edmonton
#' 
#' Simple forecast model
#' 
#' @export
#' @importFrom forecast forecast
#' @importFrom lubridate floor_date ymd %m+%
#' @importFrom zoo coredata
#' @param input data passed on as \code{h} to \code{\link{forecast}}
#' @examples
#' \dontrun{
#'    mydata <- data.frame(month='2016-01-01')
#'    pothole_predict(mydata)
#' }
pothole_predict <- function(input){

  # load input data (can either be csv file or data	0
  newdat <- if(is.character(input) && file.exists(input)){
              read.csv(input, stringsAsFactors=FALSE)
            } else {
              as.data.frame(input, stringsAsFactors=FALSE)
            }
  
  # data validation
  if(!("month" %in% names(newdat))){
    stop('Data request must provide year and month columns')
  }
  if (!all(newdat$month<=as.Date('2031-01-01'))){
    stop('Predictions only provided up through the year 2030')
  }

  # find newest month requested 
  newdat$month <- as.Date(floor_date(ymd(newdat$month), 'month'))
  max_input_month <- as.Date(max(newdat$month))
  # find the newest month reported
  max_data_month <- as.Date(max(pothole_data$month_as_date))
  min_data_month <- as.Date(min(pothole_data$month_as_date))
  
  return_dat <- newdat[,'month',drop=F]

  # if requested data exceeds historical data, then forecast monthly out until that month
  # then parse back to only the requested months
  if (max_input_month > max_data_month) {
    months_to_forecast <- length(seq(from=max_data_month, to=max_input_month, by='month')) - 1
    fc <- forecast(pothole_model, h=months_to_forecast)
    
    fc_dat <- data.frame(month=format(as.Date(c(pothole_data$month_as_date, 
                                                tail(pothole_data$month_as_date, 1)%m+%months(1:months_to_forecast))), 
                                      '%Y-%m-%d'), 
                         observed=c(pothole_data$number_of_potholes, rep(NA, months_to_forecast)),
                         forecast=c(rep(NA, nrow(pothole_data)), round(coredata(fc$mean),0)))
    
    fc_dat$prediction_type <- ifelse(is.na(fc_dat$forecast), 'HISTORICAL', 'FORECASTED')
    fc_dat$potholes_filled <- ifelse(is.na(fc_dat$forecast), fc_dat$observed, fc_dat$forecast)
    
    return_dat$prediction_type <- fc_dat[match(newdat$month, fc_dat$month), 'prediction_type']
    return_dat$potholes_filled <- fc_dat[match(newdat$month, fc_dat$month), 'potholes_filled']
  } else if (max_input_month < min_data_month)  {
    return_dat$prediction_type <- 'HISTORICAL'
    return_dat$potholes_filled <- pothole_data[match(newdat$month, pothole_data$month_as_date), 'number_of_potholes']
  } else {
    return_dat$prediction_type <- 'BEFORE HISTORICAL DATA'
    return_dat$potholes_filled <- NA
  }
  return_dat$prediction_type <- ifelse(is.na(return_dat$potholes_filled), 'UNABLE TO FORECAST', return_dat$prediction_type)
  return(return_dat)
}
