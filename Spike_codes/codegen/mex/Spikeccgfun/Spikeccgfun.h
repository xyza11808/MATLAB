/*
 * Spikeccgfun.h
 *
 * Code generation for function 'Spikeccgfun'
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
void Spikeccgfun(const emlrtStack *sp, const emxArray_uint64_T *SpikeTimes,
                 const emxArray_uint32_T *SpikeClus, real_T winsize,
                 real_T binsize, boolean_T isSymmetrize,
                 emxArray_real_T *correlograms);

emlrtCTX emlrtGetRootTLSGlobal(void);

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData);

/* End of code generation (Spikeccgfun.h) */
