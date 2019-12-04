#include <msp430.h>

#define LENGTH  64
#define RED     0b10
#define GREEN   0b1000
#define BLUE    0b100000

//Quicksort in place
void quicksort(short *A, short len) {
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
void flip(short* arr, short len){
  short i;
  short tmp;
  for(i = 0; i < len / 2; i++){
    tmp = arr[(len - 1) - i];
    arr[(len - 1) - i] = arr[i];
    arr[i] = tmp;
  }
}

//Check if each value in array is equal to its index
int arraySorted(short* arr, short len){
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

void main()
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

  short i;
  __nop();
  for(i = 0; i < 1000; i++){
    flip(array, LENGTH);
    quicksort(array, LENGTH);
  }

  if(arraySorted(array, LENGTH)){
    while(1){
      P1OUT |= BIT2;
      P2OUT = GREEN;
    }
  } else{
    while(1){
      P1OUT |= BIT2;
      P2OUT = RED;
    }
  }
}
