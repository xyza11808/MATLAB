/*
 * File: Spikeccgfun_emxutil.h
 *
 * MATLAB Coder version            : 5.2
 * C/C++ source code generated on  : 14-Apr-2022 23:34:42
 */

#ifndef SPIKECCGFUN_EMXUTIL_H
#define SPIKECCGFUN_EMXUTIL_H

/* Include Files */
#include "Spikeccgfun_types.h"
#include "rtwtypes.h"
#include "omp.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void emxEnsureCapacity_boolean_T(emxArray_boolean_T *emxArray,
                                        int oldNumel);

extern void emxEnsureCapacity_int32_T(emxArray_int32_T *emxArray, int oldNumel);

extern void emxEnsureCapacity_real_T(emxArray_real_T *emxArray, int oldNumel);

extern void emxEnsureCapacity_uint32_T(emxArray_uint32_T *emxArray,
                                       int oldNumel);

extern void emxEnsureCapacity_uint64_T(emxArray_uint64_T *emxArray,
                                       int oldNumel);

extern void emxFree_boolean_T(emxArray_boolean_T **pEmxArray);

extern void emxFree_int32_T(emxArray_int32_T **pEmxArray);

extern void emxFree_real_T(emxArray_real_T **pEmxArray);

extern void emxFree_uint32_T(emxArray_uint32_T **pEmxArray);

extern void emxFree_uint64_T(emxArray_uint64_T **pEmxArray);

extern void emxInit_boolean_T(emxArray_boolean_T **pEmxArray,
                              int numDimensions);

extern void emxInit_int32_T(emxArray_int32_T **pEmxArray, int numDimensions);

extern void emxInit_real_T(emxArray_real_T **pEmxArray, int numDimensions);

extern void emxInit_uint32_T(emxArray_uint32_T **pEmxArray, int numDimensions);

extern void emxInit_uint64_T(emxArray_uint64_T **pEmxArray, int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for Spikeccgfun_emxutil.h
 *
 * [EOF]
 */
