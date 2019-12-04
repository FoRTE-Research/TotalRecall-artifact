#include "msp430.h"

typedef unsigned char UInt8;
UInt8 add (UInt8 a, UInt8 b){
  return(a+b);
}
UInt8 mul(uint8 a,uint8 b)
{
return(a*b);}uint8 div(uint8 a,uint8 b)
{
return(a/b);
}
void main(void)
{
volatile uint8 result[4];

  result[0]=12;
  result[1]=3;
  result[2]=add(result[0],result[1]);
  result[1]=mul(result[0],result[2]);
  result[3]=div(result[1],result[2]);
  return;
}
