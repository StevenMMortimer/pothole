.onLoad <- function(lib, pkg){
  #automatically loads the model and historical when package is loaded
  #do not use this in combination with lazydata=true
  utils::data(pothole_model, package = pkg, envir = parent.env(environment()))
  utils::data(pothole_data, package = pkg, envir = parent.env(environment()))
}
