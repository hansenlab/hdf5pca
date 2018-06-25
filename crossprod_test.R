# Notes: 
# 1) Install beachmat and Rhdf5lib
# 2) Link to beachmat from package

# Resources:
# https://cran.rstudio.com/web/packages/Rcpp/vignettes/Rcpp-introduction.pdf
# http://bioconductor.org/packages/release/bioc/html/beachmat.html
# https://github.com/LTLA/MatrixEval2017 
# https://bioc.ism.ac.jp/packages/3.6/bioc/vignettes/beachmat/inst/doc/beachmat.html 
# https://gist.github.com/LTLA/7cf5d6231a9616084803429348760760 

library(BiocParallel)
library(DelayedArray)

ITER <- function(x, grid = NULL) {
  grid <- DelayedArray:::.normarg_grid(grid, x)
  b <- 0L
  function() {
    if (b == length(grid))
      return(NULL)
    b <<- b + 1L
    viewport <- grid[[b]]
    block <- DelayedArray:::extract_block(x, viewport)
    if (!is.array(block))
      block <- DelayedArray:::.as_array_or_matrix(block)
    attr(block, "from_grid") <- grid
    attr(block, "block_id") <- b
    block
  }
}

FUN <- function(i, ...) {
  crossprod(as.matrix(i))
}

REDUCE <- function(x, y) {
  x + y
}

X <- DelayedArray(matrix(rnorm(50000*10000), ncol=10000))
G <- RegularArrayGrid(dim(X), c(100, ncol(X)))

system.time({
  ref <- crossprod(as.matrix(X))
})

system.time({
out <- bpiterate(ITER(X, G), FUN, REDUCE = REDUCE, BPPARAM = MulticoreParam(2))
})

all.equal(out, ref)

# library(Rcpp)
# Test crossprod function
# Rcpp::sourceCpp("crossprod.cpp") 
# 
# ATA = crossprod_cpp(A)
