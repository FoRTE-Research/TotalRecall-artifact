#include "msp430.h"

#define RED     0b10
#define GREEN   0b1000
#define BLUE    0b100000

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
  //Set up button and LED GPIOs
  //P1.2 will be used to tell green board "I'm done"
  P1OUT &= ~(BIT2 | BIT0);
  P1DIR = BIT0 | BIT1 | BIT2;

  P2DIR = 0b00101010;
  P2OUT = BLUE;

  //BCSCTL1 = CALBC1_16MHZ;
  //DCOCTL = CALDCO_16MHZ;

  //Set up P1.3 (button) interrupt
  P1OUT |=  8;                          // P1.3 pulled high
  P1REN |=  8;                          // P1.3 pullup
  P1IE |=   8;                          // P1.3 interrupt enabled
  P1IES |=  8;                          // P1.3 Hi/lo edge
  P1IFG &= ~8;                          // P1.3 IFG cleared

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
    // Success
    P2OUT = GREEN;
  }
  return;
}
