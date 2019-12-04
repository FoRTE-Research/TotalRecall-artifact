.file "take_flash_ckpt.S"

; Takes a flash checkpoint by copying all SRAM and registers to flash
; Side effect: slows down MCLK to 1 MHz

; Define flash stuff
#define FLASH_CKPT_START	0xF800
; Relevant FCTL1 fields
#define FWKEY							0xA500
#define WRT								0x0040
#define ERASE							0x0002
; Relevant FCTL3 fields
#define LOCK							0x0010

.balign 2
.global	Port_1
.section	__interrupt_vector_3,"ax",@progbits
.word	Port_1
.text
.type	Port_1, @function
Port_1:

;MOV.B	#1, &P1OUT	 ; P1OUT,
;Flash setup
 MOV.B	#0, &DCOCTL								;Slows down the DCO
 MOV.B	&CALBC1_1MHZ, &BCSCTL1		;Slows down the DCO
 MOV.B	&CALDCO_1MHZ, &DCOCTL			;Slows down the DCO
 MOV.W	#-23230, &FCTL2						;Sets flash clock generation

MOV.W		#FWKEY, 			&FCTL3								; Unlock flash
MOV.W		#FWKEY+ERASE,	&FCTL1								; Erase = 1
MOV.W		#0, 					&FLASH_CKPT_START			; Dummy write to erase

MOV.W		#FWKEY, 			&FCTL3								; Unlock flash
MOV.W		#FWKEY+ERASE,	&FCTL1								; Erase = 1
MOV.W		#0,						&FLASH_CKPT_START+513	; Dummy write to erase next segment

MOV.W		#FWKEY+WRT, 	&FCTL1								; Write = 1
MOV.W		#FWKEY,				&FCTL3								; Lock = 0

;MOV.W #0xDEAD, 	&FLASH_CKPT_START					; Indicate we're in the middle of a checkpoint
; Write all registers to flash

MOV.W		2(SP),		&FLASH_CKPT_START + 2			; Save the PC (R0) from before the checkpoint interrupt ran
ADD.W		#4,				SP												;	Save the SP (R1) from before the checkpoint interrupt ran
MOV.W		SP,				&FLASH_CKPT_START + 4
SUB.W		#4,				SP
MOV.W		@SP,			&FLASH_CKPT_START + 6			; Save the SR (R2) from before the checkpoint interrupt ran
; R3 is a constant generator and doesn't need to be saved
MOV.W		R4,			 	&FLASH_CKPT_START + 8			; Begin saving general purpose registers (R4-R15)
MOV.W		R5,				&FLASH_CKPT_START + 10
MOV.W		R6,				&FLASH_CKPT_START + 12
MOV.W		R7,				&FLASH_CKPT_START + 14
MOV.W		R8,				&FLASH_CKPT_START + 16
MOV.W		R9,				&FLASH_CKPT_START + 18
MOV.W		R10,			&FLASH_CKPT_START + 20
MOV.W		R11,			&FLASH_CKPT_START + 22
MOV.W		R12,			&FLASH_CKPT_START + 24
MOV.W		R13,			&FLASH_CKPT_START + 26
MOV.W		R14,			&FLASH_CKPT_START + 28
MOV.W		R15,			&FLASH_CKPT_START + 30

MOV.W	#0x200, 	R11
MOV.W #FLASH_CKPT_START + 32, 	R10

; Write all of SRAM to flash
SAVE_LOOP:
  MOV.W		@R11,	@R10
  INCD.W	R11
  INCD.W	R10
  CMP.W		#0x400, R11
  JNE SAVE_LOOP

MOV.W	#0xBEEF, &FLASH_CKPT_START	; Indicate we finished the checkpoint

; timer_flash.c:38:   FCTL1 = FWKEY;          // Disable flash write.
;	MOV.W	#FWKEY, &FCTL1	 ; FCTL1,
; timer_flash.c:39:   FCTL3 = FWKEY + LOCK;   // Lock the flash.
MOV.W	#FWKEY+LOCK, &FCTL3	 ; FCTL3,

; timer_flash.c:41:   P1OUT = 0x00;                             // Clear P1.0
;MOV.B	#0, &P1OUT	 ; P1OUT, tmp29
checkpoint_done:
JMP Port_1
.size	Port_1, .-Port_1
