#' Historical Pothole Data
#'
#' This data.frame contains historical potholes filled monthly data
#' 
#' \itemize{
#'   \item report_year: a numeric representing the corresponding data year
#'   \item report_month: a a numeric representing of the corresponding data month
#'   \item number_of_potholes: a numeric representing potholes filled monthly
#'   \item month_as_date: a date formatted as 'YYYY-MM-DD' corresponding data month and year 
#' }
#'
#' @docType data
#' @keywords datasets
#' @name pothole_data
#' @usage pothole_data
#' @format a \code{data.frame} with 107 rows and 4 variables
#' @examples
#' \dontrun{
#' data(pothole_data)
#' 
#' head(pothole_data)
#' report_year report_month number_of_potholes month_as_date
#' 1        2007            1              14400    2007-01-01
#' 2        2007            2              11500    2007-02-01
#' 3        2007            3              61800    2007-03-01
#' 4        2007            4              37450    2007-04-01
#' 5        2007            5              94500    2007-05-01
#' 6        2007            6             104250    2007-06-01
#' }
NULL
