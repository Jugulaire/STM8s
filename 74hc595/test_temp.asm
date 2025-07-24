;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module test_temp
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _digit_segments
	.globl _main
	.globl _ds18b20_read_raw
	.globl _ds18b20_start_conversion
	.globl _onewire_read_byte
	.globl _onewire_write_byte
	.globl _onewire_read_bit
	.globl _onewire_write_bit
	.globl _onewire_reset
	.globl _display_step
	.globl _display_int
	.globl _display_float
	.globl _setup
	.globl _delay_ms
	.globl _delay_us
	.globl _display_digit
	.globl _disable_all_digits
	.globl _latch
	.globl _shift_out
	.globl _uart_read
	.globl _uart_write
	.globl _uart_config
	.globl _digits
	.globl _putchar
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
_display_step_pos_65536_48:
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_digits::
	.ds 4
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
;	test_temp.c: 235: static uint8_t pos = 0;
	clr	_display_step_pos_65536_48+0
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
;	test_temp.c: 27: void uart_config() {
;	-----------------------------------------
;	 function uart_config
;	-----------------------------------------
_uart_config:
;	test_temp.c: 28: CLK_CKDIVR = 0x00; // Horloge non divisée (reste à 16 MHz)
	mov	0x50c6+0, #0x00
;	test_temp.c: 33: uint8_t brr1 = (usartdiv >> 4) & 0xFF;
	ld	a, #0x68
	ld	xl, a
;	test_temp.c: 34: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);
	ld	a, #0x83
	and	a, #0x0f
;	test_temp.c: 36: UART1_BRR1 = brr1;
	ldw	y, #0x5232
	push	a
	ld	a, xl
	ld	(y), a
	pop	a
;	test_temp.c: 37: UART1_BRR2 = brr2;
	ld	0x5233, a
;	test_temp.c: 39: UART1_CR1 = 0x00; // Pas de parité, 8 bits de données
	mov	0x5234+0, #0x00
;	test_temp.c: 40: UART1_CR3 = 0x00; // 1 bit de stop
	mov	0x5236+0, #0x00
;	test_temp.c: 41: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // Active TX et RX
	mov	0x5235+0, #0x0c
;	test_temp.c: 44: (void)UART1_SR;
	ld	a, 0x5230
;	test_temp.c: 45: (void)UART1_DR;
	ld	a, 0x5231
;	test_temp.c: 46: }
	ret
;	test_temp.c: 49: void uart_write(uint8_t data) {
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
;	test_temp.c: 50: UART1_DR = data;                    // Envoie l'octet
	ld	0x5231, a
;	test_temp.c: 51: PB_ODR &= ~(1 << 5);                // Éteint une LED (facultatif pour debug)
	bres	0x5005, #5
;	test_temp.c: 52: while (!(UART1_SR & (1 << UART1_SR_TC))); // Attente que la transmission soit terminée
00101$:
	btjf	0x5230, #6, 00101$
;	test_temp.c: 53: PB_ODR |= (1 << 5);                 // Allume la LED (facultatif)
	bset	0x5005, #5
;	test_temp.c: 54: }
	ret
;	test_temp.c: 57: uint8_t uart_read() {
;	-----------------------------------------
;	 function uart_read
;	-----------------------------------------
_uart_read:
;	test_temp.c: 58: while (!(UART1_SR & (1 << UART1_SR_RXNE))); // Attente réception
00101$:
	btjf	0x5230, #5, 00101$
;	test_temp.c: 59: return UART1_DR;
	ld	a, 0x5231
;	test_temp.c: 60: }
	ret
;	test_temp.c: 63: int putchar(int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	test_temp.c: 64: uart_write(c);
	call	_uart_write
;	test_temp.c: 65: return 0;
	clrw	x
;	test_temp.c: 66: }
	ret
;	test_temp.c: 84: void shift_out(uint8_t val) {
;	-----------------------------------------
;	 function shift_out
;	-----------------------------------------
_shift_out:
	push	a
	ld	xh, a
;	test_temp.c: 85: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x01, sp)
00106$:
	ld	a, (0x01, sp)
	cp	a, #0x08
	jrnc	00108$
