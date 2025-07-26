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
                                     11 	.globl _digit_to_segment
                                     12 	.globl _main
                                     13 	.globl _tm_display_temp_x100
                                     14 	.globl _tm_set_segments
                                     15 	.globl _tm_write_byte
                                     16 	.globl _tm_stop
                                     17 	.globl _tm_start
                                     18 	.globl _tm_delay
                                     19 	.globl _delay_ms
                                     20 	.globl _delay_us
                                     21 ;--------------------------------------------------------
                                     22 ; ram data
                                     23 ;--------------------------------------------------------
                                     24 	.area DATA
                                     25 ;--------------------------------------------------------
                                     26 ; ram data
                                     27 ;--------------------------------------------------------
                                     28 	.area INITIALIZED
                                     29 ;--------------------------------------------------------
                                     30 ; Stack segment in internal ram
                                     31 ;--------------------------------------------------------
                                     32 	.area	SSEG
      000001                         33 __start__stack:
      000001                         34 	.ds	1
                                     35 
                                     36 ;--------------------------------------------------------
                                     37 ; absolute external ram data
                                     38 ;--------------------------------------------------------
                                     39 	.area DABS (ABS)
                                     40 
                                     41 ; default segment ordering for linker
                                     42 	.area HOME
                                     43 	.area GSINIT
                                     44 	.area GSFINAL
                                     45 	.area CONST
                                     46 	.area INITIALIZER
                                     47 	.area CODE
                                     48 
                                     49 ;--------------------------------------------------------
                                     50 ; interrupt vector
                                     51 ;--------------------------------------------------------
                                     52 	.area HOME
      008000                         53 __interrupt_vect:
      008000 82 00 80 07             54 	int s_GSINIT ; reset
                                     55 ;--------------------------------------------------------
                                     56 ; global & static initialisations
                                     57 ;--------------------------------------------------------
                                     58 	.area HOME
                                     59 	.area GSINIT
                                     60 	.area GSFINAL
                                     61 	.area GSINIT
      008007                         62 __sdcc_init_data:
                                     63 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   64 	ldw x, #l_DATA
      00800A 27 07            [ 1]   65 	jreq	00002$
      00800C                         66 00001$:
      00800C 72 4F 00 00      [ 1]   67 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   68 	decw x
      008011 26 F9            [ 1]   69 	jrne	00001$
      008013                         70 00002$:
      008013 AE 00 00         [ 2]   71 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   72 	jreq	00004$
      008018                         73 00003$:
      008018 D6 80 2D         [ 1]   74 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   75 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   76 	decw	x
      00801F 26 F7            [ 1]   77 	jrne	00003$
      008021                         78 00004$:
                                     79 ; stm8_genXINIT() end
                                     80 	.area GSFINAL
      008021 CC 80 04         [ 2]   81 	jp	__sdcc_program_startup
                                     82 ;--------------------------------------------------------
                                     83 ; Home
                                     84 ;--------------------------------------------------------
                                     85 	.area HOME
                                     86 	.area HOME
      008004                         87 __sdcc_program_startup:
      008004 CC 81 A6         [ 2]   88 	jp	_main
                                     89 ;	return from main will return to caller
                                     90 ;--------------------------------------------------------
                                     91 ; code
                                     92 ;--------------------------------------------------------
                                     93 	.area CODE
                                     94 ;	main.c: 15: void delay_us(uint16_t us) {
                                     95 ;	-----------------------------------------
                                     96 ;	 function delay_us
                                     97 ;	-----------------------------------------
      00802E                         98 _delay_us:
                                     99 ;	main.c: 16: while(us--) {
      00802E                        100 00101$:
      00802E 90 93            [ 1]  101 	ldw	y, x
      008030 5A               [ 2]  102 	decw	x
      008031 90 5D            [ 2]  103 	tnzw	y
      008033 26 01            [ 1]  104 	jrne	00117$
      008035 81               [ 4]  105 	ret
      008036                        106 00117$:
                                    107 ;	main.c: 17: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008036 9D               [ 1]  108 	nop
      008037 9D               [ 1]  109 	nop
      008038 9D               [ 1]  110 	nop
                                    111 ;	main.c: 18: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008039 9D               [ 1]  112 	nop
      00803A 9D               [ 1]  113 	nop
      00803B 9D               [ 1]  114 	nop
      00803C 20 F0            [ 2]  115 	jra	00101$
                                    116 ;	main.c: 20: }
      00803E 81               [ 4]  117 	ret
                                    118 ;	main.c: 22: void delay_ms(uint16_t ms) {
                                    119 ;	-----------------------------------------
                                    120 ;	 function delay_ms
                                    121 ;	-----------------------------------------
      00803F                        122 _delay_ms:
      00803F 52 0A            [ 2]  123 	sub	sp, #10
      008041 1F 05            [ 2]  124 	ldw	(0x05, sp), x
                                    125 ;	main.c: 24: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008043 5F               [ 1]  126 	clrw	x
      008044 1F 09            [ 2]  127 	ldw	(0x09, sp), x
      008046 1F 07            [ 2]  128 	ldw	(0x07, sp), x
      008048                        129 00103$:
      008048 1E 05            [ 2]  130 	ldw	x, (0x05, sp)
      00804A 89               [ 2]  131 	pushw	x
      00804B AE 03 78         [ 2]  132 	ldw	x, #0x0378
      00804E CD 81 C9         [ 4]  133 	call	___muluint2ulong
      008051 5B 02            [ 2]  134 	addw	sp, #2
      008053 1F 03            [ 2]  135 	ldw	(0x03, sp), x
      008055 17 01            [ 2]  136 	ldw	(0x01, sp), y
      008057 1E 09            [ 2]  137 	ldw	x, (0x09, sp)
      008059 13 03            [ 2]  138 	cpw	x, (0x03, sp)
      00805B 7B 08            [ 1]  139 	ld	a, (0x08, sp)
      00805D 12 02            [ 1]  140 	sbc	a, (0x02, sp)
      00805F 7B 07            [ 1]  141 	ld	a, (0x07, sp)
      008061 12 01            [ 1]  142 	sbc	a, (0x01, sp)
      008063 24 0F            [ 1]  143 	jrnc	00105$
                                    144 ;	main.c: 25: __asm__("nop");
      008065 9D               [ 1]  145 	nop
                                    146 ;	main.c: 24: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008066 1E 09            [ 2]  147 	ldw	x, (0x09, sp)
      008068 5C               [ 1]  148 	incw	x
      008069 1F 09            [ 2]  149 	ldw	(0x09, sp), x
      00806B 26 DB            [ 1]  150 	jrne	00103$
      00806D 1E 07            [ 2]  151 	ldw	x, (0x07, sp)
      00806F 5C               [ 1]  152 	incw	x
      008070 1F 07            [ 2]  153 	ldw	(0x07, sp), x
      008072 20 D4            [ 2]  154 	jra	00103$
      008074                        155 00105$:
                                    156 ;	main.c: 26: }
      008074 5B 0A            [ 2]  157 	addw	sp, #10
      008076 81               [ 4]  158 	ret
                                    159 ;	main.c: 43: void tm_delay() {
                                    160 ;	-----------------------------------------
                                    161 ;	 function tm_delay
                                    162 ;	-----------------------------------------
      008077                        163 _tm_delay:
      008077 52 02            [ 2]  164 	sub	sp, #2
                                    165 ;	main.c: 44: for (volatile int i = 0; i < 50; i++) __asm__("nop");
      008079 5F               [ 1]  166 	clrw	x
      00807A 1F 01            [ 2]  167 	ldw	(0x01, sp), x
      00807C                        168 00103$:
      00807C 1E 01            [ 2]  169 	ldw	x, (0x01, sp)
      00807E A3 00 32         [ 2]  170 	cpw	x, #0x0032
      008081 2E 08            [ 1]  171 	jrsge	00105$
      008083 9D               [ 1]  172 	nop
      008084 1E 01            [ 2]  173 	ldw	x, (0x01, sp)
      008086 5C               [ 1]  174 	incw	x
      008087 1F 01            [ 2]  175 	ldw	(0x01, sp), x
      008089 20 F1            [ 2]  176 	jra	00103$
      00808B                        177 00105$:
                                    178 ;	main.c: 45: }
      00808B 5B 02            [ 2]  179 	addw	sp, #2
      00808D 81               [ 4]  180 	ret
                                    181 ;	main.c: 47: void tm_start() {
                                    182 ;	-----------------------------------------
                                    183 ;	 function tm_start
                                    184 ;	-----------------------------------------
      00808E                        185 _tm_start:
                                    186 ;	main.c: 48: TM_DIO_DDR |= (1 << TM_DIO_PIN);
      00808E 72 12 50 02      [ 1]  187 	bset	0x5002, #1
                                    188 ;	main.c: 49: TM_CLK_DDR |= (1 << TM_CLK_PIN);
      008092 72 14 50 02      [ 1]  189 	bset	0x5002, #2
                                    190 ;	main.c: 50: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      008096 72 12 50 00      [ 1]  191 	bset	0x5000, #1
                                    192 ;	main.c: 51: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      00809A 72 14 50 00      [ 1]  193 	bset	0x5000, #2
                                    194 ;	main.c: 52: tm_delay();
      00809E CD 80 77         [ 4]  195 	call	_tm_delay
                                    196 ;	main.c: 53: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      0080A1 72 13 50 00      [ 1]  197 	bres	0x5000, #1
                                    198 ;	main.c: 54: tm_delay();
      0080A5 CD 80 77         [ 4]  199 	call	_tm_delay
                                    200 ;	main.c: 55: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0080A8 72 15 50 00      [ 1]  201 	bres	0x5000, #2
                                    202 ;	main.c: 56: }
      0080AC 81               [ 4]  203 	ret
                                    204 ;	main.c: 58: void tm_stop() {
                                    205 ;	-----------------------------------------
                                    206 ;	 function tm_stop
                                    207 ;	-----------------------------------------
      0080AD                        208 _tm_stop:
                                    209 ;	main.c: 59: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0080AD 72 15 50 00      [ 1]  210 	bres	0x5000, #2
                                    211 ;	main.c: 60: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      0080B1 72 13 50 00      [ 1]  212 	bres	0x5000, #1
                                    213 ;	main.c: 61: tm_delay();
      0080B5 CD 80 77         [ 4]  214 	call	_tm_delay
                                    215 ;	main.c: 62: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      0080B8 72 14 50 00      [ 1]  216 	bset	0x5000, #2
                                    217 ;	main.c: 63: tm_delay();
      0080BC CD 80 77         [ 4]  218 	call	_tm_delay
                                    219 ;	main.c: 64: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      0080BF 72 12 50 00      [ 1]  220 	bset	0x5000, #1
                                    221 ;	main.c: 65: }
      0080C3 81               [ 4]  222 	ret
                                    223 ;	main.c: 67: void tm_write_byte(uint8_t b) {
                                    224 ;	-----------------------------------------
                                    225 ;	 function tm_write_byte
                                    226 ;	-----------------------------------------
      0080C4                        227 _tm_write_byte:
      0080C4 52 02            [ 2]  228 	sub	sp, #2
      0080C6 6B 01            [ 1]  229 	ld	(0x01, sp), a
                                    230 ;	main.c: 68: for (uint8_t i = 0; i < 8; i++) {
      0080C8 0F 02            [ 1]  231 	clr	(0x02, sp)
      0080CA                        232 00106$:
                                    233 ;	main.c: 69: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0080CA C6 50 00         [ 1]  234 	ld	a, 0x5000
      0080CD A4 FB            [ 1]  235 	and	a, #0xfb
                                    236 ;	main.c: 68: for (uint8_t i = 0; i < 8; i++) {
      0080CF 88               [ 1]  237 	push	a
      0080D0 7B 03            [ 1]  238 	ld	a, (0x03, sp)
      0080D2 A1 08            [ 1]  239 	cp	a, #0x08
      0080D4 84               [ 1]  240 	pop	a
      0080D5 24 29            [ 1]  241 	jrnc	00104$
                                    242 ;	main.c: 69: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0080D7 C7 50 00         [ 1]  243 	ld	0x5000, a
      0080DA C6 50 00         [ 1]  244 	ld	a, 0x5000
                                    245 ;	main.c: 70: if (b & 0x01)
      0080DD 88               [ 1]  246 	push	a
      0080DE 7B 02            [ 1]  247 	ld	a, (0x02, sp)
      0080E0 44               [ 1]  248 	srl	a
      0080E1 84               [ 1]  249 	pop	a
      0080E2 24 07            [ 1]  250 	jrnc	00102$
                                    251 ;	main.c: 71: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      0080E4 AA 02            [ 1]  252 	or	a, #0x02
      0080E6 C7 50 00         [ 1]  253 	ld	0x5000, a
      0080E9 20 05            [ 2]  254 	jra	00103$
      0080EB                        255 00102$:
                                    256 ;	main.c: 73: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      0080EB A4 FD            [ 1]  257 	and	a, #0xfd
      0080ED C7 50 00         [ 1]  258 	ld	0x5000, a
      0080F0                        259 00103$:
                                    260 ;	main.c: 74: tm_delay();
      0080F0 CD 80 77         [ 4]  261 	call	_tm_delay
                                    262 ;	main.c: 75: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      0080F3 72 14 50 00      [ 1]  263 	bset	0x5000, #2
                                    264 ;	main.c: 76: tm_delay();
      0080F7 CD 80 77         [ 4]  265 	call	_tm_delay
                                    266 ;	main.c: 77: b >>= 1;
      0080FA 04 01            [ 1]  267 	srl	(0x01, sp)
                                    268 ;	main.c: 68: for (uint8_t i = 0; i < 8; i++) {
      0080FC 0C 02            [ 1]  269 	inc	(0x02, sp)
      0080FE 20 CA            [ 2]  270 	jra	00106$
      008100                        271 00104$:
                                    272 ;	main.c: 81: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008100 C7 50 00         [ 1]  273 	ld	0x5000, a
                                    274 ;	main.c: 82: TM_DIO_DDR &= ~(1 << TM_DIO_PIN); // entrée
      008103 72 13 50 02      [ 1]  275 	bres	0x5002, #1
                                    276 ;	main.c: 83: tm_delay();
      008107 CD 80 77         [ 4]  277 	call	_tm_delay
                                    278 ;	main.c: 84: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      00810A 72 14 50 00      [ 1]  279 	bset	0x5000, #2
                                    280 ;	main.c: 85: tm_delay();
      00810E CD 80 77         [ 4]  281 	call	_tm_delay
                                    282 ;	main.c: 86: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008111 72 15 50 00      [ 1]  283 	bres	0x5000, #2
                                    284 ;	main.c: 87: TM_DIO_DDR |= (1 << TM_DIO_PIN); // repasse en sortie
      008115 72 12 50 02      [ 1]  285 	bset	0x5002, #1
                                    286 ;	main.c: 88: }
      008119 5B 02            [ 2]  287 	addw	sp, #2
      00811B 81               [ 4]  288 	ret
                                    289 ;	main.c: 91: void tm_set_segments(uint8_t *segments, uint8_t length) {
                                    290 ;	-----------------------------------------
                                    291 ;	 function tm_set_segments
                                    292 ;	-----------------------------------------
      00811C                        293 _tm_set_segments:
      00811C 52 04            [ 2]  294 	sub	sp, #4
      00811E 1F 02            [ 2]  295 	ldw	(0x02, sp), x
      008120 6B 01            [ 1]  296 	ld	(0x01, sp), a
                                    297 ;	main.c: 92: tm_start();
      008122 CD 80 8E         [ 4]  298 	call	_tm_start
                                    299 ;	main.c: 93: tm_write_byte(0x40); // Commande : auto-increment mode
      008125 A6 40            [ 1]  300 	ld	a, #0x40
      008127 CD 80 C4         [ 4]  301 	call	_tm_write_byte
                                    302 ;	main.c: 94: tm_stop();
      00812A CD 80 AD         [ 4]  303 	call	_tm_stop
                                    304 ;	main.c: 96: tm_start();
      00812D CD 80 8E         [ 4]  305 	call	_tm_start
                                    306 ;	main.c: 97: tm_write_byte(0xC0); // Adresse de départ = 0
      008130 A6 C0            [ 1]  307 	ld	a, #0xc0
      008132 CD 80 C4         [ 4]  308 	call	_tm_write_byte
                                    309 ;	main.c: 98: for (uint8_t i = 0; i < length; i++) {
      008135 0F 04            [ 1]  310 	clr	(0x04, sp)
      008137                        311 00103$:
      008137 7B 04            [ 1]  312 	ld	a, (0x04, sp)
      008139 11 01            [ 1]  313 	cp	a, (0x01, sp)
      00813B 24 0F            [ 1]  314 	jrnc	00101$
                                    315 ;	main.c: 99: tm_write_byte(segments[i]);
      00813D 5F               [ 1]  316 	clrw	x
      00813E 7B 04            [ 1]  317 	ld	a, (0x04, sp)
      008140 97               [ 1]  318 	ld	xl, a
      008141 72 FB 02         [ 2]  319 	addw	x, (0x02, sp)
      008144 F6               [ 1]  320 	ld	a, (x)
      008145 CD 80 C4         [ 4]  321 	call	_tm_write_byte
                                    322 ;	main.c: 98: for (uint8_t i = 0; i < length; i++) {
      008148 0C 04            [ 1]  323 	inc	(0x04, sp)
      00814A 20 EB            [ 2]  324 	jra	00103$
      00814C                        325 00101$:
                                    326 ;	main.c: 101: tm_stop();
      00814C CD 80 AD         [ 4]  327 	call	_tm_stop
                                    328 ;	main.c: 103: tm_start();
      00814F CD 80 8E         [ 4]  329 	call	_tm_start
                                    330 ;	main.c: 104: tm_write_byte(0x88 | 0x07); // Affichage ON, luminosité max (0x00 à 0x07)
      008152 A6 8F            [ 1]  331 	ld	a, #0x8f
      008154 CD 80 C4         [ 4]  332 	call	_tm_write_byte
                                    333 ;	main.c: 105: tm_stop();
      008157 5B 04            [ 2]  334 	addw	sp, #4
                                    335 ;	main.c: 106: }
      008159 CC 80 AD         [ 2]  336 	jp	_tm_stop
                                    337 ;	main.c: 108: void tm_display_temp_x100(int temp_x100) {
                                    338 ;	-----------------------------------------
                                    339 ;	 function tm_display_temp_x100
                                    340 ;	-----------------------------------------
      00815C                        341 _tm_display_temp_x100:
      00815C 52 0A            [ 2]  342 	sub	sp, #10
                                    343 ;	main.c: 109: int val = temp_x100;
      00815E 1F 05            [ 2]  344 	ldw	(0x05, sp), x
                                    345 ;	main.c: 110: if (val < 0) val = -val;  // Ignore le signe ici (optionnel à améliorer)
      008160 5D               [ 2]  346 	tnzw	x
      008161 2A 03            [ 1]  347 	jrpl	00111$
      008163 50               [ 2]  348 	negw	x
      008164 1F 05            [ 2]  349 	ldw	(0x05, sp), x
                                    350 ;	main.c: 114: for (int i = 3; i >= 0; i--) {
      008166                        351 00111$:
      008166 AE 00 03         [ 2]  352 	ldw	x, #0x0003
      008169 1F 09            [ 2]  353 	ldw	(0x09, sp), x
      00816B                        354 00105$:
      00816B 0D 09            [ 1]  355 	tnz	(0x09, sp)
      00816D 2B 28            [ 1]  356 	jrmi	00103$
                                    357 ;	main.c: 115: digits[i] = digit_to_segment[val % 10];
      00816F 96               [ 1]  358 	ldw	x, sp
      008170 5C               [ 1]  359 	incw	x
      008171 72 FB 09         [ 2]  360 	addw	x, (0x09, sp)
      008174 1F 07            [ 2]  361 	ldw	(0x07, sp), x
      008176 4B 0A            [ 1]  362 	push	#0x0a
      008178 4B 00            [ 1]  363 	push	#0x00
      00817A 1E 07            [ 2]  364 	ldw	x, (0x07, sp)
      00817C CD 82 20         [ 4]  365 	call	__modsint
      00817F D6 80 24         [ 1]  366 	ld	a, (_digit_to_segment+0, x)
      008182 1E 07            [ 2]  367 	ldw	x, (0x07, sp)
      008184 F7               [ 1]  368 	ld	(x), a
                                    369 ;	main.c: 116: val /= 10;
      008185 4B 0A            [ 1]  370 	push	#0x0a
      008187 4B 00            [ 1]  371 	push	#0x00
      008189 1E 07            [ 2]  372 	ldw	x, (0x07, sp)
      00818B CD 82 38         [ 4]  373 	call	__divsint
      00818E 1F 05            [ 2]  374 	ldw	(0x05, sp), x
                                    375 ;	main.c: 114: for (int i = 3; i >= 0; i--) {
      008190 1E 09            [ 2]  376 	ldw	x, (0x09, sp)
      008192 5A               [ 2]  377 	decw	x
      008193 1F 09            [ 2]  378 	ldw	(0x09, sp), x
      008195 20 D4            [ 2]  379 	jra	00105$
      008197                        380 00103$:
                                    381 ;	main.c: 120: digits[1] |= 0x80;
      008197 09 02            [ 1]  382 	rlc	(0x02, sp)
      008199 99               [ 1]  383 	scf
      00819A 06 02            [ 1]  384 	rrc	(0x02, sp)
                                    385 ;	main.c: 122: tm_set_segments(digits, 4);
      00819C A6 04            [ 1]  386 	ld	a, #0x04
      00819E 96               [ 1]  387 	ldw	x, sp
      00819F 5C               [ 1]  388 	incw	x
      0081A0 CD 81 1C         [ 4]  389 	call	_tm_set_segments
                                    390 ;	main.c: 123: }
      0081A3 5B 0A            [ 2]  391 	addw	sp, #10
      0081A5 81               [ 4]  392 	ret
                                    393 ;	main.c: 128: void main() {
                                    394 ;	-----------------------------------------
                                    395 ;	 function main
                                    396 ;	-----------------------------------------
      0081A6                        397 _main:
                                    398 ;	main.c: 130: CLK_CKDIVR = 0x00; // forcer la frequence CPU
      0081A6 35 00 50 C6      [ 1]  399 	mov	0x50c6+0, #0x00
                                    400 ;	main.c: 132: PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
      0081AA C6 50 02         [ 1]  401 	ld	a, 0x5002
      0081AD AA 06            [ 1]  402 	or	a, #0x06
      0081AF C7 50 02         [ 1]  403 	ld	0x5002, a
                                    404 ;	main.c: 133: PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull
      0081B2 C6 50 03         [ 1]  405 	ld	a, 0x5003
      0081B5 AA 06            [ 1]  406 	or	a, #0x06
      0081B7 C7 50 03         [ 1]  407 	ld	0x5003, a
                                    408 ;	main.c: 139: while (1) {
      0081BA                        409 00102$:
                                    410 ;	main.c: 140: tm_display_temp_x100(1337);
      0081BA AE 05 39         [ 2]  411 	ldw	x, #0x0539
      0081BD CD 81 5C         [ 4]  412 	call	_tm_display_temp_x100
                                    413 ;	main.c: 141: delay_ms(1000);
      0081C0 AE 03 E8         [ 2]  414 	ldw	x, #0x03e8
      0081C3 CD 80 3F         [ 4]  415 	call	_delay_ms
      0081C6 20 F2            [ 2]  416 	jra	00102$
                                    417 ;	main.c: 143: }
      0081C8 81               [ 4]  418 	ret
                                    419 	.area CODE
                                    420 	.area CONST
      008024                        421 _digit_to_segment:
      008024 3F                     422 	.db #0x3f	; 63
      008025 06                     423 	.db #0x06	; 6
      008026 5B                     424 	.db #0x5b	; 91
      008027 4F                     425 	.db #0x4f	; 79	'O'
      008028 66                     426 	.db #0x66	; 102	'f'
      008029 6D                     427 	.db #0x6d	; 109	'm'
      00802A 7D                     428 	.db #0x7d	; 125
      00802B 07                     429 	.db #0x07	; 7
      00802C 7F                     430 	.db #0x7f	; 127
      00802D 6F                     431 	.db #0x6f	; 111	'o'
                                    432 	.area INITIALIZER
                                    433 	.area CABS (ABS)
