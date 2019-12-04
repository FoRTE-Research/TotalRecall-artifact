#include <msp430.h>

#define RED     0b10
#define GREEN   0b1000
#define BLUE    0b100000

long factorial(long num){
  if(num == 1){
    return 1;
  }
  return num * factorial(num - 1);
}

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

void main(){
  init();

  volatile long result;
  volatile long i;
  for(i = 0; i < 100000; i++){
    result = factorial(6);
    P1OUT |= BIT0;
    P2OUT  = BLUE;
  }

  if(result == 720){
    while(1){
      // Success
      P2OUT = GREEN;
    }
  } else{
    while(1){
      // Failure
      P2OUT = RED;
    }
  }
}
