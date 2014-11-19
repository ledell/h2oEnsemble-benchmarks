# This script benchmarks H2O Ensemble using the "HIGGS" dataset from UCI ML Repo

# Two optional arguments:
# 1. train_csv (e.g. "higgs_1k.csv" or "higgs_100k.csv") The HIGGS.csv training sub-sample
# 2. cluster_ip

# Currently the level-one data (input to metalearner) is generated with 5-fold CV,
# but this can changed below in h2o.ensemble cvControl argument


# Root directory of bench repo (change this if necessary)
BENCH_ROOT <- "/home/ubuntu/h2oEnsemble-benchmarks"

# Parse arguments
args <- (commandArgs(TRUE))
if(length(args)>0){
  eval(parse(text=args))
} else {
  warning("Default training set will be used: higgs_1k.csv")
}
if (!exists("train_csv")) train_csv <- "higgs_1k.csv"
print(train_csv)
if (!exists("cluster_ip")) cluster_ip <- "localhost"
if (cluster_ip %in% c("localhost", "127.0.0.1")) {
  startH2O <- TRUE
} else {
  startH2O <- FALSE
}
print(cluster_ip)


# Load libraries and establish H2O cluster connection
library(h2oEnsemble)
library(SuperLearner)  #For metalearner such as 'SL.glm'
library(cvAUC)  #Used to calculate test set AUC
library(doParallel)  #To calculate base learner test AUC in parallel
library(digest)  #To hash model param set
localH2O <-  h2o.init(ip = cluster_ip, port = 54321, startH2O = startH2O, nthreads = -1)


# Load training data
data_path <- sprintf("%s/data/twoClass/higgs", BENCH_ROOT)
model_path <- sprintf("%s/models/twoClass/higgs", BENCH_ROOT)
data <- h2o.importFile(localH2O, path = sprintf("%s/%s", data_path, train_csv))
y <- "C1"
x <- setdiff(names(data), y)
family <- "binomial"


# Load the base learner and metalearner wrapper functions
source("../../utils/model_utils.R")
source("../../utils/deeplearning_h2o_wrappers.R")
source("../../utils/randomForest_h2o_wrappers.R")
source("../../utils/SuperLearner_wrappers.R")  #Loads SL.nnls metalearner function


# Set up the ensemble by choosing a base learner library and metalearer
# You should experiment with different sets of base learners
rf_learner <- c("h2o.randomForest.02620d96c77d8f95808b5ed9a2c4f206","h2o.randomForest.534d97175123845403361a32d089daef")
dl_learner <- c("h2o.deeplearning.87da9b2906cac510d2949b14cd7747b9", "h2o.deeplearning.17634431ca5a6255cce017d001930278")
learner <- c(rf_learner, dl_learner) 
metalearner <- "SL.glm"
#metalearner <- "SL.nnls"


# Train the ensemble
fit <- h2o.ensemble(x = x, y = y, data = data, family = family, 
                    learner = learner, metalearner = metalearner,
                    cvControl = list(V=5))


# Load test set and generate predictions on the test set
newdata <- h2o.importFile(localH2O, path = sprintf("%s/higgs_test.csv", data_path))
pred <- predict(fit, newdata)


# Ensemble test AUC
labels <- as.data.frame(newdata[,c(y)])[,1]
auc <- AUC(predictions = as.data.frame(pred$pred)[,1], 
      labels = labels)
print(auc)


# Base learner test set AUC (for comparison)
L <- length(learner)
cl <- makeCluster(min(L, detectCores()))
clusterExport(cl, c("pred", "labels", "AUC")) 
learner_auc <- parSapply(cl=cl, X=seq(L), function(i) AUC(as.data.frame(pred$basepred)[,i], labels)) 
stopCluster(cl)
print(learner_auc)


# Save the results
n_train <- nrow(data)
learner_md5 <- digest(learner, algo=c("md5"))
metalearner_md5 <- digest(metalearner, algo=c("md5"))
res <- list(fit=fit, 
            pred=pred,
            learner=learner, 
            metalearner=metalearner, 
            learner_md5=learner_md5,
            metalearner_md5=metalearner_md5,
            n_train=n_train, 
            auc=auc, 
            learner_auc=learner_auc)
save(res, file=sprintf("%s/models/twoClass/higgs/h2oe_higgs_%s_%s_%s.rda", BENCH_ROOT, n_train, learner_md5, metalearner_md5))


