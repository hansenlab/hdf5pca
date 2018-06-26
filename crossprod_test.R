# Resources:
# https://gist.github.com/LTLA/7cf5d6231a9616084803429348760760 

library(BiocParallel)
library(DelayedArray)
library(HDF5Array)

read_time = 0
ITER <- function(x, grid = NULL) {
  grid <- DelayedArray:::.normarg_grid(grid, x)
  b <- 0L
  function() {
    if (b == length(grid))
      return(NULL)
    b <<- b + 1L
    viewport <- grid[[b]]
    start_time = proc.time()
    block <- DelayedArray:::extract_block(x, viewport)
    if (!is.array(block))
      block <- DelayedArray:::.as_array_or_matrix(block)
    read_time = read_time + (proc.time() - start_time)
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

row_n = 1000
X <- DelayedArray(matrix(rnorm(50000*1000), ncol=1000))
system.time({
  X_disk = writeHDF5Array(X, chunkdim = c(row_n, ncol(X)))
})
X = DelayedArray(X_disk)
G <- RegularArrayGrid(dim(X), c(row_n, ncol(X)))

system.time({
  ref <- crossprod(as.matrix(X))
})

system.time({
  out <- bpiterate(ITER(X, G), FUN, REDUCE = REDUCE, BPPARAM = MulticoreParam(2))
})

print(read_time)

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
