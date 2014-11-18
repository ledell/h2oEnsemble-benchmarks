# Create algorithm wrapper functions from json files and R lists


# Example json model param file. This is a deeplearning model for HIGGS.csv
# json_path <- "/home/ubuntu/h2oEnsemble-benchmarks/models/twoClass/higgs"
# json_file <- paste(json_path, "deeplearning_higgs_arno_best.json", sep="/")


model_list_from_json <- function(json_file) {
  # Read a set of model parameters from a json file
  # and return model parameters as a list.

  if (!file.exists(json_file)) {
    stop(sprintf("File does not exist: %s", json_file))
  }
  require(jsonlite)
  mod <- fromJSON(txt=json_file)
  return(mod)
}  

  
  
model_wrapper_from_list <- function(mod) {  
  # Create a model wrapper base learner function
  # from a list of model parameters.
  
  require(digest)
  `%+%` <- function(a, b) paste0(a, b)
  
  if (tolower(mod$description)=="deeplearning") {
    family <- ifelse(mod$classification=="true", "binomial", "gaussian")
    # Currently only looks at the following hardcoded options:
    nfolds <- mod$nfolds
    activation <- mod$activation
    hidden <- mod$hidden
    hidden_str <- "hidden"%+%" = c"%+%"("%+%paste(hidden, collapse=",")%+%")"
    l1 <- mod$l1
    l2 <- mod$l2
    epochs <- mod$epochs
    fun_body <- sprintf(' <- function(..., family = "%s", nfolds = %s, activation = "%s", %s, epochs = %s, l1 = %s, l2 = %s) h2o.deeplearning.wrapper(..., family = family, nfolds = nfolds, activation = activation, hidden = hidden, epochs = epochs, l1 = l1, l2 = l2)', family, nfolds, activation, hidden_str, epochs, l1, l2)
    prefix <- "h2o.deeplearning."  
  } else if (tolower(mod$description)=="randomforest") {
    family <- ifelse(mod$classification=="true", "binomial", "gaussian")
    # Currently only looks at the following hardcoded options:
    nfolds <- mod$nfolds
    ntree <- mod$ntree
    depth <- mod$depth
    mtries <- mod$mtries
    sample.rate <- mod$sample.rate
    nbins <- mod$nbins
    fun_body <- sprintf(' <- function(..., family = "%s", ntree = %s, depth = %s, mtries = %s, sample.rate = %s, nbins = %s, nfolds = %s) h2o.randomForest.wrapper(..., family = family, ntree = ntree, depth = depth, mtries = mtries, sample.rate = sample.rate, nbins = nbins, nfolds = nfolds)', family, ntree, depth, mtries, sample.rate, nbins, nfolds)    
    prefix <- "h2o.randomForest."  
  } else {
    stop("Model type not supported.  Will add support for all models soon.")
  }
  # Now get a hash for this set of model params (specified by function wrapper)
  model_wrapper_md5 <- digest(fun_body)
  eval(parse(text = paste(prefix, model_wrapper_md5, fun_body, sep = '')), envir = .GlobalEnv)
  return(model_wrapper_md5)
}


