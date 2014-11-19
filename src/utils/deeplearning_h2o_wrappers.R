# Create a bunch of h2o.randomForest wrappers from a grid of model params

#source("model_utils.R")  #load model_wrapper_from_list()

description_list <- list("deeplearning")
nfolds_list <- list(0)
hidden_list <- list(c(200,200), c(500,500,500))
activation_list <- list("Tanh", "Rectifier", "RectifierWithDropout")
epochs_list <- list(100, 400)
l1_list <- list(0.0, 1e-5) 
l2_list <- list(0.0, 1e-5)

# Convert param grid to list of model lists
params <- expand.grid(description_list, nfolds_list, hidden_list, activation_list, epochs_list, l1_list, l2_list)
names(params) <- c("description", "nfolds","hidden","activation","epochs","l1","l2")
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

