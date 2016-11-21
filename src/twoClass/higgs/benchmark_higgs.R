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
  warning("Default training set will be used: higgs_train_1k.csv")
}
if (!exists("train_csv")) train_csv <- "higgs_train_1k.csv"
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
library(digest)  #To hash model param set
h2o.init(ip = cluster_ip, port = 54321, startH2O = startH2O, nthreads = -1, max_mem_size = "50G")
#h2o.init(ip = "localhost", port = 54321, startH2O = startH2O, nthreads = -1, max_mem_size = "40960M")


# Load training data
data_path <- sprintf("%s/data/twoClass/higgs", BENCH_ROOT)
model_path <- sprintf("%s/models/twoClass/higgs", BENCH_ROOT)
train <- h2o.importFile(sprintf("%s/%s", data_path, train_csv))
y <- "response"
x <- setdiff(names(train), y)
family <- "binomial"
train[,y] <- as.factor(train[,y])  #Convert outcome to a factor for binary classification


# Load the base learner and metalearner wrapper functions
source("../../utils/model_utils.R")
source("../../utils/deeplearning_h2o_wrappers.R")
source("../../utils/randomForest_h2o_wrappers.R")


# Set up the ensemble by choosing a base learner library and metalearer
# You should experiment with different sets of base learners using the supplied wrappers,
# or even better, create your own custom wrappers for the base learners for a wider selection
rf_learner <- c("h2o.randomForest.08f3779d812c53cc0d608ba4199b84ca")
#dl_learner <- c("h2o.deeplearning.b5b29dfedea061bc0201efd7a9687ef4", "h2o.deeplearning.ccd3e304cf95b23447917dc937c21694")
#dl_learner <- c("h2o.deeplearning.a6337d1830cc1958ee4db0af3da00fb8", "h2o.deeplearning.ccd3e304cf95b23447917dc937c21694")
#dl_learner <- c("h2o.deeplearning.6eb5f17d28b06b8cb77796d08412a7fc", 
#	"h2o.deeplearning.f1fd67689316344ca72fcc78f3f6476d",
#	"h2o.deeplearning.87da9b2906cac510d2949b14cd7747b9",
#	"h2o.deeplearning.92009d10c4d21af26ccf766c92d734f5",
#	"h2o.deeplearning.23a00746dc81a69753ef7182c792986a")
dl_learner <- c("h2o.deeplearning.26cb32b0398c5facd4e8f7c976d29211",
	"h2o.deeplearning.23a00746dc81a69753ef7182c792986a")
	 

learner <- c(rf_learner, dl_learner)
h2o.glm_nn <- function(..., non_negative = TRUE) {
  h2o.glm.wrapper(..., non_negative = non_negative)
}
metalearners <- c("h2o.glm", "h2o.glm_nn") #Metalearners to use (only one at a time, multiple will create multiple fits)
#metalearner <- "h2o.glm"


# Train the ensemble
fit <- h2o.ensemble(x = x, y = y, training_frame = train, family = family, 
                    learner = learner, metalearner = metalearners[1],
                    cvControl = list(V=2))
print(fit$runtime)

# Load test set and generate predictions on the test set
test <- h2o.importFile(sprintf("%s/higgs_test_500k.csv", data_path))
test[,y] <- as.factor(test[,y])


# Ensemble & base learner performance
perf <- h2o.ensemble_performance(fit, newdata = test)
auc <- h2o.auc(perf$ensemble)
print(auc)
learner_auc <- as.vector(sapply(perf$base, h2o.auc))
print(learner_auc)


# Save the results
n_train <- nrow(train)
learner_md5 <- digest(learner, algo = c("md5"))
metalearner_md5 <- digest(metalearners[1], algo = c("md5"))
litefit <- fit
litefit[["basefits"]] <- NULL
litefit[["metafit"]] <- NULL
litefit[["Z"]] <- NULL

res <- list(fit = litefit,  #to save space, don't save fits for now 
            pred = NULL,  #from old version of the code
            learner = learner, 
            metalearner = metalearners[1], 
            learner_md5 = learner_md5,
            metalearner_md5 = metalearner_md5,
            n_train = n_train, 
            n_test = nrow(test), 
            auc = auc, 
            learner_auc = learner_auc,
            perf = perf)
save(res, file = sprintf("%s/models/twoClass/higgs/h2oe_higgs_%s_%s_%s.rda", BENCH_ROOT, n_train, learner_md5, metalearner_md5))


# Recombine using the remainder of the metalearners
if (length(metalearners) > 1) {
  for (i in 2:length(metalearners)) {
    print(metalearners[i])
    refit <- h2o.metalearn(fit, metalearner = metalearners[i])
    perf <- h2o.ensemble_performance(fit, newdata = test)
    auc <- h2o.auc(perf$ensemble)
    print(auc)
    learner_auc <- as.vector(sapply(perf$base, h2o.auc))
    print(learner_auc)
    metalearner_md5 <- digest(metalearners[i], algo = c("md5"))
    litefit <- refit
    litefit[["basefits"]] <- NULL
    litefit[["metafit"]] <- NULL
    litefit[["Z"]] <- NULL
    res[["fit"]] <- litefit
    res[["metalearner_md5"]] <- metalearner_md5 
    res[["auc"]] <- auc
    res[["learner_auc"]] <- learner_auc
    res[["perf"]] <- perf
    save(res, file = sprintf("%s/models/twoClass/higgs/h2oe_higgs_%s_%s_%s.rda", BENCH_ROOT, n_train, learner_md5, metalearner_md5))
  }
}

h2o.shutdown(prompt = FALSE)

