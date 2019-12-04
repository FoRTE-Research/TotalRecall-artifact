#include <msp430.h>

#define LENGTH  64

//Quicksort in place
void quicksort(unsigned short *A, short len) {
  if (len < 2) return;

  short pivot = A[len / 2];

  short i, j;
  for (i = 0, j = len - 1; ; i++, j--) {
    while (A[i] < pivot) i++;
    while (A[j] > pivot) j--;

    if (i >= j) break;

    short temp = A[i];
    A[i]     = A[j];
    A[j]     = temp;
  }

  quicksort(A, i);
  quicksort(A + i, len - i);
}

//Flip array in place
void flip(unsigned short* arr, short len){
  short i;
  short tmp;
  for(i = 0; i < len / 2; i++){
    tmp = arr[(len - 1) - i];
    arr[(len - 1) - i] = arr[i];
    arr[i] = tmp;
  }
}

//Check if each value in array is equal to its index
int arraySorted(unsigned short* arr, short len){
    short i;
    for(i = 0; i < len; i++){
        if(arr[i] != i){
            return 0;
        }
    }
    return 1;
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

int main(void)
{
  init();

  unsigned short array[LENGTH] =
  { 35, 54, 26, 14, 63, 57,
    27, 17, 40, 19, 18,
    60, 2, 58, 39, 5,
    25, 49, 6, 21, 22,
    7, 30, 53, 0, 61,
    15, 43, 38, 36, 31,
    28, 41, 51, 56, 33,
    59, 11, 4, 16, 9,
    45, 46, 37, 8, 12,
    48, 20, 42, 3, 47,
    52, 62, 23, 50, 29,
    55, 34, 24, 1, 32,
    10, 44, 13};

  int i;
  for(i = 0; i < 1000; i++){
    flip(array, LENGTH);
    quicksort(array, LENGTH);
    P1OUT |= BIT0;
    P9OUT |= BIT7;
  }

  __nop();

  if(arraySorted(array, LENGTH)){
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
