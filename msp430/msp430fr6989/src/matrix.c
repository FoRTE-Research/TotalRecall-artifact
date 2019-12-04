#include "msp430.h"

typedef unsigned short UInt16;
const UInt16 m1[3][4] = {
  { 0x01, 0x02, 0x03, 0x04},
  { 0x05, 0x06, 0x07, 0x08},
  { 0x09, 0x0A, 0x0B, 0x0C}
};
const UInt16 m2[4][5] = {
  { 0x01, 0x02, 0x03, 0x04, 0x05},
  { 0x06, 0x07, 0x08, 0x09, 0x0A},
  { 0x0B, 0x0C, 0x0D, 0x0E, 0x0F},
  { 0x10, 0x11, 0x12, 0x13, 0x14}
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
  int m, n, p;
  init();
  volatile UInt16 m3[3][5];
  for (m = 0; m < 3; m++) {
    for (p = 0; p < 5; p++) {
      m3[m][p] = 0;
      for (n = 0; n < 4; n++) {
        m3[m][p] += m1[m][n] * m2[n][p];
      }
    }
  }
  while(1){
    //Turn red LED off and green LED on
    P1OUT &= ~BIT0;
    P9OUT |= BIT7;
  }
  return;
}
