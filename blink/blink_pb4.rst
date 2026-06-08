                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module blink_pb4
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _delay
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
      008000 82 00 80 07             46 	int s_GSINIT ; reset
                                     47 ;--------------------------------------------------------
                                     48 ; global & static initialisations
                                     49 ;--------------------------------------------------------
                                     50 	.area HOME
                                     51 	.area GSINIT
                                     52 	.area GSFINAL
                                     53 	.area GSINIT
      008007                         54 __sdcc_init_data:
                                     55 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   56 	ldw x, #l_DATA
      00800A 27 07            [ 1]   57 	jreq	00002$
      00800C                         58 00001$:
      00800C 72 4F 00 00      [ 1]   59 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   60 	decw x
      008011 26 F9            [ 1]   61 	jrne	00001$
      008013                         62 00002$:
      008013 AE 00 00         [ 2]   63 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   64 	jreq	00004$
      008018                         65 00003$:
      008018 D6 80 23         [ 1]   66 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   67 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   68 	decw	x
      00801F 26 F7            [ 1]   69 	jrne	00003$
      008021                         70 00004$:
                                     71 ; stm8_genXINIT() end
                                     72 	.area GSFINAL
      008021 CC 80 04         [ 2]   73 	jp	__sdcc_program_startup
                                     74 ;--------------------------------------------------------
                                     75 ; Home
                                     76 ;--------------------------------------------------------
                                     77 	.area HOME
                                     78 	.area HOME
      008004                         79 __sdcc_program_startup:
      008004 CC 80 3A         [ 2]   80 	jp	_main
                                     81 ;	return from main will return to caller
                                     82 ;--------------------------------------------------------
                                     83 ; code
                                     84 ;--------------------------------------------------------
                                     85 	.area CODE
                                     86 ;	blink_pb4.c: 5: void delay(void)
                                     87 ;	-----------------------------------------
                                     88 ;	 function delay
                                     89 ;	-----------------------------------------
      008024                         90 _delay:
      008024 52 02            [ 2]   91 	sub	sp, #2
                                     92 ;	blink_pb4.c: 7: for(volatile unsigned int i = 0; i < 30000; i++);
      008026 5F               [ 1]   93 	clrw	x
      008027 1F 01            [ 2]   94 	ldw	(0x01, sp), x
      008029                         95 00103$:
      008029 1E 01            [ 2]   96 	ldw	x, (0x01, sp)
      00802B A3 75 30         [ 2]   97 	cpw	x, #0x7530
      00802E 24 07            [ 1]   98 	jrnc	00105$
      008030 1E 01            [ 2]   99 	ldw	x, (0x01, sp)
      008032 5C               [ 1]  100 	incw	x
      008033 1F 01            [ 2]  101 	ldw	(0x01, sp), x
      008035 20 F2            [ 2]  102 	jra	00103$
      008037                        103 00105$:
                                    104 ;	blink_pb4.c: 8: }
      008037 5B 02            [ 2]  105 	addw	sp, #2
      008039 81               [ 4]  106 	ret
                                    107 ;	blink_pb4.c: 10: void main(void)
                                    108 ;	-----------------------------------------
                                    109 ;	 function main
                                    110 ;	-----------------------------------------
      00803A                        111 _main:
                                    112 ;	blink_pb4.c: 12: PD_DDR |= (1 << 4);   // PD4 en sortie
      00803A 72 18 50 11      [ 1]  113 	bset	0x5011, #4
                                    114 ;	blink_pb4.c: 13: PD_CR1 |= (1 << 4);   // push-pull
      00803E 72 18 50 12      [ 1]  115 	bset	0x5012, #4
                                    116 ;	blink_pb4.c: 15: while(1)
      008042                        117 00102$:
                                    118 ;	blink_pb4.c: 17: PD_ODR ^= (1 << 4);
      008042 90 18 50 0F      [ 1]  119 	bcpl	0x500f, #4
                                    120 ;	blink_pb4.c: 18: delay();
      008046 CD 80 24         [ 4]  121 	call	_delay
      008049 20 F7            [ 2]  122 	jra	00102$
                                    123 ;	blink_pb4.c: 20: }
      00804B 81               [ 4]  124 	ret
                                    125 	.area CODE
                                    126 	.area CONST
                                    127 	.area INITIALIZER
                                    128 	.area CABS (ABS)
