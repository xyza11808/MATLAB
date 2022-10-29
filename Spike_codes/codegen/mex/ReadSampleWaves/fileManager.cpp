//
// fileManager.cpp
//
// Code generation for function 'fileManager'
//

// Include files
#include "fileManager.h"
#include "rt_nonfinite.h"

// Variable Definitions
static emlrtMCInfo f_emlrtMCI{
    191,       // lineNo
    21,        // colNo
    "cfclose", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pName
};

static emlrtMCInfo g_emlrtMCI{
    191,       // lineNo
    13,        // colNo
    "cfclose", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pName
};

static emlrtMCInfo h_emlrtMCI{
    192,       // lineNo
    5,         // colNo
    "cfclose", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pName
};

static emlrtRSInfo x_emlrtRSI{
    191,       // lineNo
    "cfclose", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pathName
};

static emlrtRSInfo y_emlrtRSI{
    192,       // lineNo
    "cfclose", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pathName
};

// Function Declarations
static const mxArray *c_coder_internal_ifWhileCondExt(const emlrtStack *sp,
                                                      const mxArray *b,
                                                      emlrtMCInfo *location);

static boolean_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                    const emlrtMsgIdentifier *msgId);

static boolean_T
emlrt_marshallIn(const emlrtStack *sp,
                 const mxArray *c_a__output_of_coder_internal_i,
                 const char_T *identifier);

static boolean_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                  const emlrtMsgIdentifier *parentId);

static const mxArray *feval(const emlrtStack *sp, const mxArray *b,
                            const mxArray *c, emlrtMCInfo *location);

static const mxArray *logical(const emlrtStack *sp, const mxArray *b,
                              emlrtMCInfo *location);

// Function Definitions
static const mxArray *c_coder_internal_ifWhileCondExt(const emlrtStack *sp,
                                                      const mxArray *b,
                                                      emlrtMCInfo *location)
{
  const mxArray *m;
  const mxArray *pArray;
  pArray = b;
  return emlrtCallMATLABR2012b(
      (emlrtCTX)sp, 1, &m, 1, &pArray,
      (const char_T *)"coder.internal.ifWhileCondExtrinsic", true, location);
}

static boolean_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                    const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  boolean_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"logical",
                          false, 0U, (void *)&dims);
  ret = *emlrtMxGetLogicals(src);
  emlrtDestroyArray(&src);
  return ret;
}

static boolean_T
emlrt_marshallIn(const emlrtStack *sp,
                 const mxArray *c_a__output_of_coder_internal_i,
                 const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  boolean_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = emlrt_marshallIn(sp, emlrtAlias(c_a__output_of_coder_internal_i),
                       &thisId);
  emlrtDestroyArray(&c_a__output_of_coder_internal_i);
  return y;
}

static boolean_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                  const emlrtMsgIdentifier *parentId)
{
  boolean_T y;
  y = d_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static const mxArray *feval(const emlrtStack *sp, const mxArray *b,
                            const mxArray *c, emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  const mxArray *m;
  pArrays[0] = b;
  pArrays[1] = c;
  return emlrtCallMATLABR2012b((emlrtCTX)sp, 1, &m, 2, &pArrays[0],
                               (const char_T *)"feval", true, location);
}

static const mxArray *logical(const emlrtStack *sp, const mxArray *b,
                              emlrtMCInfo *location)
{
  const mxArray *m;
  const mxArray *pArray;
  pArray = b;
  return emlrtCallMATLABR2012b((emlrtCTX)sp, 1, &m, 1, &pArray,
                               (const char_T *)"logical", true, location);
}

namespace coder {
int32_T cfclose(const emlrtStack *sp, real_T fid)
{
  static const int32_T iv[2]{1, 6};
  static const char_T u[6]{'f', 'c', 'l', 'o', 's', 'e'};
  emlrtStack b_st;
  const mxArray *b_y;
  const mxArray *failp;
  const mxArray *m;
  const mxArray *y;
  int32_T st;
  b_st.prev = sp;
  b_st.tls = sp->tls;
  failp = nullptr;
  y = nullptr;
  m = emlrtCreateCharArray(2, &iv[0]);
  emlrtInitCharArrayR2013a((emlrtCTX)sp, 6, m, &u[0]);
  emlrtAssign(&y, m);
  b_y = nullptr;
  m = emlrtCreateDoubleScalar(fid);
  emlrtAssign(&b_y, m);
  b_st.site = &x_emlrtRSI;
  emlrtAssign(&failp,
              logical(&b_st, feval(&b_st, y, b_y, &f_emlrtMCI), &g_emlrtMCI));
  b_st.site = &y_emlrtRSI;
  if (emlrt_marshallIn(&b_st,
                       c_coder_internal_ifWhileCondExt(&b_st, emlrtAlias(failp),
                                                       &h_emlrtMCI),
                       "<output of coder.internal.ifWhileCondExtrinsic>")) {
    st = -1;
  } else {
    st = 0;
  }
  emlrtDestroyArray(&failp);
  return st;
}

} // namespace coder

// End of code generation (fileManager.cpp)
