;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module ADC
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _adc_init
	.globl _adc_read
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
;	ADC.c: 6: void uart_config() {
;	-----------------------------------------
;	 function uart_config
;	-----------------------------------------
_uart_config:
;	ADC.c: 7: CLK_CKDIVR = 0x00; // force 16 mhz 
	mov	0x50c6+0, #0x00
;	ADC.c: 15: uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
	ld	a, #0x68
	ld	xl, a
;	ADC.c: 16: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8
	ld	a, #0x83
	and	a, #0x0f
;	ADC.c: 18: UART1_BRR1 = brr1;
	ldw	y, #0x5232
	push	a
	ld	a, xl
	ld	(y), a
	pop	a
;	ADC.c: 19: UART1_BRR2 = brr2;
	ld	0x5233, a
;	ADC.c: 20: UART1_CR1 = 0x00;    // 8 data bits, no parity
	mov	0x5234+0, #0x00
;	ADC.c: 21: UART1_CR3 = 0x00;    // 1 stop bit
	mov	0x5236+0, #0x00
;	ADC.c: 22: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
	mov	0x5235+0, #0x0c
;	ADC.c: 24: (void)UART1_SR;
	ld	a, 0x5230
;	ADC.c: 25: (void)UART1_DR;
	ld	a, 0x5231
;	ADC.c: 26: }
	ret
;	ADC.c: 28: void uart_write(uint8_t data) {
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
;	ADC.c: 29: UART1_DR = data;
	ld	0x5231, a
;	ADC.c: 30: PB_ODR &= ~(1 << 5);  // LED OFF
	bres	0x5005, #5
;	ADC.c: 31: while (!(UART1_SR & (1 << UART1_SR_TC)));
00101$:
	btjf	0x5230, #6, 00101$
;	ADC.c: 32: PB_ODR |= (1 << 5);   // LED ON
	bset	0x5005, #5
;	ADC.c: 33: }
	ret
;	ADC.c: 35: uint8_t uart_read() {
;	-----------------------------------------
;	 function uart_read
;	-----------------------------------------
_uart_read:
;	ADC.c: 36: while (!(UART1_SR & (1 << UART1_SR_RXNE)));
00101$:
	btjf	0x5230, #5, 00101$
;	ADC.c: 37: return UART1_DR;
	ld	a, 0x5231
;	ADC.c: 38: }
	ret
;	ADC.c: 40: int putchar(int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	ADC.c: 41: uart_write(c);
	call	_uart_write
;	ADC.c: 42: return 0;
	clrw	x
;	ADC.c: 43: }
	ret
;	ADC.c: 45: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	ADC.c: 48: __asm__("nop");
	nop
;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	ADC.c: 49: }
	addw	sp, #10
	ret
;	ADC.c: 52: uint16_t adc_read(uint8_t channel) {
;	-----------------------------------------
;	 function adc_read
;	-----------------------------------------
_adc_read:
	sub	sp, #4
;	ADC.c: 53: if (channel > 7) return 0; // Sanity check
	ld	xl, a
	cp	a, #0x07
	jrule	00102$
	clrw	x
	jra	00106$
00102$:
;	ADC.c: 56: ADC1_CSR = (ADC1_CSR & 0xF8) | (channel & 0x07);
	ld	a, 0x5400
	and	a, #0xf8
	ld	(0x04, sp), a
	ld	a, xl
	and	a, #0x07
	or	a, (0x04, sp)
	ld	0x5400, a
;	ADC.c: 59: ADC1_CR1 |= (1 << ADC1_CR1_ADON);
	bset	0x5401, #0
;	ADC.c: 62: while (!(ADC1_CSR & (1 << ADC1_CSR_EOC)));
00103$:
	ld	a, 0x5400
	jrpl	00103$
;	ADC.c: 65: uint8_t adcL = ADC1_DRL;
	ld	a, 0x5405
	ld	xl, a
;	ADC.c: 66: uint8_t adcH = ADC1_DRH;
	ld	a, 0x5404
	ld	xh, a
;	ADC.c: 69: ADC1_CSR &= ~(1 << ADC1_CSR_EOC);
	bres	0x5400, #7
;	ADC.c: 71: return ((uint16_t)adcH << 8) | adcL;
	clr	(0x02, sp)
	ld	a, xl
	clr	(0x03, sp)
	or	a, (0x02, sp)
	rlwa	x
	or	a, (0x03, sp)
	ld	xh, a
00106$:
;	ADC.c: 72: }
	addw	sp, #4
	ret
;	ADC.c: 74: void adc_init(uint8_t channel) {
;	-----------------------------------------
;	 function adc_init
;	-----------------------------------------
_adc_init:
	push	a
;	ADC.c: 75: if (channel > 7) return; // Sanity check pour STM8S103
	ld	xl, a
	cp	a, #0x07
	jrugt	00103$
;	ADC.c: 77: CLK_PCKENR2 |= (1 << 3); // Activer horloge ADC1
	bset	0x50ca, #3
;	ADC.c: 80: ADC1_CSR = (ADC1_CSR & 0xF8) | (channel & 0x07);
	ld	a, 0x5400
	and	a, #0xf8
	ld	(0x01, sp), a
	ld	a, xl
	and	a, #0x07
	or	a, (0x01, sp)
	ld	0x5400, a
;	ADC.c: 83: ADC1_CR2 |= (1 << ADC1_CR2_ALIGN);
	bset	0x5402, #3
;	ADC.c: 86: ADC1_CR1 |= (1 << ADC1_CR1_ADON);
	bset	0x5401, #0
00103$:
;	ADC.c: 87: }
	pop	a
	ret
;	ADC.c: 90: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	sub	sp, #2
;	ADC.c: 92: uart_config();   // UART pour debug série
	call	_uart_config
;	ADC.c: 93: adc_init(4);      // Initialise ADC sur PD3 (ADC2)
	ld	a, #0x04
	call	_adc_init
;	ADC.c: 95: while (1) {
00102$:
;	ADC.c: 96: uint16_t value = adc_read(4);  // Lecture
	ld	a, #0x04
	call	_adc_read
;	ADC.c: 97: uint16_t millivolts = (value * 5000UL) / 1023;
	ldw	(0x01, sp), x
	pushw	x
	ldw	x, #0x1388
	call	___muluint2ulong
	addw	sp, #2
	push	#0xff
	push	#0x03
	push	#0x00
	push	#0x00
	pushw	x
	pushw	y
	call	__divulong
	addw	sp, #8
;	ADC.c: 98: printf("ADC:%u,Voltage:%u\r\n", value, millivolts);
	pushw	x
	ldw	x, (0x03, sp)
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
	addw	sp, #6
;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00107$:
	cpw	y, #0x5320
	ld	a, xl
	sbc	a, #0x14
	ld	a, xh
	sbc	a, #0x00
	jrnc	00102$
;	ADC.c: 48: __asm__("nop");
	nop
;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00107$
	incw	x
	jra	00107$
;	ADC.c: 99: delay_ms(1500); // mini delay
;	ADC.c: 101: }
	addw	sp, #2
	ret
	.area CODE
	.area CONST
	.area CONST
___str_0:
	.ascii "ADC:%u,Voltage:%u"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
