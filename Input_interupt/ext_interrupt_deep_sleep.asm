;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module ext_interrupt_deep_sleep
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _button_handler
	.globl _uart_read
	.globl _uart_write
	.globl _uart_config
	.globl _puts
	.globl _wake_pending
	.globl _last_press_time
	.globl _putchar
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
_button_handler_now_65536_22:
	.ds 4
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_last_press_time::
	.ds 4
_wake_pending::
	.ds 1
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
	int 0x000000 ; trap
	int 0x000000 ; int0
	int 0x000000 ; int1
	int 0x000000 ; int2
	int _button_handler ; int3
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
;	ext_interrupt_deep_sleep.c: 55: static uint32_t now = 0;
	clrw	x
	ldw	_button_handler_now_65536_22+2, x
	ldw	_button_handler_now_65536_22+0, x
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
;	ext_interrupt_deep_sleep.c: 9: void uart_config() {
;	-----------------------------------------
;	 function uart_config
;	-----------------------------------------
_uart_config:
;	ext_interrupt_deep_sleep.c: 10: CLK_CKDIVR = 0x00; // force 16 mhz 
	mov	0x50c6+0, #0x00
;	ext_interrupt_deep_sleep.c: 18: uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
	ld	a, #0x68
	ld	xl, a
;	ext_interrupt_deep_sleep.c: 19: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8
	ld	a, #0x83
	and	a, #0x0f
;	ext_interrupt_deep_sleep.c: 21: UART1_BRR1 = brr1;
	ldw	y, #0x5232
	push	a
	ld	a, xl
	ld	(y), a
	pop	a
;	ext_interrupt_deep_sleep.c: 22: UART1_BRR2 = brr2;
	ld	0x5233, a
;	ext_interrupt_deep_sleep.c: 23: UART1_CR1 = 0x00;    // 8 data bits, no parity
	mov	0x5234+0, #0x00
;	ext_interrupt_deep_sleep.c: 24: UART1_CR3 = 0x00;    // 1 stop bit
	mov	0x5236+0, #0x00
;	ext_interrupt_deep_sleep.c: 25: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
	mov	0x5235+0, #0x0c
;	ext_interrupt_deep_sleep.c: 27: (void)UART1_SR;
	ld	a, 0x5230
;	ext_interrupt_deep_sleep.c: 28: (void)UART1_DR;
	ld	a, 0x5231
;	ext_interrupt_deep_sleep.c: 29: }
	ret
;	ext_interrupt_deep_sleep.c: 31: void uart_write(uint8_t data) {
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
;	ext_interrupt_deep_sleep.c: 32: UART1_DR = data;
	ld	0x5231, a
;	ext_interrupt_deep_sleep.c: 33: PB_ODR &= ~(1 << 5);  // LED OFF
	bres	0x5005, #5
;	ext_interrupt_deep_sleep.c: 34: while (!(UART1_SR & (1 << UART1_SR_TC)));
00101$:
	btjf	0x5230, #6, 00101$
;	ext_interrupt_deep_sleep.c: 35: PB_ODR |= (1 << 5);   // LED ON
	bset	0x5005, #5
;	ext_interrupt_deep_sleep.c: 36: }
	ret
;	ext_interrupt_deep_sleep.c: 38: uint8_t uart_read() {
;	-----------------------------------------
;	 function uart_read
;	-----------------------------------------
_uart_read:
;	ext_interrupt_deep_sleep.c: 39: while (!(UART1_SR & (1 << UART1_SR_RXNE)));
00101$:
	btjf	0x5230, #5, 00101$
;	ext_interrupt_deep_sleep.c: 40: return UART1_DR;
	ld	a, 0x5231
;	ext_interrupt_deep_sleep.c: 41: }
	ret
;	ext_interrupt_deep_sleep.c: 43: int putchar(int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	ext_interrupt_deep_sleep.c: 44: uart_write(c);
	call	_uart_write
;	ext_interrupt_deep_sleep.c: 45: return 0;
	clrw	x
;	ext_interrupt_deep_sleep.c: 46: }
	ret
;	ext_interrupt_deep_sleep.c: 48: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	ext_interrupt_deep_sleep.c: 51: __asm__("nop");
	nop
;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	ext_interrupt_deep_sleep.c: 52: }
	addw	sp, #10
	ret
