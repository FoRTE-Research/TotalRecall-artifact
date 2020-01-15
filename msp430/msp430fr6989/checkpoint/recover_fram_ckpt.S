.file "recover_fram_ckpt.S"

#include <msp430.h>

; Recovers from a FRAM checkpoint by loading the SRAM space and register file from FRAM
; Define FRAM stuff

#define FRAM_CKPT_START	0x4400

.global __recover_fram_ckpt
__recover_fram_ckpt:

  CMP.W		#0xBEEF,	&FRAM_CKPT_START	;	Check if keyword indicates valid checkpoint
  JNZ			__crt0_start								; If not, just jump to main and begin execution from start

  ; Re-initialize all peripherals, config registers, etc
  MOV.W   #WDTPW|WDTHOLD,     &WDTCTL
  MOV.W   #BIT1,      &P1OUT
  MOV.W   #BIT1,      &P1REN
  MOV.W   #0xFD,      &P1DIR  ;Set all but P1.1 to output
  MOV.W   #BIT1,      &P1IES
  MOV.W   #BIT1,      &P1IE

  ; Clock setup - 1 MHz
  MOV.B #CSKEY >> 8,          &CSCTL0_H
  MOV.W #DCOFSEL_0 | DCORSEL, &CSCTL1
  MOV.W #SELA__VLOCLK | SELS__DCOCLK | SELM__DCOCLK, &CSCTL2
  MOV.W #DIVA__1 | DIVS__1 | DIVM__1, &CSCTL3
  MOV.B #0, &CSCTL0_H
  ; Set 0 wait state for FRAM accesses
  MOV.W #FRCTLPW | NWAITS_0,  &FRCTL0

  BIC.W   #LOCKLPM5,  &PM5CTL0
  MOV.W   #0x0,       &P1IFG

  BIS.B   #0x80,      &P9DIR

  NOP
  EINT
  NOP

  ;Restore all of SRAM from FRAM
  MOV.W		#0x1C00, R10
  MOV.W		#FRAM_CKPT_START + 32, R11
  RESTORE_LOOP:
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
    CMP.W		#0x2400, R10
    JNE RESTORE_LOOP

  MOV.W		&FRAM_CKPT_START + 30,		R15			; Begin restoring general purpose registers
  MOV.W		&FRAM_CKPT_START + 28,		R14
  MOV.W		&FRAM_CKPT_START + 26,		R13
  MOV.W		&FRAM_CKPT_START + 24,		R12
  MOV.W		&FRAM_CKPT_START + 22,		R11
  MOV.W		&FRAM_CKPT_START + 20,		R10
  MOV.W		&FRAM_CKPT_START + 18,		R9
  MOV.W		&FRAM_CKPT_START + 16,		R8
  MOV.W		&FRAM_CKPT_START + 14,		R7
  MOV.W		&FRAM_CKPT_START + 12,		R6
  MOV.W		&FRAM_CKPT_START + 10,		R5
  MOV.W		&FRAM_CKPT_START + 8,		R4
  ; R3 is a constant generator and doesn't need to be saved
  MOV.W		&FRAM_CKPT_START + 4,		SP			; Restore SP (R1)
  MOV.W		&FRAM_CKPT_START + 6,		SR			; Restore SR (R2)
  MOV.W		&FRAM_CKPT_START + 2,		PC			; Restore PC (R0)
  ; At this point state should be restored and PC should be wherever we last checkpointed

;Overwrite the reset vector
.section	__interrupt_vector_56,"ax",@progbits
resetvec_ckpt:
.short	__recover_fram_ckpt
