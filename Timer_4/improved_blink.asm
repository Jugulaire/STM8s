;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module improved_blink
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _timer_isr
	.globl _tick_counter
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_tick_counter::
	.ds 2
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
	int 0x000000 ; int3
	int 0x000000 ; int4
	int 0x000000 ; int5
	int 0x000000 ; int6
	int 0x000000 ; int7
	int 0x000000 ; int8
	int 0x000000 ; int9
	int 0x000000 ; int10
	int 0x000000 ; int11
	int 0x000000 ; int12
	int 0x000000 ; int13
	int 0x000000 ; int14
	int 0x000000 ; int15
	int 0x000000 ; int16
	int 0x000000 ; int17
	int 0x000000 ; int18
	int 0x000000 ; int19
	int 0x000000 ; int20
	int 0x000000 ; int21
	int 0x000000 ; int22
	int _timer_isr ; int23
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
;	improved_blink.c: 8: void timer_isr() __interrupt(TIM4_ISR) {
;	-----------------------------------------
;	 function timer_isr
;	-----------------------------------------
_timer_isr:
;	improved_blink.c: 9: TIM4_SR &= ~(1 << TIM4_SR_UIF);  // Clear interrupt flag
	bres	0x5344, #0
;	improved_blink.c: 11: tick_counter++;
	ldw	x, _tick_counter+0
	incw	x
	ldw	_tick_counter+0, x
;	improved_blink.c: 13: if (tick_counter >= 100) {       // 100 * 5ms = 500ms
	ldw	x, _tick_counter+0
	cpw	x, #0x0064
	jrc	00103$
;	improved_blink.c: 14: PD_ODR ^= (1 << OUTPUT_PIN); // Toggle LED
	bcpl	0x500f, #3
;	improved_blink.c: 15: tick_counter = 0;
	clrw	x
	ldw	_tick_counter+0, x
00103$:
;	improved_blink.c: 17: }
	iret
;	improved_blink.c: 19: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	improved_blink.c: 20: CLK_CKDIVR = 0x18;               // Set clock to 2 MHz
	mov	0x50c6+0, #0x18
;	improved_blink.c: 21: enable_interrupts();
	rim
;	improved_blink.c: 23: PD_DDR |= (1 << OUTPUT_PIN);     // PD3 output
	bset	0x5011, #3
;	improved_blink.c: 24: PD_CR1 |= (1 << OUTPUT_PIN);     // Push-pull
	bset	0x5012, #3
;	improved_blink.c: 26: TIM4_PSCR = 0b00000111;          // Prescaler = 128
	mov	0x5347+0, #0x07
;	improved_blink.c: 27: TIM4_ARR = 77;                   // (77+1) * 64us ≈ 5ms
	mov	0x5348+0, #0x4d
;	improved_blink.c: 28: TIM4_IER |= (1 << TIM4_IER_UIE); // Enable overflow interrupt
	bset	0x5343, #0
;	improved_blink.c: 29: TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Start timer
	bset	0x5340, #0
;	improved_blink.c: 31: while (1) {
00102$:
	jra	00102$
;	improved_blink.c: 34: }
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
__xinit__tick_counter:
	.dw #0x0000
	.area CABS (ABS)
