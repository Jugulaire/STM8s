;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _uart_read
	.globl _uart_write
	.globl _uart_init
	.globl _printf
	.globl _putchar
	.globl _getchar
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
;	main.c: 11: int putchar(int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	main.c: 12: uart_write(c);
	call	_uart_write
;	main.c: 13: return 0;
	clrw	x
;	main.c: 14: }
	ret
;	main.c: 19: int getchar() {
;	-----------------------------------------
;	 function getchar
;	-----------------------------------------
_getchar:
;	main.c: 20: return uart_read();
	call	_uart_read
	clrw	x
	ld	xl, a
;	main.c: 21: }
	ret
;	main.c: 23: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	push	a
;	main.c: 24: uint8_t counter = 0;
	clr	(0x01, sp)
;	main.c: 25: uart_init();
	call	_uart_init
;	main.c: 27: while (1) {
00102$:
;	main.c: 28: printf("Test, %d\n", counter++);
	ld	a, (0x01, sp)
	inc	(0x01, sp)
	clrw	x
	ld	xl, a
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
	addw	sp, #4
;	../../lib/delay.h: 12: for (uint32_t i = 0; i < ((F_CPU / 18 / 1000UL) * ms); i++) {
	clrw	y
	clrw	x
00107$:
	cpw	y, #0xd8cc
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00102$
;	../../lib/delay.h: 13: __asm__("nop");
	nop
;	../../lib/delay.h: 12: for (uint32_t i = 0; i < ((F_CPU / 18 / 1000UL) * ms); i++) {
	incw	y
	jrne	00107$
	incw	x
	jra	00107$
;	main.c: 29: delay_ms(500);
;	main.c: 31: }
	pop	a
	ret
	.area CODE
	.area CONST
	.area CONST
___str_0:
	.ascii "Test, %d"
	.db 0x0a
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
