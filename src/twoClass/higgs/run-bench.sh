#!/bin/bash

BENCH_ROOT="/home/ubuntu/h2oEnsemble-benchmarks"
train_csv="higgs_1k.csv"

nodefile=$BENCH_ROOT/ec2/nodes-public
if [ -f $nodefile ]; then
    cluster_ip=`head -1 $nodefile`
else 
    cluster_ip="localhost"
fi
echo $cluster_ip

cat > launch.sh << EOF
#!/bin/bash
R CMD BATCH --vanilla '--args train_csv="$train_csv" cluster_ip="$cluster_ip"' benchmark_higgs.R &
EOF
chmod u+x launch.sh
nohup ./launch.sh &

