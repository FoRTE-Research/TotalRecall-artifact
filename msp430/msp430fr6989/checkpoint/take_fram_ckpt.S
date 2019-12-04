.file "take_fram_ckpt.S"

; Takes an FRAM checkpoint by copying all SRAM and registers to FRAM

#define FRAM_CKPT_START	0x4400

#include <msp430.h>

.balign 2
.global	Port_1
.section	__interrupt_vector_38,"ax",@progbits
.word	Port_1
.text
.type	Port_1, @function
Port_1:

XOR.B	#1, &P1OUT	 ; P1OUT,
BIS.B #8, &P1OUT
; Write all registers to FRAM

MOV.W		2(SP),		&FRAM_CKPT_START + 2			; Save the PC (R0) from before the checkpoint interrupt ran
ADD.W		#4,				SP												;	Save the SP (R1) from before the checkpoint interrupt ran
MOV.W		SP,				&FRAM_CKPT_START + 4
SUB.W		#4,				SP
MOV.W		@SP,			&FRAM_CKPT_START + 6			; Save the SR (R2) from before the checkpoint interrupt ran
; R3 is a constant generator and doesn't need to be saved
MOV.W		R4,			 	&FRAM_CKPT_START + 8			; Begin saving general purpose registers (R4-R15)
MOV.W		R5,				&FRAM_CKPT_START + 10
MOV.W		R6,				&FRAM_CKPT_START + 12
MOV.W		R7,				&FRAM_CKPT_START + 14
MOV.W		R8,				&FRAM_CKPT_START + 16
MOV.W		R9,				&FRAM_CKPT_START + 18
MOV.W		R10,			&FRAM_CKPT_START + 20
MOV.W		R11,			&FRAM_CKPT_START + 22
MOV.W		R12,			&FRAM_CKPT_START + 24
MOV.W		R13,			&FRAM_CKPT_START + 26
MOV.W		R14,			&FRAM_CKPT_START + 28
MOV.W		R15,			&FRAM_CKPT_START + 30

MOV.W	#0x1C00, 	R11
MOV.W #FRAM_CKPT_START + 32, 	R10

; Write all of SRAM to FRAM
SAVE_LOOP:
  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10

  MOV.W		@R10, @R11
  INCD.W	R11
  INCD.W	R10
  CMP.W		#0x2400, R11
  JNE SAVE_LOOP

MOV.W	#0xBEEF, &FRAM_CKPT_START	; Indicate we finished the checkpoint

BIC.B #8, &P1OUT
XOR.B	#1, &P1OUT	 ; P1OUT, tmp29
checkpoint_done:
JMP .
.size	Port_1, .-Port_1
