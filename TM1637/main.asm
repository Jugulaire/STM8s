;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _digit_to_segment
	.globl _main
	.globl _tm_display_temp_x100
	.globl _tm_set_segments
	.globl _tm_write_byte
	.globl _tm_stop
	.globl _tm_start
	.globl _tm_delay
	.globl _delay_ms
	.globl _delay_us
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
;	main.c: 19: void delay_us(uint16_t us) {
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
;	main.c: 20: while(us--) {
00101$:
	ldw	y, x
	decw	x
	tnzw	y
	jrne	00117$
	ret
00117$:
;	main.c: 21: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
;	main.c: 22: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
	jra	00101$
;	main.c: 24: }
	ret
;	main.c: 26: void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	main.c: 28: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	main.c: 29: __asm__("nop");
	nop
;	main.c: 28: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	main.c: 30: }
	addw	sp, #10
	ret
;	main.c: 47: void tm_delay() {
;	-----------------------------------------
;	 function tm_delay
;	-----------------------------------------
_tm_delay:
	sub	sp, #2
;	main.c: 48: for (volatile int i = 0; i < 50; i++) __asm__("nop");
	clrw	x
	ldw	(0x01, sp), x
00103$:
	ldw	x, (0x01, sp)
	cpw	x, #0x0032
	jrsge	00105$
	nop
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
	jra	00103$
00105$:
;	main.c: 49: }
	addw	sp, #2
	ret
;	main.c: 51: void tm_start() {
;	-----------------------------------------
;	 function tm_start
;	-----------------------------------------
_tm_start:
;	main.c: 52: TM_DIO_DDR |= (1 << TM_DIO_PIN);
	bset	0x5002, #1
;	main.c: 53: TM_CLK_DDR |= (1 << TM_CLK_PIN);
	bset	0x5002, #2
;	main.c: 54: TM_DIO_PORT |= (1 << TM_DIO_PIN);
	bset	0x5000, #1
;	main.c: 55: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 56: tm_delay();
	call	_tm_delay
;	main.c: 57: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
	bres	0x5000, #1
;	main.c: 58: tm_delay();
	call	_tm_delay
;	main.c: 59: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	bres	0x5000, #2
;	main.c: 60: }
	ret
;	main.c: 62: void tm_stop() {
;	-----------------------------------------
;	 function tm_stop
;	-----------------------------------------
_tm_stop:
;	main.c: 63: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	bres	0x5000, #2
;	main.c: 64: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
	bres	0x5000, #1
;	main.c: 65: tm_delay();
	call	_tm_delay
;	main.c: 66: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 67: tm_delay();
	call	_tm_delay
;	main.c: 68: TM_DIO_PORT |= (1 << TM_DIO_PIN);
	bset	0x5000, #1
;	main.c: 69: }
	ret
