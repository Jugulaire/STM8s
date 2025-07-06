;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module input
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _button_pressed
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
_button_pressed_last_state_65536_5:
	.ds 8
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
;	input.c: 13: static uint8_t last_state[8] = {0x00};  // Mémorise les derniers états (1 = repos, car pull-up active)
	mov	_button_pressed_last_state_65536_5+0, #0x00
	mov	_button_pressed_last_state_65536_5+1, #0x00
	mov	_button_pressed_last_state_65536_5+2, #0x00
	mov	_button_pressed_last_state_65536_5+3, #0x00
	mov	_button_pressed_last_state_65536_5+4, #0x00
	mov	_button_pressed_last_state_65536_5+5, #0x00
	mov	_button_pressed_last_state_65536_5+6, #0x00
	mov	_button_pressed_last_state_65536_5+7, #0x00
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
;	input.c: 5: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	input.c: 8: __asm__("nop");         // Instruction vide pour consommer du temps
	nop
;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	input.c: 9: }
	addw	sp, #10
	ret
;	input.c: 12: int8_t button_pressed(volatile uint8_t* idr, uint8_t pin) {
;	-----------------------------------------
;	 function button_pressed
;	-----------------------------------------
_button_pressed:
	sub	sp, #14
	ldw	(0x0d, sp), x
	ld	yl, a
;	input.c: 14: uint8_t current_state = *idr & (1 << pin);  // Lecture du bit correspondant au bouton
	ldw	x, (0x0d, sp)
	ldw	(0x01, sp), x
	ld	a, (x)
	ldw	x, y
	push	a
	ld	a, #0x01
	ld	(0x04, sp), a
	ld	a, xl
	tnz	a
	jreq	00141$
00140$:
	sll	(0x04, sp)
	dec	a
	jrne	00140$
00141$:
	pop	a
	and	a, (0x03, sp)
	ld	(0x04, sp), a
;	input.c: 17: if (current_state != (last_state[pin] & (1 << pin))) {
	clrw	x
	exg	a, xl
	ld	a, yl
	exg	a, xl
	addw	x, #(_button_pressed_last_state_65536_5+0)
	ldw	(0x05, sp), x
	ld	a, (x)
	ld	(0x0c, sp), a
	clrw	x
	incw	x
	ldw	(0x07, sp), x
	ld	a, yl
	tnz	a
	jreq	00143$
00142$:
	sll	(0x08, sp)
	rlc	(0x07, sp)
	dec	a
	jrne	00142$
00143$:
	ld	a, (0x0c, sp)
	ld	(0x0a, sp), a
	clr	(0x09, sp)
	ld	a, (0x0a, sp)
	and	a, (0x08, sp)
	ld	(0x0c, sp), a
	ld	a, (0x09, sp)
	and	a, (0x07, sp)
	ld	(0x0b, sp), a
	ld	a, (0x04, sp)
	ld	(0x0a, sp), a
	clr	(0x09, sp)
	ldw	x, (0x09, sp)
	cpw	x, (0x0b, sp)
	jreq	00106$
;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
	ldw	(0x07, sp), x
00110$:
	cpw	y, #0x1158
	ld	a, (0x08, sp)
	sbc	a, #0x00
	ld	a, (0x07, sp)
	sbc	a, #0x00
	jrnc	00108$
;	input.c: 8: __asm__("nop");         // Instruction vide pour consommer du temps
	nop
;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00110$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00110$
;	input.c: 18: delay_ms(5);  // Pause pour laisser passer les rebonds
00108$:
;	input.c: 19: current_state = *idr & (1 << pin);  // Relire après stabilisation
	ldw	x, (0x01, sp)
	ld	a, (x)
	and	a, (0x03, sp)
;	input.c: 22: if (current_state != (last_state[pin] & (1 << pin))) {
	ld	(0x0a, sp), a
	clrw	x
	ld	xl, a
	cpw	x, (0x0b, sp)
	jreq	00106$
;	input.c: 23: last_state[pin] = *idr;         // Mémoriser le nouvel état
	ldw	x, (0x01, sp)
	ld	a, (x)
	ldw	x, (0x05, sp)
	ld	(x), a
;	input.c: 24: if (!(current_state)) {         // Si le niveau est bas (appui)
	tnz	(0x0a, sp)
	jrne	00106$
;	input.c: 25: return 1;                   // Retourner 1 : bouton pressé
	ld	a, #0x01
;	input.c: 30: return 0;  // Aucun appui détecté
	.byte 0x21
00106$:
	clr	a
00112$:
;	input.c: 31: }
	addw	sp, #14
	ret
;	input.c: 33: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	input.c: 35: PD_DDR |= (1 << 3);      // Direction : sortie
	bset	0x5011, #3
;	input.c: 36: PD_CR1 |= (1 << 3);      // Sortie push-pull
	bset	0x5012, #3
;	input.c: 41: PA_DDR &= ~(1 << 3);    // PA3 en entrée
	bres	0x5002, #3
;	input.c: 42: PA_CR1 |= (1 << 3);     // Pull-up interne activée
	bset	0x5003, #3
;	input.c: 45: while (1) {
00104$:
;	input.c: 46: if (button_pressed(&PA_IDR, 3)) {   // Si le bouton est pressé (PA3 à 0)
	ld	a, #0x03
	ldw	x, #0x5001
	call	_button_pressed
	tnz	a
	jreq	00104$
;	input.c: 47: PD_ODR ^= (1 << 3);             // Inverser l’état de la LED sur PB5
	bcpl	0x500f, #3
	jra	00104$
;	input.c: 50: }
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
	.area CABS (ABS)
