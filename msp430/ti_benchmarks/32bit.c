#include "msp430.h"
#include <math.h>

typedef unsigned long UInt32;
UInt32 add(UInt32 a, UInt32 b) {
  return (a + b);
}
UInt32 mul(UInt32 a, UInt32 b) {
  return (a * b);
}
UInt32 div(UInt32 a, UInt32 b) {
  return (a / b);
}
void main(void) {
  volatile UInt32 result[4];
  result[0] = 43125;
  result[1] = 14567;
  result[2] = add(result[0], result[1]);
  result[1] = mul(result[0], result[2]);
  result[3] = div(result[1], result[2]);
  return;
}
