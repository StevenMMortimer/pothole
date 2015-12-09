Deploy Edmonton Pothole Prediction Model
====================

This package illustrates how to deploy a model for remote scoring/prediction. 

    # Install & Score in R
    library(devtools)
    install_github("ReportMort/pothole")
    library(pothole)
    mydata <- data.frame(month=c("2016-01-01"))
    pothole_predict(input = mydata)

    # Score from model deployed on opencpu servers
    curl https://public.opencpu.org/ocpu/github/ReportMort/pothole/R/pothole_predict/json \
      -H "Content-Type: application/json" \
      -d '{"input" : [ {"year":1914} ]}'
      
    # Score from R using RCurl
    library(RCurl)
    library(RJSONIO)
    res <- postForm("https://public.opencpu.org/ocpu/github/ReportMort/pothole/R/pothole_predict/json",
            .opts = list(postfields = toJSON(list(input=list(month="2016-01-01"))),
            httpheader = c('Content-Type' = 'application/json', Accept = 'application/json'),
            ssl.verifypeer = FALSE))
    fromJSON(res)
      
    # Score using Vagrant and Virtualbox
    # First setup virtual machine, copy package to it, ssh into it and install, and run curl against that machine
    scp -P 2222 /cygdrive/c/users/steven.mortimer/documents/personal-github/beard_0.0.tar.gz vagrant@127.0.0.1:~/.
    vagrant ssh
    sudo R CMD INSTALL pothole.0.0.1.tar.gz --library=/usr/local/lib/R/site-library
    curl http://10.68.12.119/ocpu/library/pothole/R/pothole_predict/json \
      -H "Content-Type: application/json" \
      -d '{"input" : [ {"month":"2016-01-01"} ]}'
      
The model is included in the `data` directory of the package, and was created
using the [createmodel.R](https://github.com/reportmort/pothole/blob/master/inst/pothole/createmodel.R) script. 
It predicts number of potholes filled monthly in Edmonton.
