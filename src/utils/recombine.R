h2o.recombine <- function(fit, y, data, family, metalearner = "SL.nnls") {
  
  x <- fit$x
  y <- fit$y
  family <- fit$family
  seed <- fit$seed
  
  # Metalearning: Regress y onto Z to learn optimal combination of base models
  print("Metalearning")
  if (is.numeric(seed)) set.seed(seed) #If seed given, set seed prior to next step
  if (grepl("^SL.", metalearner)) {
    # this is very hacky and should be used only for testing until we get the h2o metalearner functions sorted out...
    familyFun <- get(family, mode = "function", envir = parent.frame())
    Ztmp <- fit$Z[, -which(names(fit$Z) %in% c("fold_id", y))]
    N <- nrow(Ztmp)
    runtime <- fit$runtime
    runtime$metalearning <- system.time(metafit <- match.fun(metalearner)(Y=as.data.frame(data[,c(y)])[,1], X=Ztmp, newX=Ztmp,
                                                                          family=familyFun, id=seq(N), obsWeights=rep(1,N)), gcFirst=FALSE)
  } else {
    # Convert Z to H2OParsedData object (should remove when .make_Z is modified to create the H2OParsedData object directly)
    Z.hex <- as.h2o(localH2O, Z, key="Z.hex")
    runtime$metalearning <- system.time(metafit <- match.fun(metalearner)(x=learner, y=y, data=Z.hex, family=family), gcFirst=FALSE)
  }
  
  # Now re-save the fit (just replace the metafit element in the fit)
  # Ensemble model
  out <- list(x = fit$x,
              y = fit$y,
              family = fit$family,
              cvControl = fit$cvControl,
              folds = fit$folds,
              ylim = fit$ylim,
              seed = fit$seed,
              parallel = fit$parallel,
              basefits = fit$basefits,
              metafit = metafit,
              Z = fit$Z,
              runtime = runtime)
  class(out) <- "h2o.ensemble"
  return(out)
}

