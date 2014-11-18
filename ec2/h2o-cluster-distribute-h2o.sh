#!/bin/bash

set -e

if [ -z ${AWS_SSH_PRIVATE_KEY_FILE} ]
then
    echo "ERROR: You must set AWS_SSH_PRIVATE_KEY_FILE in the environment."
    exit 1
fi

# If you jar file is elsewhere, this will need to be updated.
# However, this is the correct location for the H2O Ubuntu AMI
h2oJarFile="/home/ubuntu/h2o/target/h2o.jar"

if [ -z ${h2oJarFile} ]
then
    echo "ERROR: Cannot file h2o.jar file."
    exit 1
fi

echo Using ${h2oJarFile}

i=0
for publicDnsName in $(cat nodes-public)
do
    i=$((i+1))
    echo "Copying h2o.jar to node ${i}: ${publicDnsName}"
    scp -o StrictHostKeyChecking=no -i ${AWS_SSH_PRIVATE_KEY_FILE} ${h2oJarFile} ubuntu@${publicDnsName}:
done

echo Success.


