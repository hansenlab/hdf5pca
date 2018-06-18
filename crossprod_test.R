# Notes: 
# 1) Install beachmat and Rhdf5lib
# 2) Link to beachmat from package

# Resources:
# https://cran.rstudio.com/web/packages/Rcpp/vignettes/Rcpp-introduction.pdf
# http://bioconductor.org/packages/release/bioc/html/beachmat.html
# https://github.com/LTLA/MatrixEval2017 

library(Rcpp)

# Test crossprod function
Rcpp::sourceCpp("crossprod.cpp") 

ATA = crossprod_cpp(A)
