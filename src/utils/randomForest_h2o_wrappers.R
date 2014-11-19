# Create a bunch of h2o.randomForest wrappers from a grid of model params

#source("model_utils.R")  #load model_wrapper_from_list()

description_list <- list("randomForest")
nfolds_list <- list(0)
ntree_list <- list(500)
depth_list <- list(20, 50, 100)
mtries_list <- list(3,4,5,6,7,8,9,10)
sample.rate_list <- list(2/3, 0.75, 0.80, 0.85)
nbins_list <- list(20,50,100)

# Convert param grid to list of model lists
params <- expand.grid(description_list, nfolds_list, ntree_list, depth_list, mtries_list, sample.rate_list, nbins_list)
names(params) <- c("description", "nfolds","ntree","depth","mtries","sample.rate","nbins")
params$body_md5 <- NA

for (i in seq(nrow(params))) {
  mod <- vector("list", length = ncol(params))
  names(mod) <- names(params)
  for (p in seq(ncol(params))) {
   mod[[names(mod)[p]]] <- params[i,p][[1]]
   mod[["classification"]] <- "true"
  }
  params$body_md5[i] <- model_wrapper_from_list(mod)
}
