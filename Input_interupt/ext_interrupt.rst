                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module ext_interrupt
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _button_handler
                                     13 	.globl _last_press_time
                                     14 ;--------------------------------------------------------
                                     15 ; ram data
                                     16 ;--------------------------------------------------------
                                     17 	.area DATA
      000001                         18 _button_handler_now_65536_15:
      000001                         19 	.ds 4
                                     20 ;--------------------------------------------------------
                                     21 ; ram data
                                     22 ;--------------------------------------------------------
                                     23 	.area INITIALIZED
      000005                         24 _last_press_time::
      000005                         25 	.ds 4
                                     26 ;--------------------------------------------------------
                                     27 ; Stack segment in internal ram
                                     28 ;--------------------------------------------------------
                                     29 	.area	SSEG
      000009                         30 __start__stack:
      000009                         31 	.ds	1
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
      008000 82 00 80 1B             51 	int s_GSINIT ; reset
      008004 82 00 00 00             52 	int 0x000000 ; trap
      008008 82 00 00 00             53 	int 0x000000 ; int0
      00800C 82 00 00 00             54 	int 0x000000 ; int1
      008010 82 00 00 00             55 	int 0x000000 ; int2
      008014 82 00 80 7B             56 	int _button_handler ; int3
                                     57 ;--------------------------------------------------------
                                     58 ; global & static initialisations
                                     59 ;--------------------------------------------------------
                                     60 	.area HOME
                                     61 	.area GSINIT
                                     62 	.area GSFINAL
                                     63 	.area GSINIT
      00801B                         64 __sdcc_init_data:
                                     65 ; stm8_genXINIT() start
      00801B AE 00 04         [ 2]   66 	ldw x, #l_DATA
      00801E 27 07            [ 1]   67 	jreq	00002$
      008020                         68 00001$:
      008020 72 4F 00 00      [ 1]   69 	clr (s_DATA - 1, x)
      008024 5A               [ 2]   70 	decw x
      008025 26 F9            [ 1]   71 	jrne	00001$
      008027                         72 00002$:
      008027 AE 00 04         [ 2]   73 	ldw	x, #l_INITIALIZER
      00802A 27 09            [ 1]   74 	jreq	00004$
      00802C                         75 00003$:
      00802C D6 80 3E         [ 1]   76 	ld	a, (s_INITIALIZER - 1, x)
      00802F D7 00 04         [ 1]   77 	ld	(s_INITIALIZED - 1, x), a
      008032 5A               [ 2]   78 	decw	x
      008033 26 F7            [ 1]   79 	jrne	00003$
      008035                         80 00004$:
                                     81 ; stm8_genXINIT() end
                                     82 ;	ext_interrupt.c: 14: static uint32_t now = 0;
      008035 5F               [ 1]   83 	clrw	x
      008036 CF 00 03         [ 2]   84 	ldw	_button_handler_now_65536_15+2, x
      008039 CF 00 01         [ 2]   85 	ldw	_button_handler_now_65536_15+0, x
                                     86 	.area GSFINAL
      00803C CC 80 18         [ 2]   87 	jp	__sdcc_program_startup
                                     88 ;--------------------------------------------------------
                                     89 ; Home
                                     90 ;--------------------------------------------------------
                                     91 	.area HOME
                                     92 	.area HOME
      008018                         93 __sdcc_program_startup:
      008018 CC 80 E8         [ 2]   94 	jp	_main
                                     95 ;	return from main will return to caller
                                     96 ;--------------------------------------------------------
                                     97 ; code
                                     98 ;--------------------------------------------------------
                                     99 	.area CODE
                                    100 ;	ext_interrupt.c: 7: static inline void delay_ms(uint16_t ms) {
                                    101 ;	-----------------------------------------
                                    102 ;	 function delay_ms
                                    103 ;	-----------------------------------------
      008043                        104 _delay_ms:
      008043 52 0A            [ 2]  105 	sub	sp, #10
      008045 1F 05            [ 2]  106 	ldw	(0x05, sp), x
                                    107 ;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008047 5F               [ 1]  108 	clrw	x
      008048 1F 09            [ 2]  109 	ldw	(0x09, sp), x
      00804A 1F 07            [ 2]  110 	ldw	(0x07, sp), x
      00804C                        111 00103$:
      00804C 1E 05            [ 2]  112 	ldw	x, (0x05, sp)
      00804E 89               [ 2]  113 	pushw	x
      00804F AE 03 78         [ 2]  114 	ldw	x, #0x0378
      008052 CD 81 18         [ 4]  115 	call	___muluint2ulong
      008055 5B 02            [ 2]  116 	addw	sp, #2
      008057 1F 03            [ 2]  117 	ldw	(0x03, sp), x
      008059 17 01            [ 2]  118 	ldw	(0x01, sp), y
      00805B 1E 09            [ 2]  119 	ldw	x, (0x09, sp)
      00805D 13 03            [ 2]  120 	cpw	x, (0x03, sp)
      00805F 7B 08            [ 1]  121 	ld	a, (0x08, sp)
      008061 12 02            [ 1]  122 	sbc	a, (0x02, sp)
      008063 7B 07            [ 1]  123 	ld	a, (0x07, sp)
      008065 12 01            [ 1]  124 	sbc	a, (0x01, sp)
      008067 24 0F            [ 1]  125 	jrnc	00105$
                                    126 ;	ext_interrupt.c: 10: __asm__("nop");
      008069 9D               [ 1]  127 	nop
                                    128 ;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00806A 1E 09            [ 2]  129 	ldw	x, (0x09, sp)
      00806C 5C               [ 1]  130 	incw	x
      00806D 1F 09            [ 2]  131 	ldw	(0x09, sp), x
      00806F 26 DB            [ 1]  132 	jrne	00103$
      008071 1E 07            [ 2]  133 	ldw	x, (0x07, sp)
      008073 5C               [ 1]  134 	incw	x
      008074 1F 07            [ 2]  135 	ldw	(0x07, sp), x
      008076 20 D4            [ 2]  136 	jra	00103$
      008078                        137 00105$:
                                    138 ;	ext_interrupt.c: 11: }
      008078 5B 0A            [ 2]  139 	addw	sp, #10
      00807A 81               [ 4]  140 	ret
                                    141 ;	ext_interrupt.c: 13: void button_handler(void) __interrupt(3) {
                                    142 ;	-----------------------------------------
                                    143 ;	 function button_handler
                                    144 ;	-----------------------------------------
      00807B                        145 _button_handler:
      00807B 4F               [ 1]  146 	clr	a
      00807C 62               [ 2]  147 	div	x, a
      00807D 52 04            [ 2]  148 	sub	sp, #4
                                    149 ;	ext_interrupt.c: 15: now += 1;  // Incrémente à chaque IT, ou via timer en fond si dispo
      00807F CE 00 03         [ 2]  150 	ldw	x, _button_handler_now_65536_15+2
      008082 1C 00 01         [ 2]  151 	addw	x, #0x0001
      008085 90 CE 00 01      [ 2]  152 	ldw	y, _button_handler_now_65536_15+0
      008089 24 02            [ 1]  153 	jrnc	00133$
      00808B 90 5C            [ 1]  154 	incw	y
      00808D                        155 00133$:
      00808D CF 00 03         [ 2]  156 	ldw	_button_handler_now_65536_15+2, x
      008090 90 CF 00 01      [ 2]  157 	ldw	_button_handler_now_65536_15+0, y
                                    158 ;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008094 90 5F            [ 1]  159 	clrw	y
      008096 5F               [ 1]  160 	clrw	x
      008097                        161 00108$:
      008097 90 A3 11 58      [ 2]  162 	cpw	y, #0x1158
      00809B 9F               [ 1]  163 	ld	a, xl
      00809C A2 00            [ 1]  164 	sbc	a, #0x00
      00809E 9E               [ 1]  165 	ld	a, xh
      00809F A2 00            [ 1]  166 	sbc	a, #0x00
      0080A1 24 08            [ 1]  167 	jrnc	00106$
                                    168 ;	ext_interrupt.c: 10: __asm__("nop");
      0080A3 9D               [ 1]  169 	nop
                                    170 ;	ext_interrupt.c: 9: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080A4 90 5C            [ 1]  171 	incw	y
      0080A6 26 EF            [ 1]  172 	jrne	00108$
      0080A8 5C               [ 1]  173 	incw	x
      0080A9 20 EC            [ 2]  174 	jra	00108$
                                    175 ;	ext_interrupt.c: 16: delay_ms(5); // timer pour un filtre anti rebond
      0080AB                        176 00106$:
                                    177 ;	ext_interrupt.c: 17: if ((now - last_press_time) > 1) {  // 1 "ticks" d'écart
      0080AB CE 00 03         [ 2]  178 	ldw	x, _button_handler_now_65536_15+2
      0080AE 72 B0 00 07      [ 2]  179 	subw	x, _last_press_time+2
      0080B2 1F 03            [ 2]  180 	ldw	(0x03, sp), x
      0080B4 C6 00 02         [ 1]  181 	ld	a, _button_handler_now_65536_15+1
      0080B7 C2 00 06         [ 1]  182 	sbc	a, _last_press_time+1
      0080BA 6B 02            [ 1]  183 	ld	(0x02, sp), a
      0080BC C6 00 01         [ 1]  184 	ld	a, _button_handler_now_65536_15+0
      0080BF C2 00 05         [ 1]  185 	sbc	a, _last_press_time+0
      0080C2 6B 01            [ 1]  186 	ld	(0x01, sp), a
      0080C4 5F               [ 1]  187 	clrw	x
      0080C5 5C               [ 1]  188 	incw	x
      0080C6 13 03            [ 2]  189 	cpw	x, (0x03, sp)
      0080C8 4F               [ 1]  190 	clr	a
      0080C9 12 02            [ 1]  191 	sbc	a, (0x02, sp)
      0080CB 4F               [ 1]  192 	clr	a
      0080CC 12 01            [ 1]  193 	sbc	a, (0x01, sp)
      0080CE 24 15            [ 1]  194 	jrnc	00110$
                                    195 ;	ext_interrupt.c: 18: if (!(PA_IDR & (1 << 3))) {
      0080D0 72 06 50 01 10   [ 2]  196 	btjt	0x5001, #3, 00110$
                                    197 ;	ext_interrupt.c: 19: PD_ODR ^= (1 << 3);
      0080D5 90 16 50 0F      [ 1]  198 	bcpl	0x500f, #3
                                    199 ;	ext_interrupt.c: 20: last_press_time = now;
      0080D9 CE 00 03         [ 2]  200 	ldw	x, _button_handler_now_65536_15+2
      0080DC CF 00 07         [ 2]  201 	ldw	_last_press_time+2, x
      0080DF CE 00 01         [ 2]  202 	ldw	x, _button_handler_now_65536_15+0
      0080E2 CF 00 05         [ 2]  203 	ldw	_last_press_time+0, x
      0080E5                        204 00110$:
                                    205 ;	ext_interrupt.c: 23: }
      0080E5 5B 04            [ 2]  206 	addw	sp, #4
      0080E7 80               [11]  207 	iret
                                    208 ;	ext_interrupt.c: 25: void main() {
                                    209 ;	-----------------------------------------
                                    210 ;	 function main
                                    211 ;	-----------------------------------------
      0080E8                        212 _main:
                                    213 ;	ext_interrupt.c: 28: PD_DDR |= (1 << 3);
      0080E8 72 16 50 11      [ 1]  214 	bset	0x5011, #3
                                    215 ;	ext_interrupt.c: 29: PD_CR1 |= (1 << 3);
      0080EC 72 16 50 12      [ 1]  216 	bset	0x5012, #3
                                    217 ;	ext_interrupt.c: 30: PD_ODR &= ~(1 << 3);  // LED éteinte
      0080F0 72 17 50 0F      [ 1]  218 	bres	0x500f, #3
                                    219 ;	ext_interrupt.c: 33: PA_DDR &= ~(1 << 3);   // Entrée
      0080F4 72 17 50 02      [ 1]  220 	bres	0x5002, #3
                                    221 ;	ext_interrupt.c: 34: PA_CR1 |= (1 << 3);    // Pull-up
      0080F8 72 16 50 03      [ 1]  222 	bset	0x5003, #3
                                    223 ;	ext_interrupt.c: 35: PA_CR2 |= (1 << 3);    // Active interruption pour PA3
      0080FC C6 50 04         [ 1]  224 	ld	a, 0x5004
      0080FF AA 08            [ 1]  225 	or	a, #0x08
      008101 C7 50 04         [ 1]  226 	ld	0x5004, a
                                    227 ;	ext_interrupt.c: 38: EXTI_CR1 &= ~(0b11 << 0);   // Efface les bits PAIS[1:0]
      008104 C6 50 A0         [ 1]  228 	ld	a, 0x50a0
      008107 A4 FC            [ 1]  229 	and	a, #0xfc
      008109 C7 50 A0         [ 1]  230 	ld	0x50a0, a
                                    231 ;	ext_interrupt.c: 39: EXTI_CR1 |=  (0b10 << 0);   // Met 10 = front descendant
      00810C C6 50 A0         [ 1]  232 	ld	a, 0x50a0
      00810F AA 02            [ 1]  233 	or	a, #0x02
      008111 C7 50 A0         [ 1]  234 	ld	0x50a0, a
                                    235 ;	ext_interrupt.c: 41: __asm__("rim");  // Active les interruptions globales
      008114 9A               [ 1]  236 	rim
                                    237 ;	ext_interrupt.c: 42: while (1);  // Boucle vide, tout est géré par interruption
      008115                        238 00102$:
      008115 20 FE            [ 2]  239 	jra	00102$
                                    240 ;	ext_interrupt.c: 44: }
      008117 81               [ 4]  241 	ret
                                    242 	.area CODE
                                    243 	.area CONST
                                    244 	.area INITIALIZER
      00803F                        245 __xinit__last_press_time:
      00803F 00 00 00 00            246 	.byte #0x00, #0x00, #0x00, #0x00	; 0
                                    247 	.area CABS (ABS)
