#!/bin/bash

# A few subsets of the original HIGGS.csv file
curl -O https://s3.amazonaws.com/erin-data/higgs/higgs_train_1k.csv  #first 1k rows of HIGGS.csv 
curl -O https://s3.amazonaws.com/erin-data/higgs/higgs_train_10k.csv
curl -O https://s3.amazonaws.com/erin-data/higgs/higgs_train_100k.csv
curl -O https://s3.amazonaws.com/erin-data/higgs/higgs_train_1M.csv

# The last 500k observations of HIGGS.csv are the designated test set
curl -O https://s3.amazonaws.com/erin-data/higgs/higgs_test_500k.csv
