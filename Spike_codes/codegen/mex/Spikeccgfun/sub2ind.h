/*
 * sub2ind.h
 *
 * Code generation for function 'sub2ind'
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
void eml_sub2ind(const emlrtStack *sp, const int32_T siz[3],
                 const emxArray_real_T *varargin_1,
                 const emxArray_real_T *varargin_2,
                 const emxArray_uint64_T *varargin_3, emxArray_int32_T *idx);

/* End of code generation (sub2ind.h) */
