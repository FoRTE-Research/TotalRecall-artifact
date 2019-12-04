#include "msp430.h"

float add(float  a, float b) {
  return (a + b);
}
float mul(float a, float b) {
  return (a * b);
}
float div(float a, float b) {
  return (a / b);
}
void main(void) {
  volatile float result[4];
  result[0] = 54.567;
  result[1] = 14346.67;
  result[2] = add(result[0], result[1]);
  result[1] = mul(result[0], result[2]);
  result[3] = div(result[1], result[2]);
  return;
}
