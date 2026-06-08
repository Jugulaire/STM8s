;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module blink_pb4
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _delay
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
;--------------------------------------------------------
; Stack segment in internal ram
;--------------------------------------------------------
	.area	SSEG
__start__stack:
	.ds	1

;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area DABS (ABS)

; default segment ordering for linker
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area CONST
	.area INITIALIZER
	.area CODE

;--------------------------------------------------------
; interrupt vector
;--------------------------------------------------------
	.area HOME
__interrupt_vect:
	int s_GSINIT ; reset
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area GSINIT
__sdcc_init_data:
; stm8_genXINIT() start
	ldw x, #l_DATA
	jreq	00002$
00001$:
	clr (s_DATA - 1, x)
	decw x
	jrne	00001$
00002$:
	ldw	x, #l_INITIALIZER
	jreq	00004$
00003$:
	ld	a, (s_INITIALIZER - 1, x)
	ld	(s_INITIALIZED - 1, x), a
	decw	x
	jrne	00003$
00004$:
; stm8_genXINIT() end
	.area GSFINAL
	jp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME
	.area HOME
__sdcc_program_startup:
	jp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CODE
;	blink_pb4.c: 5: void delay(void)
;	-----------------------------------------
;	 function delay
;	-----------------------------------------
_delay:
	sub	sp, #2
;	blink_pb4.c: 7: for(volatile unsigned int i = 0; i < 30000; i++);
	clrw	x
	ldw	(0x01, sp), x
00103$:
	ldw	x, (0x01, sp)
	cpw	x, #0x7530
	jrnc	00105$
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
	jra	00103$
00105$:
;	blink_pb4.c: 8: }
	addw	sp, #2
	ret
;	blink_pb4.c: 10: void main(void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	blink_pb4.c: 12: PD_DDR |= (1 << 4);   // PD4 en sortie
	bset	0x5011, #4
;	blink_pb4.c: 13: PD_CR1 |= (1 << 4);   // push-pull
	bset	0x5012, #4
;	blink_pb4.c: 15: while(1)
00102$:
;	blink_pb4.c: 17: PD_ODR ^= (1 << 4);
	bcpl	0x500f, #4
;	blink_pb4.c: 18: delay();
	call	_delay
	jra	00102$
;	blink_pb4.c: 20: }
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
	.area CABS (ABS)
