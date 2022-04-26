/*
 * Spikeccgfun_emxutil.h
 *
 * Code generation for function 'Spikeccgfun_emxutil'
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
void emxEnsureCapacity_boolean_T(const emlrtStack *sp,
                                 emxArray_boolean_T *emxArray, int32_T oldNumel,
                                 const emlrtRTEInfo *srcLocation);

void emxEnsureCapacity_int32_T(const emlrtStack *sp, emxArray_int32_T *emxArray,
                               int32_T oldNumel,
                               const emlrtRTEInfo *srcLocation);

void emxEnsureCapacity_real_T(const emlrtStack *sp, emxArray_real_T *emxArray,
                              int32_T oldNumel,
                              const emlrtRTEInfo *srcLocation);

void emxEnsureCapacity_uint32_T(const emlrtStack *sp,
                                emxArray_uint32_T *emxArray, int32_T oldNumel,
                                const emlrtRTEInfo *srcLocation);

void emxEnsureCapacity_uint64_T(const emlrtStack *sp,
                                emxArray_uint64_T *emxArray, int32_T oldNumel,
                                const emlrtRTEInfo *srcLocation);

void emxFree_boolean_T(emxArray_boolean_T **pEmxArray);

void emxFree_int32_T(emxArray_int32_T **pEmxArray);

void emxFree_real_T(emxArray_real_T **pEmxArray);

void emxFree_uint32_T(emxArray_uint32_T **pEmxArray);

void emxFree_uint64_T(emxArray_uint64_T **pEmxArray);

void emxInit_boolean_T(const emlrtStack *sp, emxArray_boolean_T **pEmxArray,
                       int32_T numDimensions, const emlrtRTEInfo *srcLocation,
                       boolean_T doPush);

void emxInit_int32_T(const emlrtStack *sp, emxArray_int32_T **pEmxArray,
                     int32_T numDimensions, const emlrtRTEInfo *srcLocation,
                     boolean_T doPush);

void emxInit_real_T(const emlrtStack *sp, emxArray_real_T **pEmxArray,
                    int32_T numDimensions, const emlrtRTEInfo *srcLocation,
                    boolean_T doPush);

void emxInit_uint32_T(const emlrtStack *sp, emxArray_uint32_T **pEmxArray,
                      int32_T numDimensions, const emlrtRTEInfo *srcLocation,
                      boolean_T doPush);

void emxInit_uint64_T(const emlrtStack *sp, emxArray_uint64_T **pEmxArray,
                      int32_T numDimensions, const emlrtRTEInfo *srcLocation,
                      boolean_T doPush);

/* End of code generation (Spikeccgfun_emxutil.h) */
