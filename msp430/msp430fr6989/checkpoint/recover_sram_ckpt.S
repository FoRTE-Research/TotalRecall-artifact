.file "recover_sram_ckpt_fr6989_engine32.S"

#include <msp430.h>

.weak init

; Recovers from an SRAM checkpoint by recomputing and checking the CRC of the SRAM block and restoring the register file

; Define the top of SRAM. The linker script has been modified so that compiled code does not clobber information here
#define CRC_MSG_LENGTH  2000
#define SRAM_TOP        0x2400
#define SRAM_BOTTOM     0x1C00

.global __recover_sram_ckpt
__recover_sram_ckpt:

	CMP.W		#0xBEEF,				&SRAM_TOP-38	;	Check if keyword indicates valid checkpoint
	JNZ			_no_checkpoint												; If not, just jump to main and begin execution from start

  ; Re-initialize all peripherals, config registers, etc
;  MOV.W   #WDTPW|WDTHOLD,     &WDTCTL
;  MOV.W   #0x02,      &P1OUT
;  MOV.W   #0x02,      &P1REN
;  MOV.W   #0xFD,      &P1DIR  ;Set all but P1.1 to output
;  MOV.W   #0x02,      &P1IES
;  MOV.W   #0x02,      &P1IE
;
;  ; Clock setup - 1 MHz
;  MOV.B #CSKEY >> 8,          &CSCTL0_H
;  MOV.W #DCOFSEL_0 | DCORSEL, &CSCTL1
;  MOV.W #SELA__VLOCLK | SELS__DCOCLK | SELM__DCOCLK, &CSCTL2
;  MOV.W #DIVA__1 | DIVS__1 | DIVM__1, &CSCTL3
;  MOV.B #0, &CSCTL0_H
;  ; Set 0 wait state for FRAM accesses
;  MOV.W #FRCTLPW | NWAITS_0,  &FRCTL0
;
;  BIC.W   #LOCKLPM5,  &PM5CTL0
;  MOV.W   #0x0,       &P1IFG
;
;  BIS.B   #0x80,      &P9DIR

  NOP
  EINT
  NOP

	;------------------------- CRC32 -------------------------

	; At this point a valid checkpoint was taken, but the CRC will have been calculated
	; with &SRAM_TOP-38 = 0xDEAD. We've already checked the integrity of this word
	; (i.e. if we're here we know it contains 0xBEEF) so we can temporarily set it to
	; 0xDEAD for calculating the CRC.

	MOV.W		#0xDEAD, &SRAM_TOP-38

	;Compute CRC of  all SRAM and store it in &SRAM_TOP-2 and &SRAM_TOP-4

	#define CRC_Init 0xFFFF
	#define i R5
	#define CRC_Results R6
	#define SW_Results R7
	#define CRC_New R8
	#define LowByte R9
	#define UpByte R10

	MOV.W		#CRC_Init,				&CRC32INIRESW1
	MOV.W		#CRC_Init,				&CRC32INIRESW0
	MOV.W		#SRAM_BOTTOM,			R11
	MOV.W		#CRC_MSG_LENGTH,	i

	;Unroll loop to improve performance
	.global __crc32RamCheck_r
	__crc32RamCheck_r:
	MOV.W   @R11,&CRC32DIRBW0            ; Input data in CRC
	INCD.W  R11                     ; Advance pointer in array
	MOV.W		@R11,&CRC32DIRBW1
	INCD.W	R11

	MOV.W   @R11,&CRC32DIRBW0            ; Input data in CRC
	INCD.W  R11                     ; Advance pointer in array
	MOV.W		@R11,&CRC32DIRBW1
	INCD.W	R11

	MOV.W   @R11,&CRC32DIRBW0            ; Input data in CRC
	INCD.W  R11                     ; Advance pointer in array
	MOV.W		@R11,&CRC32DIRBW1
	INCD.W	R11

	MOV.W   @R11,&CRC32DIRBW0            ; Input data in CRC
	INCD.W  R11                     ; Advance pointer in array
	MOV.W		@R11,&CRC32DIRBW1
	INCD.W	R11
	CMP.W   #SRAM_BOTTOM+CRC_MSG_LENGTH, R11
	JNE     __crc32RamCheck_r                ; If more data, then input
	;------------------------- CRC32 -------------------------

	CMP.W		&CRC32INIRESW1,					&SRAM_TOP-2
	JNZ			_no_checkpoint						;If CRC check failed, just jump to main and begin execution from start
	CMP.W		&CRC32INIRESW0,					&SRAM_TOP-4
	JNZ			_no_checkpoint

	MOV.W		&(SRAM_TOP-34),		R15			; Begin restoring general purpose registers
	MOV.W		&(SRAM_TOP-32),		R14
	MOV.W		&(SRAM_TOP-30),		R13
	MOV.W		&(SRAM_TOP-28),		R12
	MOV.W		&(SRAM_TOP-26),		R11
	MOV.W		&(SRAM_TOP-24),		R10
	MOV.W		&(SRAM_TOP-22),		R9
	MOV.W		&(SRAM_TOP-20),		R8
	MOV.W		&(SRAM_TOP-18),		R7
	MOV.W		&(SRAM_TOP-16),		R6
	MOV.W		&(SRAM_TOP-14),		R5
	MOV.W		&(SRAM_TOP-12),		R4
	; R3 is a constant generator and doesn't need to be saved
	MOV.W		&(SRAM_TOP-8),			SP			; Restore SP (R1)
	; Potential interrupt enable should be surrounded with NOPs
	NOP
	MOV.W		&(SRAM_TOP-10),			SR			; Restore SR (R2)
	NOP
  call   #init
	MOV.W		&(SRAM_TOP-6),			PC			; Restore PC (R0)
	; At this point state should be restored and PC should be wherever we last checkpointed
  _no_checkpoint:
  JMP __crt0_start ;Just return to main and run as normal if no checkpoint

  ;Overwrite the reset vector
  .section	__interrupt_vector_56,"ax",@progbits
  resetvec_ckpt:
  .short	__recover_sram_ckpt
