.file "take_sram_ckpt_sw32.S"

; Takes an SRAM checkpoint by placing all registers in SRAM and storing the CRC of the SRAM space

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Only here for purposes of timing the CRC32.
; This will NOT properly take a checkpoint because the CRC32 result will
; overwrite the checkpointed PC.
; The only thing necessary to make this a working checkpoint routine is to move
; everything down to make space for the expanded CRC result.
;
; Also, replace the CRC table.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#define CRC_MSG_LENGTH #510
; Define the top of SRAM. The linker script has been modified so that compiled code does not clobber information here
#define SRAM_TOP 0x400

.balign 2
.global	Port_1
.section	__interrupt_vector_3,"ax",@progbits
.word	Port_1
.text
.type	Port_1, @function
Port_1:
BIS.B	#1, &P1OUT	 ; Set P1.0 to measure checkpoint time

;BEGIN CHECKPOINTING

;Save the stack pointer and PC from before we called this interrupt
;Interrupt call implicitly pushes pre-interrupt PC (R0) and then SR (R2) onto the stack
MOV.W		#0xDEAD,	&(SRAM_TOP-36)	; Kill active checkpoint keyword to indicate we're in the middle of a checkpoint
MOV.W		#0x1234,	&(SRAM_TOP-2)	; Placeholder for CRC result
MOV.W		2(SP),		&(SRAM_TOP-4)	; Save the PC (R0) from before the checkpoint interrupt ran
ADD.W		#4,				SP						;	Save the SP (R1) from before the checkpoint interrupt ran
MOV.W		SP,				&(SRAM_TOP-6)
SUB.W		#4,				SP
MOV.W		@SP,			&(SRAM_TOP-8)	; Save the SR (R2) from before the checkpoint interrupt ran
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

;------------------------- CRC -------------------------
;Compute CRC of  all SRAM and store it in &SRAM_TOP-2
;And &SRAM_TOP-4
.global __crc32RamCheck_c
__crc32RamCheck_c:
#define r_crc_h		    R13
#define r_crc_l       R12
#define r_ptable      R14

#define r_mask        R7
#define r_tmp         R8
#define r_index	 	    R9
#define r_msg_size    R10
#define r_pmsg		    R11

_prequel_c:
  MOV             #0xFF00,		r_mask
  MOV 						#0x0, 			r_crc_h
  MOV             #0x0,       r_crc_l
  MOV 						#CRC_TABLE, r_ptable
  MOV 					  #0x0200,		r_pmsg
  MOV 						CRC_MSG_LENGTH,				r_msg_size
_rc_loop_c:
    SWPB            r_crc_h
    MOV.B           r_crc_h,r_index
    XOR.B           @r_pmsg+,r_index
    ADD             r_index,r_index
    ADD             r_index,r_index
    ADD             r_ptable,r_index
    SWPB            r_crc_l
    MOV.B           r_crc_l,r_tmp
    AND             r_mask,r_crc_h
    BIS             r_tmp,r_crc_h      ; OR operation
    AND             r_mask,r_crc_l
    XOR             @r_index+,r_crc_l
    XOR             @r_index,r_crc_h
  DEC		r_msg_size

  SWPB            r_crc_h
  MOV.B           r_crc_h,r_index
  XOR.B           @r_pmsg+,r_index
  ADD             r_index,r_index
  ADD             r_index,r_index
  ADD             r_ptable,r_index
  SWPB            r_crc_l
  MOV.B           r_crc_l,r_tmp
  AND             r_mask,r_crc_h
  BIS             r_tmp,r_crc_h      ; OR operation
  AND             r_mask,r_crc_l
  XOR             @r_index+,r_crc_l
  XOR             @r_index,r_crc_h
DEC		r_msg_size
  JNZ		_rc_loop_c

#undef  r_crc
#undef  r_ptable
#undef  r_mask
#undef  r_index
#undef  r_msg_size
#undef  r_pmsg
;------------------------- CRC -------------------------

; At this point CRC result is in R12:R13
; Save it in the SRAM_TOP-2 and SRAM_TOP-4 slot
MOV.W		R13,			&(SRAM_TOP-2)
MOV.W		R12,			&(SRAM_TOP-4)

MOV.W		#0xBEEF,	&(SRAM_TOP-36)	; Keyword indicating active checkpoint

;END CHECKPOINTING
checkpoint_done:
BIC.B	#1, &P1OUT	 ; Clear P1.0 to measure checkpoint time
BIC.B #8, &P1IFG    ; Clear P1.3 flag
;TODO: disable interrupts?
NOP
DINT
NOP
JMP .
RETI
.size	Port_1, .-Port_1

#ifndef CRC16_TABLE
#define CRC16_TABLE

; CRC16 lookup table
; width=16 poly=0x8005 init=0x0000 refin=false refout=false xorout=0x0000 check=0xfee8 residue=0x0000 name="CRC-16/UMTS"

