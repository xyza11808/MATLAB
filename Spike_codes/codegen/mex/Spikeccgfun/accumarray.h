/*
 * accumarray.h
 *
 * Code generation for function 'accumarray'
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
void accumarray(const emlrtStack *sp, const emxArray_real_T *subs,
                emxArray_real_T *A);

/* End of code generation (accumarray.h) */
