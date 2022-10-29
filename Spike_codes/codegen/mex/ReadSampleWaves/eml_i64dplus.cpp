//
// eml_i64dplus.cpp
//
// Code generation for function 'eml_i64dplus'
//

// Include files
#include "eml_i64dplus.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"

// Function Definitions
namespace coder {
uint64_T plus(uint64_T x, real_T y)
{
  real_T roundedy;
  uint64_T z;
  roundedy = muDoubleScalarRound(y);
  if (y >= 0.0) {
    if (y < 1.8446744073709552E+19) {
      z = x + static_cast<uint64_T>(roundedy);
      if (z < x) {
        z = MAX_uint64_T;
      }
    } else {
      z = MAX_uint64_T;
    }
  } else if (y < 0.0) {
    if (-y < 1.8446744073709552E+19) {
      if (y - roundedy == 0.5) {
        z = x - static_cast<uint64_T>(muDoubleScalarFloor(-y));
        if (z > x) {
          z = 0ULL;
        }
      } else {
        z = x - static_cast<uint64_T>(muDoubleScalarRound(-y));
        if (z > x) {
          z = 0ULL;
        }
      }
    } else {
      z = 0ULL;
    }
  } else {
    z = 0ULL;
  }
  return z;
}

} // namespace coder

// End of code generation (eml_i64dplus.cpp)
