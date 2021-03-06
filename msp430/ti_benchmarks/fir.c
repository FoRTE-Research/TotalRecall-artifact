#include "msp430.h"
#include <math.h>
#define FIR_LENGTH 17

const float COEFF[FIR_LENGTH] = {
  -0.000091552734,
  0.000305175781,
  0.004608154297,
  0.003356933594,
  -0.025939941406,
  -0.044006347656,
  0.063079833984,
  0.290313720703,
  0.416748046875,
  0.290313720703,
  0.063079833984,
  -0.044006347656,
  -0.025939941406,
  0.003356933594,
  0.004608154297,
  0.000305175781,
  -0.000091552734
};

/*The following array simulates input A/D converted values*/
const unsigned int INPUT[] = {
  0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0400, 0x0800, 0x0C00, 0x1000, 0x1400,
  0x1800, 0x1C00, 0x2000, 0x2400, 0x2000,
  0x1C00, 0x1800, 0x1400, 0x1000, 0x0C00,
  0x0800, 0x0400, 0x0400, 0x0800, 0x0C00,
  0x1000, 0x1400, 0x1800, 0x1C00, 0x2000,
  0x2400, 0x2000, 0x1C00, 0x1800, 0x1400,
  0x1000, 0x0C00, 0x0800, 0x0400, 0x0400,
  0x0800, 0x0C00, 0x1000, 0x1400, 0x1800,
  0x1C00, 0x2000, 0x2400, 0x2000, 0x1C00,
  0x1800, 0x1400, 0x1000, 0x0C00, 0x0800,
  0x0400
};

void main(void) {
  int i, y; /*Loop counters*/
  volatile float OUTPUT[36], sum;
  WDTCTL = WDTPW + WDTHOLD; /*Stop watchdog timer*/
  for(y = 0; y < 36; y++) {
    sum = 0;
    for (i = 0; i < FIR_LENGTH / 2; i++) {
      sum = sum + COEFF[i] * (INPUT[y + 16 - i] + INPUT[y + i]);
    }
    OUTPUT[y] = sum + (INPUT[y + FIR_LENGTH / 2] * COEFF[FIR_LENGTH / 2]);
  }

  return;
}
