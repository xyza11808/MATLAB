/*
 * _coder_Spikeccgfun_mex.h
 *
 * Code generation for function '_coder_Spikeccgfun_mex'
 *
 */

#pragma once

/* Include files */
#include "rtwtypes.h"
#include "emlrt.h"
#include "mex.h"
#include "omp.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void Spikeccgfun_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs,
                             const mxArray *prhs[5]);

MEXFUNCTION_LINKAGE void mexFunction(int32_T nlhs, mxArray *plhs[],
                                     int32_T nrhs, const mxArray *prhs[]);

emlrtCTX mexFunctionCreateRootTLS(void);

/* End of code generation (_coder_Spikeccgfun_mex.h) */
