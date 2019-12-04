#include "msp430.h"

typedef unsigned short UInt16;
UInt16 switch_case(UInt16 a) {
  UInt16 output;
  switch (a) {
    case 0x0001: output = 0x0001;
    break;
    case 0x0002: output = 0x0002;
    break;
    case 0x0003: output = 0x0003;
    break;
    case 0x0004: output = 0x0004;
    break;
    case 0x0005: output = 0x0005;
    break;
    case 0x0006: output = 0x0006;
    break;
    case 0x0007: output = 0x0007;
    break;
    case 0x0008: output = 0x0008;
    break;
    case 0x0009: output = 0x0009;
    break;
    case 0x000a: output = 0x000a;
    break;
    case 0x000b: output = 0x000b;
    break;
    case 0x000c: output = 0x000c;
    break;
    case 0x000d: output = 0x000d;
    break;
    case 0x000e: output = 0x000e;
    break;
    case 0x000f: output = 0x000f;
    break;
    case 0x0010: output = 0x0010;
    break;
  } /*endswitch*/
  return (output);
}
void main(void) {
  volatile UInt16 result;
  result = switch_case(0x0010);
  return;
}
