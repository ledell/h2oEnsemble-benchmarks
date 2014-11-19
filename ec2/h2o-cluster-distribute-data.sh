#!/bin/bash

# This will copy a file from the master node to the same location on the worker nodes.
# To use, pass the local file as an argument to the script:
# ./h2o-cluster-distribute-data.sh ~/h2oEnsemble-benchmarks/data/twoClass/higgs_1k.csv

dataFile=$1
dataFileName=`echo $(basename $dataFile)`
dataDir=`echo $(dirname $dataFile)`
mkdirCmd="mkdir -p "$dataDir

set -e

if [ -z ${AWS_SSH_PRIVATE_KEY_FILE} ]
then
    echo "ERROR: You must set AWS_SSH_PRIVATE_KEY_FILE in the environment."
    exit 1
fi

if [ -z ${dataFile} ]
then
    echo "ERROR: Cannot find $dataFile"
    exit 1
fi

i=0
for publicDnsName in $(cat nodes-public)
do
    i=$((i+1))
    echo "Copying data to node ${i}: ${publicDnsName}"
    ssh -i ${AWS_SSH_PRIVATE_KEY_FILE} ubuntu@${publicDnsName} -C ${mkdirCmd}
    scp -o StrictHostKeyChecking=no -i ${AWS_SSH_PRIVATE_KEY_FILE} ${dataFile} ubuntu@${publicDnsName}:${dataFile}
done

echo Success.


