/*
 * unique.h
 *
 * Code generation for function 'unique'
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
void unique_vector(const emlrtStack *sp, const emxArray_uint32_T *a,
                   emxArray_uint32_T *b);

/* End of code generation (unique.h) */
