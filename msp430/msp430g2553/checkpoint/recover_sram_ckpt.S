.file "recover_sram_ckpt.S"

#include <msp430.h>

; Recovers from an SRAM checkpoint by recomputing and checking the CRC of the SRAM block and restoring the register file

#define CRC_MSG_LENGTH #510
; Define the top of SRAM. The linker script has been modified so that compiled code does not clobber information here
#define SRAM_TOP 0x400

.global __recover_sram_ckpt
__recover_sram_ckpt:

  ; TODO: Putting the init stuff in here for now, hopefully later can call it as a c function?
  mov.w	#23168,	&0x0120
  BIC.B #BIT2,  &P1OUT
  BIC.B #BIT0,  &P1OUT
  mov.b	#3,	&0x0022
  mov.b	#42,	&0x002a
  mov.b	#32,	&0x0029
  BIS.B #BIT2,  &P1DIR
  bis.b	#8,	&0x0021
  bis.b	#8,	&0x0027
  bis.b	#8,	&0x0025
  bis.b	#8,	&0x0024
  bic.b	#8,	&0x0023

  ;MOV.W #CALBC1_16MHZ, BCSCTL1
  ;MOV.W #CALDCO_16MHZ,  DCOCTL

	CMP.W		#0xBEEF,				&SRAM_TOP-36	;	Check if keyword indicates valid checkpoint
	JNZ			_no_checkpoint												; If not, just jump to main and begin execution from start

	;------------------------- CRC -------------------------

	; At this point a valid checkpoint was taken, but the CRC will have been calculated
	; with &SRAM_TOP-36 = 0xDEAD. We've already checked the integrity of this word
	; (i.e. if we're here we know it contains 0xBEEF) so we can temporarily set it to
	; 0xDEAD for calculating the CRC.

	MOV.W		#0xDEAD, &SRAM_TOP-36

	;Compute CRC of  all SRAM and compare it to &SRAM_TOP-2
	.global __crc16RamCheck_r
	__crc16RamCheck_r:
	#define r_crc		    R12
	#define r_ptable    R13
	#define r_pmsg		  R14
	#define r_msg_size  R15
	#define r_mask      R8
	#define r_index	 	  R9

	_prequel_r:
		MOV             #0xFF00,		r_mask
		MOV 						#0x0, 			r_crc
		MOV 						#CRC_TABLE, r_ptable
		MOV 					  #0x0200,		r_pmsg
		MOV 						CRC_MSG_LENGTH,				r_msg_size
	_rc_loop_r:
	  SWPB            r_crc								; 1 cycle
	  MOV.B           r_crc, r_index			; 1 cycle
	  XOR.B           @r_pmsg+, r_index		; 2 cycles
	  ADD             r_index, r_index		; 1 cycle
	  ADD             r_ptable, r_index 	; 1 cycle
	  AND             r_mask, r_crc				; 1 cycle
	  XOR             @r_index, r_crc 		; 2 cycles
		DEC		r_msg_size										; 1 cycle I think? Emulated instruction using CG, so...
		JNZ		_rc_loop_r										;	2 cycles

	#undef  r_crc
	#undef  r_ptable
	#undef  r_mask
	#undef  r_index
	#undef  r_msg_size
	#undef  r_pmsg
	;------------------------- CRC -------------------------

	; CRC calculation done, so put 0xBEEF back in &SRAM_TOP-36
	MOV.W		#0xBEEF, &SRAM_TOP-36

	;At this point CRC result is in R12
	CMP.W		R12,					&SRAM_TOP-2
	JNZ			_no_checkpoint						;If CRC check failed, just jump to main and begin execution from start

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
	MOV.W		&(SRAM_TOP-6),			SP			; Restore SP (R1)
	; Potential interrupt enable should be surrounded with NOPs
	NOP
	MOV.W		&(SRAM_TOP-8),			SR			; Restore SR (R2)
	NOP
	MOV.W		&(SRAM_TOP-4),			PC			; Restore PC (R0)
	; At this point state should be restored and PC should be wherever we last checkpointed
  _no_checkpoint:
  JMP __crt0_start ;Just return to main and run as normal if no checkpoint

  ;Overwrite the reset vector
  .section	__interrupt_vector_16,"ax",@progbits
  resetvec_ckpt:
  .short	__recover_sram_ckpt
