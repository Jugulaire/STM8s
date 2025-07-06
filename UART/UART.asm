;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module UART
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _uart_read
	.globl _uart_write
	.globl _uart_config
	.globl _printf
	.globl _putchar
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
;	UART.c: 8: void uart_config() {
;	-----------------------------------------
;	 function uart_config
;	-----------------------------------------
_uart_config:
;	UART.c: 16: uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
	ld	a, #0x68
	ld	xl, a
;	UART.c: 17: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8
	ld	a, #0x83
	and	a, #0x0f
;	UART.c: 19: UART1_BRR1 = brr1;
	ldw	y, #0x5232
	push	a
	ld	a, xl
	ld	(y), a
	pop	a
;	UART.c: 20: UART1_BRR2 = brr2;
	ld	0x5233, a
;	UART.c: 21: UART1_CR1 = 0x00;    // 8 data bits, no parity
	mov	0x5234+0, #0x00
;	UART.c: 22: UART1_CR3 = 0x00;    // 1 stop bit
	mov	0x5236+0, #0x00
;	UART.c: 23: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
	mov	0x5235+0, #0x0c
;	UART.c: 24: }
	ret
;	UART.c: 26: void uart_write(uint8_t data) {
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
;	UART.c: 27: UART1_DR = data;
	ld	0x5231, a
;	UART.c: 28: PB_ODR &= ~(1 << 5);  // LED OFF
	bres	0x5005, #5
;	UART.c: 29: while (!(UART1_SR & (1 << UART1_SR_TC)));
00101$:
	btjf	0x5230, #6, 00101$
;	UART.c: 30: PB_ODR |= (1 << 5);   // LED ON
	bset	0x5005, #5
;	UART.c: 31: }
	ret
;	UART.c: 33: uint8_t uart_read() {
;	-----------------------------------------
;	 function uart_read
;	-----------------------------------------
_uart_read:
;	UART.c: 34: while (!(UART1_SR & (1 << UART1_SR_RXNE)));
00101$:
	btjf	0x5230, #5, 00101$
;	UART.c: 35: return UART1_DR;
	ld	a, 0x5231
;	UART.c: 36: }
	ret
;	UART.c: 38: int putchar(int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	UART.c: 39: uart_write(c);
	call	_uart_write
;	UART.c: 40: return 0;
	clrw	x
;	UART.c: 41: }
	ret
;	UART.c: 43: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	UART.c: 45: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	x
	ldw	(0x09, sp), x
	ldw	(0x07, sp), x
00103$:
	ldw	x, (0x05, sp)
	pushw	x
	ldw	x, #0x0378
	call	___muluint2ulong
	addw	sp, #2
	ldw	(0x03, sp), x
	ldw	(0x01, sp), y
	ldw	x, (0x09, sp)
	cpw	x, (0x03, sp)
	ld	a, (0x08, sp)
	sbc	a, (0x02, sp)
	ld	a, (0x07, sp)
	sbc	a, (0x01, sp)
	jrnc	00105$
;	UART.c: 46: __asm__("nop");
	nop
;	UART.c: 45: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	UART.c: 47: }
	addw	sp, #10
	ret
;	UART.c: 49: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	UART.c: 50: CLK_CKDIVR = 0x00;  // Set system clock to full 16 MHz
	mov	0x50c6+0, #0x00
;	UART.c: 52: uart_config();
	call	_uart_config
;	UART.c: 55: PB_CR1= (1 << 5);
	mov	0x5008+0, #0x20
;	UART.c: 56: PB_DDR = (1 << 5);
	mov	0x5007+0, #0x20
;	UART.c: 58: while (1) {
00102$:
;	UART.c: 59: uint8_t c = uart_read();   // Attendre un caractère du terminal
	call	_uart_read
;	UART.c: 60: printf("Echo : %c \r\n", c);
	clrw	x
	ld	xl, a
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
	addw	sp, #4
	jra	00102$
;	UART.c: 62: }
	ret
	.area CODE
	.area CONST
	.area CONST
___str_0:
	.ascii "Echo : %c "
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