;	ext_interrupt_deep_sleep.c: 54: void button_handler(void) __interrupt(3) {
;	-----------------------------------------
;	 function button_handler
;	-----------------------------------------
_button_handler:
	sub	sp, #4
;	ext_interrupt_deep_sleep.c: 56: now += 1;  // Incrémente à chaque IT, ou via timer en fond si dispo
	ldw	x, _button_handler_now_65536_22+2
	addw	x, #0x0001
	ldw	y, _button_handler_now_65536_22+0
	jrnc	00117$
	incw	y
00117$:
	ldw	_button_handler_now_65536_22+2, x
	ldw	_button_handler_now_65536_22+0, y
;	ext_interrupt_deep_sleep.c: 57: if ((now - last_press_time) > 1) {  // 1 "ticks" d'écart
	ldw	x, _button_handler_now_65536_22+2
	subw	x, _last_press_time+2
	ldw	(0x03, sp), x
	ld	a, _button_handler_now_65536_22+1
	sbc	a, _last_press_time+1
	ld	(0x02, sp), a
	ld	a, _button_handler_now_65536_22+0
	sbc	a, _last_press_time+0
	ld	(0x01, sp), a
	clrw	x
	incw	x
	cpw	x, (0x03, sp)
	clr	a
	sbc	a, (0x02, sp)
	clr	a
	sbc	a, (0x01, sp)
	jrnc	00105$
;	ext_interrupt_deep_sleep.c: 58: if (!(PA_IDR & (1 << 3))) {
	btjt	0x5001, #3, 00105$
;	ext_interrupt_deep_sleep.c: 59: wake_pending = 1;  // Juste un flag de réveil
	mov	_wake_pending+0, #0x01
;	ext_interrupt_deep_sleep.c: 60: last_press_time = now;
	ldw	x, _button_handler_now_65536_22+2
	ldw	_last_press_time+2, x
	ldw	x, _button_handler_now_65536_22+0
	ldw	_last_press_time+0, x
00105$:
;	ext_interrupt_deep_sleep.c: 63: }
	addw	sp, #4
	iret
;	ext_interrupt_deep_sleep.c: 65: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	ext_interrupt_deep_sleep.c: 67: uart_config();
	call	_uart_config
;	ext_interrupt_deep_sleep.c: 69: PD_DDR |= (1 << 3);
	bset	0x5011, #3
;	ext_interrupt_deep_sleep.c: 70: PD_CR1 |= (1 << 3);
	bset	0x5012, #3
;	ext_interrupt_deep_sleep.c: 71: PD_ODR &= ~(1 << 3);  // LED éteinte
	bres	0x500f, #3
;	ext_interrupt_deep_sleep.c: 74: PA_DDR &= ~(1 << 3);   // Entrée
	bres	0x5002, #3
;	ext_interrupt_deep_sleep.c: 75: PA_CR1 |= (1 << 3);    // Pull-up
	bset	0x5003, #3
;	ext_interrupt_deep_sleep.c: 76: PA_CR2 |= (1 << 3);    // Active interruption pour PA3
	ld	a, 0x5004
	or	a, #0x08
	ld	0x5004, a
;	ext_interrupt_deep_sleep.c: 79: EXTI_CR1 &= ~(0b11 << 0);   // Efface les bits PAIS[1:0]
	ld	a, 0x50a0
	and	a, #0xfc
	ld	0x50a0, a
;	ext_interrupt_deep_sleep.c: 80: EXTI_CR1 |=  (0b10 << 0);   // Met 10 = front descendant
	ld	a, 0x50a0
	or	a, #0x02
	ld	0x50a0, a
;	ext_interrupt_deep_sleep.c: 82: __asm__("rim");  // autorise les interruptions
	rim
;	ext_interrupt_deep_sleep.c: 84: while (1) {
00104$:
;	ext_interrupt_deep_sleep.c: 85: __asm__("halt");  // Va en sommeil
	halt
;	ext_interrupt_deep_sleep.c: 87: if (wake_pending) {
	tnz	_wake_pending+0
	jreq	00104$
;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00111$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00107$
;	ext_interrupt_deep_sleep.c: 51: __asm__("nop");
	nop
;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00111$
	incw	x
	jra	00111$
;	ext_interrupt_deep_sleep.c: 88: delay_ms(5); // timer pour un filtre anti rebond
00107$:
;	ext_interrupt_deep_sleep.c: 89: wake_pending = 0;
	clr	_wake_pending+0
;	ext_interrupt_deep_sleep.c: 90: PD_ODR |= (1 << 3);  
	bset	0x500f, #3
;	ext_interrupt_deep_sleep.c: 91: printf("Réveillé !\r\n");
	ldw	x, #(___str_1+0)
	call	_puts
;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00114$:
	cpw	y, #0xad70
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00109$
;	ext_interrupt_deep_sleep.c: 51: __asm__("nop");
	nop
;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00114$
	incw	x
	jra	00114$
;	ext_interrupt_deep_sleep.c: 92: delay_ms(50);
00109$:
;	ext_interrupt_deep_sleep.c: 93: printf("ZZZzzzzzZZZZZzzzzZZZ\r\n");
	ldw	x, #(___str_3+0)
	call	_puts
;	ext_interrupt_deep_sleep.c: 94: PD_ODR &= ~(1 << 3);
	ld	a, 0x500f
	and	a, #0xf7
	ld	0x500f, a
	jra	00104$
;	ext_interrupt_deep_sleep.c: 98: }
	ret
	.area CODE
	.area CONST
	.area CONST
___str_1:
	.ascii "R"
	.db 0xc3
	.db 0xa9
	.ascii "veill"
	.db 0xc3
	.db 0xa9
	.ascii " !"
	.db 0x0d
	.db 0x00
	.area CODE
	.area CONST
___str_3:
	.ascii "ZZZzzzzzZZZZZzzzzZZZ"
	.db 0x0d
	.db 0x00
	.area CODE
	.area INITIALIZER
__xinit__last_press_time:
	.byte #0x00, #0x00, #0x00, #0x00	; 0
__xinit__wake_pending:
	.db #0x00	; 0
	.area CABS (ABS)
