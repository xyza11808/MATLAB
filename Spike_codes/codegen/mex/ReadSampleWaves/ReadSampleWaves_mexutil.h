//
// ReadSampleWaves_mexutil.h
//
// Code generation for function 'ReadSampleWaves_mexutil'
//

#pragma once

// Include files
#include "rtwtypes.h"
#include "emlrt.h"
#include "mex.h"
#include "omp.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// Function Declarations
real_T b_emlrt_marshallIn(const emlrtStack *sp,
                          const mxArray *a__output_of_feval_,
                          const char_T *identifier);

real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                          const emlrtMsgIdentifier *parentId);

real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                          const emlrtMsgIdentifier *msgId);

// End of code generation (ReadSampleWaves_mexutil.h)
