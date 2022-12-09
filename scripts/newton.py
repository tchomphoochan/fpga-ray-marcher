from functools import partial
import numpy as np
import matplotlib.pyplot as plt
import math

NUM_WHOLE_DIGITS = 6
NUM_FRAC_DIGITS = 18

def count_leading_zeros(a):
  if a >= 1:
    return 1 + count_leading_zeros(a/2)
  return 0

def fp_inv_sqrt(iters, a):
  diff = count_leading_zeros(a)
  a /= (2**diff);
  slope = 2 * (math.sqrt(2) - 1)
  x = math.sqrt(2) - slope * (a - 0.5)
  for i in range(iters):
    x = x * (3/2 - 1/2 * a * x * x)
  x = x * (1/math.sqrt(2))**(diff)
  return x

if __name__ == "__main__":
  xs = np.arange(0.5, 3, 0.01)
  y2 = np.vectorize(partial(fp_inv_sqrt, 2))(xs)
  yr = 1/np.sqrt(xs)
  err2 = (y2-yr)
  plt.xlabel('Input')
  plt.ylabel('Absolute error')
  plt.plot(xs, err2, color='black')

  plt.show()

# ofunction automatic fp fp_inv_sqrt(input fp _a);
#   // 0.5 should have `NUM_WHOLE_DIGITS leading zeros
#   logic [$clog2(`NUM_WHOLE_DIGITS):0] cnt = fp_count_leading_zeros(_a);
#   logic [$clog2(`NUM_WHOLE_DIGITS):0] diff = `NUM_WHOLE_DIGITS - cnt;
#   fp a = _a >> diff; // if has less than that (i.e. number is too large), must shift
#   // work with that number
#   fp slope = fp_mul(`FP_TWO, fp_sub(`FP_SQRT_TWO, `FP_ONE));
#   fp x = fp_sub(`FP_SQRT_TWO,
#                 fp_mul(slope,
#                        fp_sub(a, `FP_HALF))); // first approximation, good for a in [0.5,1]
#   x = fp_mul(x,
#              fp_sub(`FP_THREE_HALFS,
#                     fp_mul(fp_mul(`FP_HALF, a),
#                            fp_mul(x, x)))); // one newton iteration
#   x = fp_mul(x,
#              fp_sub(`FP_THREE_HALFS,
#                     fp_mul(fp_mul(`FP_HALF, a),
#                            fp_mul(x, x)))); // one newton iteration
#   // must shift answer properly
#   x = x >> (diff >> 1);
#   x = (diff & 1) ? fp_mul(x, `FP_INV_SQRT_TWO) : x;
#   return x;
# endfunction