;	test_temp.c: 86: if (val & 0x80) PC_ODR |= (1 << 3);   // DATA HIGH
	ld	a, 0x500a
	tnzw	x
	jrpl	00102$
	or	a, #0x08
	ld	0x500a, a
	jra	00103$
00102$:
;	test_temp.c: 87: else            PC_ODR &= ~(1 << 3);  // DATA LOW
	and	a, #0xf7
	ld	0x500a, a
00103$:
;	test_temp.c: 89: PC_ODR |= (1 << 4);  // CLOCK HIGH
	bset	0x500a, #4
;	test_temp.c: 90: PC_ODR &= ~(1 << 4); // CLOCK LOW
	bres	0x500a, #4
;	test_temp.c: 92: val <<= 1;
	ld	a, xh
	sll	a
	ld	xh, a
;	test_temp.c: 85: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x01, sp)
	jra	00106$
00108$:
;	test_temp.c: 94: }
	pop	a
	ret
;	test_temp.c: 96: void latch() {
;	-----------------------------------------
;	 function latch
;	-----------------------------------------
_latch:
;	test_temp.c: 97: PC_ODR |= (1 << 5);  // LATCH HIGH
	bset	0x500a, #5
;	test_temp.c: 98: PC_ODR &= ~(1 << 5); // LATCH LOW
	bres	0x500a, #5
;	test_temp.c: 99: }
	ret
;	test_temp.c: 102: void disable_all_digits() {
;	-----------------------------------------
;	 function disable_all_digits
;	-----------------------------------------
_disable_all_digits:
;	test_temp.c: 104: PA_ODR |= (1 << 1); // D3
	bset	0x5000, #1
;	test_temp.c: 105: PA_ODR |= (1 << 2); // D1
	bset	0x5000, #2
;	test_temp.c: 106: PA_ODR |= (1 << 3); // D4
	bset	0x5000, #3
;	test_temp.c: 107: PD_ODR |= (1 << 4); // D2
	bset	0x500f, #4
;	test_temp.c: 108: }
	ret
;	test_temp.c: 110: void display_digit(uint8_t value, uint8_t pos) {
;	-----------------------------------------
;	 function display_digit
;	-----------------------------------------
_display_digit:
	ld	xl, a
;	test_temp.c: 112: PA_ODR |= (1 << 1); // D3
	bset	0x5000, #1
;	test_temp.c: 113: PA_ODR |= (1 << 2); // D1
	bset	0x5000, #2
;	test_temp.c: 114: PA_ODR |= (1 << 3); // D4
	bset	0x5000, #3
;	test_temp.c: 115: PD_ODR |= (1 << 4); // D2
	bset	0x500f, #4
;	test_temp.c: 118: shift_out(digit_segments[value]);
	clr	a
	ld	xh, a
	ld	a, (_digit_segments+0, x)
	call	_shift_out
;	test_temp.c: 119: latch();
	call	_latch
;	test_temp.c: 123: switch (pos) {
	ld	a, (0x03, sp)
	cp	a, #0x00
	jreq	00101$
	ld	a, (0x03, sp)
	dec	a
	jreq	00102$
	ld	a, (0x03, sp)
	cp	a, #0x02
	jreq	00103$
	ld	a, (0x03, sp)
	cp	a, #0x03
	jreq	00104$
	jra	00106$
;	test_temp.c: 124: case 0: PA_ODR &= ~(1 << 3); break; // D4 → gauche
00101$:
	ld	a, 0x5000
	and	a, #0xf7
	ld	0x5000, a
	jra	00106$
;	test_temp.c: 125: case 1: PA_ODR &= ~(1 << 1); break; // D3
00102$:
	ld	a, 0x5000
	and	a, #0xfd
	ld	0x5000, a
	jra	00106$
;	test_temp.c: 126: case 2: PD_ODR &= ~(1 << 4); break; // D2
00103$:
	ld	a, 0x500f
	and	a, #0xef
	ld	0x500f, a
	jra	00106$
;	test_temp.c: 127: case 3: PA_ODR &= ~(1 << 2); break; // D1 → droite
00104$:
	ld	a, 0x5000
	and	a, #0xfb
	ld	0x5000, a
;	test_temp.c: 128: }
00106$:
;	test_temp.c: 130: }
	popw	x
	pop	a
	jp	(x)
