/*
 * File: Spikeccgfun_emxAPI.h
 *
 * MATLAB Coder version            : 5.2
 * C/C++ source code generated on  : 14-Apr-2022 23:34:42
 */

#ifndef SPIKECCGFUN_EMXAPI_H
#define SPIKECCGFUN_EMXAPI_H

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
extern emxArray_real_T *emxCreateND_real_T(int numDimensions, const int *size);

extern emxArray_uint32_T *emxCreateND_uint32_T(int numDimensions,
                                               const int *size);

extern emxArray_uint64_T *emxCreateND_uint64_T(int numDimensions,
                                               const int *size);

extern emxArray_real_T *
emxCreateWrapperND_real_T(double *data, int numDimensions, const int *size);

extern emxArray_uint32_T *emxCreateWrapperND_uint32_T(unsigned int *data,
                                                      int numDimensions,
                                                      const int *size);

extern emxArray_uint64_T *emxCreateWrapperND_uint64_T(unsigned long long *data,
                                                      int numDimensions,
                                                      const int *size);

extern emxArray_real_T *emxCreateWrapper_real_T(double *data, int rows,
                                                int cols);

extern emxArray_uint32_T *emxCreateWrapper_uint32_T(unsigned int *data,
                                                    int rows, int cols);

extern emxArray_uint64_T *emxCreateWrapper_uint64_T(unsigned long long *data,
                                                    int rows, int cols);

extern emxArray_real_T *emxCreate_real_T(int rows, int cols);

extern emxArray_uint32_T *emxCreate_uint32_T(int rows, int cols);

extern emxArray_uint64_T *emxCreate_uint64_T(int rows, int cols);

extern void emxDestroyArray_real_T(emxArray_real_T *emxArray);

extern void emxDestroyArray_uint32_T(emxArray_uint32_T *emxArray);

extern void emxDestroyArray_uint64_T(emxArray_uint64_T *emxArray);

extern void emxInitArray_real_T(emxArray_real_T **pEmxArray, int numDimensions);

extern void emxInitArray_uint32_T(emxArray_uint32_T **pEmxArray,
                                  int numDimensions);

extern void emxInitArray_uint64_T(emxArray_uint64_T **pEmxArray,
                                  int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for Spikeccgfun_emxAPI.h
 *
 * [EOF]
 */
