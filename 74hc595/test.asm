;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module test
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _shift_register_send
	.globl _shift_register_init
	.globl _delay_ms
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
;	test.c: 5: void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #6
	ldw	(0x03, sp), x
;	test.c: 6: for (uint16_t i = 0; i < ms * 1000; i++)
	clrw	x
	ldw	(0x05, sp), x
00103$:
	ldw	x, (0x03, sp)
	pushw	x
	ldw	x, #0x03e8
	call	__mulint
	ldw	(0x01, sp), x
	ldw	x, (0x05, sp)
	cpw	x, (0x01, sp)
	jrnc	00105$
;	test.c: 7: __asm__("nop");
	nop
;	test.c: 6: for (uint16_t i = 0; i < ms * 1000; i++)
	ldw	x, (0x05, sp)
	incw	x
	ldw	(0x05, sp), x
	jra	00103$
00105$:
;	test.c: 8: }
	addw	sp, #6
	ret
;	test.c: 10: void shift_register_init(void) {
;	-----------------------------------------
;	 function shift_register_init
;	-----------------------------------------
_shift_register_init:
;	test.c: 11: PA_DDR |= (1 << 1) | (1 << 2) | (1 << 3);  // PA1, PA2, PA3 = output
	ld	a, 0x5002
	or	a, #0x0e
	ld	0x5002, a
;	test.c: 12: PA_CR1 |= (1 << 1) | (1 << 2) | (1 << 3);  // push-pull
	ld	a, 0x5003
	or	a, #0x0e
	ld	0x5003, a
;	test.c: 13: PA_ODR &= ~((1 << 1) | (1 << 2) | (1 << 3)); // start low
	ld	a, 0x5000
	and	a, #0xf1
	ld	0x5000, a
;	test.c: 14: }
	ret
;	test.c: 16: void shift_register_send(uint8_t segments, uint8_t digits) {
;	-----------------------------------------
;	 function shift_register_send
;	-----------------------------------------
_shift_register_send:
	sub	sp, #7
	ld	(0x07, sp), a
;	test.c: 18: for (int8_t i = 7; i >= 0; i--) {
	ld	a, #0x07
	ld	(0x06, sp), a
00110$:
	tnz	(0x06, sp)
	jrmi	00104$
;	test.c: 19: if (segments & (1 << i)) PA_ODR |= (1 << 3);
	ld	a, (0x06, sp)
	clrw	x
	incw	x
	tnz	a
	jreq	00151$
00150$:
	sllw	x
	dec	a
	jrne	00150$
00151$:
	ld	a, (0x07, sp)
	ld	(0x03, sp), a
	clr	(0x02, sp)
	ld	a, 0x5000
	push	a
	ld	a, xl
	and	a, (0x04, sp)
	ld	(0x06, sp), a
	ld	a, xh
	and	a, (0x03, sp)
	ld	(0x05, sp), a
	pop	a
	ldw	x, (0x04, sp)
	jreq	00102$
	or	a, #0x08
	ld	0x5000, a
	jra	00103$
00102$:
;	test.c: 20: else                     PA_ODR &= ~(1 << 3);
	and	a, #0xf7
	ld	0x5000, a
00103$:
;	test.c: 21: PA_ODR |= (1 << 1); PA_ODR &= ~(1 << 1);
	bset	0x5000, #1
	bres	0x5000, #1
;	test.c: 18: for (int8_t i = 7; i >= 0; i--) {
	dec	(0x06, sp)
	jra	00110$
00104$:
;	test.c: 25: for (int8_t i = 7; i >= 0; i--) {
	ld	a, #0x07
	ld	xl, a
00113$:
;	test.c: 19: if (segments & (1 << i)) PA_ODR |= (1 << 3);
	ld	a, 0x5000
	ld	xh, a
;	test.c: 25: for (int8_t i = 7; i >= 0; i--) {
	ld	a, xl
	tnz	a
	jrmi	00108$
;	test.c: 26: if (digits & (1 << i)) PA_ODR |= (1 << 3);
	ld	a, xl
	ldw	y, #0x0001
	ldw	(0x01, sp), y
	tnz	a
	jreq	00155$
00154$:
	sll	(0x02, sp)
	rlc	(0x01, sp)
	dec	a
	jrne	00154$
00155$:
	ld	a, (0x0a, sp)
	clr	(0x03, sp)
	and	a, (0x02, sp)
	ld	(0x06, sp), a
	ld	a, (0x03, sp)
	and	a, (0x01, sp)
	ld	(0x05, sp), a
	ldw	y, (0x05, sp)
	jreq	00106$
	ld	a, xh
	or	a, #0x08
	ld	0x5000, a
	jra	00107$
00106$:
;	test.c: 27: else                   PA_ODR &= ~(1 << 3);
	ld	a, xh
	and	a, #0xf7
	ld	0x5000, a
00107$:
;	test.c: 28: PA_ODR |= (1 << 1); PA_ODR &= ~(1 << 1);
	bset	0x5000, #1
	bres	0x5000, #1
;	test.c: 25: for (int8_t i = 7; i >= 0; i--) {
	decw	x
	jra	00113$
00108$:
;	test.c: 32: PA_ODR |= (1 << 2);
	ld	a, xh
	or	a, #0x04
	ld	0x5000, a
;	test.c: 33: PA_ODR &= ~(1 << 2);
	bres	0x5000, #2
;	test.c: 34: }
	addw	sp, #7
	popw	x
	pop	a
	jp	(x)
;	test.c: 38: void main(void) {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	test.c: 39: shift_register_init();
	call	_shift_register_init
;	test.c: 41: while (1) {
00102$:
;	test.c: 42: shift_register_send(0b11111111, 0b11101111); // Affiche "8" sur DS4
	push	#0xef
	ld	a, #0xff
	call	_shift_register_send
;	test.c: 43: delay_ms(2000);
	ldw	x, #0x07d0
	call	_delay_ms
;	test.c: 44: shift_register_send(0b11111111, 0b11110111);
	push	#0xf7
	ld	a, #0xff
	call	_shift_register_send
;	test.c: 45: delay_ms(2000);
	ldw	x, #0x07d0
	call	_delay_ms
;	test.c: 46: shift_register_send(0b11111111, 0b11111011);
	push	#0xfb
	ld	a, #0xff
	call	_shift_register_send
;	test.c: 47: delay_ms(2000);
	ldw	x, #0x07d0
	call	_delay_ms
;	test.c: 48: shift_register_send(0b11111111, 0b11111101);
	push	#0xfd
	ld	a, #0xff
	call	_shift_register_send
;	test.c: 49: delay_ms(2000);
	ldw	x, #0x07d0
	call	_delay_ms
	jra	00102$
;	test.c: 52: }
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
	.area CABS (ABS)
