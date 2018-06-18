#include "beachmat/numeric_matrix.h"

/* get_nrow (testing function) */
SEXP get_nrow (SEXP dmat) {
    auto dptr = beachmat::create_numeric_matrix(dmat);
    dptr->get_nrow();
    return dptr->yield();
}

/* cross_prod function */
SEXP crossprod_cpp (SEXP dmat) {
    // Step 1: get_rows
    // Step 2: form crossprod with lapack/RcppArmadillo
    // Iterate and sum up crossprod
    // Return crossprod with yield();
}
