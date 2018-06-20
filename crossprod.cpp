#include "beachmat/numeric_matrix.h"
#include <RcppArmadillo.h>

/* get_nrow (testing function) */
const std::size_t get_nrow (SEXP dmat) {
    auto dptr = beachmat::create_numeric_matrix(dmat);
    const std::size_t nrow = dptr->get_nrow();
    return nrow;
}

/* cross_prod function */
RcppArmadillo::mat crossprod_cpp (SEXP dmat) {
    auto dptr = beachmat::create_numeric_matrix(dmat); // pointer to numeric_matrix
    const std::size_t nrow = dptr->get_nrow();
    const std::size_t ncol = dptr->get_ncol();
    RcppArmadillo::mat out = zeros(ncol, ncol);                       // matrix of zeros

    for(int r = 0; r < nrow; ++r){
    // Step 1: get_row r
        Rcpp::NumericVector::iterator in;
        dptr->get_row(r, in);
    // Step 2: form crossprod with lapack/RcppArmadillo
        RcppArmadillo::mat temp = *in.t() * *in;
        out = out + temp;
    }
    // Return crossprod;
    return out;
}
