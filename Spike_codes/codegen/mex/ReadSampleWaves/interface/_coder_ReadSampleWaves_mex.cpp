//
// _coder_ReadSampleWaves_mex.cpp
//
// Code generation for function '_coder_ReadSampleWaves_mex'
//

// Include files
#include "_coder_ReadSampleWaves_mex.h"
#include "ReadSampleWaves.h"
#include "ReadSampleWaves_data.h"
#include "ReadSampleWaves_initialize.h"
#include "ReadSampleWaves_terminate.h"
#include "_coder_ReadSampleWaves_api.h"
#include "rt_nonfinite.h"
#include <stdexcept>

void emlrtExceptionBridge();
void emlrtExceptionBridge()
{
  throw std::runtime_error("");
}
// Function Definitions
void ReadSampleWaves_mexFunction(int32_T nlhs, mxArray *plhs[2], int32_T nrhs,
                                 const mxArray *prhs[5])
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  const mxArray *outputs[2];
  int32_T b_nlhs;
  st.tls = emlrtRootTLSGlobal;
  // Check for proper number of arguments.
  if (nrhs != 5) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 5, 4,
                        15, "ReadSampleWaves");
  }
  if (nlhs > 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 15,
                        "ReadSampleWaves");
  }
  // Call the function.
  ReadSampleWaves_api(prhs, nlhs, outputs);
  // Copy over outputs to the caller.
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }
  emlrtReturnArrays(b_nlhs, &plhs[0], &outputs[0]);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexAtExit(&ReadSampleWaves_atexit);
  emlrtLoadLibrary(
      (const char_T *)"C:\\ProgramData\\MATLAB\\SupportPackages\\R2021a\\3P."
                      "instrset\\mingw_w64.instrset\\bin\\libgomp-1.dll");
  // Initialize the memory manager.
  omp_init_lock(&emlrtLockGlobal);
  omp_init_nest_lock(&emlrtNestLockGlobal);
  // Module initialization.
  ReadSampleWaves_initialize();
  st.tls = emlrtRootTLSGlobal;
  try {
    emlrtShouldCleanupOnError((emlrtCTX *)emlrtRootTLSGlobal, false);
    // Dispatch the entry-point.
    ReadSampleWaves_mexFunction(nlhs, plhs, nrhs, prhs);
    // Module termination.
    ReadSampleWaves_terminate();
    omp_destroy_lock(&emlrtLockGlobal);
    omp_destroy_nest_lock(&emlrtNestLockGlobal);
  } catch (...) {
    omp_destroy_lock(&emlrtLockGlobal);
    omp_destroy_nest_lock(&emlrtNestLockGlobal);
    emlrtReportParallelRunTimeError(&st);
    emlrtCleanupOnException((emlrtCTX *)emlrtRootTLSGlobal);
    throw;
  }
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLSR2021a(&emlrtRootTLSGlobal, &emlrtContextGlobal,
                           &emlrtLockerFunction, omp_get_num_procs(),
                           (void *)&emlrtExceptionBridge);
  return emlrtRootTLSGlobal;
}

// End of code generation (_coder_ReadSampleWaves_mex.cpp)
