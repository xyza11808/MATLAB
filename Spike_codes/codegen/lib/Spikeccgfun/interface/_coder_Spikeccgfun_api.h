/*
 * File: _coder_Spikeccgfun_api.h
 *
 * MATLAB Coder version            : 5.2
 * C/C++ source code generated on  : 14-Apr-2022 23:34:42
 */

#ifndef _CODER_SPIKECCGFUN_API_H
#define _CODER_SPIKECCGFUN_API_H

/* Include Files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Type Definitions */
#ifndef struct_emxArray_uint64_T
#define struct_emxArray_uint64_T
struct emxArray_uint64_T {
  uint64_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_uint64_T */
#ifndef typedef_emxArray_uint64_T
#define typedef_emxArray_uint64_T
typedef struct emxArray_uint64_T emxArray_uint64_T;
#endif /* typedef_emxArray_uint64_T */

#ifndef struct_emxArray_uint32_T
#define struct_emxArray_uint32_T
struct emxArray_uint32_T {
  uint32_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_uint32_T */
#ifndef typedef_emxArray_uint32_T
#define typedef_emxArray_uint32_T
typedef struct emxArray_uint32_T emxArray_uint32_T;
#endif /* typedef_emxArray_uint32_T */

#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T
struct emxArray_real_T {
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_real_T */
#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T
typedef struct emxArray_real_T emxArray_real_T;
#endif /* typedef_emxArray_real_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void Spikeccgfun(emxArray_uint64_T *SpikeTimes, emxArray_uint32_T *SpikeClus,
                 real_T winsize, real_T binsize, boolean_T isSymmetrize,
                 emxArray_real_T *correlograms);

void Spikeccgfun_api(const mxArray *const prhs[5], const mxArray **plhs);

void Spikeccgfun_atexit(void);

void Spikeccgfun_initialize(void);

void Spikeccgfun_terminate(void);

void Spikeccgfun_xil_shutdown(void);

void Spikeccgfun_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_Spikeccgfun_api.h
 *
 * [EOF]
 */
