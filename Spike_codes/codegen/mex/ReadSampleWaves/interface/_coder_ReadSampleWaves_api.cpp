//
// _coder_ReadSampleWaves_api.cpp
//
// Code generation for function '_coder_ReadSampleWaves_api'
//

// Include files
#include "_coder_ReadSampleWaves_api.h"
#include "ReadSampleWaves.h"
#include "ReadSampleWaves_data.h"
#include "ReadSampleWaves_mexutil.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<char_T, 2U> &ret);

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<uint64_T, 2U> &ret);

static real_T (*c_emlrt_marshallIn(const emlrtStack *sp,
                                   const mxArray *WaveWinSamples,
                                   const char_T *identifier))[2];

static real_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId))[2];

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *fullpaths,
                             const char_T *identifier,
                             coder::array<char_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<char_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *UsedSptimes,
                             const char_T *identifier,
                             coder::array<uint64_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<uint64_T, 2U> &y);

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 2U> &u);

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 3U> &u);

static real_T (*f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[2];

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<char_T, 2U> &ret)
{
  static const int32_T dims[2]{1, -1};
  int32_T iv[2];
  const boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"char",
                            false, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret.set_size((emlrtRTEInfo *)nullptr, sp, iv[0], iv[1]);
  emlrtImportArrayR2015b((emlrtCTX)sp, src, &ret[0], 1, false);
  emlrtDestroyArray(&src);
}

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<uint64_T, 2U> &ret)
{
  static const int32_T dims[2]{1, -1};
  int32_T iv[2];
  const boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"uint64",
                            false, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret.prealloc(iv[0] * iv[1]);
  ret.set_size((emlrtRTEInfo *)nullptr, sp, iv[0], iv[1]);
  ret.set((uint64_T *)emlrtMxGetData(src), ret.size(0), ret.size(1));
  emlrtDestroyArray(&src);
}

static real_T (*c_emlrt_marshallIn(const emlrtStack *sp,
                                   const mxArray *WaveWinSamples,
                                   const char_T *identifier))[2]
{
  emlrtMsgIdentifier thisId;
  real_T(*y)[2];
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = c_emlrt_marshallIn(sp, emlrtAlias(WaveWinSamples), &thisId);
  emlrtDestroyArray(&WaveWinSamples);
  return y;
}

static real_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId))[2]
{
  real_T(*y)[2];
  y = f_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *fullpaths,
                             const char_T *identifier,
                             coder::array<char_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(fullpaths), &thisId, y);
  emlrtDestroyArray(&fullpaths);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<char_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *UsedSptimes,
                             const char_T *identifier,
                             coder::array<uint64_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(UsedSptimes), &thisId, y);
  emlrtDestroyArray(&UsedSptimes);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<uint64_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 2U> &u)
{
  static const int32_T iv[2]{0, 0};
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, &(((coder::array<real_T, 2U> *)&u)->data())[0]);
  emlrtSetDimensions((mxArray *)m, ((coder::array<real_T, 2U> *)&u)->size(), 2);
  emlrtAssign(&y, m);
  return y;
}

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 3U> &u)
{
  static const int32_T iv[3]{0, 0, 0};
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateNumericArray(3, (const void *)&iv[0], mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, &(((coder::array<real_T, 3U> *)&u)->data())[0]);
  emlrtSetDimensions((mxArray *)m, ((coder::array<real_T, 3U> *)&u)->size(), 3);
  emlrtAssign(&y, m);
  return y;
}

static real_T (*f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[2]
{
  static const int32_T dims[2]{1, 2};
  real_T(*ret)[2];
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                          false, 2U, (void *)&dims[0]);
  ret = (real_T(*)[2])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void ReadSampleWaves_api(const mxArray *const prhs[5], int32_T nlhs,
                         const mxArray *plhs[2])
{
  coder::array<real_T, 3U> AllChannelWaveData;
  coder::array<real_T, 2U> cspWaveform;
  coder::array<uint64_T, 2U> UsedSptimes;
  coder::array<char_T, 2U> fullpaths;
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  real_T(*WaveWinSamples)[2];
  real_T TotalSamples;
  real_T cClusChannel;
  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  // Marshall function inputs
  emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "fullpaths", fullpaths);
  UsedSptimes.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "UsedSptimes", UsedSptimes);
  WaveWinSamples =
      c_emlrt_marshallIn(&st, emlrtAlias(prhs[2]), "WaveWinSamples");
  TotalSamples = b_emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "TotalSamples");
  cClusChannel = b_emlrt_marshallIn(&st, emlrtAliasP(prhs[4]), "cClusChannel");
  // Invoke the target function
  ReadSampleWaves(&st, fullpaths, UsedSptimes, *WaveWinSamples, TotalSamples,
                  cClusChannel, cspWaveform, AllChannelWaveData);
  // Marshall function outputs
  cspWaveform.no_free();
  plhs[0] = emlrt_marshallOut(cspWaveform);
  if (nlhs > 1) {
    AllChannelWaveData.no_free();
    plhs[1] = emlrt_marshallOut(AllChannelWaveData);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

// End of code generation (_coder_ReadSampleWaves_api.cpp)
