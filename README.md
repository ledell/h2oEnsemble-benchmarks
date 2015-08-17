# h2oEnsemble Benchmarks (H2O 2.0)

**Note:** These benchmarks are for [H2O 2.0](https://github.com/h2oai/h2o-2) (aka. "H2O Classic").  The current version of H2O is [H2O 3.0](https://github.com/h2oai/h2o-3).  An H2O 3.0-compatible version of these benchmarks will be added in the future.  

This repository provides a framework for benchmarking the `h2oEnsemble` package.  The `h2oEnsemble` package provides an R API to train ensembles of [H2O](https://github.com/h2oai/h2o-2) machine learning algorithms.  You can read more about the "H2O Ensemble" project on its [GitHub page](https://github.com/h2oai/h2o-2/tree/master/R/ensemble). 

- An example binary classification benchmark is provided in the `twoClass/higgs` folder.
- To use the software on an Amazon EC2 cluster, follow the instructions in the `ec2/README.md` file to set up the cluster.
- After you set up the cluster, you should `cd` to a specific benchmark directory and execute the benchmark.  For example, the `higgs` benchmark can be executed as follows:
```
cd src/twoClass/higgs
nohup ./run-bench.sh &
```
- If you choose to use a single node instead of a multi-node cluster, you can skip the EC2 steps.  If a multi-node cluster is not available, the code will create a single node multicore cluster using all the cores available on your machine.
- If the benchmark is not executed using the H2O Ubuntu AMI, you may have to change the path of the `BENCH_ROOT` variable in the scripts to point to the location of this repository on your machine.
