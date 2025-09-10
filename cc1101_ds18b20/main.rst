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
                                     12 	.globl _cc_send_temp_x100
                                     13 	.globl _ds18b20_read_raw
                                     14 	.globl _ds18b20_start_conversion
                                     15 	.globl _onewire_read_byte
                                     16 	.globl _onewire_write_byte
                                     17 	.globl _onewire_read_bit
                                     18 	.globl _onewire_write_bit
                                     19 	.globl _onewire_reset
                                     20 	.globl _delay_us
                                     21 	.globl _printf
                                     22 	.globl _putchar
                                     23 ;--------------------------------------------------------
                                     24 ; ram data
                                     25 ;--------------------------------------------------------
                                     26 	.area DATA
                                     27 ;--------------------------------------------------------
                                     28 ; ram data
                                     29 ;--------------------------------------------------------
                                     30 	.area INITIALIZED
                                     31 ;--------------------------------------------------------
                                     32 ; Stack segment in internal ram
                                     33 ;--------------------------------------------------------
                                     34 	.area	SSEG
      000001                         35 __start__stack:
      000001                         36 	.ds	1
                                     37 
                                     38 ;--------------------------------------------------------
                                     39 ; absolute external ram data
                                     40 ;--------------------------------------------------------
                                     41 	.area DABS (ABS)
                                     42 
                                     43 ; default segment ordering for linker
                                     44 	.area HOME
                                     45 	.area GSINIT
                                     46 	.area GSFINAL
                                     47 	.area CONST
                                     48 	.area INITIALIZER
                                     49 	.area CODE
                                     50 
                                     51 ;--------------------------------------------------------
                                     52 ; interrupt vector
                                     53 ;--------------------------------------------------------
                                     54 	.area HOME
      008000                         55 __interrupt_vect:
      008000 82 00 80 07             56 	int s_GSINIT ; reset
                                     57 ;--------------------------------------------------------
                                     58 ; global & static initialisations
                                     59 ;--------------------------------------------------------
                                     60 	.area HOME
                                     61 	.area GSINIT
                                     62 	.area GSFINAL
                                     63 	.area GSINIT
      008007                         64 __sdcc_init_data:
                                     65 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   66 	ldw x, #l_DATA
      00800A 27 07            [ 1]   67 	jreq	00002$
      00800C                         68 00001$:
      00800C 72 4F 00 00      [ 1]   69 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   70 	decw x
      008011 26 F9            [ 1]   71 	jrne	00001$
      008013                         72 00002$:
      008013 AE 00 00         [ 2]   73 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   74 	jreq	00004$
      008018                         75 00003$:
      008018 D6 80 56         [ 1]   76 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   77 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   78 	decw	x
      00801F 26 F7            [ 1]   79 	jrne	00003$
      008021                         80 00004$:
                                     81 ; stm8_genXINIT() end
                                     82 	.area GSFINAL
      008021 CC 80 04         [ 2]   83 	jp	__sdcc_program_startup
                                     84 ;--------------------------------------------------------
                                     85 ; Home
                                     86 ;--------------------------------------------------------
                                     87 	.area HOME
                                     88 	.area HOME
      008004                         89 __sdcc_program_startup:
      008004 CC 85 20         [ 2]   90 	jp	_main
                                     91 ;	return from main will return to caller
                                     92 ;--------------------------------------------------------
                                     93 ; code
                                     94 ;--------------------------------------------------------
                                     95 	.area CODE
                                     96 ;	main.c: 10: static void uart_init(void){
                                     97 ;	-----------------------------------------
                                     98 ;	 function uart_init
                                     99 ;	-----------------------------------------
      008057                        100 _uart_init:
                                    101 ;	main.c: 11: CLK_CKDIVR = 0x00;
      008057 35 00 50 C6      [ 1]  102 	mov	0x50c6+0, #0x00
                                    103 ;	main.c: 13: UART1_BRR1 = (div >> 4) & 0xFF;
      00805B A6 68            [ 1]  104 	ld	a, #0x68
      00805D C7 52 32         [ 1]  105 	ld	0x5232, a
                                    106 ;	main.c: 14: UART1_BRR2 = ((div & 0x0F) | ((div >> 8) & 0xF0));
      008060 A6 83            [ 1]  107 	ld	a, #0x83
      008062 A4 0F            [ 1]  108 	and	a, #0x0f
      008064 C7 52 33         [ 1]  109 	ld	0x5233, a
                                    110 ;	main.c: 15: UART1_CR1 = 0x00; UART1_CR3 = 0x00;
      008067 35 00 52 34      [ 1]  111 	mov	0x5234+0, #0x00
      00806B 35 00 52 36      [ 1]  112 	mov	0x5236+0, #0x00
                                    113 ;	main.c: 16: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
      00806F 35 0C 52 35      [ 1]  114 	mov	0x5235+0, #0x0c
                                    115 ;	main.c: 17: (void)UART1_SR; (void)UART1_DR;
      008073 C6 52 30         [ 1]  116 	ld	a, 0x5230
      008076 C6 52 31         [ 1]  117 	ld	a, 0x5231
                                    118 ;	main.c: 18: }
      008079 81               [ 4]  119 	ret
                                    120 ;	main.c: 19: int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; } // Gestion des printf 
                                    121 ;	-----------------------------------------
                                    122 ;	 function putchar
                                    123 ;	-----------------------------------------
      00807A                        124 _putchar:
      00807A                        125 00101$:
      00807A C6 52 30         [ 1]  126 	ld	a, 0x5230
      00807D 2A FB            [ 1]  127 	jrpl	00101$
      00807F 9F               [ 1]  128 	ld	a, xl
      008080 C7 52 31         [ 1]  129 	ld	0x5231, a
      008083 5F               [ 1]  130 	clrw	x
      008084 81               [ 4]  131 	ret
                                    132 ;	main.c: 42: void delay_us(uint16_t us) {
                                    133 ;	-----------------------------------------
                                    134 ;	 function delay_us
                                    135 ;	-----------------------------------------
      008085                        136 _delay_us:
                                    137 ;	main.c: 43: while(us--) {
      008085                        138 00101$:
      008085 90 93            [ 1]  139 	ldw	y, x
      008087 5A               [ 2]  140 	decw	x
      008088 90 5D            [ 2]  141 	tnzw	y
      00808A 26 01            [ 1]  142 	jrne	00117$
      00808C 81               [ 4]  143 	ret
      00808D                        144 00117$:
                                    145 ;	main.c: 44: __asm__("nop"); __asm__("nop"); __asm__("nop");
      00808D 9D               [ 1]  146 	nop
      00808E 9D               [ 1]  147 	nop
      00808F 9D               [ 1]  148 	nop
                                    149 ;	main.c: 45: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008090 9D               [ 1]  150 	nop
      008091 9D               [ 1]  151 	nop
      008092 9D               [ 1]  152 	nop
      008093 20 F0            [ 2]  153 	jra	00101$
                                    154 ;	main.c: 47: }
      008095 81               [ 4]  155 	ret
                                    156 ;	main.c: 50: static inline void delay_ms(uint16_t ms) {
                                    157 ;	-----------------------------------------
                                    158 ;	 function delay_ms
                                    159 ;	-----------------------------------------
      008096                        160 _delay_ms:
      008096 52 0A            [ 2]  161 	sub	sp, #10
      008098 1F 05            [ 2]  162 	ldw	(0x05, sp), x
                                    163 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00809A 5F               [ 1]  164 	clrw	x
      00809B 1F 09            [ 2]  165 	ldw	(0x09, sp), x
      00809D 1F 07            [ 2]  166 	ldw	(0x07, sp), x
      00809F                        167 00103$:
      00809F 1E 05            [ 2]  168 	ldw	x, (0x05, sp)
      0080A1 89               [ 2]  169 	pushw	x
      0080A2 AE 03 78         [ 2]  170 	ldw	x, #0x0378
      0080A5 CD 85 BB         [ 4]  171 	call	___muluint2ulong
      0080A8 5B 02            [ 2]  172 	addw	sp, #2
      0080AA 1F 03            [ 2]  173 	ldw	(0x03, sp), x
      0080AC 17 01            [ 2]  174 	ldw	(0x01, sp), y
      0080AE 1E 09            [ 2]  175 	ldw	x, (0x09, sp)
      0080B0 13 03            [ 2]  176 	cpw	x, (0x03, sp)
      0080B2 7B 08            [ 1]  177 	ld	a, (0x08, sp)
      0080B4 12 02            [ 1]  178 	sbc	a, (0x02, sp)
      0080B6 7B 07            [ 1]  179 	ld	a, (0x07, sp)
      0080B8 12 01            [ 1]  180 	sbc	a, (0x01, sp)
      0080BA 24 0F            [ 1]  181 	jrnc	00105$
                                    182 ;	main.c: 53: __asm__("nop");
      0080BC 9D               [ 1]  183 	nop
                                    184 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080BD 1E 09            [ 2]  185 	ldw	x, (0x09, sp)
      0080BF 5C               [ 1]  186 	incw	x
      0080C0 1F 09            [ 2]  187 	ldw	(0x09, sp), x
      0080C2 26 DB            [ 1]  188 	jrne	00103$
      0080C4 1E 07            [ 2]  189 	ldw	x, (0x07, sp)
      0080C6 5C               [ 1]  190 	incw	x
      0080C7 1F 07            [ 2]  191 	ldw	(0x07, sp), x
      0080C9 20 D4            [ 2]  192 	jra	00103$
      0080CB                        193 00105$:
                                    194 ;	main.c: 54: }
      0080CB 5B 0A            [ 2]  195 	addw	sp, #10
      0080CD 81               [ 4]  196 	ret
                                    197 ;	main.c: 59: uint8_t onewire_reset(void) {
                                    198 ;	-----------------------------------------
                                    199 ;	 function onewire_reset
                                    200 ;	-----------------------------------------
      0080CE                        201 _onewire_reset:
                                    202 ;	main.c: 60: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
      0080CE 72 16 50 11      [ 1]  203 	bset	0x5011, #3
      0080D2 72 17 50 0F      [ 1]  204 	bres	0x500f, #3
                                    205 ;	main.c: 61: delay_us(480);
      0080D6 AE 01 E0         [ 2]  206 	ldw	x, #0x01e0
      0080D9 CD 80 85         [ 4]  207 	call	_delay_us
                                    208 ;	main.c: 62: DS_INPUT();                    // Relâche la ligne
      0080DC 72 17 50 11      [ 1]  209 	bres	0x5011, #3
                                    210 ;	main.c: 63: delay_us(70);                  // Attend la réponse du capteur
      0080E0 AE 00 46         [ 2]  211 	ldw	x, #0x0046
      0080E3 CD 80 85         [ 4]  212 	call	_delay_us
                                    213 ;	main.c: 64: uint8_t presence = !DS_READ(); // 0 = présence détectée
      0080E6 C6 50 10         [ 1]  214 	ld	a, 0x5010
      0080E9 4E               [ 1]  215 	swap	a
      0080EA 48               [ 1]  216 	sll	a
      0080EB 4F               [ 1]  217 	clr	a
      0080EC 49               [ 1]  218 	rlc	a
      0080ED A0 01            [ 1]  219 	sub	a, #0x01
      0080EF 4F               [ 1]  220 	clr	a
      0080F0 49               [ 1]  221 	rlc	a
                                    222 ;	main.c: 65: delay_us(410);                 // Fin du timing 1-Wire
      0080F1 88               [ 1]  223 	push	a
      0080F2 AE 01 9A         [ 2]  224 	ldw	x, #0x019a
      0080F5 CD 80 85         [ 4]  225 	call	_delay_us
      0080F8 84               [ 1]  226 	pop	a
                                    227 ;	main.c: 66: return presence;
                                    228 ;	main.c: 67: }
      0080F9 81               [ 4]  229 	ret
                                    230 ;	main.c: 70: void onewire_write_bit(uint8_t bit) {
                                    231 ;	-----------------------------------------
                                    232 ;	 function onewire_write_bit
                                    233 ;	-----------------------------------------
      0080FA                        234 _onewire_write_bit:
      0080FA 88               [ 1]  235 	push	a
      0080FB 6B 01            [ 1]  236 	ld	(0x01, sp), a
                                    237 ;	main.c: 71: DS_OUTPUT(); DS_LOW();
      0080FD 72 16 50 11      [ 1]  238 	bset	0x5011, #3
      008101 72 17 50 0F      [ 1]  239 	bres	0x500f, #3
                                    240 ;	main.c: 72: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
      008105 0D 01            [ 1]  241 	tnz	(0x01, sp)
      008107 27 04            [ 1]  242 	jreq	00103$
      008109 AE 00 06         [ 2]  243 	ldw	x, #0x0006
      00810C BC                     244 	.byte 0xbc
      00810D                        245 00103$:
      00810D AE 00 3C         [ 2]  246 	ldw	x, #0x003c
      008110                        247 00104$:
      008110 CD 80 85         [ 4]  248 	call	_delay_us
                                    249 ;	main.c: 73: DS_INPUT();                    // Libère la ligne
      008113 72 17 50 11      [ 1]  250 	bres	0x5011, #3
                                    251 ;	main.c: 74: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
      008117 0D 01            [ 1]  252 	tnz	(0x01, sp)
      008119 27 05            [ 1]  253 	jreq	00105$
      00811B AE 00 40         [ 2]  254 	ldw	x, #0x0040
      00811E 20 03            [ 2]  255 	jra	00106$
      008120                        256 00105$:
      008120 AE 00 0A         [ 2]  257 	ldw	x, #0x000a
      008123                        258 00106$:
      008123 84               [ 1]  259 	pop	a
      008124 CC 80 85         [ 2]  260 	jp	_delay_us
                                    261 ;	main.c: 75: }
      008127 84               [ 1]  262 	pop	a
      008128 81               [ 4]  263 	ret
                                    264 ;	main.c: 78: uint8_t onewire_read_bit(void) {
                                    265 ;	-----------------------------------------
                                    266 ;	 function onewire_read_bit
                                    267 ;	-----------------------------------------
      008129                        268 _onewire_read_bit:
                                    269 ;	main.c: 80: DS_OUTPUT(); DS_LOW();
      008129 72 16 50 11      [ 1]  270 	bset	0x5011, #3
      00812D 72 17 50 0F      [ 1]  271 	bres	0x500f, #3
                                    272 ;	main.c: 81: delay_us(6);                   // Pulse d'initiation de lecture
      008131 AE 00 06         [ 2]  273 	ldw	x, #0x0006
      008134 CD 80 85         [ 4]  274 	call	_delay_us
                                    275 ;	main.c: 82: DS_INPUT();                    // Libère la ligne pour lire
      008137 72 17 50 11      [ 1]  276 	bres	0x5011, #3
                                    277 ;	main.c: 83: delay_us(9);                   // Délai standard
      00813B AE 00 09         [ 2]  278 	ldw	x, #0x0009
      00813E CD 80 85         [ 4]  279 	call	_delay_us
                                    280 ;	main.c: 84: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
      008141 72 07 50 10 03   [ 2]  281 	btjf	0x5010, #3, 00103$
      008146 5F               [ 1]  282 	clrw	x
      008147 5C               [ 1]  283 	incw	x
      008148 21                     284 	.byte 0x21
      008149                        285 00103$:
      008149 5F               [ 1]  286 	clrw	x
      00814A                        287 00104$:
      00814A 9F               [ 1]  288 	ld	a, xl
                                    289 ;	main.c: 85: delay_us(55);                  // Fin du slot
      00814B 88               [ 1]  290 	push	a
      00814C AE 00 37         [ 2]  291 	ldw	x, #0x0037
      00814F CD 80 85         [ 4]  292 	call	_delay_us
      008152 84               [ 1]  293 	pop	a
                                    294 ;	main.c: 86: return bit;
                                    295 ;	main.c: 87: }
      008153 81               [ 4]  296 	ret
                                    297 ;	main.c: 90: void onewire_write_byte(uint8_t byte) {
                                    298 ;	-----------------------------------------
                                    299 ;	 function onewire_write_byte
                                    300 ;	-----------------------------------------
      008154                        301 _onewire_write_byte:
      008154 52 02            [ 2]  302 	sub	sp, #2
      008156 6B 01            [ 1]  303 	ld	(0x01, sp), a
                                    304 ;	main.c: 91: for (uint8_t i = 0; i < 8; i++) {
      008158 0F 02            [ 1]  305 	clr	(0x02, sp)
      00815A                        306 00103$:
      00815A 7B 02            [ 1]  307 	ld	a, (0x02, sp)
      00815C A1 08            [ 1]  308 	cp	a, #0x08
      00815E 24 0D            [ 1]  309 	jrnc	00105$
                                    310 ;	main.c: 92: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
      008160 7B 01            [ 1]  311 	ld	a, (0x01, sp)
      008162 A4 01            [ 1]  312 	and	a, #0x01
      008164 CD 80 FA         [ 4]  313 	call	_onewire_write_bit
                                    314 ;	main.c: 93: byte >>= 1;
      008167 04 01            [ 1]  315 	srl	(0x01, sp)
                                    316 ;	main.c: 91: for (uint8_t i = 0; i < 8; i++) {
      008169 0C 02            [ 1]  317 	inc	(0x02, sp)
      00816B 20 ED            [ 2]  318 	jra	00103$
      00816D                        319 00105$:
                                    320 ;	main.c: 95: }
      00816D 5B 02            [ 2]  321 	addw	sp, #2
      00816F 81               [ 4]  322 	ret
                                    323 ;	main.c: 98: uint8_t onewire_read_byte(void) {
                                    324 ;	-----------------------------------------
                                    325 ;	 function onewire_read_byte
                                    326 ;	-----------------------------------------
      008170                        327 _onewire_read_byte:
      008170 52 02            [ 2]  328 	sub	sp, #2
                                    329 ;	main.c: 99: uint8_t byte = 0;
      008172 0F 01            [ 1]  330 	clr	(0x01, sp)
                                    331 ;	main.c: 100: for (uint8_t i = 0; i < 8; i++) {
      008174 0F 02            [ 1]  332 	clr	(0x02, sp)
      008176                        333 00105$:
      008176 7B 02            [ 1]  334 	ld	a, (0x02, sp)
      008178 A1 08            [ 1]  335 	cp	a, #0x08
      00817A 24 11            [ 1]  336 	jrnc	00103$
                                    337 ;	main.c: 101: byte >>= 1;
      00817C 04 01            [ 1]  338 	srl	(0x01, sp)
                                    339 ;	main.c: 102: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
      00817E CD 81 29         [ 4]  340 	call	_onewire_read_bit
      008181 4D               [ 1]  341 	tnz	a
      008182 27 05            [ 1]  342 	jreq	00106$
      008184 08 01            [ 1]  343 	sll	(0x01, sp)
      008186 99               [ 1]  344 	scf
      008187 06 01            [ 1]  345 	rrc	(0x01, sp)
      008189                        346 00106$:
                                    347 ;	main.c: 100: for (uint8_t i = 0; i < 8; i++) {
      008189 0C 02            [ 1]  348 	inc	(0x02, sp)
      00818B 20 E9            [ 2]  349 	jra	00105$
      00818D                        350 00103$:
                                    351 ;	main.c: 104: return byte;
      00818D 7B 01            [ 1]  352 	ld	a, (0x01, sp)
                                    353 ;	main.c: 105: }
      00818F 5B 02            [ 2]  354 	addw	sp, #2
      008191 81               [ 4]  355 	ret
                                    356 ;	main.c: 108: void ds18b20_start_conversion(void) {
                                    357 ;	-----------------------------------------
                                    358 ;	 function ds18b20_start_conversion
                                    359 ;	-----------------------------------------
      008192                        360 _ds18b20_start_conversion:
                                    361 ;	main.c: 109: onewire_reset();
      008192 CD 80 CE         [ 4]  362 	call	_onewire_reset
                                    363 ;	main.c: 110: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
      008195 A6 CC            [ 1]  364 	ld	a, #0xcc
      008197 CD 81 54         [ 4]  365 	call	_onewire_write_byte
                                    366 ;	main.c: 111: onewire_write_byte(0x44); // Convert T (lance mesure)
      00819A A6 44            [ 1]  367 	ld	a, #0x44
                                    368 ;	main.c: 112: }
      00819C CC 81 54         [ 2]  369 	jp	_onewire_write_byte
                                    370 ;	main.c: 115: int16_t ds18b20_read_raw(void) {
                                    371 ;	-----------------------------------------
                                    372 ;	 function ds18b20_read_raw
                                    373 ;	-----------------------------------------
      00819F                        374 _ds18b20_read_raw:
      00819F 52 04            [ 2]  375 	sub	sp, #4
                                    376 ;	main.c: 116: onewire_reset();
      0081A1 CD 80 CE         [ 4]  377 	call	_onewire_reset
                                    378 ;	main.c: 117: onewire_write_byte(0xCC); // Skip ROM
      0081A4 A6 CC            [ 1]  379 	ld	a, #0xcc
      0081A6 CD 81 54         [ 4]  380 	call	_onewire_write_byte
                                    381 ;	main.c: 118: onewire_write_byte(0xBE); // Read Scratchpad
      0081A9 A6 BE            [ 1]  382 	ld	a, #0xbe
      0081AB CD 81 54         [ 4]  383 	call	_onewire_write_byte
                                    384 ;	main.c: 120: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
      0081AE CD 81 70         [ 4]  385 	call	_onewire_read_byte
                                    386 ;	main.c: 121: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
      0081B1 88               [ 1]  387 	push	a
      0081B2 CD 81 70         [ 4]  388 	call	_onewire_read_byte
      0081B5 95               [ 1]  389 	ld	xh, a
      0081B6 84               [ 1]  390 	pop	a
                                    391 ;	main.c: 123: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
      0081B7 0F 02            [ 1]  392 	clr	(0x02, sp)
      0081B9 0F 03            [ 1]  393 	clr	(0x03, sp)
      0081BB 1A 02            [ 1]  394 	or	a, (0x02, sp)
      0081BD 02               [ 1]  395 	rlwa	x
      0081BE 1A 03            [ 1]  396 	or	a, (0x03, sp)
      0081C0 95               [ 1]  397 	ld	xh, a
                                    398 ;	main.c: 124: }
      0081C1 5B 04            [ 2]  399 	addw	sp, #4
      0081C3 81               [ 4]  400 	ret
                                    401 ;	main.c: 140: static void gpio_init(void){
                                    402 ;	-----------------------------------------
                                    403 ;	 function gpio_init
                                    404 ;	-----------------------------------------
      0081C4                        405 _gpio_init:
                                    406 ;	main.c: 142: PC_DDR |= (1<<5) | (1<<MOSI_BIT);
      0081C4 C6 50 0C         [ 1]  407 	ld	a, 0x500c
      0081C7 AA 60            [ 1]  408 	or	a, #0x60
      0081C9 C7 50 0C         [ 1]  409 	ld	0x500c, a
                                    410 ;	main.c: 143: PC_CR1 |= (1<<5) | (1<<MOSI_BIT);
      0081CC C6 50 0D         [ 1]  411 	ld	a, 0x500d
      0081CF AA 60            [ 1]  412 	or	a, #0x60
      0081D1 C7 50 0D         [ 1]  413 	ld	0x500d, a
                                    414 ;	main.c: 145: PC_DDR &= (uint8_t)~(1<<MISO_BIT);
      0081D4 72 1F 50 0C      [ 1]  415 	bres	0x500c, #7
                                    416 ;	main.c: 146: PC_CR1 &= (uint8_t)~(1<<MISO_BIT);
      0081D8 72 1F 50 0D      [ 1]  417 	bres	0x500d, #7
                                    418 ;	main.c: 148: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
      0081DC 72 14 50 11      [ 1]  419 	bset	0x5011, #2
      0081E0 72 14 50 12      [ 1]  420 	bset	0x5012, #2
      0081E4 72 14 50 0F      [ 1]  421 	bset	0x500f, #2
                                    422 ;	main.c: 150: PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
      0081E8 72 19 50 11      [ 1]  423 	bres	0x5011, #4
      0081EC 72 19 50 12      [ 1]  424 	bres	0x5012, #4
                                    425 ;	main.c: 152: PD_DDR &= (uint8_t)~(1<<3);
      0081F0 72 17 50 11      [ 1]  426 	bres	0x5011, #3
                                    427 ;	main.c: 153: PD_CR1 |= (1<<3);
      0081F4 72 16 50 12      [ 1]  428 	bset	0x5012, #3
                                    429 ;	main.c: 154: }
      0081F8 81               [ 4]  430 	ret
                                    431 ;	main.c: 157: static void spi_init(void){
                                    432 ;	-----------------------------------------
                                    433 ;	 function spi_init
                                    434 ;	-----------------------------------------
      0081F9                        435 _spi_init:
                                    436 ;	main.c: 159: SPI_CR1 = (1<<SPI_CR1_MSTR) | (1<<SPI_CR1_BR2) | (1<<SPI_CR1_BR1) | (1<<SPI_CR1_BR0);
      0081F9 35 3C 52 00      [ 1]  437 	mov	0x5200+0, #0x3c
                                    438 ;	main.c: 160: SPI_CR2 = (1<<SPI_CR2_SSM) | (1<<SPI_CR2_SSI);
      0081FD 35 03 52 01      [ 1]  439 	mov	0x5201+0, #0x03
                                    440 ;	main.c: 161: SPI_CR1 |= (1<<SPI_CR1_SPE);
      008201 72 1C 52 00      [ 1]  441 	bset	0x5200, #6
                                    442 ;	main.c: 162: }
      008205 81               [ 4]  443 	ret
                                    444 ;	main.c: 163: static uint8_t spi_txrx(uint8_t v){
                                    445 ;	-----------------------------------------
                                    446 ;	 function spi_txrx
                                    447 ;	-----------------------------------------
      008206                        448 _spi_txrx:
                                    449 ;	main.c: 164: SPI_DR = v;
      008206 C7 52 04         [ 1]  450 	ld	0x5204, a
                                    451 ;	main.c: 165: while(!(SPI_SR & (1<<SPI_SR_TXE)));
      008209                        452 00101$:
      008209 72 03 52 03 FB   [ 2]  453 	btjf	0x5203, #1, 00101$
                                    454 ;	main.c: 166: while(!(SPI_SR & (1<<SPI_SR_RXNE)));
      00820E                        455 00104$:
      00820E 72 01 52 03 FB   [ 2]  456 	btjf	0x5203, #0, 00104$
                                    457 ;	main.c: 167: return SPI_DR;
      008213 C6 52 04         [ 1]  458 	ld	a, 0x5204
                                    459 ;	main.c: 168: }
      008216 81               [ 4]  460 	ret
                                    461 ;	main.c: 169: static void spi_wait_idle(void){ while(SPI_SR & (1<<SPI_SR_BSY)); }
                                    462 ;	-----------------------------------------
                                    463 ;	 function spi_wait_idle
                                    464 ;	-----------------------------------------
      008217                        465 _spi_wait_idle:
      008217                        466 00101$:
      008217 C6 52 03         [ 1]  467 	ld	a, 0x5203
      00821A 2B FB            [ 1]  468 	jrmi	00101$
      00821C 81               [ 4]  469 	ret
                                    470 ;	main.c: 189: static uint8_t cc_select(void){
                                    471 ;	-----------------------------------------
                                    472 ;	 function cc_select
                                    473 ;	-----------------------------------------
      00821D                        474 _cc_select:
      00821D 52 04            [ 2]  475 	sub	sp, #4
                                    476 ;	main.c: 190: CSN_LOW();
      00821F 72 15 50 0F      [ 1]  477 	bres	0x500f, #2
                                    478 ;	main.c: 193: while(MISO_IS_HIGH()){
      008223 5F               [ 1]  479 	clrw	x
      008224 1F 03            [ 2]  480 	ldw	(0x03, sp), x
      008226 1F 01            [ 2]  481 	ldw	(0x01, sp), x
      008228                        482 00103$:
      008228 C6 50 0B         [ 1]  483 	ld	a, 0x500b
      00822B 2A 20            [ 1]  484 	jrpl	00105$
                                    485 ;	main.c: 194: if(++guard>100000UL){ CSN_HIGH(); return 0; }
      00822D 1E 03            [ 2]  486 	ldw	x, (0x03, sp)
      00822F 5C               [ 1]  487 	incw	x
      008230 1F 03            [ 2]  488 	ldw	(0x03, sp), x
      008232 26 05            [ 1]  489 	jrne	00124$
      008234 1E 01            [ 2]  490 	ldw	x, (0x01, sp)
      008236 5C               [ 1]  491 	incw	x
      008237 1F 01            [ 2]  492 	ldw	(0x01, sp), x
      008239                        493 00124$:
      008239 AE 86 A0         [ 2]  494 	ldw	x, #0x86a0
      00823C 13 03            [ 2]  495 	cpw	x, (0x03, sp)
      00823E A6 01            [ 1]  496 	ld	a, #0x01
      008240 12 02            [ 1]  497 	sbc	a, (0x02, sp)
      008242 4F               [ 1]  498 	clr	a
      008243 12 01            [ 1]  499 	sbc	a, (0x01, sp)
      008245 24 E1            [ 1]  500 	jrnc	00103$
      008247 72 14 50 0F      [ 1]  501 	bset	0x500f, #2
      00824B 4F               [ 1]  502 	clr	a
                                    503 ;	main.c: 196: return 1;
      00824C C5                     504 	.byte 0xc5
      00824D                        505 00105$:
      00824D A6 01            [ 1]  506 	ld	a, #0x01
      00824F                        507 00106$:
                                    508 ;	main.c: 197: }
      00824F 5B 04            [ 2]  509 	addw	sp, #4
      008251 81               [ 4]  510 	ret
                                    511 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
                                    512 ;	-----------------------------------------
                                    513 ;	 function cc_deselect
                                    514 ;	-----------------------------------------
      008252                        515 _cc_deselect:
      008252 CD 82 17         [ 4]  516 	call	_spi_wait_idle
      008255 72 14 50 0F      [ 1]  517 	bset	0x500f, #2
      008259 81               [ 4]  518 	ret
                                    519 ;	main.c: 200: static uint8_t cc_strobe(uint8_t st){
                                    520 ;	-----------------------------------------
                                    521 ;	 function cc_strobe
                                    522 ;	-----------------------------------------
      00825A                        523 _cc_strobe:
      00825A 52 02            [ 2]  524 	sub	sp, #2
      00825C 6B 02            [ 1]  525 	ld	(0x02, sp), a
                                    526 ;	main.c: 201: if(!cc_select()) return 0xFF;
      00825E CD 82 1D         [ 4]  527 	call	_cc_select
      008261 4D               [ 1]  528 	tnz	a
      008262 26 04            [ 1]  529 	jrne	00102$
      008264 A6 FF            [ 1]  530 	ld	a, #0xff
      008266 20 10            [ 2]  531 	jra	00104$
      008268                        532 00102$:
                                    533 ;	main.c: 202: uint8_t s = spi_txrx(st);
      008268 7B 02            [ 1]  534 	ld	a, (0x02, sp)
      00826A CD 82 06         [ 4]  535 	call	_spi_txrx
      00826D 6B 01            [ 1]  536 	ld	(0x01, sp), a
                                    537 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      00826F CD 82 17         [ 4]  538 	call	_spi_wait_idle
      008272 72 14 50 0F      [ 1]  539 	bset	0x500f, #2
                                    540 ;	main.c: 204: return s;
      008276 7B 01            [ 1]  541 	ld	a, (0x01, sp)
      008278                        542 00104$:
                                    543 ;	main.c: 205: }
      008278 5B 02            [ 2]  544 	addw	sp, #2
      00827A 81               [ 4]  545 	ret
                                    546 ;	main.c: 206: static void cc_write_reg(uint8_t a, uint8_t v){
                                    547 ;	-----------------------------------------
                                    548 ;	 function cc_write_reg
                                    549 ;	-----------------------------------------
      00827B                        550 _cc_write_reg:
      00827B 88               [ 1]  551 	push	a
      00827C 6B 01            [ 1]  552 	ld	(0x01, sp), a
                                    553 ;	main.c: 207: if(!cc_select()) return;
      00827E CD 82 1D         [ 4]  554 	call	_cc_select
      008281 4D               [ 1]  555 	tnz	a
      008282 27 15            [ 1]  556 	jreq	00104$
                                    557 ;	main.c: 208: spi_txrx(a); spi_txrx(v);
      008284 7B 01            [ 1]  558 	ld	a, (0x01, sp)
      008286 CD 82 06         [ 4]  559 	call	_spi_txrx
      008289 7B 04            [ 1]  560 	ld	a, (0x04, sp)
      00828B CD 82 06         [ 4]  561 	call	_spi_txrx
                                    562 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      00828E CD 82 17         [ 4]  563 	call	_spi_wait_idle
      008291 C6 50 0F         [ 1]  564 	ld	a, 0x500f
      008294 AA 04            [ 1]  565 	or	a, #0x04
      008296 C7 50 0F         [ 1]  566 	ld	0x500f, a
                                    567 ;	main.c: 209: cc_deselect();
      008299                        568 00104$:
                                    569 ;	main.c: 210: }
      008299 84               [ 1]  570 	pop	a
      00829A 85               [ 2]  571 	popw	x
      00829B 84               [ 1]  572 	pop	a
      00829C FC               [ 2]  573 	jp	(x)
                                    574 ;	main.c: 211: static uint8_t cc_read_status(uint8_t addr){
                                    575 ;	-----------------------------------------
                                    576 ;	 function cc_read_status
                                    577 ;	-----------------------------------------
      00829D                        578 _cc_read_status:
      00829D 52 02            [ 2]  579 	sub	sp, #2
      00829F 6B 02            [ 1]  580 	ld	(0x02, sp), a
                                    581 ;	main.c: 212: if(!cc_select()) return 0xFF;
      0082A1 CD 82 1D         [ 4]  582 	call	_cc_select
      0082A4 4D               [ 1]  583 	tnz	a
      0082A5 26 04            [ 1]  584 	jrne	00102$
      0082A7 A6 FF            [ 1]  585 	ld	a, #0xff
      0082A9 20 17            [ 2]  586 	jra	00104$
      0082AB                        587 00102$:
                                    588 ;	main.c: 213: (void)spi_txrx(addr | 0xC0);   // READ | BURST pour status regs
      0082AB 7B 02            [ 1]  589 	ld	a, (0x02, sp)
      0082AD AA C0            [ 1]  590 	or	a, #0xc0
      0082AF CD 82 06         [ 4]  591 	call	_spi_txrx
                                    592 ;	main.c: 214: uint8_t v = spi_txrx(0xFF);
      0082B2 A6 FF            [ 1]  593 	ld	a, #0xff
      0082B4 CD 82 06         [ 4]  594 	call	_spi_txrx
      0082B7 6B 01            [ 1]  595 	ld	(0x01, sp), a
                                    596 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0082B9 CD 82 17         [ 4]  597 	call	_spi_wait_idle
      0082BC 72 14 50 0F      [ 1]  598 	bset	0x500f, #2
                                    599 ;	main.c: 216: return v;
      0082C0 7B 01            [ 1]  600 	ld	a, (0x01, sp)
      0082C2                        601 00104$:
                                    602 ;	main.c: 217: }
      0082C2 5B 02            [ 2]  603 	addw	sp, #2
      0082C4 81               [ 4]  604 	ret
                                    605 ;	main.c: 220: static void cc_reset(void){
                                    606 ;	-----------------------------------------
                                    607 ;	 function cc_reset
                                    608 ;	-----------------------------------------
      0082C5                        609 _cc_reset:
                                    610 ;	main.c: 221: CSN_HIGH(); delay_ms(5);
      0082C5 72 14 50 0F      [ 1]  611 	bset	0x500f, #2
                                    612 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082C9 90 5F            [ 1]  613 	clrw	y
      0082CB 5F               [ 1]  614 	clrw	x
      0082CC                        615 00113$:
      0082CC 90 A3 11 58      [ 2]  616 	cpw	y, #0x1158
      0082D0 9F               [ 1]  617 	ld	a, xl
      0082D1 A2 00            [ 1]  618 	sbc	a, #0x00
      0082D3 9E               [ 1]  619 	ld	a, xh
      0082D4 A2 00            [ 1]  620 	sbc	a, #0x00
      0082D6 24 08            [ 1]  621 	jrnc	00104$
                                    622 ;	main.c: 53: __asm__("nop");
      0082D8 9D               [ 1]  623 	nop
                                    624 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082D9 90 5C            [ 1]  625 	incw	y
      0082DB 26 EF            [ 1]  626 	jrne	00113$
      0082DD 5C               [ 1]  627 	incw	x
      0082DE 20 EC            [ 2]  628 	jra	00113$
                                    629 ;	main.c: 221: CSN_HIGH(); delay_ms(5);
      0082E0                        630 00104$:
                                    631 ;	main.c: 222: CSN_LOW();  delay_ms(5);
      0082E0 72 15 50 0F      [ 1]  632 	bres	0x500f, #2
                                    633 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082E4 90 5F            [ 1]  634 	clrw	y
      0082E6 5F               [ 1]  635 	clrw	x
      0082E7                        636 00116$:
      0082E7 90 A3 11 58      [ 2]  637 	cpw	y, #0x1158
      0082EB 9F               [ 1]  638 	ld	a, xl
      0082EC A2 00            [ 1]  639 	sbc	a, #0x00
      0082EE 9E               [ 1]  640 	ld	a, xh
      0082EF A2 00            [ 1]  641 	sbc	a, #0x00
      0082F1 24 08            [ 1]  642 	jrnc	00106$
                                    643 ;	main.c: 53: __asm__("nop");
      0082F3 9D               [ 1]  644 	nop
                                    645 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082F4 90 5C            [ 1]  646 	incw	y
      0082F6 26 EF            [ 1]  647 	jrne	00116$
      0082F8 5C               [ 1]  648 	incw	x
      0082F9 20 EC            [ 2]  649 	jra	00116$
                                    650 ;	main.c: 222: CSN_LOW();  delay_ms(5);
      0082FB                        651 00106$:
                                    652 ;	main.c: 223: CSN_HIGH(); delay_ms(5);
      0082FB 72 14 50 0F      [ 1]  653 	bset	0x500f, #2
                                    654 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082FF 90 5F            [ 1]  655 	clrw	y
      008301 5F               [ 1]  656 	clrw	x
      008302                        657 00119$:
      008302 90 A3 11 58      [ 2]  658 	cpw	y, #0x1158
      008306 9F               [ 1]  659 	ld	a, xl
      008307 A2 00            [ 1]  660 	sbc	a, #0x00
      008309 9E               [ 1]  661 	ld	a, xh
      00830A A2 00            [ 1]  662 	sbc	a, #0x00
      00830C 24 08            [ 1]  663 	jrnc	00108$
                                    664 ;	main.c: 53: __asm__("nop");
      00830E 9D               [ 1]  665 	nop
                                    666 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00830F 90 5C            [ 1]  667 	incw	y
      008311 26 EF            [ 1]  668 	jrne	00119$
      008313 5C               [ 1]  669 	incw	x
      008314 20 EC            [ 2]  670 	jra	00119$
                                    671 ;	main.c: 223: CSN_HIGH(); delay_ms(5);
      008316                        672 00108$:
                                    673 ;	main.c: 224: if(cc_select()){ spi_txrx(SRES); cc_deselect(); }
      008316 CD 82 1D         [ 4]  674 	call	_cc_select
      008319 4D               [ 1]  675 	tnz	a
      00831A 27 0C            [ 1]  676 	jreq	00134$
      00831C A6 30            [ 1]  677 	ld	a, #0x30
      00831E CD 82 06         [ 4]  678 	call	_spi_txrx
                                    679 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      008321 CD 82 17         [ 4]  680 	call	_spi_wait_idle
      008324 72 14 50 0F      [ 1]  681 	bset	0x500f, #2
                                    682 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008328                        683 00134$:
      008328 90 5F            [ 1]  684 	clrw	y
      00832A 5F               [ 1]  685 	clrw	x
      00832B                        686 00122$:
      00832B 90 A3 11 58      [ 2]  687 	cpw	y, #0x1158
      00832F 9F               [ 1]  688 	ld	a, xl
      008330 A2 00            [ 1]  689 	sbc	a, #0x00
      008332 9E               [ 1]  690 	ld	a, xh
      008333 A2 00            [ 1]  691 	sbc	a, #0x00
      008335 25 01            [ 1]  692 	jrc	00182$
      008337 81               [ 4]  693 	ret
      008338                        694 00182$:
                                    695 ;	main.c: 53: __asm__("nop");
      008338 9D               [ 1]  696 	nop
                                    697 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008339 90 5C            [ 1]  698 	incw	y
      00833B 26 EE            [ 1]  699 	jrne	00122$
      00833D 5C               [ 1]  700 	incw	x
      00833E 20 EB            [ 2]  701 	jra	00122$
                                    702 ;	main.c: 225: delay_ms(5);
                                    703 ;	main.c: 226: }
      008340 81               [ 4]  704 	ret
                                    705 ;	main.c: 228: static void cc_write_patble(uint8_t pa){
                                    706 ;	-----------------------------------------
                                    707 ;	 function cc_write_patble
                                    708 ;	-----------------------------------------
      008341                        709 _cc_write_patble:
      008341 88               [ 1]  710 	push	a
      008342 6B 01            [ 1]  711 	ld	(0x01, sp), a
                                    712 ;	main.c: 229: if(!cc_select()) return;
      008344 CD 82 1D         [ 4]  713 	call	_cc_select
      008347 4D               [ 1]  714 	tnz	a
      008348 27 1B            [ 1]  715 	jreq	00108$
                                    716 ;	main.c: 230: spi_txrx(PATABLE | CC_BURST);
      00834A A6 7E            [ 1]  717 	ld	a, #0x7e
      00834C CD 82 06         [ 4]  718 	call	_spi_txrx
                                    719 ;	main.c: 231: for(uint8_t i=0;i<8;i++) spi_txrx(pa);
      00834F 4F               [ 1]  720 	clr	a
      008350                        721 00106$:
      008350 A1 08            [ 1]  722 	cp	a, #0x08
      008352 24 0A            [ 1]  723 	jrnc	00103$
      008354 88               [ 1]  724 	push	a
      008355 7B 02            [ 1]  725 	ld	a, (0x02, sp)
      008357 CD 82 06         [ 4]  726 	call	_spi_txrx
      00835A 84               [ 1]  727 	pop	a
      00835B 4C               [ 1]  728 	inc	a
      00835C 20 F2            [ 2]  729 	jra	00106$
      00835E                        730 00103$:
                                    731 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      00835E CD 82 17         [ 4]  732 	call	_spi_wait_idle
      008361 72 14 50 0F      [ 1]  733 	bset	0x500f, #2
                                    734 ;	main.c: 232: cc_deselect();
      008365                        735 00108$:
                                    736 ;	main.c: 233: }
      008365 84               [ 1]  737 	pop	a
      008366 81               [ 4]  738 	ret
                                    739 ;	main.c: 235: static void cc_config_868(void){
                                    740 ;	-----------------------------------------
                                    741 ;	 function cc_config_868
                                    742 ;	-----------------------------------------
      008367                        743 _cc_config_868:
                                    744 ;	main.c: 237: cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
      008367 4B 29            [ 1]  745 	push	#0x29
      008369 4F               [ 1]  746 	clr	a
      00836A CD 82 7B         [ 4]  747 	call	_cc_write_reg
      00836D 4B 06            [ 1]  748 	push	#0x06
      00836F A6 02            [ 1]  749 	ld	a, #0x02
      008371 CD 82 7B         [ 4]  750 	call	_cc_write_reg
      008374 4B 47            [ 1]  751 	push	#0x47
      008376 A6 03            [ 1]  752 	ld	a, #0x03
      008378 CD 82 7B         [ 4]  753 	call	_cc_write_reg
                                    754 ;	main.c: 238: cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
      00837B 4B 3D            [ 1]  755 	push	#0x3d
      00837D A6 06            [ 1]  756 	ld	a, #0x06
      00837F CD 82 7B         [ 4]  757 	call	_cc_write_reg
      008382 4B 04            [ 1]  758 	push	#0x04
      008384 A6 07            [ 1]  759 	ld	a, #0x07
      008386 CD 82 7B         [ 4]  760 	call	_cc_write_reg
      008389 4B 05            [ 1]  761 	push	#0x05
      00838B A6 08            [ 1]  762 	ld	a, #0x08
      00838D CD 82 7B         [ 4]  763 	call	_cc_write_reg
                                    764 ;	main.c: 239: cc_write_reg(0x0B,0x06);
      008390 4B 06            [ 1]  765 	push	#0x06
      008392 A6 0B            [ 1]  766 	ld	a, #0x0b
      008394 CD 82 7B         [ 4]  767 	call	_cc_write_reg
                                    768 ;	main.c: 240: cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
      008397 4B 21            [ 1]  769 	push	#0x21
      008399 A6 0D            [ 1]  770 	ld	a, #0x0d
      00839B CD 82 7B         [ 4]  771 	call	_cc_write_reg
      00839E 4B 65            [ 1]  772 	push	#0x65
      0083A0 A6 0E            [ 1]  773 	ld	a, #0x0e
      0083A2 CD 82 7B         [ 4]  774 	call	_cc_write_reg
      0083A5 4B 6A            [ 1]  775 	push	#0x6a
      0083A7 A6 0F            [ 1]  776 	ld	a, #0x0f
      0083A9 CD 82 7B         [ 4]  777 	call	_cc_write_reg
                                    778 ;	main.c: 241: cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
      0083AC 4B F5            [ 1]  779 	push	#0xf5
      0083AE A6 10            [ 1]  780 	ld	a, #0x10
      0083B0 CD 82 7B         [ 4]  781 	call	_cc_write_reg
      0083B3 4B 83            [ 1]  782 	push	#0x83
      0083B5 A6 11            [ 1]  783 	ld	a, #0x11
      0083B7 CD 82 7B         [ 4]  784 	call	_cc_write_reg
      0083BA 4B 13            [ 1]  785 	push	#0x13
      0083BC A6 12            [ 1]  786 	ld	a, #0x12
      0083BE CD 82 7B         [ 4]  787 	call	_cc_write_reg
                                    788 ;	main.c: 242: cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
      0083C1 4B 22            [ 1]  789 	push	#0x22
      0083C3 A6 13            [ 1]  790 	ld	a, #0x13
      0083C5 CD 82 7B         [ 4]  791 	call	_cc_write_reg
      0083C8 4B F8            [ 1]  792 	push	#0xf8
      0083CA A6 14            [ 1]  793 	ld	a, #0x14
      0083CC CD 82 7B         [ 4]  794 	call	_cc_write_reg
                                    795 ;	main.c: 243: cc_write_reg(0x15,0x15);
      0083CF 4B 15            [ 1]  796 	push	#0x15
      0083D1 A6 15            [ 1]  797 	ld	a, #0x15
      0083D3 CD 82 7B         [ 4]  798 	call	_cc_write_reg
                                    799 ;	main.c: 244: cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
      0083D6 4B 18            [ 1]  800 	push	#0x18
      0083D8 A6 18            [ 1]  801 	ld	a, #0x18
      0083DA CD 82 7B         [ 4]  802 	call	_cc_write_reg
      0083DD 4B 16            [ 1]  803 	push	#0x16
      0083DF A6 19            [ 1]  804 	ld	a, #0x19
      0083E1 CD 82 7B         [ 4]  805 	call	_cc_write_reg
                                    806 ;	main.c: 245: cc_write_reg(0x1B,0x43);
      0083E4 4B 43            [ 1]  807 	push	#0x43
      0083E6 A6 1B            [ 1]  808 	ld	a, #0x1b
      0083E8 CD 82 7B         [ 4]  809 	call	_cc_write_reg
                                    810 ;	main.c: 246: cc_write_reg(0x22,0x11);
      0083EB 4B 11            [ 1]  811 	push	#0x11
      0083ED A6 22            [ 1]  812 	ld	a, #0x22
      0083EF CD 82 7B         [ 4]  813 	call	_cc_write_reg
                                    814 ;	main.c: 247: cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
      0083F2 4B E9            [ 1]  815 	push	#0xe9
      0083F4 A6 23            [ 1]  816 	ld	a, #0x23
      0083F6 CD 82 7B         [ 4]  817 	call	_cc_write_reg
      0083F9 4B 2A            [ 1]  818 	push	#0x2a
      0083FB A6 24            [ 1]  819 	ld	a, #0x24
      0083FD CD 82 7B         [ 4]  820 	call	_cc_write_reg
      008400 4B 00            [ 1]  821 	push	#0x00
      008402 A6 25            [ 1]  822 	ld	a, #0x25
      008404 CD 82 7B         [ 4]  823 	call	_cc_write_reg
      008407 4B 1F            [ 1]  824 	push	#0x1f
      008409 A6 26            [ 1]  825 	ld	a, #0x26
      00840B CD 82 7B         [ 4]  826 	call	_cc_write_reg
                                    827 ;	main.c: 248: cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
      00840E 4B 81            [ 1]  828 	push	#0x81
      008410 A6 2C            [ 1]  829 	ld	a, #0x2c
      008412 CD 82 7B         [ 4]  830 	call	_cc_write_reg
      008415 4B 35            [ 1]  831 	push	#0x35
      008417 A6 2D            [ 1]  832 	ld	a, #0x2d
      008419 CD 82 7B         [ 4]  833 	call	_cc_write_reg
      00841C 4B 09            [ 1]  834 	push	#0x09
      00841E A6 2E            [ 1]  835 	ld	a, #0x2e
      008420 CD 82 7B         [ 4]  836 	call	_cc_write_reg
                                    837 ;	main.c: 249: cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
      008423 A6 36            [ 1]  838 	ld	a, #0x36
      008425 CD 82 5A         [ 4]  839 	call	_cc_strobe
      008428 A6 3A            [ 1]  840 	ld	a, #0x3a
      00842A CD 82 5A         [ 4]  841 	call	_cc_strobe
      00842D A6 3B            [ 1]  842 	ld	a, #0x3b
      00842F CD 82 5A         [ 4]  843 	call	_cc_strobe
                                    844 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008432 90 5F            [ 1]  845 	clrw	y
      008434 5F               [ 1]  846 	clrw	x
      008435                        847 00104$:
      008435 90 A3 06 F0      [ 2]  848 	cpw	y, #0x06f0
      008439 9F               [ 1]  849 	ld	a, xl
      00843A A2 00            [ 1]  850 	sbc	a, #0x00
      00843C 9E               [ 1]  851 	ld	a, xh
      00843D A2 00            [ 1]  852 	sbc	a, #0x00
      00843F 24 08            [ 1]  853 	jrnc	00102$
                                    854 ;	main.c: 53: __asm__("nop");
      008441 9D               [ 1]  855 	nop
                                    856 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008442 90 5C            [ 1]  857 	incw	y
      008444 26 EF            [ 1]  858 	jrne	00104$
      008446 5C               [ 1]  859 	incw	x
      008447 20 EC            [ 2]  860 	jra	00104$
                                    861 ;	main.c: 250: delay_ms(2);
      008449                        862 00102$:
                                    863 ;	main.c: 252: cc_write_patble(0xC0);      // mets 0x84 pour tester “0 dBm”, 0xC8 si tu veux un cran de plus
      008449 A6 C0            [ 1]  864 	ld	a, #0xc0
                                    865 ;	main.c: 253: }
      00844B CC 83 41         [ 2]  866 	jp	_cc_write_patble
                                    867 ;	main.c: 256: static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
                                    868 ;	-----------------------------------------
                                    869 ;	 function cc_send_packet
                                    870 ;	-----------------------------------------
      00844E                        871 _cc_send_packet:
      00844E 52 07            [ 2]  872 	sub	sp, #7
      008450 1F 02            [ 2]  873 	ldw	(0x02, sp), x
                                    874 ;	main.c: 257: if(len==0 || len>61) return 0;
      008452 6B 01            [ 1]  875 	ld	(0x01, sp), a
      008454 27 06            [ 1]  876 	jreq	00101$
      008456 7B 01            [ 1]  877 	ld	a, (0x01, sp)
      008458 A1 3D            [ 1]  878 	cp	a, #0x3d
      00845A 23 03            [ 2]  879 	jrule	00102$
      00845C                        880 00101$:
      00845C 4F               [ 1]  881 	clr	a
      00845D 20 61            [ 2]  882 	jra	00116$
      00845F                        883 00102$:
                                    884 ;	main.c: 258: cc_strobe(SIDLE); 
      00845F A6 36            [ 1]  885 	ld	a, #0x36
      008461 CD 82 5A         [ 4]  886 	call	_cc_strobe
                                    887 ;	main.c: 259: cc_strobe(SFTX);
      008464 A6 3B            [ 1]  888 	ld	a, #0x3b
      008466 CD 82 5A         [ 4]  889 	call	_cc_strobe
                                    890 ;	main.c: 261: if(!cc_select()) return 0;
      008469 CD 82 1D         [ 4]  891 	call	_cc_select
      00846C 4D               [ 1]  892 	tnz	a
      00846D 26 03            [ 1]  893 	jrne	00105$
      00846F 4F               [ 1]  894 	clr	a
      008470 20 4E            [ 2]  895 	jra	00116$
      008472                        896 00105$:
                                    897 ;	main.c: 262: spi_txrx(TXFIFO | CC_BURST);
      008472 A6 7F            [ 1]  898 	ld	a, #0x7f
      008474 CD 82 06         [ 4]  899 	call	_spi_txrx
                                    900 ;	main.c: 263: spi_txrx(len);
      008477 7B 01            [ 1]  901 	ld	a, (0x01, sp)
      008479 CD 82 06         [ 4]  902 	call	_spi_txrx
                                    903 ;	main.c: 264: for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
      00847C 0F 07            [ 1]  904 	clr	(0x07, sp)
      00847E                        905 00111$:
      00847E 7B 07            [ 1]  906 	ld	a, (0x07, sp)
      008480 11 01            [ 1]  907 	cp	a, (0x01, sp)
      008482 24 0F            [ 1]  908 	jrnc	00106$
      008484 5F               [ 1]  909 	clrw	x
      008485 7B 07            [ 1]  910 	ld	a, (0x07, sp)
      008487 97               [ 1]  911 	ld	xl, a
      008488 72 FB 02         [ 2]  912 	addw	x, (0x02, sp)
      00848B F6               [ 1]  913 	ld	a, (x)
      00848C CD 82 06         [ 4]  914 	call	_spi_txrx
      00848F 0C 07            [ 1]  915 	inc	(0x07, sp)
      008491 20 EB            [ 2]  916 	jra	00111$
      008493                        917 00106$:
                                    918 ;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      008493 CD 82 17         [ 4]  919 	call	_spi_wait_idle
      008496 72 14 50 0F      [ 1]  920 	bset	0x500f, #2
                                    921 ;	main.c: 267: cc_strobe(STX);
      00849A A6 35            [ 1]  922 	ld	a, #0x35
      00849C CD 82 5A         [ 4]  923 	call	_cc_strobe
                                    924 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00849F 90 5F            [ 1]  925 	clrw	y
      0084A1 5F               [ 1]  926 	clrw	x
      0084A2 1F 04            [ 2]  927 	ldw	(0x04, sp), x
      0084A4                        928 00114$:
      0084A4 90 A3 11 58      [ 2]  929 	cpw	y, #0x1158
      0084A8 7B 05            [ 1]  930 	ld	a, (0x05, sp)
      0084AA A2 00            [ 1]  931 	sbc	a, #0x00
      0084AC 7B 04            [ 1]  932 	ld	a, (0x04, sp)
      0084AE A2 00            [ 1]  933 	sbc	a, #0x00
      0084B0 24 0C            [ 1]  934 	jrnc	00109$
                                    935 ;	main.c: 53: __asm__("nop");
      0084B2 9D               [ 1]  936 	nop
                                    937 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0084B3 90 5C            [ 1]  938 	incw	y
      0084B5 26 ED            [ 1]  939 	jrne	00114$
      0084B7 1E 04            [ 2]  940 	ldw	x, (0x04, sp)
      0084B9 5C               [ 1]  941 	incw	x
      0084BA 1F 04            [ 2]  942 	ldw	(0x04, sp), x
      0084BC 20 E6            [ 2]  943 	jra	00114$
                                    944 ;	main.c: 270: delay_ms(5);
      0084BE                        945 00109$:
                                    946 ;	main.c: 271: return 1;
      0084BE A6 01            [ 1]  947 	ld	a, #0x01
      0084C0                        948 00116$:
                                    949 ;	main.c: 272: }
      0084C0 5B 07            [ 2]  950 	addw	sp, #7
      0084C2 81               [ 4]  951 	ret
                                    952 ;	main.c: 275: void cc_send_temp_x100(int16_t temp_x100) {
                                    953 ;	-----------------------------------------
                                    954 ;	 function cc_send_temp_x100
                                    955 ;	-----------------------------------------
      0084C3                        956 _cc_send_temp_x100:
      0084C3 52 08            [ 2]  957 	sub	sp, #8
                                    958 ;	main.c: 277: int16_t temp_x10 = temp_x100 / 10;
      0084C5 4B 0A            [ 1]  959 	push	#0x0a
      0084C7 4B 00            [ 1]  960 	push	#0x00
      0084C9 CD 87 28         [ 4]  961 	call	__divsint
      0084CC 1F 05            [ 2]  962 	ldw	(0x05, sp), x
                                    963 ;	main.c: 280: pkt[0] = NODE_ID;                        // Identifiant du capteur
      0084CE A6 01            [ 1]  964 	ld	a, #0x01
      0084D0 6B 01            [ 1]  965 	ld	(0x01, sp), a
                                    966 ;	main.c: 281: pkt[1] = (uint8_t)(temp_x10 >> 8);       // MSB
      0084D2 7B 05            [ 1]  967 	ld	a, (0x05, sp)
      0084D4 6B 07            [ 1]  968 	ld	(0x07, sp), a
      0084D6 6B 02            [ 1]  969 	ld	(0x02, sp), a
                                    970 ;	main.c: 282: pkt[2] = (uint8_t)(temp_x10 & 0xFF);     // LSB
      0084D8 7B 06            [ 1]  971 	ld	a, (0x06, sp)
      0084DA 6B 08            [ 1]  972 	ld	(0x08, sp), a
      0084DC 6B 03            [ 1]  973 	ld	(0x03, sp), a
                                    974 ;	main.c: 283: pkt[3] = pkt[0] ^ pkt[1] ^ pkt[2];       // Checksum XOR
      0084DE 7B 01            [ 1]  975 	ld	a, (0x01, sp)
      0084E0 18 07            [ 1]  976 	xor	a, (0x07, sp)
      0084E2 18 08            [ 1]  977 	xor	a, (0x08, sp)
      0084E4 6B 04            [ 1]  978 	ld	(0x04, sp), a
                                    979 ;	main.c: 285: uint8_t ok = cc_send_packet(pkt, sizeof(pkt));
      0084E6 A6 04            [ 1]  980 	ld	a, #0x04
      0084E8 96               [ 1]  981 	ldw	x, sp
      0084E9 5C               [ 1]  982 	incw	x
      0084EA CD 84 4E         [ 4]  983 	call	_cc_send_packet
                                    984 ;	main.c: 289: ok ? "OK" : "FAIL");
      0084ED 4D               [ 1]  985 	tnz	a
      0084EE 27 04            [ 1]  986 	jreq	00103$
      0084F0 AE 80 44         [ 2]  987 	ldw	x, #___str_1+0
      0084F3 BC                     988 	.byte 0xbc
      0084F4                        989 00103$:
      0084F4 AE 80 47         [ 2]  990 	ldw	x, #(___str_2+0)
      0084F7                        991 00104$:
      0084F7 1F 07            [ 2]  992 	ldw	(0x07, sp), x
                                    993 ;	main.c: 288: temp_x10/10, temp_x10%10,
      0084F9 1E 05            [ 2]  994 	ldw	x, (0x05, sp)
      0084FB 89               [ 2]  995 	pushw	x
      0084FC 4B 0A            [ 1]  996 	push	#0x0a
      0084FE 4B 00            [ 1]  997 	push	#0x00
      008500 CD 86 94         [ 4]  998 	call	__modsint
      008503 1F 07            [ 2]  999 	ldw	(0x07, sp), x
      008505 85               [ 2] 1000 	popw	x
      008506 4B 0A            [ 1] 1001 	push	#0x0a
      008508 4B 00            [ 1] 1002 	push	#0x00
                                   1003 ;	main.c: 287: printf("[RADIO] send %d.%01d°C -> %s\r\n",
      00850A CD 87 28         [ 4] 1004 	call	__divsint
      00850D 16 07            [ 2] 1005 	ldw	y, (0x07, sp)
      00850F 90 89            [ 2] 1006 	pushw	y
      008511 16 07            [ 2] 1007 	ldw	y, (0x07, sp)
      008513 90 89            [ 2] 1008 	pushw	y
      008515 89               [ 2] 1009 	pushw	x
      008516 4B 24            [ 1] 1010 	push	#<(___str_0+0)
      008518 4B 80            [ 1] 1011 	push	#((___str_0+0) >> 8)
      00851A CD 86 83         [ 4] 1012 	call	_printf
                                   1013 ;	main.c: 290: }
      00851D 5B 10            [ 2] 1014 	addw	sp, #16
      00851F 81               [ 4] 1015 	ret
                                   1016 ;	main.c: 292: void main() {
                                   1017 ;	-----------------------------------------
                                   1018 ;	 function main
                                   1019 ;	-----------------------------------------
      008520                       1020 _main:
      008520 52 06            [ 2] 1021 	sub	sp, #6
                                   1022 ;	main.c: 294: CLK_CKDIVR = 0x00; // forcer la frequence CPU
      008522 35 00 50 C6      [ 1] 1023 	mov	0x50c6+0, #0x00
                                   1024 ;	main.c: 297: PD_DDR &= ~(1 << 3);    // PD3 en entrée
      008526 72 17 50 11      [ 1] 1025 	bres	0x5011, #3
                                   1026 ;	main.c: 298: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
      00852A 72 16 50 12      [ 1] 1027 	bset	0x5012, #3
                                   1028 ;	main.c: 300: uart_init();
      00852E CD 80 57         [ 4] 1029 	call	_uart_init
                                   1030 ;	main.c: 301: gpio_init();
      008531 CD 81 C4         [ 4] 1031 	call	_gpio_init
                                   1032 ;	main.c: 302: spi_init();
      008534 CD 81 F9         [ 4] 1033 	call	_spi_init
                                   1034 ;	main.c: 303: cc_reset();
      008537 CD 82 C5         [ 4] 1035 	call	_cc_reset
                                   1036 ;	main.c: 304: cc_config_868();
      00853A CD 83 67         [ 4] 1037 	call	_cc_config_868
                                   1038 ;	main.c: 309: while (1) {
      00853D 5F               [ 1] 1039 	clrw	x
      00853E 1F 01            [ 2] 1040 	ldw	(0x01, sp), x
      008540                       1041 00104$:
                                   1042 ;	main.c: 310: ds18b20_start_conversion(); // Démarre une conversion de température
      008540 CD 81 92         [ 4] 1043 	call	_ds18b20_start_conversion
                                   1044 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008543 90 5F            [ 1] 1045 	clrw	y
      008545 5F               [ 1] 1046 	clrw	x
      008546 1F 03            [ 2] 1047 	ldw	(0x03, sp), x
      008548                       1048 00111$:
      008548 90 A3 29 90      [ 2] 1049 	cpw	y, #0x2990
      00854C 7B 04            [ 1] 1050 	ld	a, (0x04, sp)
      00854E A2 0A            [ 1] 1051 	sbc	a, #0x0a
      008550 7B 03            [ 1] 1052 	ld	a, (0x03, sp)
      008552 A2 00            [ 1] 1053 	sbc	a, #0x00
      008554 24 0C            [ 1] 1054 	jrnc	00107$
                                   1055 ;	main.c: 53: __asm__("nop");
      008556 9D               [ 1] 1056 	nop
                                   1057 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008557 90 5C            [ 1] 1058 	incw	y
      008559 26 ED            [ 1] 1059 	jrne	00111$
      00855B 1E 03            [ 2] 1060 	ldw	x, (0x03, sp)
      00855D 5C               [ 1] 1061 	incw	x
      00855E 1F 03            [ 2] 1062 	ldw	(0x03, sp), x
      008560 20 E6            [ 2] 1063 	jra	00111$
                                   1064 ;	main.c: 311: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
      008562                       1065 00107$:
                                   1066 ;	main.c: 313: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
      008562 CD 81 9F         [ 4] 1067 	call	_ds18b20_read_raw
                                   1068 ;	main.c: 316: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
      008565 90 5F            [ 1] 1069 	clrw	y
      008567 5D               [ 2] 1070 	tnzw	x
      008568 2A 02            [ 1] 1071 	jrpl	00151$
      00856A 90 5A            [ 2] 1072 	decw	y
      00856C                       1073 00151$:
      00856C 89               [ 2] 1074 	pushw	x
      00856D 90 89            [ 2] 1075 	pushw	y
      00856F 4B 71            [ 1] 1076 	push	#0x71
      008571 4B 02            [ 1] 1077 	push	#0x02
      008573 5F               [ 1] 1078 	clrw	x
      008574 89               [ 2] 1079 	pushw	x
      008575 CD 86 AC         [ 4] 1080 	call	__mullong
      008578 5B 08            [ 2] 1081 	addw	sp, #8
      00857A 4B 64            [ 1] 1082 	push	#0x64
      00857C 4B 00            [ 1] 1083 	push	#0x00
      00857E 4B 00            [ 1] 1084 	push	#0x00
      008580 4B 00            [ 1] 1085 	push	#0x00
      008582 89               [ 2] 1086 	pushw	x
      008583 90 89            [ 2] 1087 	pushw	y
      008585 CD 86 12         [ 4] 1088 	call	__divulong
      008588 5B 08            [ 2] 1089 	addw	sp, #8
      00858A 1F 05            [ 2] 1090 	ldw	(0x05, sp), x
                                   1091 ;	main.c: 320: if (counter % 120 == 0) {
      00858C 1E 01            [ 2] 1092 	ldw	x, (0x01, sp)
      00858E 90 AE 00 78      [ 2] 1093 	ldw	y, #0x0078
      008592 65               [ 2] 1094 	divw	x, y
      008593 90 5D            [ 2] 1095 	tnzw	y
      008595 26 05            [ 1] 1096 	jrne	00102$
                                   1097 ;	main.c: 321: cc_send_temp_x100(temp_x100);
      008597 1E 05            [ 2] 1098 	ldw	x, (0x05, sp)
      008599 CD 84 C3         [ 4] 1099 	call	_cc_send_temp_x100
      00859C                       1100 00102$:
                                   1101 ;	main.c: 324: counter++;
      00859C 1E 01            [ 2] 1102 	ldw	x, (0x01, sp)
      00859E 5C               [ 1] 1103 	incw	x
      00859F 1F 01            [ 2] 1104 	ldw	(0x01, sp), x
                                   1105 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0085A1 90 5F            [ 1] 1106 	clrw	y
      0085A3 5F               [ 1] 1107 	clrw	x
      0085A4                       1108 00114$:
      0085A4 90 A3 8C C0      [ 2] 1109 	cpw	y, #0x8cc0
      0085A8 9F               [ 1] 1110 	ld	a, xl
      0085A9 A2 0D            [ 1] 1111 	sbc	a, #0x0d
      0085AB 9E               [ 1] 1112 	ld	a, xh
      0085AC A2 00            [ 1] 1113 	sbc	a, #0x00
      0085AE 24 90            [ 1] 1114 	jrnc	00104$
                                   1115 ;	main.c: 53: __asm__("nop");
      0085B0 9D               [ 1] 1116 	nop
                                   1117 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0085B1 90 5C            [ 1] 1118 	incw	y
      0085B3 26 EF            [ 1] 1119 	jrne	00114$
      0085B5 5C               [ 1] 1120 	incw	x
      0085B6 20 EC            [ 2] 1121 	jra	00114$
                                   1122 ;	main.c: 328: delay_ms(NODE_ID * 1000UL);
                                   1123 ;	main.c: 330: }
      0085B8 5B 06            [ 2] 1124 	addw	sp, #6
      0085BA 81               [ 4] 1125 	ret
                                   1126 	.area CODE
                                   1127 	.area CONST
                                   1128 	.area CONST
      008024                       1129 ___str_0:
      008024 5B 52 41 44 49 4F 5D  1130 	.ascii "[RADIO] send %d.%01d"
             20 73 65 6E 64 20 25
             64 2E 25 30 31 64
      008038 C2                    1131 	.db 0xc2
      008039 B0                    1132 	.db 0xb0
      00803A 43 20 2D 3E 20 25 73  1133 	.ascii "C -> %s"
      008041 0D                    1134 	.db 0x0d
      008042 0A                    1135 	.db 0x0a
      008043 00                    1136 	.db 0x00
                                   1137 	.area CODE
                                   1138 	.area CONST
      008044                       1139 ___str_1:
      008044 4F 4B                 1140 	.ascii "OK"
      008046 00                    1141 	.db 0x00
                                   1142 	.area CODE
                                   1143 	.area CONST
      008047                       1144 ___str_2:
      008047 46 41 49 4C           1145 	.ascii "FAIL"
      00804B 00                    1146 	.db 0x00
                                   1147 	.area CODE
                                   1148 	.area INITIALIZER
                                   1149 	.area CABS (ABS)
