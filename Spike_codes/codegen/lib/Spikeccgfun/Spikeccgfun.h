/*
 * File: Spikeccgfun.h
 *
 * MATLAB Coder version            : 5.2
 * C/C++ source code generated on  : 14-Apr-2022 23:34:42
 */

#ifndef SPIKECCGFUN_H
#define SPIKECCGFUN_H

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
extern void Spikeccgfun(const emxArray_uint64_T *SpikeTimes,
                        const emxArray_uint32_T *SpikeClus, double winsize,
                        double binsize, boolean_T isSymmetrize,
                        emxArray_real_T *correlograms);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for Spikeccgfun.h
 *
 * [EOF]
 */
