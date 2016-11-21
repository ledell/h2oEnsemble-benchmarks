#!/usr/bin/Rscript

#update.packages(ask = FALSE)

# This will unload and uninstall h2o and h2oEnsemble packages, if installed.

if ("package:h2oEnsemble" %in% search()) { detach("package:h2oEnsemble", unload=TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2oEnsemble") }
if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }


# This will install a the most recent version of h2o and h2oEnsemble as of 11/20/2016.
# Specific versions are listed here, for reproducibility reasons, however newer versions
# or both packages can be used as they become available.

# Next, we download packages that H2O depends on.
pkgs <- c("methods","statmod","stats","graphics","RCurl","jsonlite","tools","utils")
for (pkg in pkgs) {
  if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg, repo="http://cran.rstudio.com/") }
}

install.packages("h2o", type="source", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/rel-turing/10/R")))
install.packages("https://h2o-release.s3.amazonaws.com/h2o-ensemble/R/h2oEnsemble_0.1.8.tar.gz", repos = NULL)
