#include "msp430.h"

typedef unsigned short UInt16;
UInt16 add(uint16 a, uint16 b) {
  return (a + b);
}
uint16 mul(uint16 a, uint16 b) {
  return (a * b);
}
uint16 div(uint16 a, uint16 b) {
  return (a / b);
}
void main(void) {
  volatile uint16 result[4];
  result[0] = 231;
  result[1] = 12;
  result[2] = add(result[0], result[1]);
  result[1] = mul(result[0], result[2]);
  result[3] = div(result[1], result[2]);
  return;
}
