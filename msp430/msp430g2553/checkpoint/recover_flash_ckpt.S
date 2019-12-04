.file "recover_flash_ckpt.S"

; Recovers from a flash checkpoint by loading the SRAM space and register file from flash
; Define flash stuff
#define FLASH_CKPT_START	0xF800

.global __recover_flash_ckpt
__recover_flash_ckpt:

  ; TODO: Putting board init stuff in here for now
  mov.w	#23168,	&0x0120
  mov.b	#3,	&0x0022
  mov.b	#42,	&0x002a
  mov.b	#32,	&0x0029
  bis.b	#8,	&0x0021
  bis.b	#8,	&0x0027
  bis.b	#8,	&0x0025
  bis.b	#8,	&0x0024
  bic.b	#8,	&0x0023

  BIC.B #0x1,  &P1OUT
  BIS.B #0x1,  &P1DIR

  ;Flash setup
  MOV.B	#0, &DCOCTL								;Slows down the DCO
  MOV.B	&CALBC1_1MHZ, &BCSCTL1		;Slows down the DCO
  MOV.B	&CALDCO_1MHZ, &DCOCTL			;Slows down the DCO
  ;MOV.W	#-23230, &FCTL2						;Sets flash clock generation

  CMP.W		#0xBEEF,	&FLASH_CKPT_START	;	Check if keyword indicates valid checkpoint
  JNZ			__crt0_start								; If not, just jump to main and begin execution from start
  BIS.B #0x1,  &P1OUT

  ;Restore all of SRAM from flash
  MOV.W		#0x200, R11
  MOV.W		#FLASH_CKPT_START + 32, R10
  RESTORE_LOOP:
    MOV.W		@R10, @R11
    INCD.W	R11
    INCD.W	R10
    CMP.W		#0x400, R11
    JNE RESTORE_LOOP

  MOV.W		&FLASH_CKPT_START + 30,		R15			; Begin restoring general purpose registers
  MOV.W		&FLASH_CKPT_START + 28,		R14
  MOV.W		&FLASH_CKPT_START + 26,		R13
  MOV.W		&FLASH_CKPT_START + 24,		R12
  MOV.W		&FLASH_CKPT_START + 22,		R11
  MOV.W		&FLASH_CKPT_START + 20,		R10
  MOV.W		&FLASH_CKPT_START + 18,		R9
  MOV.W		&FLASH_CKPT_START + 16,		R8
  MOV.W		&FLASH_CKPT_START + 14,		R7
  MOV.W		&FLASH_CKPT_START + 12,		R6
  MOV.W		&FLASH_CKPT_START + 10,		R5
  MOV.W		&FLASH_CKPT_START + 8,		R4
  ; R3 is a constant generator and doesn't need to be saved
  MOV.W		&FLASH_CKPT_START + 4,		SP			; Restore SP (R1)
  MOV.W		&FLASH_CKPT_START + 6,		SR			; Restore SR (R2)
  ;Redo a flash read to emulate whole checkpoint recovery
  MOV.W		&FLASH_CKPT_START + 6,		SR			; Restore PC (R0)
  BIC.B   #0x1,  &P1OUT
  MOV.W		&FLASH_CKPT_START + 2,		PC			; Restore PC (R0)
  ; At this point state should be restored and PC should be wherever we last checkpointed

;Overwrite the reset vector
.section	__interrupt_vector_16,"ax",@progbits
resetvec_ckpt:
.short	__recover_flash_ckpt
