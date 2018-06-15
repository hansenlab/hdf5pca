# hdf5pca

## First strategy

We want code to compute `svd(scale(X))` where `scale(X)` is having rows (or columns) of `X` having zero mean and unit variance.  We are assuming that one dimension of `X` is much smaller than the other, and that it is feasible to have a square matrix of the smaller dimension in memory. We will approach this by the strategy of computing one of the two crossproducts `t(X) %*% X` or `X %*% t(X)`, whichever is the smaller dimension, followed by an SVD of the crossproduct.  We will utilize that we can compute the cross product in an embarrasingly parallel way.

I suggest starting by focusing on only one situation, either a tall or a wide matrix.

We will use `X` is stored as an HDF5 backed `SummarizedExperiment` and I propose we use `beachmat` to interfact to this object.  This package allows for low-level access to an HDF5 object.

In very rough pseudo code
  - read in a small part of X
  - form the cross product for this small part of X, perhaps by a call to lapack or by using RcppArmadillo
  - return the crossproduct
This pseudocode ignores the difference between `X` and `scale(X)`.

`beachmat` has a lot of documentation: [beachmat](https://bioconductor.org/packages/devel/bioc/html/beachmat.html) (always use Bioc devel or `conda_R/R-3.5.x` on JHPCE. There is also a paper [beachmat_paper](https://doi.org/10.1371/journal.pcbi.1006135)

**Dataset**: as a test dataset we can use [TENxBrainData](https://www.bioconductor.org/packages/devel/data/experiment/html/TENxBrainData.html). This is a (large) dataset of dimension 28k x 1.3M (wide). It may be good to start with subsets of this dataset due to its size. 

- FIMXE: need to put in R package structure, inside a subdir of this repos.
