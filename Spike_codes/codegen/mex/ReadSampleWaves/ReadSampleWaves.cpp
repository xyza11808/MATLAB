//
// ReadSampleWaves.cpp
//
// Code generation for function 'ReadSampleWaves'
//

// Include files
#include "ReadSampleWaves.h"
#include "ReadSampleWaves_data.h"
#include "ReadSampleWaves_mexutil.h"
#include "eml_i64dplus.h"
#include "fileManager.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include <stdio.h>

// Variable Definitions
static emlrtRSInfo emlrtRSI{
    22,                                                           // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo b_emlrtRSI{
    17,                                                           // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo c_emlrtRSI{
    16,                                                           // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo d_emlrtRSI{
    15,                                                           // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo e_emlrtRSI{
    14,                                                           // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo f_emlrtRSI{
    11,                                                           // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo g_emlrtRSI{
    2,                                                            // lineNo
    "ReadSampleWaves",                                            // fcnName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pathName
};

static emlrtRSInfo h_emlrtRSI{
    51,      // lineNo
    "fopen", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fopen.m" // pathName
};

static emlrtRSInfo i_emlrtRSI{
    35,            // lineNo
    "fileManager", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pathName
};

static emlrtRSInfo
    j_emlrtRSI{
        53,              // lineNo
        "eml_i64relops", // fcnName
        "C:\\Program "
        "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\eml\\eml_"
        "i64relops.m" // pathName
    };

static emlrtRSInfo
    k_emlrtRSI{
        135,         // lineNo
        "eml_le_lt", // fcnName
        "C:\\Program "
        "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\eml\\eml_"
        "i64relops.m" // pathName
    };

static emlrtRSInfo
    l_emlrtRSI{
        214,                 // lineNo
        "eml_get_bounds_tf", // fcnName
        "C:\\Program "
        "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\eml\\eml_"
        "i64relops.m" // pathName
    };

static emlrtRSInfo m_emlrtRSI{
    44,       // lineNo
    "mpower", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\ops\\mpower.m" // pathName
};