;	test_temp.c: 132: void delay_us(uint16_t us) {
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
;	test_temp.c: 133: while(us--) {
00101$:
	ldw	y, x
	decw	x
	tnzw	y
	jrne	00117$
	ret
00117$:
;	test_temp.c: 134: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
;	test_temp.c: 135: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
	jra	00101$
;	test_temp.c: 137: }
	ret
;	test_temp.c: 140: void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #4
	ldw	(0x03, sp), x
;	test_temp.c: 141: for (uint16_t i = 0; i < ms; i++) {
	clrw	x
00107$:
	cpw	x, (0x03, sp)
	jrnc	00109$
;	test_temp.c: 142: for (volatile uint16_t j = 0; j < 1000; j++)
	clr	(0x02, sp)
	clr	(0x01, sp)
00104$:
	ldw	y, (0x01, sp)
	cpw	y, #0x03e8
	jrnc	00108$
;	test_temp.c: 143: __asm__("nop");
	nop
;	test_temp.c: 142: for (volatile uint16_t j = 0; j < 1000; j++)
	ldw	y, (0x01, sp)
	incw	y
	ldw	(0x01, sp), y
	jra	00104$
00108$:
;	test_temp.c: 141: for (uint16_t i = 0; i < ms; i++) {
	incw	x
	jra	00107$
00109$:
;	test_temp.c: 145: }
	addw	sp, #4
	ret
;	test_temp.c: 148: void setup() {
;	-----------------------------------------
;	 function setup
;	-----------------------------------------
_setup:
;	test_temp.c: 150: PC_DDR |= (1 << 3) | (1 << 4) | (1 << 5);
	ld	a, 0x500c
	or	a, #0x38
	ld	0x500c, a
;	test_temp.c: 151: PC_CR1 |= (1 << 3) | (1 << 4) | (1 << 5);
	ld	a, 0x500d
	or	a, #0x38
	ld	0x500d, a
;	test_temp.c: 154: PA_DDR |= (1 << 1) | (1 << 2) | (1 << 3);
	ld	a, 0x5002
	or	a, #0x0e
	ld	0x5002, a
;	test_temp.c: 155: PA_CR1 |= (1 << 1) | (1 << 2) | (1 << 3);
	ld	a, 0x5003
	or	a, #0x0e
	ld	0x5003, a
;	test_temp.c: 158: PD_DDR |= (1 << 4);
	bset	0x5011, #4
;	test_temp.c: 159: PD_CR1 |= (1 << 4);
	bset	0x5012, #4
;	test_temp.c: 160: }
	ret
;	test_temp.c: 162: void display_float(float value) {
;	-----------------------------------------
;	 function display_float
;	-----------------------------------------
_display_float:
	sub	sp, #6
;	test_temp.c: 163: if (value < 0 || value >= 100) return; // Ne supporte que 00.00 à 99.99
	clrw	x
	pushw	x
	clrw	x
	pushw	x
	ldw	x, (0x0f, sp)
	pushw	x
	ldw	x, (0x0f, sp)
	pushw	x
	call	___fslt
	ld	(0x06, sp), a
	jreq	00167$
	jp	00119$
00167$:
	clrw	x
	pushw	x
	push	#0xc8
	push	#0x42
	ldw	x, (0x0f, sp)
	pushw	x
	ldw	x, (0x0f, sp)
	pushw	x
	call	___fslt
	tnz	a
	jrne	00102$
	jp	00119$
00102$:
;	test_temp.c: 165: uint16_t scaled = (uint16_t)(value * 100); // Ex: 34.56 → 3456
	ldw	x, (0x0b, sp)
	pushw	x
	ldw	x, (0x0b, sp)
	pushw	x
	clrw	x
	pushw	x
	push	#0xc8
	push	#0x42
	call	___fsmul
	pushw	x
	pushw	y
	call	___fs2uint
;	test_temp.c: 168: digits[0] = (scaled / 1000) % 10;
	ldw	(0x05, sp), x
	ldw	y, #0x03e8
	divw	x, y
	ldw	y, #0x000a
	divw	x, y
	ld	a, yl
	ld	(0x01, sp), a
;	test_temp.c: 169: digits[1] = (scaled / 100) % 10;
	ldw	x, (0x05, sp)
	ldw	y, #0x0064
	divw	x, y
	ldw	y, #0x000a
	divw	x, y
	ld	a, yl
	ld	(0x02, sp), a
;	test_temp.c: 170: digits[2] = (scaled / 10) % 10;
	ldw	x, (0x05, sp)
	ldw	y, #0x000a
	divw	x, y
	ldw	y, #0x000a
	divw	x, y
	ld	a, yl
	ld	(0x03, sp), a
;	test_temp.c: 171: digits[3] = scaled % 10;
	ldw	x, (0x05, sp)
	ldw	y, #0x000a
	divw	x, y
	ld	a, yl
	ld	(0x04, sp), a
;	test_temp.c: 173: for (uint8_t i = 0; i < 4; i++) {
	clr	(0x06, sp)
00117$:
	ld	a, (0x06, sp)
	cp	a, #0x04
	jrc	00169$
	jp	00119$
00169$:
;	test_temp.c: 174: uint8_t seg = digit_segments[digits[i]];
	clrw	x
	ld	a, (0x06, sp)
	ld	xl, a
	pushw	x
	ldw	x, sp
	addw	x, #3
	addw	x, (1, sp)
	addw	sp, #2
	ld	a, (x)
	clrw	x
	ld	xl, a
	addw	x, #(_digit_segments+0)
	ld	a, (x)
;	test_temp.c: 177: if (i == 1) seg |= 0x80;
	push	a
	ld	a, (0x07, sp)
	dec	a
	pop	a
	jrne	00171$
	push	a
	ld	a, #0x01
	ld	(0x06, sp), a
	pop	a
	.byte 0xc5
00171$:
	clr	(0x05, sp)
00172$:
	tnz	(0x05, sp)
	jreq	00105$
	or	a, #0x80
00105$:
;	test_temp.c: 179: disable_all_digits();
	push	a
	call	_disable_all_digits
	pop	a
;	test_temp.c: 180: shift_out(seg);
	call	_shift_out
;	test_temp.c: 181: latch();
	call	_latch
;	test_temp.c: 184: switch (i) {
	ld	a, (0x06, sp)
	sub	a, #0x03
	jrne	00175$
	inc	a
	ld	xl, a
	jra	00176$
00175$:
	clr	a
	ld	xl, a
00176$:
	ld	a, (0x06, sp)
	cp	a, #0x00
	jreq	00106$
	tnz	(0x05, sp)
	jrne	00107$
	ld	a, (0x06, sp)
	cp	a, #0x02
	jreq	00108$
	ld	a, xl
	tnz	a
	jrne	00109$
	jra	00110$
;	test_temp.c: 185: case 0: PA_ODR &= ~(1 << 3); break; // D4 (pos 0)
00106$:
	bres	0x5000, #3
	jra	00110$
;	test_temp.c: 186: case 1: PA_ODR &= ~(1 << 1); break; // D3
00107$:
	bres	0x5000, #1
	jra	00110$
;	test_temp.c: 187: case 2: PD_ODR &= ~(1 << 4); break; // D2
00108$:
	bres	0x500f, #4
	jra	00110$
;	test_temp.c: 188: case 3: PA_ODR &= ~(1 << 2); break; // D1
00109$:
	bres	0x5000, #2
;	test_temp.c: 189: }
00110$:
;	test_temp.c: 192: if (i == 1 || i == 3) delay_us(800); // digits 0 et 1 = 1ms
	tnz	(0x05, sp)
	jrne	00111$
	ld	a, xl
	tnz	a
	jreq	00112$
00111$:
	ldw	x, #0x0320
	call	_delay_us
	jra	00118$
00112$:
;	test_temp.c: 193: else                  delay_us(400);  // autres = 0.7ms 
	ldw	x, #0x0190
	call	_delay_us
00118$:
;	test_temp.c: 173: for (uint8_t i = 0; i < 4; i++) {
	inc	(0x06, sp)
	jp	00117$
00119$:
;	test_temp.c: 196: }
	ldw	x, (7, sp)
	addw	sp, #12
	jp	(x)
;	test_temp.c: 198: void display_int(uint16_t temp_x100) {
;	-----------------------------------------
;	 function display_int
;	-----------------------------------------
_display_int:
	sub	sp, #8
;	test_temp.c: 200: if (temp_x100 > 9999) temp_x100 = 9999;
	ldw	y, x
	cpw	y, #0x270f
	jrule	00102$
	ldw	x, #0x270f
00102$:
;	test_temp.c: 203: uint8_t d0 = (temp_x100 / 1000) % 10;
	ldw	(0x01, sp), x
	ldw	y, #0x03e8
	divw	x, y
	ldw	y, #0x000a
	divw	x, y
	ld	a, yl
;	test_temp.c: 204: uint8_t d1 = (temp_x100 / 100) % 10;
	ldw	x, (0x01, sp)
	ldw	y, #0x0064
	divw	x, y
	ldw	y, #0x000a
	divw	x, y
	exg	a, yl
	ld	(0x08, sp), a
	exg	a, yl
;	test_temp.c: 205: uint8_t d2 = (temp_x100 / 10) % 10;
	ldw	x, (0x01, sp)
	ldw	y, #0x000a
	divw	x, y
	ldw	y, #0x000a
	divw	x, y
	ldw	x, y
;	test_temp.c: 206: uint8_t d3 = temp_x100 % 10;
	pushw	x
	ldw	x, (0x03, sp)
	ldw	y, #0x000a
	divw	x, y
	popw	x
;	test_temp.c: 208: uint8_t digits[4] = { d0, d1, d2, d3 };
	ld	(0x03, sp), a
	ld	a, (0x08, sp)
	ld	(0x04, sp), a
	exg	a, xl
	ld	(0x05, sp), a
	exg	a, xl
	exg	a, yl
	ld	(0x06, sp), a
	exg	a, yl
;	test_temp.c: 210: for (uint8_t i = 0; i < 4; i++) {
	clr	(0x08, sp)
00116$:
	ld	a, (0x08, sp)
	cp	a, #0x04
	jrc	00167$
	jp	00118$
00167$:
;	test_temp.c: 211: uint8_t seg = digit_segments[digits[i]];
	clrw	x
	ld	a, (0x08, sp)
	ld	xl, a
	pushw	x
	ldw	x, sp
	addw	x, #5
	addw	x, (1, sp)
	addw	sp, #2
	ld	a, (x)
	clrw	x
	ld	xl, a
	addw	x, #(_digit_segments+0)
	ld	a, (x)
;	test_temp.c: 214: if (i == 1) seg |= 0x80;
	push	a
	ld	a, (0x09, sp)
	dec	a
	pop	a
	jrne	00169$
	push	a
	ld	a, #0x01
	ld	(0x08, sp), a
	pop	a
	.byte 0xc5
00169$:
	clr	(0x07, sp)
00170$:
	tnz	(0x07, sp)
	jreq	00104$
	or	a, #0x80
00104$:
;	test_temp.c: 216: disable_all_digits();
	push	a
	call	_disable_all_digits
	pop	a
;	test_temp.c: 217: shift_out(seg);
	call	_shift_out
;	test_temp.c: 218: latch();
	call	_latch
;	test_temp.c: 221: switch (i) {
	ld	a, (0x08, sp)
	sub	a, #0x03
	jrne	00173$
	inc	a
	ld	xl, a
	jra	00174$
00173$:
	clr	a
	ld	xl, a
00174$:
	ld	a, (0x08, sp)
	cp	a, #0x00
	jreq	00105$
	tnz	(0x07, sp)
	jrne	00106$
	ld	a, (0x08, sp)
	cp	a, #0x02
	jreq	00107$
	ld	a, xl
	tnz	a
	jrne	00108$
	jra	00109$
;	test_temp.c: 222: case 0: PA_ODR &= ~(1 << 3); break; // D4
00105$:
	bres	0x5000, #3
	jra	00109$
;	test_temp.c: 223: case 1: PA_ODR &= ~(1 << 1); break; // D3
00106$:
	bres	0x5000, #1
	jra	00109$
;	test_temp.c: 224: case 2: PD_ODR &= ~(1 << 4); break; // D2
00107$:
	bres	0x500f, #4
	jra	00109$
;	test_temp.c: 225: case 3: PA_ODR &= ~(1 << 2); break; // D1
00108$:
	bres	0x5000, #2
;	test_temp.c: 226: }
00109$:
;	test_temp.c: 229: if (i == 1 || i == 3) delay_us(800);
	tnz	(0x07, sp)
	jrne	00110$
	ld	a, xl
	tnz	a
	jreq	00111$
00110$:
	ldw	x, #0x0320
	call	_delay_us
	jra	00117$
00111$:
;	test_temp.c: 230: else                  delay_us(400);
	ldw	x, #0x0190
	call	_delay_us
00117$:
;	test_temp.c: 210: for (uint8_t i = 0; i < 4; i++) {
	inc	(0x08, sp)
	jp	00116$
00118$:
;	test_temp.c: 232: }
	addw	sp, #8
	ret
;	test_temp.c: 234: void display_step() {
;	-----------------------------------------
;	 function display_step
;	-----------------------------------------
_display_step:
;	test_temp.c: 237: disable_all_digits();
	call	_disable_all_digits
;	test_temp.c: 239: uint8_t seg = digit_segments[digits[pos]];
	clrw	x
	ld	a, _display_step_pos_65536_48+0
	ld	xl, a
	ld	a, (_digits+0, x)
	clrw	x
	ld	xl, a
	ld	a, (_digit_segments+0, x)
;	test_temp.c: 242: if (pos == 1) seg |= 0x80;
	push	a
	ld	a, _display_step_pos_65536_48+0
	dec	a
	pop	a
	jrne	00102$
	or	a, #0x80
00102$:
;	test_temp.c: 244: shift_out(seg);
	call	_shift_out
;	test_temp.c: 245: latch();
	call	_latch
;	test_temp.c: 248: switch (pos) {
	ld	a, _display_step_pos_65536_48+0
	cp	a, #0x00
	jreq	00103$
	ld	a, _display_step_pos_65536_48+0
	dec	a
	jreq	00104$
	ld	a, _display_step_pos_65536_48+0
	cp	a, #0x02
	jreq	00105$
	ld	a, _display_step_pos_65536_48+0
	cp	a, #0x03
	jreq	00106$
	jra	00107$
;	test_temp.c: 249: case 0: PA_ODR &= ~(1 << 3); break; // D4
00103$:
	bres	0x5000, #3
	jra	00107$
;	test_temp.c: 250: case 1: PA_ODR &= ~(1 << 1); break; // D3
00104$:
	bres	0x5000, #1
	jra	00107$
;	test_temp.c: 251: case 2: PD_ODR &= ~(1 << 4); break; // D2
00105$:
	bres	0x500f, #4
	jra	00107$
;	test_temp.c: 252: case 3: PA_ODR &= ~(1 << 2); break; // D1
00106$:
	bres	0x5000, #2
;	test_temp.c: 253: }
00107$:
;	test_temp.c: 255: pos = (pos + 1) % 4; // Passe au digit suivant à chaque appel
	ld	a, _display_step_pos_65536_48+0
	clrw	x
	ld	xl, a
	incw	x
	push	#0x04
	push	#0x00
	call	__modsint
	ld	a, xl
	ld	_display_step_pos_65536_48+0, a
;	test_temp.c: 256: }
	ret
;	test_temp.c: 262: uint8_t onewire_reset(void) {
;	-----------------------------------------
;	 function onewire_reset
;	-----------------------------------------
_onewire_reset:
;	test_temp.c: 263: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
	bset	0x5011, #3
	bres	0x500f, #3
;	test_temp.c: 264: delay_us(480);
	ldw	x, #0x01e0
	call	_delay_us
;	test_temp.c: 265: DS_INPUT();                    // Relâche la ligne
	bres	0x5011, #3
;	test_temp.c: 266: delay_us(70);                  // Attend la réponse du capteur
	ldw	x, #0x0046
	call	_delay_us
;	test_temp.c: 267: uint8_t presence = !DS_READ(); // 0 = présence détectée
	ld	a, 0x5010
	swap	a
	sll	a
	clr	a
	rlc	a
	sub	a, #0x01
	clr	a
	rlc	a
;	test_temp.c: 268: delay_us(410);                 // Fin du timing 1-Wire
	push	a
	ldw	x, #0x019a
	call	_delay_us
	pop	a
;	test_temp.c: 269: return presence;
;	test_temp.c: 270: }
	ret
;	test_temp.c: 273: void onewire_write_bit(uint8_t bit) {
;	-----------------------------------------
;	 function onewire_write_bit
;	-----------------------------------------
_onewire_write_bit:
	push	a
	ld	(0x01, sp), a
;	test_temp.c: 274: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	test_temp.c: 275: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
	tnz	(0x01, sp)
	jreq	00103$
	ldw	x, #0x0006
	.byte 0xbc
00103$:
	ldw	x, #0x003c
00104$:
	call	_delay_us
;	test_temp.c: 276: DS_INPUT();                    // Libère la ligne
	bres	0x5011, #3
;	test_temp.c: 277: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
	tnz	(0x01, sp)
	jreq	00105$
	ldw	x, #0x0040
	jra	00106$
00105$:
	ldw	x, #0x000a
00106$:
	pop	a
	jp	_delay_us
;	test_temp.c: 278: }
	pop	a
	ret
;	test_temp.c: 281: uint8_t onewire_read_bit(void) {
;	-----------------------------------------
;	 function onewire_read_bit
;	-----------------------------------------
_onewire_read_bit:
;	test_temp.c: 283: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	test_temp.c: 284: delay_us(6);                   // Pulse d'initiation de lecture
	ldw	x, #0x0006
	call	_delay_us
;	test_temp.c: 285: DS_INPUT();                    // Libère la ligne pour lire
	bres	0x5011, #3
;	test_temp.c: 286: delay_us(9);                   // Délai standard
	ldw	x, #0x0009
	call	_delay_us
;	test_temp.c: 287: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
	btjf	0x5010, #3, 00103$
	clrw	x
	incw	x
	.byte 0x21
00103$:
	clrw	x
00104$:
	ld	a, xl
;	test_temp.c: 288: delay_us(55);                  // Fin du slot
	push	a
	ldw	x, #0x0037
	call	_delay_us
	pop	a
;	test_temp.c: 289: return bit;
;	test_temp.c: 290: }
	ret
;	test_temp.c: 293: void onewire_write_byte(uint8_t byte) {
;	-----------------------------------------
;	 function onewire_write_byte
;	-----------------------------------------
_onewire_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	test_temp.c: 294: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00103$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00105$
;	test_temp.c: 295: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
	ld	a, (0x01, sp)
	and	a, #0x01
	call	_onewire_write_bit
;	test_temp.c: 296: byte >>= 1;
	srl	(0x01, sp)
;	test_temp.c: 294: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00103$
00105$:
;	test_temp.c: 298: }
	addw	sp, #2
	ret
;	test_temp.c: 301: uint8_t onewire_read_byte(void) {
;	-----------------------------------------
;	 function onewire_read_byte
;	-----------------------------------------
_onewire_read_byte:
	sub	sp, #2
;	test_temp.c: 302: uint8_t byte = 0;
	clr	(0x01, sp)
;	test_temp.c: 303: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00105$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00103$
;	test_temp.c: 304: byte >>= 1;
	srl	(0x01, sp)
;	test_temp.c: 305: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
	call	_onewire_read_bit
	tnz	a
	jreq	00106$
	sll	(0x01, sp)
	scf
	rrc	(0x01, sp)
00106$:
;	test_temp.c: 303: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00105$
00103$:
;	test_temp.c: 307: return byte;
	ld	a, (0x01, sp)
;	test_temp.c: 308: }
	addw	sp, #2
	ret
;	test_temp.c: 311: void ds18b20_start_conversion(void) {
;	-----------------------------------------
;	 function ds18b20_start_conversion
;	-----------------------------------------
_ds18b20_start_conversion:
;	test_temp.c: 312: onewire_reset();
	call	_onewire_reset
;	test_temp.c: 313: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
	ld	a, #0xcc
	call	_onewire_write_byte
;	test_temp.c: 314: onewire_write_byte(0x44); // Convert T (lance mesure)
	ld	a, #0x44
;	test_temp.c: 315: }
	jp	_onewire_write_byte
;	test_temp.c: 318: int16_t ds18b20_read_raw(void) {
;	-----------------------------------------
;	 function ds18b20_read_raw
;	-----------------------------------------
_ds18b20_read_raw:
	sub	sp, #4
;	test_temp.c: 319: onewire_reset();
	call	_onewire_reset
;	test_temp.c: 320: onewire_write_byte(0xCC); // Skip ROM
	ld	a, #0xcc
	call	_onewire_write_byte
;	test_temp.c: 321: onewire_write_byte(0xBE); // Read Scratchpad
	ld	a, #0xbe
	call	_onewire_write_byte
;	test_temp.c: 323: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
	call	_onewire_read_byte
;	test_temp.c: 324: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
	push	a
	call	_onewire_read_byte
	ld	xh, a
	pop	a
;	test_temp.c: 326: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
	clr	(0x02, sp)
	clr	(0x03, sp)
	or	a, (0x02, sp)
	rlwa	x
	or	a, (0x03, sp)
	ld	xh, a
;	test_temp.c: 327: }
	addw	sp, #4
	ret
;	test_temp.c: 330: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	sub	sp, #4
;	test_temp.c: 331: setup();
	call	_setup
;	test_temp.c: 332: uart_config();
	call	_uart_config
;	test_temp.c: 334: PD_DDR &= ~(1 << 3);
	bres	0x5011, #3
;	test_temp.c: 335: PD_CR1 |= (1 << 3);
	bset	0x5012, #3
;	test_temp.c: 337: uint16_t temp_x100 = 2430; // Valeur de départ par défaut
	ldw	x, #0x097e
	ldw	(0x01, sp), x
;	test_temp.c: 338: uint16_t counter = 0;
	clrw	x
	ldw	(0x03, sp), x
;	test_temp.c: 340: ds18b20_start_conversion(); // Démarre première conversion
	call	_ds18b20_start_conversion
;	test_temp.c: 342: while (1) {
00104$:
;	test_temp.c: 344: display_int(temp_x100);
	ldw	x, (0x01, sp)
	call	_display_int
;	test_temp.c: 346: delay_ms(5); // assez long pour multiplexage stable
	ldw	x, #0x0005
	call	_delay_ms
;	test_temp.c: 348: counter += 5;
	ldw	x, (0x03, sp)
	addw	x, #0x0005
;	test_temp.c: 349: if (counter >= 750) {
	ldw	(0x03, sp), x
	cpw	x, #0x02ee
	jrc	00104$
;	test_temp.c: 350: counter = 0;
	clrw	x
	ldw	(0x03, sp), x
;	test_temp.c: 353: int16_t raw = ds18b20_read_raw();
	call	_ds18b20_read_raw
;	test_temp.c: 354: temp_x100 = (raw * 625UL) / 100;
	clrw	y
	tnzw	x
	jrpl	00119$
	decw	y
00119$:
	pushw	x
	pushw	y
	push	#0x71
	push	#0x02
	clrw	x
	pushw	x
	call	__mullong
	addw	sp, #8
	push	#0x64
	push	#0x00
	push	#0x00
	push	#0x00
	pushw	x
	pushw	y
	call	__divulong
	addw	sp, #8
	ldw	(0x01, sp), x
;	test_temp.c: 357: ds18b20_start_conversion();
	call	_ds18b20_start_conversion
	jra	00104$
;	test_temp.c: 360: }
	addw	sp, #4
	ret
	.area CODE
	.area CONST
_digit_segments:
	.db #0x3f	; 63
	.db #0x06	; 6
	.db #0x5b	; 91
	.db #0x4f	; 79	'O'
	.db #0x66	; 102	'f'
	.db #0x6d	; 109	'm'
	.db #0x7d	; 125
	.db #0x07	; 7
	.db #0x7f	; 127
	.db #0x6f	; 111	'o'
	.area INITIALIZER
__xinit__digits:
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.area CABS (ABS)
