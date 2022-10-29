//
// ReadSampleWaves_terminate.cpp
//
// Code generation for function 'ReadSampleWaves_terminate'
//

// Include files
#include "ReadSampleWaves_terminate.h"
#include "ReadSampleWaves_data.h"
#include "_coder_ReadSampleWaves_mex.h"
#include "rt_nonfinite.h"

// Function Definitions
void ReadSampleWaves_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void ReadSampleWaves_terminate()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (ReadSampleWaves_terminate.cpp)
