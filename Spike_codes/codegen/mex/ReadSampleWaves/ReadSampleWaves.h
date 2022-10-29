//
// ReadSampleWaves.h
//
// Code generation for function 'ReadSampleWaves'
//

#pragma once

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include "emlrt.h"
#include "mex.h"
#include "omp.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// Function Declarations
void ReadSampleWaves(const emlrtStack *sp,
                     const coder::array<char_T, 2U> &fullpaths,
                     const coder::array<uint64_T, 2U> &UsedSptimes,
                     const real_T WaveWinSamples[2], real_T TotalSamples,
                     real_T cClusChannel, coder::array<real_T, 2U> &cspWaveform,
                     coder::array<real_T, 3U> &AllChannelWaveData);

emlrtCTX emlrtGetRootTLSGlobal();

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData);

// End of code generation (ReadSampleWaves.h)
