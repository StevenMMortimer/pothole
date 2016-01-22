Deploy Edmonton Pothole Prediction Model
====================

This package was created to illustrate how to deploy an R model as an API using OpenCPU. 
The model is included in the `data` directory of the package, and was created
using the [createmodel.R](https://github.com/reportmort/pothole/blob/master/inst/pothole/createmodel.R) script. 
It predicts number of potholes filled monthly in Edmonton.

Below are a set of various commands for hitting the API after it's been created per
instructions laid out by OpenCPU

    # Install & Score in R
    library(devtools)
    install_github("ReportMort/pothole")
    library(pothole)
    mydata <- data.frame(month=c("2016-01-01"))
    pothole_predict(input = mydata)

    # Score from model deployed on opencpu servers
    curl https://public.opencpu.org/ocpu/github/ReportMort/pothole/R/pothole_predict/json \
      -H "Content-Type: application/json" \
      -d '{"input" : [ {"month":"2016-01-01"} ]}'
      
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
    scp -P 2222 /cygdrive/c/users/steven.mortimer/documents/personal-github/pothole_0.0.1.tar.gz vagrant@127.0.0.1:~/.
    vagrant ssh
    sudo R CMD INSTALL pothole.0.0.1.tar.gz --library=/usr/local/lib/R/site-library
    curl http://10.68.12.119/ocpu/library/pothole/R/pothole_predict/json \
      -H "Content-Type: application/json" \
      -d '{"input" : [ {"month":"2016-01-01"} ]}'
      

For users who prefer to not use public hosting provided by OpenCPU
below is a vagrant script for deploying on AWS.

```
access_key_id = ENV['AWS_ACCESS_KEY_ID']
secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

Vagrant.configure("2") do |config|

	config.vm.box = "dummy"
	
	config.vm.provider :aws do |aws, override|
		aws.access_key_id = access_key_id
		aws.secret_access_key = secret_access_key
		aws.keypair_name = "your-keypair-name"
		aws.region = "us-west-2"
		aws.instance_type = "t2.micro"
		aws.ami = "ami-07677666"
		aws.security_groups = ['name-of-your-security-group']

		override.ssh.username = "ubuntu"
		override.ssh.private_key_path = "/path/to/your/private/key.pem"
	
	end

$script = <<BOOTSTRAP

# Install system level dependencies
sudo apt-get update
sudo apt-get upgrade
sudo apt-get build-dep -y libcurl4-gnutls-dev
sudo apt-get build-dep -y libcurl4-openssl-dev
sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y git gcc
sudo apt-get install -y gdebi-core
sudo apt-get install -y libapparmor1
sudo apt-get install -y openjdk-7-jre-headless
sudo apt-get install -y apt-file
sudo apt-file update

# Install the development version of base R
echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" | sudo tee --append /etc/apt/sources.list > /dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo add-apt-repository ppa:marutter/rdev
sudo apt-get update
sudo apt-get -y install r-base r-base-dev

# Install RStudio for the convenience of working directly on the server
wget -q https://download2.rstudio.org/rstudio-server-0.99.489-amd64.deb
gdebi -n rstudio-server-0.99.489-amd64.deb
chmod -R 777 /usr/lib/R/site-library
chmod -R 777 /usr/share/R/doc

# Add a user to be able to access RStudio Server
sudo useradd -d /home/rstudio -m rstudio
echo -e "pass\npass" | (sudo passwd rstudio)

# install the R packages required for this prediction API
sudo R -e "install.packages(c('forecast', 'zoo', 'lubridate'), repos = 'http://cran.rstudio.com/', dep = TRUE)"

# Prevent postfix from prompting for hostname
sudo debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix
 
# Install OpenCPU
sudo add-apt-repository -y ppa:opencpu/opencpu-1.5
sudo apt-get update
sudo apt-get install -y opencpu-server

# Install the package for this prediction API
sudo R -e "install.packages('/vagrant/pothole_0.0.1.tar.gz', repos=NULL, type='source')"

BOOTSTRAP

  config.vm.provision :shell, :inline => $script
  
end
```



