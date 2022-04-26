/*
 * eml_i64relops.h
 *
 * Code generation for function 'eml_i64relops'
 *
 */

#pragma once

/* Include files */
#include "Spikeccgfun_types.h"
#include "rtwtypes.h"
#include "emlrt.h"
#include "mex.h"
#include "omp.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void eml_i64relops(const emlrtStack *sp, const emxArray_uint64_T *a, real_T b,
                   emxArray_boolean_T *p);

/* End of code generation (eml_i64relops.h) */
