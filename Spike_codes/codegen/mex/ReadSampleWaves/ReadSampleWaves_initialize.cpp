//
// ReadSampleWaves_initialize.cpp
//
// Code generation for function 'ReadSampleWaves_initialize'
//

// Include files
#include "ReadSampleWaves_initialize.h"
#include "ReadSampleWaves_data.h"
#include "_coder_ReadSampleWaves_mex.h"
#include "rt_nonfinite.h"

// Function Definitions
void ReadSampleWaves_initialize()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mex_InitInfAndNan();
  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

// End of code generation (ReadSampleWaves_initialize.cpp)
