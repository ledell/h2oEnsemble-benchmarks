# Amazon EC2 scripts for Ubuntu 14.04 LT2

- These scripts are modified versions of the scripts from the [h2o/ec2 folder](https://github.com/0xdata/h2o/tree/master/ec2) for working with Ubuntu instances.
- Python and the boto library are required.


## Set up Amazon credentials
In order to use these scripts, you should update the following lines in the `~/.bashrc` file of this instance (the master node).
- Add your Amazon private key to your running instance.  There is a blank ~/.ssh/aws_key.pem` file which you can paste your private key into. 
```
vim ~/.ssh/aws_key.pem
chmod 400 ~/.ssh/aws_key.pem
```
- On the instance, update the EC2 keys section of `~/.bashrc` with your Amazon key info:
```
# EC2 keys
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_SSH_PRIVATE_KEY_FILE="/home/ubuntu/.ssh/aws_key.pem"
```
- Source the file:
```
source ~/.bashrc
```

## Start EC2 cluster
- You should first make the recommended modifications to the `h2o-cluster-launch-instances.py` script.  This includes updating the following:
```
keyName = 'ds' 
securityGroupName = 'h2o'
```
The `keyName` variable refers to the name (in Amazon) that you assigned to the key associated with the `~/.ssh/aws_key.pem` file mentioned above.

- Optionally, you can update the instance type and number of worker nodes:
```
numInstancesToLaunch = 5
instanceType = 'c3.8xlarge'
```
- If you updated the `h2oEnsemble-benchmarks` repo, the AMI id specified in this script should be current and correct.


## Start H2O cluster
- This will distribute the `h2o.jar` file to all the worker nodes, along with your AWS credentials and then start the H2O cluster.
```
./h2o-cluster-distribute-h2o.sh
./h2o-cluster-distribute-aws-credentials.sh
./h2o-cluster-start-h2o.sh
```
- If you need to distribute data files to the worker nodes, you can do that using the following script:
```
./h2o-cluster-distribute-data.sh /path/to/mydata.csv
```
However, if you use the specified AMI for the worker nodes, the benchmark data files should already exist on the worker nodes.  This is only if you want to add your own data files to the repo.


## Stop H2O cluster
- This will stop the H2O cluster, but your worker nodes will still be running and can be terminated manually or using the boto library.  (Script to auto-terminate the worker instances is forthcoming.)
```
./h2o-cluster-stop-h2o.sh
```

Note: If any of this is unclear, please contact me at *ledell _at_ berkeley.edu*.