static emlrtRSInfo o_emlrtRSI{
    56,      // lineNo
    "fread", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo p_emlrtRSI{
    86,      // lineNo
    "fread", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo q_emlrtRSI{
    169,         // lineNo
    "fullFread", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo r_emlrtRSI{
    119,         // lineNo
    "fullFread", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo s_emlrtRSI{
    424,               // lineNo
    "computeDimArray", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo t_emlrtRSI{
    436,               // lineNo
    "computeDimArray", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo u_emlrtRSI{
    15,       // lineNo
    "fclose", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fclose.m" // pathName
};

static emlrtRSInfo v_emlrtRSI{
    22,            // lineNo
    "fileManager", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pathName
};

static emlrtRSInfo w_emlrtRSI{
    170,         // lineNo
    "fileclose", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pathName
};

static emlrtMCInfo emlrtMCI{
    99,         // lineNo
    17,         // colNo
    "fileopen", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pName
};

static emlrtMCInfo b_emlrtMCI{
    10,      // lineNo
    14,      // colNo
    "fseek", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fseek.m" // pName
};

static emlrtMCInfo c_emlrtMCI{
    356,              // lineNo
    1,                // colNo
    "freadExtrinsic", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pName
};

static emlrtMCInfo d_emlrtMCI{
    360,              // lineNo
    9,                // colNo
    "freadExtrinsic", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pName
};

static emlrtMCInfo e_emlrtMCI{
    384,              // lineNo
    13,               // colNo
    "freadExtrinsic", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pName
};

static emlrtECInfo emlrtECI{
    -1,                                                           // nDims
    19,                                                           // lineNo
    9,                                                            // colNo
    "ReadSampleWaves",                                            // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pName
};

static emlrtBCInfo emlrtBCI{
    -1,                                                            // iFirst
    -1,                                                            // iLast
    19,                                                            // lineNo
    28,                                                            // colNo
    "AllChannelWaveData",                                          // aName
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    0                                                              // checkKind
};

static emlrtECInfo b_emlrtECI{
    -1,                                                           // nDims
    18,                                                           // lineNo
    9,                                                            // colNo
    "ReadSampleWaves",                                            // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pName
};

static emlrtBCInfo b_emlrtBCI{
    -1,                                                            // iFirst
    -1,                                                            // iLast
    18,                                                            // lineNo
    21,                                                            // colNo
    "cspWaveform",                                                 // aName
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    0                                                              // checkKind
};

static emlrtBCInfo c_emlrtBCI{
    -1,                                                            // iFirst
    -1,                                                            // iLast
    18,                                                            // lineNo
    42,                                                            // colNo
    "AllChnDatas",                                                 // aName
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    0                                                              // checkKind
};

static emlrtDCInfo emlrtDCI{
    18,                                                            // lineNo
    42,                                                            // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    1                                                              // checkKind
};

static emlrtBCInfo d_emlrtBCI{
    -1,                                                            // iFirst
    -1,                                                            // iLast
    7,                                                             // lineNo
    27,                                                            // colNo
    "UsedSptimes",                                                 // aName
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    0                                                              // checkKind
};

static emlrtRTEInfo emlrtRTEI{
    37,      // lineNo
    9,       // colNo
    "fopen", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fopen.m" // pName
};

static emlrtRTEInfo b_emlrtRTEI{
    13,               // lineNo
    13,               // colNo
    "toLogicalCheck", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\toLogicalCheck.m" // pName
};

static emlrtRTEInfo c_emlrtRTEI{
    72,      // lineNo
    9,       // colNo
    "fread", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pName
};

static emlrtDCInfo b_emlrtDCI{
    392,              // lineNo
    45,               // colNo
    "freadExtrinsic", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m", // pName
    4 // checkKind
};

static emlrtDCInfo c_emlrtDCI{
    392,              // lineNo
    52,               // colNo
    "freadExtrinsic", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m", // pName
    4 // checkKind
};

static emlrtRTEInfo d_emlrtRTEI{
    454,            // lineNo
    15,             // colNo
    "checkSizeVal", // fName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pName
};

static emlrtDCInfo d_emlrtDCI{
    4,                                                             // lineNo
    26,                                                            // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    1                                                              // checkKind
};

static emlrtDCInfo e_emlrtDCI{
    4,                                                             // lineNo
    26,                                                            // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    4                                                              // checkKind
};

static emlrtDCInfo f_emlrtDCI{
    5,                                                             // lineNo
    37,                                                            // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    1                                                              // checkKind
};

static emlrtDCInfo g_emlrtDCI{
    5,                                                             // lineNo
    37,                                                            // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    4                                                              // checkKind
};

static emlrtDCInfo h_emlrtDCI{
    4,                                                             // lineNo
    1,                                                             // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    1                                                              // checkKind
};

static emlrtDCInfo i_emlrtDCI{
    5,                                                             // lineNo
    1,                                                             // colNo
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    1                                                              // checkKind
};

static emlrtBCInfo e_emlrtBCI{
    -1,                                                            // iFirst
    -1,                                                            // iLast
    19,                                                            // lineNo
    51,                                                            // colNo
    "AllChnDatas",                                                 // aName
    "ReadSampleWaves",                                             // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m", // pName
    0                                                              // checkKind
};

static emlrtRTEInfo e_emlrtRTEI{
    4,                                                            // lineNo
    1,                                                            // colNo
    "ReadSampleWaves",                                            // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pName
};

static emlrtRTEInfo f_emlrtRTEI{
    5,                                                            // lineNo
    1,                                                            // colNo
    "ReadSampleWaves",                                            // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pName
};

static emlrtRTEInfo g_emlrtRTEI{
    17,                                                           // lineNo
    9,                                                            // colNo
    "ReadSampleWaves",                                            // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pName
};

static emlrtRTEInfo h_emlrtRTEI{
    18,                                                           // lineNo
    30,                                                           // colNo
    "ReadSampleWaves",                                            // fName
    "E:\\codes\\matcodes\\MATLAB\\Spike_codes\\ReadSampleWaves.m" // pName
};

static emlrtRSInfo ab_emlrtRSI{
    99,         // lineNo
    "fileopen", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\private\\fileM"
    "anager.m" // pathName
};

static emlrtRSInfo bb_emlrtRSI{
    10,      // lineNo
    "fseek", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fseek.m" // pathName
};

static emlrtRSInfo cb_emlrtRSI{
    356,              // lineNo
    "freadExtrinsic", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo db_emlrtRSI{
    384,              // lineNo
    "freadExtrinsic", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo eb_emlrtRSI{
    360,              // lineNo
    "freadExtrinsic", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

static emlrtRSInfo fb_emlrtRSI{
    407,              // lineNo
    "freadExtrinsic", // fcnName
    "C:\\Program "
    "Files\\Polyspace\\R2021a\\toolbox\\eml\\lib\\matlab\\iofun\\fread.m" // pathName
};

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *t,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y);

static const mxArray *feval(const emlrtStack *sp, const mxArray *b,
                            const mxArray *c, const mxArray *d,
                            emlrtMCInfo *location);

static const mxArray *feval(const emlrtStack *sp, const mxArray *b,
                            const mxArray *c, const mxArray *d,
                            const mxArray *e, emlrtMCInfo *location);

static void feval(const emlrtStack *sp, const mxArray *b, const mxArray *c,
                  const mxArray *d, const mxArray *e, const mxArray *f,
                  emlrtMCInfo *location, const mxArray **g, const mxArray **h);

static void mul_wide_u64(uint64_T in0, uint64_T in1, uint64_T *ptrOutBitsHi,
                         uint64_T *ptrOutBitsLo);

static uint64_T mulv_u64_sat(uint64_T a, uint64_T b);

static const mxArray *size(const emlrtStack *sp, const mxArray *b,
                           const mxArray *c, emlrtMCInfo *location);

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret)
{
  static const int32_T dims[2]{-1, -1};
  int32_T iv[2];
  const boolean_T bv[2]{true, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                            false, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret.set_size((emlrtRTEInfo *)nullptr, sp, iv[0], iv[1]);
  emlrtImportArrayR2015b((emlrtCTX)sp, src, &ret[0], 8, false);
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *t,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(t), &thisId, y);
  emlrtDestroyArray(&t);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *feval(const emlrtStack *sp, const mxArray *b,
                            const mxArray *c, const mxArray *d,
                            emlrtMCInfo *location)
{
  const mxArray *pArrays[3];
  const mxArray *m;
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  return emlrtCallMATLABR2012b((emlrtCTX)sp, 1, &m, 3, &pArrays[0],
                               (const char_T *)"feval", true, location);
}

static const mxArray *feval(const emlrtStack *sp, const mxArray *b,
                            const mxArray *c, const mxArray *d,
                            const mxArray *e, emlrtMCInfo *location)
{
  const mxArray *pArrays[4];
  const mxArray *m;
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  pArrays[3] = e;
  return emlrtCallMATLABR2012b((emlrtCTX)sp, 1, &m, 4, &pArrays[0],
                               (const char_T *)"feval", true, location);
}

static void feval(const emlrtStack *sp, const mxArray *b, const mxArray *c,
                  const mxArray *d, const mxArray *e, const mxArray *f,
                  emlrtMCInfo *location, const mxArray **g, const mxArray **h)
{
  const mxArray *pArrays[5];
  const mxArray *mv[2];
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  pArrays[3] = e;
  pArrays[4] = f;
  emlrtAssign(g,
              emlrtCallMATLABR2012b((emlrtCTX)sp, 2, &mv[0], 5, &pArrays[0],
                                    (const char_T *)"feval", true, location));
  emlrtAssign(h, mv[1]);
}

static void mul_wide_u64(uint64_T in0, uint64_T in1, uint64_T *ptrOutBitsHi,
                         uint64_T *ptrOutBitsLo)
{
  uint64_T in0Hi;
  uint64_T in0Lo;
  uint64_T in1Hi;
  uint64_T in1Lo;
  uint64_T outBitsLo;
  uint64_T productHiLo;
  uint64_T productLoHi;
  in0Hi = in0 >> 32ULL;
  in0Lo = in0 & 4294967295ULL;
  in1Hi = in1 >> 32ULL;
  in1Lo = in1 & 4294967295ULL;
  productHiLo = in0Hi * in1Lo;
  productLoHi = in0Lo * in1Hi;
  in0Lo *= in1Lo;
  in1Lo = 0ULL;
  outBitsLo = in0Lo + (productLoHi << 32ULL);
  if (outBitsLo < in0Lo) {
    in1Lo = 1ULL;
  }
  in0Lo = outBitsLo;
  outBitsLo += productHiLo << 32ULL;
  if (outBitsLo < in0Lo) {
    in1Lo++;
  }
  *ptrOutBitsHi = ((in1Lo + in0Hi * in1Hi) + (productLoHi >> 32ULL)) +
                  (productHiLo >> 32ULL);
  *ptrOutBitsLo = outBitsLo;
}

static uint64_T mulv_u64_sat(uint64_T a, uint64_T b)
{
  uint64_T result;
  uint64_T u64_chi;
  mul_wide_u64(a, b, &u64_chi, &result);
  if (u64_chi) {
    result = MAX_uint64_T;
  }
  return result;
}

static const mxArray *size(const emlrtStack *sp, const mxArray *b,
                           const mxArray *c, emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  const mxArray *m;
  pArrays[0] = b;
  pArrays[1] = c;
  return emlrtCallMATLABR2012b((emlrtCTX)sp, 1, &m, 2, &pArrays[0],
                               (const char_T *)"size", true, location);
}

void ReadSampleWaves(const emlrtStack *sp,
                     const coder::array<char_T, 2U> &fullpaths,
                     const coder::array<uint64_T, 2U> &UsedSptimes,
                     const real_T WaveWinSamples[2], real_T TotalSamples,
                     real_T cClusChannel, coder::array<real_T, 2U> &cspWaveform,
                     coder::array<real_T, 3U> &AllChannelWaveData)
{
  static const int32_T iv[2]{1, 5};
  static const int32_T iv2[2]{1, 5};
  static const int32_T iv3[2]{1, 3};
  static const int32_T iv4[2]{1, 5};
  static const int32_T iv5[2]{1, 5};
  static const int32_T iv6[2]{1, 2};
  static const char_T b_u[5]{'f', 's', 'e', 'e', 'k'};
  static const char_T c_u[5]{'f', 'r', 'e', 'a', 'd'};
  static const char_T precision[5]{'i', 'n', 't', '1', '6'};
  static const char_T u[5]{'f', 'o', 'p', 'e', 'n'};
  static const char_T cv[3]{'a', 'l', 'l'};
  static const char_T origin[3]{'b', 'o', 'f'};
  coder::array<real_T, 2U> AllChnDatas;
  coder::array<real_T, 2U> b_AllChnDatas;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *count;
  const mxArray *d_y;
  const mxArray *e_y;
  const mxArray *f_y;
  const mxArray *g_y;
  const mxArray *h_y;
  const mxArray *i_y;
  const mxArray *j_y;
  const mxArray *k_y;
  const mxArray *l_y;
  const mxArray *m;
  const mxArray *m_y;
  const mxArray *n_y;
  const mxArray *t;
  const mxArray *y;
  real_T ftempid;
  real_T ncols;
  real_T status;
  real_T *pData;
  int32_T iv7[3];
  int32_T iv1[2];
  int32_T i;
  int32_T kstr;
  int32_T loop_ub;
  boolean_T b_bool;
  boolean_T inq;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtCTX)sp);
  st.site = &g_emlrtRSI;
  b_bool = false;
  if (fullpaths.size(1) == 3) {
    kstr = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (kstr < 3) {
        if (fullpaths[kstr] != cv[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  if (b_bool) {
    emlrtErrorWithMessageIdR2018a(&st, &emlrtRTEI,
                                  "Coder:toolbox:fopenAllNotSupported",
                                  "Coder:toolbox:fopenAllNotSupported", 0);
  } else {
    b_st.site = &h_emlrtRSI;
    c_st.site = &i_emlrtRSI;
    y = nullptr;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a(&c_st, 5, m, &u[0]);
    emlrtAssign(&y, m);
    b_y = nullptr;
    iv1[0] = 1;
    iv1[1] = fullpaths.size(1);
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a(&c_st, fullpaths.size(1), m, &fullpaths[0]);
    emlrtAssign(&b_y, m);
    c_y = nullptr;
    m = emlrtCreateString1('r');
    emlrtAssign(&c_y, m);
    d_st.site = &ab_emlrtRSI;
    ftempid = b_emlrt_marshallIn(&d_st, feval(&d_st, y, b_y, c_y, &emlrtMCI),
                                 "<output of feval>");
  }
  status = WaveWinSamples[1] - WaveWinSamples[0];
  cspWaveform.set_size(&e_emlrtRTEI, sp, UsedSptimes.size(1),
                       cspWaveform.size(1));
  if (!(status >= 0.0)) {
    emlrtNonNegativeCheckR2012b(status, &e_emlrtDCI, (emlrtCTX)sp);
  }
  ncols = static_cast<int32_T>(muDoubleScalarFloor(status));
  if (status != ncols) {
    emlrtIntegerCheckR2012b(status, &d_emlrtDCI, (emlrtCTX)sp);
  }
  cspWaveform.set_size(&e_emlrtRTEI, sp, cspWaveform.size(0),
                       static_cast<int32_T>(status));
  if (status != ncols) {
    emlrtIntegerCheckR2012b(status, &h_emlrtDCI, (emlrtCTX)sp);
  }
  loop_ub = UsedSptimes.size(1) * static_cast<int32_T>(status);
  if (static_cast<int32_T>(loop_ub < 1600)) {
    for (i = 0; i < loop_ub; i++) {
      cspWaveform[i] = rtNaN;
    }
  } else {
    emlrtEnterParallelRegion((emlrtCTX)sp,
                             static_cast<boolean_T>(omp_in_parallel()));
#pragma omp parallel for num_threads(                                          \
    emlrtAllocRegionTLSs(sp->tls, omp_in_parallel(), omp_get_max_threads(),    \
                         omp_get_num_procs())) private(i)

    for (i = 0; i < loop_ub; i++) {
      cspWaveform[i] = rtNaN;
    }
    emlrtExitParallelRegion((emlrtCTX)sp,
                            static_cast<boolean_T>(omp_in_parallel()));
  }
  status = WaveWinSamples[1] - WaveWinSamples[0];
  AllChannelWaveData.set_size(&f_emlrtRTEI, sp, UsedSptimes.size(1), 384,
                              AllChannelWaveData.size(2));
  if (!(status >= 0.0)) {
    emlrtNonNegativeCheckR2012b(status, &g_emlrtDCI, (emlrtCTX)sp);
  }
  ncols = static_cast<int32_T>(muDoubleScalarFloor(status));
  if (status != ncols) {
    emlrtIntegerCheckR2012b(status, &f_emlrtDCI, (emlrtCTX)sp);
  }
  AllChannelWaveData.set_size(&f_emlrtRTEI, sp, AllChannelWaveData.size(0),
                              AllChannelWaveData.size(1),
                              static_cast<int32_T>(status));
  if (status != ncols) {
    emlrtIntegerCheckR2012b(status, &i_emlrtDCI, (emlrtCTX)sp);
  }
  loop_ub = UsedSptimes.size(1) * 384 * static_cast<int32_T>(status);
  if (static_cast<int32_T>(loop_ub < 1600)) {
    for (i = 0; i < loop_ub; i++) {
      AllChannelWaveData[i] = rtNaN;
    }
  } else {
    emlrtEnterParallelRegion((emlrtCTX)sp,
                             static_cast<boolean_T>(omp_in_parallel()));
#pragma omp parallel for num_threads(                                          \
    emlrtAllocRegionTLSs(sp->tls, omp_in_parallel(), omp_get_max_threads(),    \
                         omp_get_num_procs())) private(i)

    for (i = 0; i < loop_ub; i++) {
      AllChannelWaveData[i] = rtNaN;
    }
    emlrtExitParallelRegion((emlrtCTX)sp,
                            static_cast<boolean_T>(omp_in_parallel()));
  }
  kstr = UsedSptimes.size(1);
  if (0 <= UsedSptimes.size(1) - 1) {
    if ((0.0 <= TotalSamples) && (TotalSamples < 1.8446744073709552E+19)) {
      inq = true;
    } else {
      inq = false;
    }
  }
  for (int32_T csp{0}; csp < kstr; csp++) {
    uint64_T b;
    if (csp + 1 > UsedSptimes.size(1)) {
      emlrtDynamicBoundsCheckR2012b(csp + 1, 1, UsedSptimes.size(1),
                                    &d_emlrtBCI, (emlrtCTX)sp);
    }
    b = coder::plus(UsedSptimes[csp], WaveWinSamples[1]);
    st.site = &f_emlrtRSI;
    b_st.site = &j_emlrtRSI;
    b_bool = false;
    if (!inq) {
      b_bool = (TotalSamples < 0.0);
    } else {
      boolean_T alarge;
      boolean_T blarge;
      c_st.site = &k_emlrtRSI;
      d_st.site = &l_emlrtRSI;
      e_st.site = &m_emlrtRSI;
      alarge = (TotalSamples >= 4.503599627370496E+15);
      blarge = (b >= 4503599627370496ULL);
      if ((!alarge) && blarge) {
        b_bool = true;
      } else if (alarge && blarge) {
        b_bool = (static_cast<uint64_T>(muDoubleScalarRound(TotalSamples)) < b);
      } else if (!alarge) {
        b_bool = (TotalSamples < b);
      }
    }
    if (!b_bool) {
      uint64_T qY;
      st.site = &e_emlrtRSI;
      st.site = &e_emlrtRSI;
      st.site = &d_emlrtRSI;
      d_y = nullptr;
      m = emlrtCreateCharArray(2, &iv2[0]);
      emlrtInitCharArrayR2013a(&st, 5, m, &b_u[0]);
      emlrtAssign(&d_y, m);
      e_y = nullptr;
      m = emlrtCreateDoubleScalar(ftempid);
      emlrtAssign(&e_y, m);
      f_y = nullptr;
      m = emlrtCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
      b = coder::plus(UsedSptimes[csp], WaveWinSamples[0]);
      qY = b - 1ULL;
      if (b - 1ULL > b) {
        qY = 0ULL;
      }
      *(uint64_T *)emlrtMxGetData(m) =
          mulv_u64_sat(mulv_u64_sat(385ULL, qY), 2ULL);
      emlrtAssign(&f_y, m);
      g_y = nullptr;
      m = emlrtCreateCharArray(2, &iv3[0]);
      emlrtInitCharArrayR2013a(&st, 3, m, &origin[0]);
      emlrtAssign(&g_y, m);
      b_st.site = &bb_emlrtRSI;
      status = b_emlrt_marshallIn(&b_st,
                                  feval(&b_st, d_y, e_y, f_y, g_y, &b_emlrtMCI),
                                  "<output of feval>");
      st.site = &c_emlrtRSI;
      if (muDoubleScalarIsNaN(status)) {
        emlrtErrorWithMessageIdR2018a(&st, &b_emlrtRTEI, "MATLAB:nologicalnan",
                                      "MATLAB:nologicalnan", 0);
      }
      if (!(status != 0.0)) {
        int32_T i1;
        st.site = &b_emlrtRSI;
        status = WaveWinSamples[1] - WaveWinSamples[0];
        b_st.site = &o_emlrtRSI;
        if ((!(ftempid != 0.0)) || (!(ftempid != 1.0)) || (!(ftempid != 2.0))) {
          emlrtErrorWithMessageIdR2018a(
              &b_st, &c_emlrtRTEI, "MATLAB:legacy_two_part:notimplemented_mx",
              "MATLAB:legacy_two_part:notimplemented_mx", 0);
        }
        c_st.site = &p_emlrtRSI;
        d_st.site = &r_emlrtRSI;
        e_st.site = &s_emlrtRSI;
        e_st.site = &t_emlrtRSI;
        if ((!(status >= 0.0)) ||
            ((!(status <= 2.147483647E+9)) && (!muDoubleScalarIsInf(status)))) {
          emlrtErrorWithMessageIdR2018a(
              &e_st, &d_emlrtRTEI, "MATLAB:badsize_mx", "MATLAB:badsize_mx", 0);
        }
        d_st.site = &q_emlrtRSI;
        t = nullptr;
        count = nullptr;
        h_y = nullptr;
        m = emlrtCreateCharArray(2, &iv4[0]);
        emlrtInitCharArrayR2013a(&d_st, 5, m, &c_u[0]);
        emlrtAssign(&h_y, m);
        i_y = nullptr;
        m = emlrtCreateDoubleScalar(ftempid);
        emlrtAssign(&i_y, m);
        j_y = nullptr;
        m = emlrtCreateCharArray(2, &iv5[0]);
        emlrtInitCharArrayR2013a(&d_st, 5, m, &precision[0]);
        emlrtAssign(&j_y, m);
        k_y = nullptr;
        m = emlrtCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
        *(int32_T *)emlrtMxGetData(m) = 0;
        emlrtAssign(&k_y, m);
        l_y = nullptr;
        m = emlrtCreateNumericArray(2, (const void *)&iv6[0], mxDOUBLE_CLASS,
                                    mxREAL);
        pData = emlrtMxGetPr(m);
        pData[0] = 385.0;
        pData[1] = status;
        emlrtAssign(&l_y, m);
        e_st.site = &cb_emlrtRSI;
        feval(&e_st, h_y, i_y, l_y, j_y, k_y, &c_emlrtMCI, &t, &count);
        e_st.site = &cb_emlrtRSI;
        b_emlrt_marshallIn(&e_st, emlrtAlias(count), "count");
        m_y = nullptr;
        m = emlrtCreateDoubleScalar(1.0);
        emlrtAssign(&m_y, m);
        e_st.site = &eb_emlrtRSI;
        status = b_emlrt_marshallIn(
            &e_st, size(&e_st, emlrtAlias(t), m_y, &d_emlrtMCI),
            "<output of size>");
        n_y = nullptr;
        m = emlrtCreateDoubleScalar(2.0);
        emlrtAssign(&n_y, m);
        e_st.site = &db_emlrtRSI;
        ncols = b_emlrt_marshallIn(&e_st,
                                   size(&e_st, emlrtAlias(t), n_y, &e_emlrtMCI),
                                   "<output of size>");
        if (!(status >= 0.0)) {
          emlrtNonNegativeCheckR2012b(status, &b_emlrtDCI, &d_st);
        }
        if (!(ncols >= 0.0)) {
          emlrtNonNegativeCheckR2012b(ncols, &c_emlrtDCI, &d_st);
        }
        if (status * ncols == 0.0) {
          AllChnDatas.set_size(&g_emlrtRTEI, &d_st, 385, 0);
        } else {
          e_st.site = &fb_emlrtRSI;
          emlrt_marshallIn(&e_st, emlrtAlias(t), "t", AllChnDatas);
        }
        emlrtDestroyArray(&t);
        emlrtDestroyArray(&count);
        if (csp + 1 > cspWaveform.size(0)) {
          emlrtDynamicBoundsCheckR2012b(csp + 1, 1, cspWaveform.size(0),
                                        &b_emlrtBCI, (emlrtCTX)sp);
        }
        if (cClusChannel !=
            static_cast<int32_T>(muDoubleScalarFloor(cClusChannel))) {
          emlrtIntegerCheckR2012b(cClusChannel, &emlrtDCI, (emlrtCTX)sp);
        }
        if ((static_cast<int32_T>(cClusChannel) < 1) ||
            (static_cast<int32_T>(cClusChannel) > AllChnDatas.size(0))) {
          emlrtDynamicBoundsCheckR2012b(static_cast<int32_T>(cClusChannel), 1,
                                        AllChnDatas.size(0), &c_emlrtBCI,
                                        (emlrtCTX)sp);
        }
        loop_ub = AllChnDatas.size(1);
        b_AllChnDatas.set_size(&h_emlrtRTEI, sp, 1, AllChnDatas.size(1));
        for (i1 = 0; i1 < loop_ub; i1++) {
          b_AllChnDatas[i1] = AllChnDatas[(static_cast<int32_T>(cClusChannel) +
                                           AllChnDatas.size(0) * i1) -
                                          1];
        }
        iv1[0] = 1;
        iv1[1] = cspWaveform.size(1);
        emlrtSubAssignSizeCheckR2012b(&iv1[0], 2, b_AllChnDatas.size(), 2,
                                      &b_emlrtECI, (emlrtCTX)sp);
        loop_ub = AllChnDatas.size(1);
        for (i1 = 0; i1 < loop_ub; i1++) {
          cspWaveform[csp + cspWaveform.size(0) * i1] =
              AllChnDatas[(static_cast<int32_T>(cClusChannel) +
                           AllChnDatas.size(0) * i1) -
                          1];
        }
        if (csp + 1 > AllChannelWaveData.size(0)) {
          emlrtDynamicBoundsCheckR2012b(csp + 1, 1, AllChannelWaveData.size(0),
                                        &emlrtBCI, (emlrtCTX)sp);
        }
        for (i1 = 0; i1 < 384; i1++) {
          if (i1 + 1 > AllChnDatas.size(0)) {
            emlrtDynamicBoundsCheckR2012b(i1 + 1, 1, AllChnDatas.size(0),
                                          &e_emlrtBCI, (emlrtCTX)sp);
          }
        }
        iv7[0] = 1;
        iv7[1] = 384;
        iv7[2] = AllChannelWaveData.size(2);
        iv1[0] = 384;
        iv1[1] = AllChnDatas.size(1);
        emlrtSubAssignSizeCheckR2012b(&iv7[0], 3, &iv1[0], 2, &emlrtECI,
                                      (emlrtCTX)sp);
        loop_ub = AllChannelWaveData.size(2);
        for (i1 = 0; i1 < loop_ub; i1++) {
          for (int32_T i2{0}; i2 < 384; i2++) {
            AllChannelWaveData[(csp + AllChannelWaveData.size(0) * i2) +
                               AllChannelWaveData.size(0) * 384 * i1] =
                AllChnDatas[i2 + AllChnDatas.size(0) * i1];
          }
        }
        //  for waveform spread calculation
      }
    }
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtCTX)sp);
    }
  }
  st.site = &emlrtRSI;
  b_st.site = &u_emlrtRSI;
  c_st.site = &v_emlrtRSI;
  d_st.site = &w_emlrtRSI;
  coder::cfclose(&d_st, ftempid);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtCTX)sp);
}

emlrtCTX emlrtGetRootTLSGlobal()
{
  return emlrtRootTLSGlobal;
}

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData)
{
  omp_set_lock(&emlrtLockGlobal);
  emlrtCallLockeeFunction(aLockee, aTLS, aData);
  omp_unset_lock(&emlrtLockGlobal);
}

// End of code generation (ReadSampleWaves.cpp)