;	main.c: 71: void tm_write_byte(uint8_t b) {
;	-----------------------------------------
;	 function tm_write_byte
;	-----------------------------------------
_tm_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	main.c: 72: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00106$:
;	main.c: 73: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	ld	a, 0x5000
	and	a, #0xfb
;	main.c: 72: for (uint8_t i = 0; i < 8; i++) {
	push	a
	ld	a, (0x03, sp)
	cp	a, #0x08
	pop	a
	jrnc	00104$
;	main.c: 73: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	ld	0x5000, a
	ld	a, 0x5000
;	main.c: 74: if (b & 0x01)
	push	a
	ld	a, (0x02, sp)
	srl	a
	pop	a
	jrnc	00102$
;	main.c: 75: TM_DIO_PORT |= (1 << TM_DIO_PIN);
	or	a, #0x02
	ld	0x5000, a
	jra	00103$
00102$:
;	main.c: 77: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
	and	a, #0xfd
	ld	0x5000, a
00103$:
;	main.c: 78: tm_delay();
	call	_tm_delay
;	main.c: 79: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 80: tm_delay();
	call	_tm_delay
;	main.c: 81: b >>= 1;
	srl	(0x01, sp)
;	main.c: 72: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00106$
00104$:
;	main.c: 85: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	ld	0x5000, a
;	main.c: 86: TM_DIO_DDR &= ~(1 << TM_DIO_PIN); // entrée
	bres	0x5002, #1
;	main.c: 87: tm_delay();
	call	_tm_delay
;	main.c: 88: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 89: tm_delay();
	call	_tm_delay
;	main.c: 90: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	bres	0x5000, #2
;	main.c: 91: TM_DIO_DDR |= (1 << TM_DIO_PIN); // repasse en sortie
	bset	0x5002, #1
;	main.c: 92: }
	addw	sp, #2
	ret
;	main.c: 95: void tm_set_segments(uint8_t *segments, uint8_t length) {
;	-----------------------------------------
;	 function tm_set_segments
;	-----------------------------------------
_tm_set_segments:
	sub	sp, #4
	ldw	(0x02, sp), x
	ld	(0x01, sp), a
;	main.c: 96: tm_start();
	call	_tm_start
;	main.c: 97: tm_write_byte(0x40); // Commande : auto-increment mode
	ld	a, #0x40
	call	_tm_write_byte
;	main.c: 98: tm_stop();
	call	_tm_stop
;	main.c: 100: tm_start();
	call	_tm_start
;	main.c: 101: tm_write_byte(0xC0); // Adresse de départ = 0
	ld	a, #0xc0
	call	_tm_write_byte
;	main.c: 102: for (uint8_t i = 0; i < length; i++) {
	clr	(0x04, sp)
00103$:
	ld	a, (0x04, sp)
	cp	a, (0x01, sp)
	jrnc	00101$
;	main.c: 103: tm_write_byte(segments[i]);
	clrw	x
	ld	a, (0x04, sp)
	ld	xl, a
	addw	x, (0x02, sp)
	ld	a, (x)
	call	_tm_write_byte
;	main.c: 102: for (uint8_t i = 0; i < length; i++) {
	inc	(0x04, sp)
	jra	00103$
00101$:
;	main.c: 105: tm_stop();
	call	_tm_stop
;	main.c: 107: tm_start();
	call	_tm_start
;	main.c: 108: tm_write_byte(0x88 | 0x07); // Affichage ON, luminosité max (0x00 à 0x07)
	ld	a, #0x8f
	call	_tm_write_byte
;	main.c: 109: tm_stop();
	addw	sp, #4
;	main.c: 110: }
	jp	_tm_stop
;	main.c: 113: void tm_display_temp_x100(int temp_x100) {
;	-----------------------------------------
;	 function tm_display_temp_x100
;	-----------------------------------------
_tm_display_temp_x100:
	sub	sp, #10
;	main.c: 114: int val = temp_x100;
	ldw	(0x05, sp), x
;	main.c: 115: if (val < 0) val = -val;  // Ignore le signe ici (optionnel à améliorer)
	tnzw	x
	jrpl	00111$
	negw	x
	ldw	(0x05, sp), x
;	main.c: 119: for (int i = 3; i >= 0; i--) {
00111$:
	ldw	x, #0x0003
	ldw	(0x09, sp), x
00105$:
	tnz	(0x09, sp)
	jrmi	00103$
;	main.c: 120: digits[i] = digit_to_segment[val % 10];
	ldw	x, sp
	incw	x
	addw	x, (0x09, sp)
	ldw	(0x07, sp), x
	push	#0x0a
	push	#0x00
	ldw	x, (0x07, sp)
	call	__modsint
	ld	a, (_digit_to_segment+0, x)
	ldw	x, (0x07, sp)
	ld	(x), a
;	main.c: 121: val /= 10;
	push	#0x0a
	push	#0x00
	ldw	x, (0x07, sp)
	call	__divsint
	ldw	(0x05, sp), x
;	main.c: 119: for (int i = 3; i >= 0; i--) {
	ldw	x, (0x09, sp)
	decw	x
	ldw	(0x09, sp), x
	jra	00105$
00103$:
;	main.c: 125: digits[1] |= 0x80;
	rlc	(0x02, sp)
	scf
	rrc	(0x02, sp)
;	main.c: 127: tm_set_segments(digits, 4);
	ld	a, #0x04
	ldw	x, sp
	incw	x
	call	_tm_set_segments
;	main.c: 128: }
	addw	sp, #10
	ret
;	main.c: 131: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	main.c: 133: CLK_CKDIVR = 0x00; // forcer la frequence CPU
	mov	0x50c6+0, #0x00
;	main.c: 135: PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
	ld	a, 0x5002
	or	a, #0x06
	ld	0x5002, a
;	main.c: 136: PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull
	ld	a, 0x5003
	or	a, #0x06
	ld	0x5003, a
;	main.c: 139: while (1) {
00102$:
;	main.c: 140: tm_display_temp_x100(1337);
	ldw	x, #0x0539
	call	_tm_display_temp_x100
;	main.c: 141: delay_ms(1000);
	ldw	x, #0x03e8
	call	_delay_ms
	jra	00102$
;	main.c: 143: }
	ret
	.area CODE
	.area CONST
_digit_to_segment:
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
	.area CABS (ABS)