.global CRC_TABLE
.text
CRC_TABLE:
	.word 0x0000
	.word 0x8005
	.word 0x800F
	.word 0x000A
	.word 0x801B
	.word 0x001E
	.word 0x0014
	.word 0x8011
	.word 0x8033
	.word 0x0036
	.word 0x003C
	.word 0x8039
	.word 0x0028
	.word 0x802D
	.word 0x8027
	.word 0x0022
	.word 0x8063
	.word 0x0066
	.word 0x006C
	.word 0x8069
	.word 0x0078
	.word 0x807D
	.word 0x8077
	.word 0x0072
	.word 0x0050
	.word 0x8055
	.word 0x805F
	.word 0x005A
	.word 0x804B
	.word 0x004E
	.word 0x0044
	.word 0x8041
	.word 0x80C3
	.word 0x00C6
	.word 0x00CC
	.word 0x80C9
	.word 0x00D8
	.word 0x80DD
	.word 0x80D7
	.word 0x00D2
	.word 0x00F0
	.word 0x80F5
	.word 0x80FF
	.word 0x00FA
	.word 0x80EB
	.word 0x00EE
	.word 0x00E4
	.word 0x80E1
	.word 0x00A0
	.word 0x80A5
	.word 0x80AF
	.word 0x00AA
	.word 0x80BB
	.word 0x00BE
	.word 0x00B4
	.word 0x80B1
	.word 0x8093
	.word 0x0096
	.word 0x009C
	.word 0x8099
	.word 0x0088
	.word 0x808D
	.word 0x8087
	.word 0x0082
	.word 0x8183
	.word 0x0186
	.word 0x018C
	.word 0x8189
	.word 0x0198
	.word 0x819D
	.word 0x8197
	.word 0x0192
	.word 0x01B0
	.word 0x81B5
	.word 0x81BF
	.word 0x01BA
	.word 0x81AB
	.word 0x01AE
	.word 0x01A4
	.word 0x81A1
	.word 0x01E0
	.word 0x81E5
	.word 0x81EF
	.word 0x01EA
	.word 0x81FB
	.word 0x01FE
	.word 0x01F4
	.word 0x81F1
	.word 0x81D3
	.word 0x01D6
	.word 0x01DC
	.word 0x81D9
	.word 0x01C8
	.word 0x81CD
	.word 0x81C7
	.word 0x01C2
	.word 0x0140
	.word 0x8145
	.word 0x814F
	.word 0x014A
	.word 0x815B
	.word 0x015E
	.word 0x0154
	.word 0x8151
	.word 0x8173
	.word 0x0176
	.word 0x017C
	.word 0x8179
	.word 0x0168
	.word 0x816D
	.word 0x8167
	.word 0x0162
	.word 0x8123
	.word 0x0126
	.word 0x012C
	.word 0x8129
	.word 0x0138
	.word 0x813D
	.word 0x8137
	.word 0x0132
	.word 0x0110
	.word 0x8115
	.word 0x811F
	.word 0x011A
	.word 0x810B
	.word 0x010E
	.word 0x0104
	.word 0x8101
	.word 0x8303
	.word 0x0306
	.word 0x030C
	.word 0x8309
	.word 0x0318
	.word 0x831D
	.word 0x8317
	.word 0x0312
	.word 0x0330
	.word 0x8335
	.word 0x833F
	.word 0x033A
	.word 0x832B
	.word 0x032E
	.word 0x0324
	.word 0x8321
	.word 0x0360
	.word 0x8365
	.word 0x836F
	.word 0x036A
	.word 0x837B
	.word 0x037E
	.word 0x0374
	.word 0x8371
	.word 0x8353
	.word 0x0356
	.word 0x035C
	.word 0x8359
	.word 0x0348
	.word 0x834D
	.word 0x8347
	.word 0x0342
	.word 0x03C0
	.word 0x83C5
	.word 0x83CF
	.word 0x03CA
	.word 0x83DB
	.word 0x03DE
	.word 0x03D4
	.word 0x83D1
	.word 0x83F3
	.word 0x03F6
	.word 0x03FC
	.word 0x83F9
	.word 0x03E8
	.word 0x83ED
	.word 0x83E7
	.word 0x03E2
	.word 0x83A3
	.word 0x03A6
	.word 0x03AC
	.word 0x83A9
	.word 0x03B8
	.word 0x83BD
	.word 0x83B7
	.word 0x03B2
	.word 0x0390
	.word 0x8395
	.word 0x839F
	.word 0x039A
	.word 0x838B
	.word 0x038E
	.word 0x0384
	.word 0x8381
	.word 0x0280
	.word 0x8285
	.word 0x828F
	.word 0x028A
	.word 0x829B
	.word 0x029E
	.word 0x0294
	.word 0x8291
	.word 0x82B3
	.word 0x02B6
	.word 0x02BC
	.word 0x82B9
	.word 0x02A8
	.word 0x82AD
	.word 0x82A7
	.word 0x02A2
	.word 0x82E3
	.word 0x02E6
	.word 0x02EC
	.word 0x82E9
	.word 0x02F8
	.word 0x82FD
	.word 0x82F7
	.word 0x02F2
	.word 0x02D0
	.word 0x82D5
	.word 0x82DF
	.word 0x02DA
	.word 0x82CB
	.word 0x02CE
	.word 0x02C4
	.word 0x82C1
	.word 0x8243
	.word 0x0246
	.word 0x024C
	.word 0x8249
	.word 0x0258
	.word 0x825D
	.word 0x8257
	.word 0x0252
	.word 0x0270
	.word 0x8275
	.word 0x827F
	.word 0x027A
	.word 0x826B
	.word 0x026E
	.word 0x0264
	.word 0x8261
	.word 0x0220
	.word 0x8225
	.word 0x822F
	.word 0x022A
	.word 0x823B
	.word 0x023E
	.word 0x0234
	.word 0x8231
	.word 0x8213
	.word 0x0216
	.word 0x021C
	.word 0x8219
	.word 0x0208
	.word 0x820D
	.word 0x8207
	.word 0x0202
	.end
#endif
