/*
 * squeeze.h
 *
 * Code generation for function 'squeeze'
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
void squeeze(const emlrtStack *sp, const emxArray_real_T *a,
             emxArray_real_T *b);

/* End of code generation (squeeze.h) */
