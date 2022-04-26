/*
 * find.h
 *
 * Code generation for function 'find'
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
void eml_find(const emlrtStack *sp, const emxArray_real_T *x,
              emxArray_int32_T *i);

/* End of code generation (find.h) */
