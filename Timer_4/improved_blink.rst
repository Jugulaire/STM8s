                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module improved_blink
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _timer_isr
                                     13 	.globl _tick_counter
                                     14 ;--------------------------------------------------------
                                     15 ; ram data
                                     16 ;--------------------------------------------------------
                                     17 	.area DATA
                                     18 ;--------------------------------------------------------
                                     19 ; ram data
                                     20 ;--------------------------------------------------------
                                     21 	.area INITIALIZED
      000001                         22 _tick_counter::
      000001                         23 	.ds 2
                                     24 ;--------------------------------------------------------
                                     25 ; Stack segment in internal ram
                                     26 ;--------------------------------------------------------
                                     27 	.area	SSEG
      000003                         28 __start__stack:
      000003                         29 	.ds	1
                                     30 
                                     31 ;--------------------------------------------------------
                                     32 ; absolute external ram data
                                     33 ;--------------------------------------------------------
                                     34 	.area DABS (ABS)
                                     35 
                                     36 ; default segment ordering for linker
                                     37 	.area HOME
                                     38 	.area GSINIT
                                     39 	.area GSFINAL
                                     40 	.area CONST
                                     41 	.area INITIALIZER
                                     42 	.area CODE
                                     43 
                                     44 ;--------------------------------------------------------
                                     45 ; interrupt vector
                                     46 ;--------------------------------------------------------
                                     47 	.area HOME
      008000                         48 __interrupt_vect:
      008000 82 00 80 6B             49 	int s_GSINIT ; reset
      008004 82 00 00 00             50 	int 0x000000 ; trap
      008008 82 00 00 00             51 	int 0x000000 ; int0
      00800C 82 00 00 00             52 	int 0x000000 ; int1
      008010 82 00 00 00             53 	int 0x000000 ; int2
      008014 82 00 00 00             54 	int 0x000000 ; int3
      008018 82 00 00 00             55 	int 0x000000 ; int4
      00801C 82 00 00 00             56 	int 0x000000 ; int5
      008020 82 00 00 00             57 	int 0x000000 ; int6
      008024 82 00 00 00             58 	int 0x000000 ; int7
      008028 82 00 00 00             59 	int 0x000000 ; int8
      00802C 82 00 00 00             60 	int 0x000000 ; int9
      008030 82 00 00 00             61 	int 0x000000 ; int10
      008034 82 00 00 00             62 	int 0x000000 ; int11
      008038 82 00 00 00             63 	int 0x000000 ; int12
      00803C 82 00 00 00             64 	int 0x000000 ; int13
      008040 82 00 00 00             65 	int 0x000000 ; int14
      008044 82 00 00 00             66 	int 0x000000 ; int15
      008048 82 00 00 00             67 	int 0x000000 ; int16
      00804C 82 00 00 00             68 	int 0x000000 ; int17
      008050 82 00 00 00             69 	int 0x000000 ; int18
      008054 82 00 00 00             70 	int 0x000000 ; int19
      008058 82 00 00 00             71 	int 0x000000 ; int20
      00805C 82 00 00 00             72 	int 0x000000 ; int21
      008060 82 00 00 00             73 	int 0x000000 ; int22
      008064 82 00 80 8A             74 	int _timer_isr ; int23
                                     75 ;--------------------------------------------------------
                                     76 ; global & static initialisations
                                     77 ;--------------------------------------------------------
                                     78 	.area HOME
                                     79 	.area GSINIT
                                     80 	.area GSFINAL
                                     81 	.area GSINIT
      00806B                         82 __sdcc_init_data:
                                     83 ; stm8_genXINIT() start
      00806B AE 00 00         [ 2]   84 	ldw x, #l_DATA
      00806E 27 07            [ 1]   85 	jreq	00002$
      008070                         86 00001$:
      008070 72 4F 00 00      [ 1]   87 	clr (s_DATA - 1, x)
      008074 5A               [ 2]   88 	decw x
      008075 26 F9            [ 1]   89 	jrne	00001$
      008077                         90 00002$:
      008077 AE 00 02         [ 2]   91 	ldw	x, #l_INITIALIZER
      00807A 27 09            [ 1]   92 	jreq	00004$
      00807C                         93 00003$:
      00807C D6 80 87         [ 1]   94 	ld	a, (s_INITIALIZER - 1, x)
      00807F D7 00 00         [ 1]   95 	ld	(s_INITIALIZED - 1, x), a
      008082 5A               [ 2]   96 	decw	x
      008083 26 F7            [ 1]   97 	jrne	00003$
      008085                         98 00004$:
                                     99 ; stm8_genXINIT() end
                                    100 	.area GSFINAL
      008085 CC 80 68         [ 2]  101 	jp	__sdcc_program_startup
                                    102 ;--------------------------------------------------------
                                    103 ; Home
                                    104 ;--------------------------------------------------------
                                    105 	.area HOME
                                    106 	.area HOME
      008068                        107 __sdcc_program_startup:
      008068 CC 80 A6         [ 2]  108 	jp	_main
                                    109 ;	return from main will return to caller
                                    110 ;--------------------------------------------------------
                                    111 ; code
                                    112 ;--------------------------------------------------------
                                    113 	.area CODE
                                    114 ;	improved_blink.c: 8: void timer_isr() __interrupt(TIM4_ISR) {
                                    115 ;	-----------------------------------------
                                    116 ;	 function timer_isr
                                    117 ;	-----------------------------------------
      00808A                        118 _timer_isr:
                                    119 ;	improved_blink.c: 9: TIM4_SR &= ~(1 << TIM4_SR_UIF);  // Clear interrupt flag
      00808A 72 11 53 44      [ 1]  120 	bres	0x5344, #0
                                    121 ;	improved_blink.c: 11: tick_counter++;
      00808E CE 00 01         [ 2]  122 	ldw	x, _tick_counter+0
      008091 5C               [ 1]  123 	incw	x
      008092 CF 00 01         [ 2]  124 	ldw	_tick_counter+0, x
                                    125 ;	improved_blink.c: 13: if (tick_counter >= 100) {       // 100 * 5ms = 500ms
      008095 CE 00 01         [ 2]  126 	ldw	x, _tick_counter+0
      008098 A3 00 64         [ 2]  127 	cpw	x, #0x0064
      00809B 25 08            [ 1]  128 	jrc	00103$
                                    129 ;	improved_blink.c: 14: PD_ODR ^= (1 << OUTPUT_PIN); // Toggle LED
      00809D 90 16 50 0F      [ 1]  130 	bcpl	0x500f, #3
                                    131 ;	improved_blink.c: 15: tick_counter = 0;
      0080A1 5F               [ 1]  132 	clrw	x
      0080A2 CF 00 01         [ 2]  133 	ldw	_tick_counter+0, x
      0080A5                        134 00103$:
                                    135 ;	improved_blink.c: 17: }
      0080A5 80               [11]  136 	iret
                                    137 ;	improved_blink.c: 19: void main() {
                                    138 ;	-----------------------------------------
                                    139 ;	 function main
                                    140 ;	-----------------------------------------
      0080A6                        141 _main:
                                    142 ;	improved_blink.c: 20: CLK_CKDIVR = 0x18;               // Set clock to 2 MHz
      0080A6 35 18 50 C6      [ 1]  143 	mov	0x50c6+0, #0x18
                                    144 ;	improved_blink.c: 21: enable_interrupts();
      0080AA 9A               [ 1]  145 	rim
                                    146 ;	improved_blink.c: 23: PD_DDR |= (1 << OUTPUT_PIN);     // PD3 output
      0080AB 72 16 50 11      [ 1]  147 	bset	0x5011, #3
                                    148 ;	improved_blink.c: 24: PD_CR1 |= (1 << OUTPUT_PIN);     // Push-pull
      0080AF 72 16 50 12      [ 1]  149 	bset	0x5012, #3
                                    150 ;	improved_blink.c: 26: TIM4_PSCR = 0b00000111;          // Prescaler = 128
      0080B3 35 07 53 47      [ 1]  151 	mov	0x5347+0, #0x07
                                    152 ;	improved_blink.c: 27: TIM4_ARR = 77;                   // (77+1) * 64us ≈ 5ms
      0080B7 35 4D 53 48      [ 1]  153 	mov	0x5348+0, #0x4d
                                    154 ;	improved_blink.c: 28: TIM4_IER |= (1 << TIM4_IER_UIE); // Enable overflow interrupt
      0080BB 72 10 53 43      [ 1]  155 	bset	0x5343, #0
                                    156 ;	improved_blink.c: 29: TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Start timer
      0080BF 72 10 53 40      [ 1]  157 	bset	0x5340, #0
                                    158 ;	improved_blink.c: 31: while (1) {
      0080C3                        159 00102$:
      0080C3 20 FE            [ 2]  160 	jra	00102$
                                    161 ;	improved_blink.c: 34: }
      0080C5 81               [ 4]  162 	ret
                                    163 	.area CODE
                                    164 	.area CONST
                                    165 	.area INITIALIZER
      008088                        166 __xinit__tick_counter:
      008088 00 00                  167 	.dw #0x0000
                                    168 	.area CABS (ABS)
