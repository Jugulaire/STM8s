                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module main
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _timer_isr
                                     13 ;--------------------------------------------------------
                                     14 ; ram data
                                     15 ;--------------------------------------------------------
                                     16 	.area DATA
                                     17 ;--------------------------------------------------------
                                     18 ; ram data
                                     19 ;--------------------------------------------------------
                                     20 	.area INITIALIZED
                                     21 ;--------------------------------------------------------
                                     22 ; Stack segment in internal ram
                                     23 ;--------------------------------------------------------
                                     24 	.area	SSEG
      000001                         25 __start__stack:
      000001                         26 	.ds	1
                                     27 
                                     28 ;--------------------------------------------------------
                                     29 ; absolute external ram data
                                     30 ;--------------------------------------------------------
                                     31 	.area DABS (ABS)
                                     32 
                                     33 ; default segment ordering for linker
                                     34 	.area HOME
                                     35 	.area GSINIT
                                     36 	.area GSFINAL
                                     37 	.area CONST
                                     38 	.area INITIALIZER
                                     39 	.area CODE
                                     40 
                                     41 ;--------------------------------------------------------
                                     42 ; interrupt vector
                                     43 ;--------------------------------------------------------
                                     44 	.area HOME
      008000                         45 __interrupt_vect:
      008000 82 00 80 6B             46 	int s_GSINIT ; reset
      008004 82 00 00 00             47 	int 0x000000 ; trap
      008008 82 00 00 00             48 	int 0x000000 ; int0
      00800C 82 00 00 00             49 	int 0x000000 ; int1
      008010 82 00 00 00             50 	int 0x000000 ; int2
      008014 82 00 00 00             51 	int 0x000000 ; int3
      008018 82 00 00 00             52 	int 0x000000 ; int4
      00801C 82 00 00 00             53 	int 0x000000 ; int5
      008020 82 00 00 00             54 	int 0x000000 ; int6
      008024 82 00 00 00             55 	int 0x000000 ; int7
      008028 82 00 00 00             56 	int 0x000000 ; int8
      00802C 82 00 00 00             57 	int 0x000000 ; int9
      008030 82 00 00 00             58 	int 0x000000 ; int10
      008034 82 00 00 00             59 	int 0x000000 ; int11
      008038 82 00 00 00             60 	int 0x000000 ; int12
      00803C 82 00 00 00             61 	int 0x000000 ; int13
      008040 82 00 00 00             62 	int 0x000000 ; int14
      008044 82 00 00 00             63 	int 0x000000 ; int15
      008048 82 00 00 00             64 	int 0x000000 ; int16
      00804C 82 00 00 00             65 	int 0x000000 ; int17
      008050 82 00 00 00             66 	int 0x000000 ; int18
      008054 82 00 00 00             67 	int 0x000000 ; int19
      008058 82 00 00 00             68 	int 0x000000 ; int20
      00805C 82 00 00 00             69 	int 0x000000 ; int21
      008060 82 00 00 00             70 	int 0x000000 ; int22
      008064 82 00 80 88             71 	int _timer_isr ; int23
                                     72 ;--------------------------------------------------------
                                     73 ; global & static initialisations
                                     74 ;--------------------------------------------------------
                                     75 	.area HOME
                                     76 	.area GSINIT
                                     77 	.area GSFINAL
                                     78 	.area GSINIT
      00806B                         79 __sdcc_init_data:
                                     80 ; stm8_genXINIT() start
      00806B AE 00 00         [ 2]   81 	ldw x, #l_DATA
      00806E 27 07            [ 1]   82 	jreq	00002$
      008070                         83 00001$:
      008070 72 4F 00 00      [ 1]   84 	clr (s_DATA - 1, x)
      008074 5A               [ 2]   85 	decw x
      008075 26 F9            [ 1]   86 	jrne	00001$
      008077                         87 00002$:
      008077 AE 00 00         [ 2]   88 	ldw	x, #l_INITIALIZER
      00807A 27 09            [ 1]   89 	jreq	00004$
      00807C                         90 00003$:
      00807C D6 80 87         [ 1]   91 	ld	a, (s_INITIALIZER - 1, x)
      00807F D7 00 00         [ 1]   92 	ld	(s_INITIALIZED - 1, x), a
      008082 5A               [ 2]   93 	decw	x
      008083 26 F7            [ 1]   94 	jrne	00003$
      008085                         95 00004$:
                                     96 ; stm8_genXINIT() end
                                     97 	.area GSFINAL
      008085 CC 80 68         [ 2]   98 	jp	__sdcc_program_startup
                                     99 ;--------------------------------------------------------
                                    100 ; Home
                                    101 ;--------------------------------------------------------
                                    102 	.area HOME
                                    103 	.area HOME
      008068                        104 __sdcc_program_startup:
      008068 CC 80 91         [ 2]  105 	jp	_main
                                    106 ;	return from main will return to caller
                                    107 ;--------------------------------------------------------
                                    108 ; code
                                    109 ;--------------------------------------------------------
                                    110 	.area CODE
                                    111 ;	main.c: 6: void timer_isr() __interrupt(TIM4_ISR) {
                                    112 ;	-----------------------------------------
                                    113 ;	 function timer_isr
                                    114 ;	-----------------------------------------
      008088                        115 _timer_isr:
                                    116 ;	main.c: 7: PD_ODR ^= (1 << OUTPUT_PIN);
      008088 90 16 50 0F      [ 1]  117 	bcpl	0x500f, #3
                                    118 ;	main.c: 8: TIM4_SR &= ~(1 << TIM4_SR_UIF);
      00808C 72 11 53 44      [ 1]  119 	bres	0x5344, #0
                                    120 ;	main.c: 9: }
      008090 80               [11]  121 	iret
                                    122 ;	main.c: 11: void main() {
                                    123 ;	-----------------------------------------
                                    124 ;	 function main
                                    125 ;	-----------------------------------------
      008091                        126 _main:
                                    127 ;	main.c: 12: enable_interrupts();
      008091 9A               [ 1]  128 	rim
                                    129 ;	main.c: 15: PD_DDR |= (1 << OUTPUT_PIN);
      008092 72 16 50 11      [ 1]  130 	bset	0x5011, #3
                                    131 ;	main.c: 16: PD_CR1 |= (1 << OUTPUT_PIN);
      008096 72 16 50 12      [ 1]  132 	bset	0x5012, #3
                                    133 ;	main.c: 19: TIM4_PSCR = 0b00000111;
      00809A 35 07 53 47      [ 1]  134 	mov	0x5347+0, #0x07
                                    135 ;	main.c: 23: TIM4_ARR = 250;
      00809E 35 FA 53 48      [ 1]  136 	mov	0x5348+0, #0xfa
                                    137 ;	main.c: 25: TIM4_IER |= (1 << TIM4_IER_UIE); // Enable Update Interrupt
      0080A2 72 10 53 43      [ 1]  138 	bset	0x5343, #0
                                    139 ;	main.c: 26: TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Enable TIM4
      0080A6 72 10 53 40      [ 1]  140 	bset	0x5340, #0
                                    141 ;	main.c: 28: while (1) {
      0080AA                        142 00102$:
      0080AA 20 FE            [ 2]  143 	jra	00102$
                                    144 ;	main.c: 31: }
      0080AC 81               [ 4]  145 	ret
                                    146 	.area CODE
                                    147 	.area CONST
                                    148 	.area INITIALIZER
                                    149 	.area CABS (ABS)
