#!/bin/bash


# Install H2O
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y oracle-java8-installer
java -version


# This is a script will install the necessary software on Ubuntu 16.04 LTS
# This is part of 'h2oEnsemble-benchmarks':
# git clone https://github.com/ledell/h2oEnsemble-benchmarks.git

# Install R
echo "deb http://cran.cnr.berkeley.edu/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get update
sudo apt-get install -y r-base r-base-dev r-recommended

# Install RCurl dependency (for h2o)
sudo apt-get install -y libcurl4-openssl-dev

# Install h2oEnsemble
sudo ./install_h2oEnsemble.R

# To run on Amazon EC2 requires the Python boto library
sudo apt-get install -y python-pip
sudo pip install boto
