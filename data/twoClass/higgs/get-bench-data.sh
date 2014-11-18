#!/bin/bash

# A few subsets of the original HIGGS.csv file
wget https://s3.amazonaws.com/uciml-higgs/higgs_1k.csv # first 1k rows of HIGGS.csv 
wget https://s3.amazonaws.com/uciml-higgs/higgs_10k.csv
wget https://s3.amazonaws.com/uciml-higgs/higgs_100k.csv
wget https://s3.amazonaws.com/uciml-higgs/higgs_1M.csv

# The last 500k observations of HIGGS.csv are the designated test set.
wget https://s3.amazonaws.com/uciml-higgs/higgs_test.csv
wget https://s3.amazonaws.com/uciml-higgs/labels_higgs_test.csv
