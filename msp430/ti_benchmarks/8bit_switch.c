#include "msp430.h"

typedef unsigned char UInt8;
UInt8 switch_case(UInt8 a) {
    UInt8 output;
    switch (a) {
      case 0x01: output = 0x01;
      break;
      case 0x02: output = 0x02;
      break;
      case 0x03: output = 0x03;
      break;
      case 0x04: output = 0x04;
      break;
      case 0x05: output = 0x05;
      break;
      case 0x06: output = 0x06;
      break;
      case 0x07: output = 0x07;
      break;
      case 0x08: output = 0x08;
      break;
      case 0x09: output = 0x09;
      break;
      case 0x0a: output = 0x0a;
      break;
      case 0x0b: output = 0x0b;
      break;
      case 0x0c: output = 0x0c;
      break;
      case 0x0d: output = 0x0d;
      break;
      case 0x0e: output = 0x0e;
      break;
      case 0x0f: output = 0x0f;
      break;
      case 0x10: output = 0x10;
      break;
    } /*endswitch*/
    
    return (output);
  }

void main(void){
  volatile UInt8 result;
  result = switch_case(0x10);
  return;
}
