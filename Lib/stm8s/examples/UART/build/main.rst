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
                                     12 	.globl _uart_read
                                     13 	.globl _uart_write
                                     14 	.globl _uart_init
                                     15 	.globl _printf
                                     16 	.globl _putchar
                                     17 	.globl _getchar
                                     18 ;--------------------------------------------------------
                                     19 ; ram data
                                     20 ;--------------------------------------------------------
                                     21 	.area DATA
                                     22 ;--------------------------------------------------------
                                     23 ; ram data
                                     24 ;--------------------------------------------------------
                                     25 	.area INITIALIZED
                                     26 ;--------------------------------------------------------
                                     27 ; Stack segment in internal ram
                                     28 ;--------------------------------------------------------
                                     29 	.area	SSEG
      000001                         30 __start__stack:
      000001                         31 	.ds	1
                                     32 
                                     33 ;--------------------------------------------------------
                                     34 ; absolute external ram data
                                     35 ;--------------------------------------------------------
                                     36 	.area DABS (ABS)
                                     37 
                                     38 ; default segment ordering for linker
                                     39 	.area HOME
                                     40 	.area GSINIT
                                     41 	.area GSFINAL
                                     42 	.area CONST
                                     43 	.area INITIALIZER
                                     44 	.area CODE
                                     45 
                                     46 ;--------------------------------------------------------
                                     47 ; interrupt vector
                                     48 ;--------------------------------------------------------
                                     49 	.area HOME
      008000                         50 __interrupt_vect:
      008000 82 00 80 07             51 	int s_GSINIT ; reset
                                     52 ;--------------------------------------------------------
                                     53 ; global & static initialisations
                                     54 ;--------------------------------------------------------
                                     55 	.area HOME
                                     56 	.area GSINIT
                                     57 	.area GSFINAL
                                     58 	.area GSINIT
      008007                         59 __sdcc_init_data:
                                     60 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   61 	ldw x, #l_DATA
      00800A 27 07            [ 1]   62 	jreq	00002$
      00800C                         63 00001$:
      00800C 72 4F 00 00      [ 1]   64 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   65 	decw x
      008011 26 F9            [ 1]   66 	jrne	00001$
      008013                         67 00002$:
      008013 AE 00 00         [ 2]   68 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   69 	jreq	00004$
      008018                         70 00003$:
      008018 D6 80 38         [ 1]   71 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   72 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   73 	decw	x
      00801F 26 F7            [ 1]   74 	jrne	00003$
      008021                         75 00004$:
                                     76 ; stm8_genXINIT() end
                                     77 	.area GSFINAL
      008021 CC 80 04         [ 2]   78 	jp	__sdcc_program_startup
                                     79 ;--------------------------------------------------------
                                     80 ; Home
                                     81 ;--------------------------------------------------------
                                     82 	.area HOME
                                     83 	.area HOME
      008004                         84 __sdcc_program_startup:
      008004 CC 80 45         [ 2]   85 	jp	_main
                                     86 ;	return from main will return to caller
                                     87 ;--------------------------------------------------------
                                     88 ; code
                                     89 ;--------------------------------------------------------
                                     90 	.area CODE
                                     91 ;	main.c: 11: int putchar(int c) {
                                     92 ;	-----------------------------------------
                                     93 ;	 function putchar
                                     94 ;	-----------------------------------------
      008039                         95 _putchar:
      008039 9F               [ 1]   96 	ld	a, xl
                                     97 ;	main.c: 12: uart_write(c);
      00803A CD 81 4C         [ 4]   98 	call	_uart_write
                                     99 ;	main.c: 13: return 0;
      00803D 5F               [ 1]  100 	clrw	x
                                    101 ;	main.c: 14: }
      00803E 81               [ 4]  102 	ret
                                    103 ;	main.c: 19: int getchar() {
                                    104 ;	-----------------------------------------
                                    105 ;	 function getchar
                                    106 ;	-----------------------------------------
      00803F                        107 _getchar:
                                    108 ;	main.c: 20: return uart_read();
      00803F CD 81 55         [ 4]  109 	call	_uart_read
      008042 5F               [ 1]  110 	clrw	x
      008043 97               [ 1]  111 	ld	xl, a
                                    112 ;	main.c: 21: }
      008044 81               [ 4]  113 	ret
                                    114 ;	main.c: 23: void main() {
                                    115 ;	-----------------------------------------
                                    116 ;	 function main
                                    117 ;	-----------------------------------------
      008045                        118 _main:
      008045 88               [ 1]  119 	push	a
                                    120 ;	main.c: 24: uint8_t counter = 0;
      008046 0F 01            [ 1]  121 	clr	(0x01, sp)
                                    122 ;	main.c: 25: uart_init();
      008048 CD 81 35         [ 4]  123 	call	_uart_init
                                    124 ;	main.c: 27: while (1) {
      00804B                        125 00102$:
                                    126 ;	main.c: 28: printf("Test, %d\n", counter++);
      00804B 7B 01            [ 1]  127 	ld	a, (0x01, sp)
      00804D 0C 01            [ 1]  128 	inc	(0x01, sp)
      00804F 5F               [ 1]  129 	clrw	x
      008050 97               [ 1]  130 	ld	xl, a
      008051 89               [ 2]  131 	pushw	x
      008052 4B 24            [ 1]  132 	push	#<(___str_0+0)
      008054 4B 80            [ 1]  133 	push	#((___str_0+0) >> 8)
      008056 CD 81 76         [ 4]  134 	call	_printf
      008059 5B 04            [ 2]  135 	addw	sp, #4
                                    136 ;	../../lib/delay.h: 12: for (uint32_t i = 0; i < ((F_CPU / 18 / 1000UL) * ms); i++) {
      00805B 90 5F            [ 1]  137 	clrw	y
      00805D 5F               [ 1]  138 	clrw	x
      00805E                        139 00107$:
      00805E 90 A3 D8 CC      [ 2]  140 	cpw	y, #0xd8cc
      008062 9F               [ 1]  141 	ld	a, xl
      008063 A2 00            [ 1]  142 	sbc	a, #0x00
      008065 9E               [ 1]  143 	ld	a, xh
      008066 A2 00            [ 1]  144 	sbc	a, #0x00
      008068 24 E1            [ 1]  145 	jrnc	00102$
                                    146 ;	../../lib/delay.h: 13: __asm__("nop");
      00806A 9D               [ 1]  147 	nop
                                    148 ;	../../lib/delay.h: 12: for (uint32_t i = 0; i < ((F_CPU / 18 / 1000UL) * ms); i++) {
      00806B 90 5C            [ 1]  149 	incw	y
      00806D 26 EF            [ 1]  150 	jrne	00107$
      00806F 5C               [ 1]  151 	incw	x
      008070 20 EC            [ 2]  152 	jra	00107$
                                    153 ;	main.c: 29: delay_ms(500);
                                    154 ;	main.c: 31: }
      008072 84               [ 1]  155 	pop	a
      008073 81               [ 4]  156 	ret
                                    157 	.area CODE
                                    158 	.area CONST
                                    159 	.area CONST
      008024                        160 ___str_0:
      008024 54 65 73 74 2C 20 25   161 	.ascii "Test, %d"
             64
      00802C 0A                     162 	.db 0x0a
      00802D 00                     163 	.db 0x00
                                    164 	.area CODE
                                    165 	.area INITIALIZER
                                    166 	.area CABS (ABS)
