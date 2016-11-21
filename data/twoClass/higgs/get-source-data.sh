#!/bin/bash

# HIGGS.csv is a 11M row x 29 col (1 label, 28 features) dataset.
# The first column is the class label (1 = signal, 0 = background).
# More info: https://archive.ics.uci.edu/ml/datasets/HIGGS

curl -O https://archive.ics.uci.edu/ml/machine-learning-databases/00280/HIGGS.csv.gz
gunzip HIGGS.csv.gz

