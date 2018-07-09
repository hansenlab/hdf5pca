# crossprod_test.R
# ---------------------------------------------
#
# Author:             Albert Kuo
# Date last modified: July 9, 2018
#
# Test crossprod function for HDF5 matrices

# Resources:
# https://gist.github.com/LTLA/7cf5d6231a9616084803429348760760 

library(BiocParallel)
library(DelayedArray)
library(HDF5Array)

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

row_n = 100 # Number of rows per block read
X <- DelayedArray(matrix(rnorm(50000*1000), ncol=1000))
G <- RegularArrayGrid(dim(X), c(row_n, ncol(X)))

## Test 1
# Regular crossprod
system.time({
  ref <- crossprod(as.matrix(X))
})

## Test 2
# Crossprod on DelayedArray of in memory matrix
system.time({
  out <- bpiterate(ITER(X, G), FUN, REDUCE = REDUCE, BPPARAM = MulticoreParam(2))
})

## Test 3
# Crossprod on DelayedArray of HDF5 matrix
use_HDF5 = T
if(use_HDF5){
  system.time({
    X_disk = writeHDF5Array(X, chunkdim = c(row_n, ncol(X)))
  })
  X2 = DelayedArray(X_disk)
}
system.time({
  out2 <- bpiterate(ITER(X2, G), FUN, REDUCE = REDUCE, BPPARAM = MulticoreParam(2))
})

## Test 4
# Crossprod on list of matrices
blocks_n = 50000/row_n # Length of list
X_ls  = lapply(1:blocks_n, function(i) matrix(rnorm(row_n*1000), ncol=1000))
system.time({
  crossprod_ls = lapply(X_ls, function(X) crossprod(X))
  out3 = Reduce(REDUCE, crossprod_ls)
})

all.equal(out, ref)

# (Old) Notes: 
# 1) Install beachmat and Rhdf5lib
# 2) Link to beachmat from package
# https://cran.rstudio.com/web/packages/Rcpp/vignettes/Rcpp-introduction.pdf
# http://bioconductor.org/packages/release/bioc/html/beachmat.html
# https://github.com/LTLA/MatrixEval2017 
# https://bioc.ism.ac.jp/packages/3.6/bioc/vignettes/beachmat/inst/doc/beachmat.html 

# library(Rcpp)
# Test crossprod function
# Rcpp::sourceCpp("crossprod.cpp") 
# 
# ATA = crossprod_cpp(A)
