.file "take_sram_ckpt_fr6989_engine32.S"

#include <msp430.h>

; Takes an SRAM checkpoint by placing all registers in SRAM and storing the CRC of the SRAM space

; Define the top of SRAM. The linker script has been modified so that compiled code does not clobber information here
#define CRC_MSG_LENGTH  2000
#define SRAM_TOP        0x2400
#define SRAM_BOTTOM     0x1C00

.balign 2
.global	Port_1
.section	__interrupt_vector_38,"ax",@progbits
.word	Port_1
.text
.type	Port_1, @function
Port_1:
BIS.B	#8, &P1OUT	 ; Set P1.3 to measure checkpoint time

;BEGIN CHECKPOINTING

;Save the stack pointer and PC from before we called this interrupt
;Interrupt call implicitly pushes pre-interrupt PC (R0) and then SR (R2) onto the stack
MOV.W		#0xDEAD,	&(SRAM_TOP-38)	; Kill active checkpoint keyword to indicate we're in the middle of a checkpoint
MOV.W		#0x1234,	&(SRAM_TOP-2)	; Placeholder for CRC result
MOV.W		#0x5678,	&(SRAM_TOP-4)
MOV.W		2(SP),		&(SRAM_TOP-6)	; Save the PC (R0) from before the checkpoint interrupt ran
ADD.W		#4,				SP						;	Save the SP (R1) from before the checkpoint interrupt ran
MOV.W		SP,				&(SRAM_TOP-8)
SUB.W		#4,				SP
MOV.W		@SP,			&(SRAM_TOP-10)	; Save the SR (R2) from before the checkpoint interrupt ran
; R3 is a constant generator and doesn't need to be saved
MOV.W		R4,				&(SRAM_TOP-12)	; Begin saving general purpose registers (R4-R15)
MOV.W		R5,				&(SRAM_TOP-14)
MOV.W		R6,				&(SRAM_TOP-16)
MOV.W		R7,				&(SRAM_TOP-18)
MOV.W		R8,				&(SRAM_TOP-20)
MOV.W		R9,				&(SRAM_TOP-22)
MOV.W		R10,			&(SRAM_TOP-24)
MOV.W		R11,			&(SRAM_TOP-26)
MOV.W		R12,			&(SRAM_TOP-28)
MOV.W		R13,			&(SRAM_TOP-30)
MOV.W		R14,			&(SRAM_TOP-32)
MOV.W		R15,			&(SRAM_TOP-34)

;------------------------- CRC32 -------------------------
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
.global __crc32RamCheck_c
__crc32RamCheck_c:
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
JNE     __crc32RamCheck_c                ; If more data, then input
MOV.W   &CRC32INIRESW1,&SRAM_TOP-2  ; Save results
MOV.W		&CRC32INIRESW0,&SRAM_TOP-4

;------------------------- CRC32 -------------------------

MOV.W		#0xBEEF,	&(SRAM_TOP-38)	; Keyword indicating active checkpoint

;END CHECKPOINTING
checkpoint_done:
BIC.B	#8, &P1OUT	 ; Clear P1.3 to measure checkpoint time
;TODO: disable interrupts?
NOP
DINT
NOP
JMP .
RETI
.size	Port_1, .-Port_1
