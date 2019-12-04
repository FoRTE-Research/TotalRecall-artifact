#include <msp430.h>

long factorial(long num){
  long i;
  long long result = 1;
  for(i = 1; i <= num; i++){
    result *= i;
  }
  return result;
}

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

void main(){
  init();

  volatile long result;
  volatile long i;
  for(i = 0; i < 500; i++){
    result = factorial(6);
    P1OUT |= BIT0;
    P9OUT |= BIT7;
  }

  if(result == 720){
    while(1){
      //Turn red LED off and green LED on
      P1OUT &= ~BIT0;
      P9OUT |= BIT7;
    }
  } else{
    while(1){
      //Turn red LED on and green LED off
      P1OUT |= BIT0;
      P9OUT &= ~BIT7;
    }
  }
}
