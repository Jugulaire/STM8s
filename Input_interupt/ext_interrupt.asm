;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module ext_interrupt
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _button_handler
	.globl _last_press_time
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
_button_handler_now_65536_15:
	.ds 4
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_last_press_time::
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
;	ext_interrupt.c: 14: static uint32_t now = 0;
	clrw	x
	ldw	_button_handler_now_65536_15+2, x
	ldw	_button_handler_now_65536_15+0, x
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
;	ext_interrupt.c: 7: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	ext_interrupt.c: 10: __asm__("nop");
	nop
;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	ext_interrupt.c: 11: }
	addw	sp, #10
	ret
;	ext_interrupt.c: 13: void button_handler(void) __interrupt(3) {
;	-----------------------------------------
;	 function button_handler
;	-----------------------------------------
_button_handler:
	clr	a
	div	x, a
	sub	sp, #4
;	ext_interrupt.c: 15: now += 1;  // Incrémente à chaque IT, ou via timer en fond si dispo
	ldw	x, _button_handler_now_65536_15+2
	addw	x, #0x0001
	ldw	y, _button_handler_now_65536_15+0
	jrnc	00133$
	incw	y
00133$:
	ldw	_button_handler_now_65536_15+2, x
	ldw	_button_handler_now_65536_15+0, y
;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00108$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00106$
;	ext_interrupt.c: 10: __asm__("nop");
	nop
;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00108$
	incw	x
	jra	00108$
;	ext_interrupt.c: 16: delay_ms(5); // timer pour un filtre anti rebond
00106$:
;	ext_interrupt.c: 17: if ((now - last_press_time) > 1) {  // 1 "ticks" d'écart
	ldw	x, _button_handler_now_65536_15+2
	subw	x, _last_press_time+2
	ldw	(0x03, sp), x
	ld	a, _button_handler_now_65536_15+1
	sbc	a, _last_press_time+1
	ld	(0x02, sp), a
	ld	a, _button_handler_now_65536_15+0
	sbc	a, _last_press_time+0
	ld	(0x01, sp), a
	clrw	x
	incw	x
	cpw	x, (0x03, sp)
	clr	a
	sbc	a, (0x02, sp)
	clr	a
	sbc	a, (0x01, sp)
	jrnc	00110$
;	ext_interrupt.c: 18: if (!(PA_IDR & (1 << 3))) {
	btjt	0x5001, #3, 00110$
;	ext_interrupt.c: 19: PD_ODR ^= (1 << 3);
	bcpl	0x500f, #3
;	ext_interrupt.c: 20: last_press_time = now;
	ldw	x, _button_handler_now_65536_15+2
	ldw	_last_press_time+2, x
	ldw	x, _button_handler_now_65536_15+0
	ldw	_last_press_time+0, x
00110$:
;	ext_interrupt.c: 23: }
	addw	sp, #4
	iret
;	ext_interrupt.c: 25: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	ext_interrupt.c: 28: PD_DDR |= (1 << 3);
	bset	0x5011, #3
;	ext_interrupt.c: 29: PD_CR1 |= (1 << 3);
	bset	0x5012, #3
;	ext_interrupt.c: 30: PD_ODR &= ~(1 << 3);  // LED éteinte
	bres	0x500f, #3
;	ext_interrupt.c: 33: PA_DDR &= ~(1 << 3);   // Entrée
	bres	0x5002, #3
;	ext_interrupt.c: 34: PA_CR1 |= (1 << 3);    // Pull-up
	bset	0x5003, #3
;	ext_interrupt.c: 35: PA_CR2 |= (1 << 3);    // Active interruption pour PA3
	ld	a, 0x5004
	or	a, #0x08
	ld	0x5004, a
;	ext_interrupt.c: 38: EXTI_CR1 &= ~(0b11 << 0);   // Efface les bits PAIS[1:0]
	ld	a, 0x50a0
	and	a, #0xfc
	ld	0x50a0, a
;	ext_interrupt.c: 39: EXTI_CR1 |=  (0b10 << 0);   // Met 10 = front descendant
	ld	a, 0x50a0
	or	a, #0x02
	ld	0x50a0, a
;	ext_interrupt.c: 41: __asm__("rim");  // Active les interruptions globales
	rim
;	ext_interrupt.c: 42: while (1);  // Boucle vide, tout est géré par interruption
00102$:
	jra	00102$
;	ext_interrupt.c: 44: }
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
__xinit__last_press_time:
	.byte #0x00, #0x00, #0x00, #0x00	; 0
	.area CABS (ABS)
