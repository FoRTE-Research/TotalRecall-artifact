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

void init(){
  WDTCTL = WDTPW | WDTHOLD; // Stop WDT

  // Clock System Setup
  CSCTL0_H = CSKEY >> 8;                    // Unlock CS registers
  CSCTL1 = DCOFSEL_0 | DCORSEL;            // Set DCO to 1 MHz
  CSCTL2 = SELA__VLOCLK | SELS__DCOCLK | SELM__DCOCLK; // Set SMCLK = MCLK = DCO,
                                            // ACLK = VLOCLK
  CSCTL3 = DIVA__1 | DIVS__1 | DIVM__1;     // Set all dividers
  CSCTL0_H = 0;                             // Lock CS registers

  // Zero FRAM wait states for 1 MHz operation
  FRCTL0 = FRCTLPW | NWAITS_0;

  //Set up P1.1 (button) interrupt
  P1OUT = BIT1;                             // Pull-up resistor on P1.1
  P1REN = BIT1;                             // Select pull-up mode for P1.1
  P1DIR = 0xFF ^ BIT1;                      // Set all but P1.1 to output direction
  P1IES = BIT1;                             // P1.1 Hi/Lo edge
  P1IE = BIT1;                              // P1.1 interrupt enabled

  // Disable the GPIO power-on default high-impedance mode to activate
  // previously configured port settings
  PM5CTL0 &= ~LOCKLPM5;
  // Need to clear IFG _after_ unlock
  P1IFG = 0;                                // Clear all P1 interrupt flags

  P9DIR |= BIT7;

  //Turn both LEDs on
  P1OUT |= BIT0;
  P9OUT |= BIT7;

  __nop();
  __bis_SR_register(GIE);               // Enable interrupts
  __nop();
}

void main(void) {
  int i, y; /*Loop counters*/
  volatile float OUTPUT[36], sum;
  init();
  for(y = 0; y < 36; y++) {
    sum = 0;
    for (i = 0; i < FIR_LENGTH / 2; i++) {
      sum = sum + COEFF[i] * (INPUT[y + 16 - i] + INPUT[y + i]);
    }
    OUTPUT[y] = sum + (INPUT[y + FIR_LENGTH / 2] * COEFF[FIR_LENGTH / 2]);
  }
  while(1){
    //Turn red LED off and green LED on
    P1OUT &= ~BIT0;
    P9OUT |= BIT7;
  }
  return;
}
