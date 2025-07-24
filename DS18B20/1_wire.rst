                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module 1_wire
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _ds18b20_read_raw
                                     13 	.globl _ds18b20_start_conversion
                                     14 	.globl _onewire_read_byte
                                     15 	.globl _onewire_write_byte
                                     16 	.globl _onewire_read_bit
                                     17 	.globl _onewire_write_bit
                                     18 	.globl _onewire_reset
                                     19 	.globl _delay_us
                                     20 	.globl _uart_read
                                     21 	.globl _uart_write
                                     22 	.globl _uart_config
                                     23 	.globl _printf
                                     24 	.globl _putchar
                                     25 ;--------------------------------------------------------
                                     26 ; ram data
                                     27 ;--------------------------------------------------------
                                     28 	.area DATA
                                     29 ;--------------------------------------------------------
                                     30 ; ram data
                                     31 ;--------------------------------------------------------
                                     32 	.area INITIALIZED
                                     33 ;--------------------------------------------------------
                                     34 ; Stack segment in internal ram
                                     35 ;--------------------------------------------------------
                                     36 	.area	SSEG
      000001                         37 __start__stack:
      000001                         38 	.ds	1
                                     39 
                                     40 ;--------------------------------------------------------
                                     41 ; absolute external ram data
                                     42 ;--------------------------------------------------------
                                     43 	.area DABS (ABS)
                                     44 
                                     45 ; default segment ordering for linker
                                     46 	.area HOME
                                     47 	.area GSINIT
                                     48 	.area GSFINAL
                                     49 	.area CONST
                                     50 	.area INITIALIZER
                                     51 	.area CODE
                                     52 
                                     53 ;--------------------------------------------------------
                                     54 ; interrupt vector
                                     55 ;--------------------------------------------------------
                                     56 	.area HOME
      008000                         57 __interrupt_vect:
      008000 82 00 80 07             58 	int s_GSINIT ; reset
                                     59 ;--------------------------------------------------------
                                     60 ; global & static initialisations
                                     61 ;--------------------------------------------------------
                                     62 	.area HOME
                                     63 	.area GSINIT
                                     64 	.area GSFINAL
                                     65 	.area GSINIT
      008007                         66 __sdcc_init_data:
                                     67 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   68 	ldw x, #l_DATA
      00800A 27 07            [ 1]   69 	jreq	00002$
      00800C                         70 00001$:
      00800C 72 4F 00 00      [ 1]   71 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   72 	decw x
      008011 26 F9            [ 1]   73 	jrne	00001$
      008013                         74 00002$:
      008013 AE 00 00         [ 2]   75 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   76 	jreq	00004$
      008018                         77 00003$:
      008018 D6 80 4B         [ 1]   78 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   79 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   80 	decw	x
      00801F 26 F7            [ 1]   81 	jrne	00003$
      008021                         82 00004$:
                                     83 ; stm8_genXINIT() end
                                     84 	.area GSFINAL
      008021 CC 80 04         [ 2]   85 	jp	__sdcc_program_startup
                                     86 ;--------------------------------------------------------
                                     87 ; Home
                                     88 ;--------------------------------------------------------
                                     89 	.area HOME
                                     90 	.area HOME
      008004                         91 __sdcc_program_startup:
      008004 CC 81 D5         [ 2]   92 	jp	_main
                                     93 ;	return from main will return to caller
                                     94 ;--------------------------------------------------------
                                     95 ; code
                                     96 ;--------------------------------------------------------
                                     97 	.area CODE
                                     98 ;	1_wire.c: 17: void uart_config() {
                                     99 ;	-----------------------------------------
                                    100 ;	 function uart_config
                                    101 ;	-----------------------------------------
      00804C                        102 _uart_config:
                                    103 ;	1_wire.c: 18: CLK_CKDIVR = 0x00; // Horloge non divisée (reste à 16 MHz)
      00804C 35 00 50 C6      [ 1]  104 	mov	0x50c6+0, #0x00
                                    105 ;	1_wire.c: 23: uint8_t brr1 = (usartdiv >> 4) & 0xFF;
      008050 A6 68            [ 1]  106 	ld	a, #0x68
      008052 97               [ 1]  107 	ld	xl, a
                                    108 ;	1_wire.c: 24: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);
      008053 A6 83            [ 1]  109 	ld	a, #0x83
      008055 A4 0F            [ 1]  110 	and	a, #0x0f
                                    111 ;	1_wire.c: 26: UART1_BRR1 = brr1;
      008057 90 AE 52 32      [ 2]  112 	ldw	y, #0x5232
      00805B 88               [ 1]  113 	push	a
      00805C 9F               [ 1]  114 	ld	a, xl
      00805D 90 F7            [ 1]  115 	ld	(y), a
      00805F 84               [ 1]  116 	pop	a
                                    117 ;	1_wire.c: 27: UART1_BRR2 = brr2;
      008060 C7 52 33         [ 1]  118 	ld	0x5233, a
                                    119 ;	1_wire.c: 29: UART1_CR1 = 0x00; // Pas de parité, 8 bits de données
      008063 35 00 52 34      [ 1]  120 	mov	0x5234+0, #0x00
                                    121 ;	1_wire.c: 30: UART1_CR3 = 0x00; // 1 bit de stop
      008067 35 00 52 36      [ 1]  122 	mov	0x5236+0, #0x00
                                    123 ;	1_wire.c: 31: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // Active TX et RX
      00806B 35 0C 52 35      [ 1]  124 	mov	0x5235+0, #0x0c
                                    125 ;	1_wire.c: 34: (void)UART1_SR;
      00806F C6 52 30         [ 1]  126 	ld	a, 0x5230
                                    127 ;	1_wire.c: 35: (void)UART1_DR;
      008072 C6 52 31         [ 1]  128 	ld	a, 0x5231
                                    129 ;	1_wire.c: 36: }
      008075 81               [ 4]  130 	ret
                                    131 ;	1_wire.c: 39: void uart_write(uint8_t data) {
                                    132 ;	-----------------------------------------
                                    133 ;	 function uart_write
                                    134 ;	-----------------------------------------
      008076                        135 _uart_write:
                                    136 ;	1_wire.c: 40: UART1_DR = data;                    // Envoie l'octet
      008076 C7 52 31         [ 1]  137 	ld	0x5231, a
                                    138 ;	1_wire.c: 41: PB_ODR &= ~(1 << 5);                // Éteint une LED (facultatif pour debug)
      008079 72 1B 50 05      [ 1]  139 	bres	0x5005, #5
                                    140 ;	1_wire.c: 42: while (!(UART1_SR & (1 << UART1_SR_TC))); // Attente que la transmission soit terminée
      00807D                        141 00101$:
      00807D 72 0D 52 30 FB   [ 2]  142 	btjf	0x5230, #6, 00101$
                                    143 ;	1_wire.c: 43: PB_ODR |= (1 << 5);                 // Allume la LED (facultatif)
      008082 72 1A 50 05      [ 1]  144 	bset	0x5005, #5
                                    145 ;	1_wire.c: 44: }
      008086 81               [ 4]  146 	ret
                                    147 ;	1_wire.c: 47: uint8_t uart_read() {
                                    148 ;	-----------------------------------------
                                    149 ;	 function uart_read
                                    150 ;	-----------------------------------------
      008087                        151 _uart_read:
                                    152 ;	1_wire.c: 48: while (!(UART1_SR & (1 << UART1_SR_RXNE))); // Attente réception
      008087                        153 00101$:
      008087 72 0B 52 30 FB   [ 2]  154 	btjf	0x5230, #5, 00101$
                                    155 ;	1_wire.c: 49: return UART1_DR;
      00808C C6 52 31         [ 1]  156 	ld	a, 0x5231
                                    157 ;	1_wire.c: 50: }
      00808F 81               [ 4]  158 	ret
                                    159 ;	1_wire.c: 53: int putchar(int c) {
                                    160 ;	-----------------------------------------
                                    161 ;	 function putchar
                                    162 ;	-----------------------------------------
      008090                        163 _putchar:
      008090 9F               [ 1]  164 	ld	a, xl
                                    165 ;	1_wire.c: 54: uart_write(c);
      008091 CD 80 76         [ 4]  166 	call	_uart_write
                                    167 ;	1_wire.c: 55: return 0;
      008094 5F               [ 1]  168 	clrw	x
                                    169 ;	1_wire.c: 56: }
      008095 81               [ 4]  170 	ret
                                    171 ;	1_wire.c: 60: void delay_us(uint16_t us) {
                                    172 ;	-----------------------------------------
                                    173 ;	 function delay_us
                                    174 ;	-----------------------------------------
      008096                        175 _delay_us:
                                    176 ;	1_wire.c: 61: while(us--) {
      008096                        177 00101$:
      008096 90 93            [ 1]  178 	ldw	y, x
      008098 5A               [ 2]  179 	decw	x
      008099 90 5D            [ 2]  180 	tnzw	y
      00809B 26 01            [ 1]  181 	jrne	00117$
      00809D 81               [ 4]  182 	ret
      00809E                        183 00117$:
                                    184 ;	1_wire.c: 62: __asm__("nop"); __asm__("nop"); __asm__("nop");
      00809E 9D               [ 1]  185 	nop
      00809F 9D               [ 1]  186 	nop
      0080A0 9D               [ 1]  187 	nop
                                    188 ;	1_wire.c: 63: __asm__("nop"); __asm__("nop"); __asm__("nop");
      0080A1 9D               [ 1]  189 	nop
      0080A2 9D               [ 1]  190 	nop
      0080A3 9D               [ 1]  191 	nop
      0080A4 20 F0            [ 2]  192 	jra	00101$
                                    193 ;	1_wire.c: 65: }
      0080A6 81               [ 4]  194 	ret
                                    195 ;	1_wire.c: 68: static inline void delay_ms(uint16_t ms) {
                                    196 ;	-----------------------------------------
                                    197 ;	 function delay_ms
                                    198 ;	-----------------------------------------
      0080A7                        199 _delay_ms:
      0080A7 52 0A            [ 2]  200 	sub	sp, #10
      0080A9 1F 05            [ 2]  201 	ldw	(0x05, sp), x
                                    202 ;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080AB 5F               [ 1]  203 	clrw	x
      0080AC 1F 09            [ 2]  204 	ldw	(0x09, sp), x
      0080AE 1F 07            [ 2]  205 	ldw	(0x07, sp), x
      0080B0                        206 00103$:
      0080B0 1E 05            [ 2]  207 	ldw	x, (0x05, sp)
      0080B2 89               [ 2]  208 	pushw	x
      0080B3 AE 03 78         [ 2]  209 	ldw	x, #0x0378
      0080B6 CD 82 5E         [ 4]  210 	call	___muluint2ulong
      0080B9 5B 02            [ 2]  211 	addw	sp, #2
      0080BB 1F 03            [ 2]  212 	ldw	(0x03, sp), x
      0080BD 17 01            [ 2]  213 	ldw	(0x01, sp), y
      0080BF 1E 09            [ 2]  214 	ldw	x, (0x09, sp)
      0080C1 13 03            [ 2]  215 	cpw	x, (0x03, sp)
      0080C3 7B 08            [ 1]  216 	ld	a, (0x08, sp)
      0080C5 12 02            [ 1]  217 	sbc	a, (0x02, sp)
      0080C7 7B 07            [ 1]  218 	ld	a, (0x07, sp)
      0080C9 12 01            [ 1]  219 	sbc	a, (0x01, sp)
      0080CB 24 0F            [ 1]  220 	jrnc	00105$
                                    221 ;	1_wire.c: 71: __asm__("nop");
      0080CD 9D               [ 1]  222 	nop
                                    223 ;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080CE 1E 09            [ 2]  224 	ldw	x, (0x09, sp)
      0080D0 5C               [ 1]  225 	incw	x
      0080D1 1F 09            [ 2]  226 	ldw	(0x09, sp), x
      0080D3 26 DB            [ 1]  227 	jrne	00103$
      0080D5 1E 07            [ 2]  228 	ldw	x, (0x07, sp)
      0080D7 5C               [ 1]  229 	incw	x
      0080D8 1F 07            [ 2]  230 	ldw	(0x07, sp), x
      0080DA 20 D4            [ 2]  231 	jra	00103$
      0080DC                        232 00105$:
                                    233 ;	1_wire.c: 72: }
      0080DC 5B 0A            [ 2]  234 	addw	sp, #10
      0080DE 81               [ 4]  235 	ret
                                    236 ;	1_wire.c: 77: uint8_t onewire_reset(void) {
                                    237 ;	-----------------------------------------
                                    238 ;	 function onewire_reset
                                    239 ;	-----------------------------------------
      0080DF                        240 _onewire_reset:
                                    241 ;	1_wire.c: 78: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
      0080DF 72 16 50 11      [ 1]  242 	bset	0x5011, #3
      0080E3 72 17 50 0F      [ 1]  243 	bres	0x500f, #3
                                    244 ;	1_wire.c: 79: delay_us(480);
      0080E7 AE 01 E0         [ 2]  245 	ldw	x, #0x01e0
      0080EA CD 80 96         [ 4]  246 	call	_delay_us
                                    247 ;	1_wire.c: 80: DS_INPUT();                    // Relâche la ligne
      0080ED 72 17 50 11      [ 1]  248 	bres	0x5011, #3
                                    249 ;	1_wire.c: 81: delay_us(70);                  // Attend la réponse du capteur
      0080F1 AE 00 46         [ 2]  250 	ldw	x, #0x0046
      0080F4 CD 80 96         [ 4]  251 	call	_delay_us
                                    252 ;	1_wire.c: 82: uint8_t presence = !DS_READ(); // 0 = présence détectée
      0080F7 C6 50 10         [ 1]  253 	ld	a, 0x5010
      0080FA 4E               [ 1]  254 	swap	a
      0080FB 48               [ 1]  255 	sll	a
      0080FC 4F               [ 1]  256 	clr	a
      0080FD 49               [ 1]  257 	rlc	a
      0080FE A0 01            [ 1]  258 	sub	a, #0x01
      008100 4F               [ 1]  259 	clr	a
      008101 49               [ 1]  260 	rlc	a
                                    261 ;	1_wire.c: 83: delay_us(410);                 // Fin du timing 1-Wire
      008102 88               [ 1]  262 	push	a
      008103 AE 01 9A         [ 2]  263 	ldw	x, #0x019a
      008106 CD 80 96         [ 4]  264 	call	_delay_us
      008109 84               [ 1]  265 	pop	a
                                    266 ;	1_wire.c: 84: return presence;
                                    267 ;	1_wire.c: 85: }
      00810A 81               [ 4]  268 	ret
                                    269 ;	1_wire.c: 88: void onewire_write_bit(uint8_t bit) {
                                    270 ;	-----------------------------------------
                                    271 ;	 function onewire_write_bit
                                    272 ;	-----------------------------------------
      00810B                        273 _onewire_write_bit:
      00810B 88               [ 1]  274 	push	a
      00810C 6B 01            [ 1]  275 	ld	(0x01, sp), a
                                    276 ;	1_wire.c: 89: DS_OUTPUT(); DS_LOW();
      00810E 72 16 50 11      [ 1]  277 	bset	0x5011, #3
      008112 72 17 50 0F      [ 1]  278 	bres	0x500f, #3
                                    279 ;	1_wire.c: 90: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
      008116 0D 01            [ 1]  280 	tnz	(0x01, sp)
      008118 27 04            [ 1]  281 	jreq	00103$
      00811A AE 00 06         [ 2]  282 	ldw	x, #0x0006
      00811D BC                     283 	.byte 0xbc
      00811E                        284 00103$:
      00811E AE 00 3C         [ 2]  285 	ldw	x, #0x003c
      008121                        286 00104$:
      008121 CD 80 96         [ 4]  287 	call	_delay_us
                                    288 ;	1_wire.c: 91: DS_INPUT();                    // Libère la ligne
      008124 72 17 50 11      [ 1]  289 	bres	0x5011, #3
                                    290 ;	1_wire.c: 92: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
      008128 0D 01            [ 1]  291 	tnz	(0x01, sp)
      00812A 27 05            [ 1]  292 	jreq	00105$
      00812C AE 00 40         [ 2]  293 	ldw	x, #0x0040
      00812F 20 03            [ 2]  294 	jra	00106$
      008131                        295 00105$:
      008131 AE 00 0A         [ 2]  296 	ldw	x, #0x000a
      008134                        297 00106$:
      008134 84               [ 1]  298 	pop	a
      008135 CC 80 96         [ 2]  299 	jp	_delay_us
                                    300 ;	1_wire.c: 93: }
      008138 84               [ 1]  301 	pop	a
      008139 81               [ 4]  302 	ret
                                    303 ;	1_wire.c: 96: uint8_t onewire_read_bit(void) {
                                    304 ;	-----------------------------------------
                                    305 ;	 function onewire_read_bit
                                    306 ;	-----------------------------------------
      00813A                        307 _onewire_read_bit:
                                    308 ;	1_wire.c: 98: DS_OUTPUT(); DS_LOW();
      00813A 72 16 50 11      [ 1]  309 	bset	0x5011, #3
      00813E 72 17 50 0F      [ 1]  310 	bres	0x500f, #3
                                    311 ;	1_wire.c: 99: delay_us(6);                   // Pulse d'initiation de lecture
      008142 AE 00 06         [ 2]  312 	ldw	x, #0x0006
      008145 CD 80 96         [ 4]  313 	call	_delay_us
                                    314 ;	1_wire.c: 100: DS_INPUT();                    // Libère la ligne pour lire
      008148 72 17 50 11      [ 1]  315 	bres	0x5011, #3
                                    316 ;	1_wire.c: 101: delay_us(9);                   // Délai standard
      00814C AE 00 09         [ 2]  317 	ldw	x, #0x0009
      00814F CD 80 96         [ 4]  318 	call	_delay_us
                                    319 ;	1_wire.c: 102: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
      008152 72 07 50 10 03   [ 2]  320 	btjf	0x5010, #3, 00103$
      008157 5F               [ 1]  321 	clrw	x
      008158 5C               [ 1]  322 	incw	x
      008159 21                     323 	.byte 0x21
      00815A                        324 00103$:
      00815A 5F               [ 1]  325 	clrw	x
      00815B                        326 00104$:
      00815B 9F               [ 1]  327 	ld	a, xl
                                    328 ;	1_wire.c: 103: delay_us(55);                  // Fin du slot
      00815C 88               [ 1]  329 	push	a
      00815D AE 00 37         [ 2]  330 	ldw	x, #0x0037
      008160 CD 80 96         [ 4]  331 	call	_delay_us
      008163 84               [ 1]  332 	pop	a
                                    333 ;	1_wire.c: 104: return bit;
                                    334 ;	1_wire.c: 105: }
      008164 81               [ 4]  335 	ret
                                    336 ;	1_wire.c: 108: void onewire_write_byte(uint8_t byte) {
                                    337 ;	-----------------------------------------
                                    338 ;	 function onewire_write_byte
                                    339 ;	-----------------------------------------
      008165                        340 _onewire_write_byte:
      008165 52 02            [ 2]  341 	sub	sp, #2
      008167 6B 01            [ 1]  342 	ld	(0x01, sp), a
                                    343 ;	1_wire.c: 109: for (uint8_t i = 0; i < 8; i++) {
      008169 0F 02            [ 1]  344 	clr	(0x02, sp)
      00816B                        345 00103$:
      00816B 7B 02            [ 1]  346 	ld	a, (0x02, sp)
      00816D A1 08            [ 1]  347 	cp	a, #0x08
      00816F 24 0D            [ 1]  348 	jrnc	00105$
                                    349 ;	1_wire.c: 110: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
      008171 7B 01            [ 1]  350 	ld	a, (0x01, sp)
      008173 A4 01            [ 1]  351 	and	a, #0x01
      008175 CD 81 0B         [ 4]  352 	call	_onewire_write_bit
                                    353 ;	1_wire.c: 111: byte >>= 1;
      008178 04 01            [ 1]  354 	srl	(0x01, sp)
                                    355 ;	1_wire.c: 109: for (uint8_t i = 0; i < 8; i++) {
      00817A 0C 02            [ 1]  356 	inc	(0x02, sp)
      00817C 20 ED            [ 2]  357 	jra	00103$
      00817E                        358 00105$:
                                    359 ;	1_wire.c: 113: }
      00817E 5B 02            [ 2]  360 	addw	sp, #2
      008180 81               [ 4]  361 	ret
                                    362 ;	1_wire.c: 116: uint8_t onewire_read_byte(void) {
                                    363 ;	-----------------------------------------
                                    364 ;	 function onewire_read_byte
                                    365 ;	-----------------------------------------
      008181                        366 _onewire_read_byte:
      008181 52 02            [ 2]  367 	sub	sp, #2
                                    368 ;	1_wire.c: 117: uint8_t byte = 0;
      008183 0F 01            [ 1]  369 	clr	(0x01, sp)
                                    370 ;	1_wire.c: 118: for (uint8_t i = 0; i < 8; i++) {
      008185 0F 02            [ 1]  371 	clr	(0x02, sp)
      008187                        372 00105$:
      008187 7B 02            [ 1]  373 	ld	a, (0x02, sp)
      008189 A1 08            [ 1]  374 	cp	a, #0x08
      00818B 24 11            [ 1]  375 	jrnc	00103$
                                    376 ;	1_wire.c: 119: byte >>= 1;
      00818D 04 01            [ 1]  377 	srl	(0x01, sp)
                                    378 ;	1_wire.c: 120: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
      00818F CD 81 3A         [ 4]  379 	call	_onewire_read_bit
      008192 4D               [ 1]  380 	tnz	a
      008193 27 05            [ 1]  381 	jreq	00106$
      008195 08 01            [ 1]  382 	sll	(0x01, sp)
      008197 99               [ 1]  383 	scf
      008198 06 01            [ 1]  384 	rrc	(0x01, sp)
      00819A                        385 00106$:
                                    386 ;	1_wire.c: 118: for (uint8_t i = 0; i < 8; i++) {
      00819A 0C 02            [ 1]  387 	inc	(0x02, sp)
      00819C 20 E9            [ 2]  388 	jra	00105$
      00819E                        389 00103$:
                                    390 ;	1_wire.c: 122: return byte;
      00819E 7B 01            [ 1]  391 	ld	a, (0x01, sp)
                                    392 ;	1_wire.c: 123: }
      0081A0 5B 02            [ 2]  393 	addw	sp, #2
      0081A2 81               [ 4]  394 	ret
                                    395 ;	1_wire.c: 126: void ds18b20_start_conversion(void) {
                                    396 ;	-----------------------------------------
                                    397 ;	 function ds18b20_start_conversion
                                    398 ;	-----------------------------------------
      0081A3                        399 _ds18b20_start_conversion:
                                    400 ;	1_wire.c: 127: onewire_reset();
      0081A3 CD 80 DF         [ 4]  401 	call	_onewire_reset
                                    402 ;	1_wire.c: 128: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
      0081A6 A6 CC            [ 1]  403 	ld	a, #0xcc
      0081A8 CD 81 65         [ 4]  404 	call	_onewire_write_byte
                                    405 ;	1_wire.c: 129: onewire_write_byte(0x44); // Convert T (lance mesure)
      0081AB A6 44            [ 1]  406 	ld	a, #0x44
                                    407 ;	1_wire.c: 130: }
      0081AD CC 81 65         [ 2]  408 	jp	_onewire_write_byte
                                    409 ;	1_wire.c: 133: int16_t ds18b20_read_raw(void) {
                                    410 ;	-----------------------------------------
                                    411 ;	 function ds18b20_read_raw
                                    412 ;	-----------------------------------------
      0081B0                        413 _ds18b20_read_raw:
      0081B0 52 04            [ 2]  414 	sub	sp, #4
                                    415 ;	1_wire.c: 134: onewire_reset();
      0081B2 CD 80 DF         [ 4]  416 	call	_onewire_reset
                                    417 ;	1_wire.c: 135: onewire_write_byte(0xCC); // Skip ROM
      0081B5 A6 CC            [ 1]  418 	ld	a, #0xcc
      0081B7 CD 81 65         [ 4]  419 	call	_onewire_write_byte
                                    420 ;	1_wire.c: 136: onewire_write_byte(0xBE); // Read Scratchpad
      0081BA A6 BE            [ 1]  421 	ld	a, #0xbe
      0081BC CD 81 65         [ 4]  422 	call	_onewire_write_byte
                                    423 ;	1_wire.c: 138: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
      0081BF CD 81 81         [ 4]  424 	call	_onewire_read_byte
                                    425 ;	1_wire.c: 139: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
      0081C2 88               [ 1]  426 	push	a
      0081C3 CD 81 81         [ 4]  427 	call	_onewire_read_byte
      0081C6 95               [ 1]  428 	ld	xh, a
      0081C7 84               [ 1]  429 	pop	a
                                    430 ;	1_wire.c: 141: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
      0081C8 0F 02            [ 1]  431 	clr	(0x02, sp)
      0081CA 0F 03            [ 1]  432 	clr	(0x03, sp)
      0081CC 1A 02            [ 1]  433 	or	a, (0x02, sp)
      0081CE 02               [ 1]  434 	rlwa	x
      0081CF 1A 03            [ 1]  435 	or	a, (0x03, sp)
      0081D1 95               [ 1]  436 	ld	xh, a
                                    437 ;	1_wire.c: 142: }
      0081D2 5B 04            [ 2]  438 	addw	sp, #4
      0081D4 81               [ 4]  439 	ret
                                    440 ;	1_wire.c: 145: void main() {
                                    441 ;	-----------------------------------------
                                    442 ;	 function main
                                    443 ;	-----------------------------------------
      0081D5                        444 _main:
      0081D5 52 02            [ 2]  445 	sub	sp, #2
                                    446 ;	1_wire.c: 147: uart_config();   // Initialise l'UART (9600 bauds sur UART1)
      0081D7 CD 80 4C         [ 4]  447 	call	_uart_config
                                    448 ;	1_wire.c: 150: PD_DDR &= ~(1 << 3);    // PD3 en entrée
      0081DA 72 17 50 11      [ 1]  449 	bres	0x5011, #3
                                    450 ;	1_wire.c: 151: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
      0081DE 72 16 50 12      [ 1]  451 	bset	0x5012, #3
                                    452 ;	1_wire.c: 153: while (1) {
      0081E2                        453 00102$:
                                    454 ;	1_wire.c: 154: ds18b20_start_conversion(); // Démarre une conversion de température
      0081E2 CD 81 A3         [ 4]  455 	call	_ds18b20_start_conversion
                                    456 ;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0081E5 90 5F            [ 1]  457 	clrw	y
      0081E7 5F               [ 1]  458 	clrw	x
      0081E8                        459 00109$:
      0081E8 90 A3 29 90      [ 2]  460 	cpw	y, #0x2990
      0081EC 9F               [ 1]  461 	ld	a, xl
      0081ED A2 0A            [ 1]  462 	sbc	a, #0x0a
      0081EF 9E               [ 1]  463 	ld	a, xh
      0081F0 A2 00            [ 1]  464 	sbc	a, #0x00
      0081F2 24 08            [ 1]  465 	jrnc	00105$
                                    466 ;	1_wire.c: 71: __asm__("nop");
      0081F4 9D               [ 1]  467 	nop
                                    468 ;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0081F5 90 5C            [ 1]  469 	incw	y
      0081F7 26 EF            [ 1]  470 	jrne	00109$
      0081F9 5C               [ 1]  471 	incw	x
      0081FA 20 EC            [ 2]  472 	jra	00109$
                                    473 ;	1_wire.c: 155: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
      0081FC                        474 00105$:
                                    475 ;	1_wire.c: 157: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
      0081FC CD 81 B0         [ 4]  476 	call	_ds18b20_read_raw
                                    477 ;	1_wire.c: 160: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
      0081FF 90 5F            [ 1]  478 	clrw	y
      008201 5D               [ 2]  479 	tnzw	x
      008202 2A 02            [ 1]  480 	jrpl	00144$
      008204 90 5A            [ 2]  481 	decw	y
      008206                        482 00144$:
      008206 89               [ 2]  483 	pushw	x
      008207 90 89            [ 2]  484 	pushw	y
      008209 4B 71            [ 1]  485 	push	#0x71
      00820B 4B 02            [ 1]  486 	push	#0x02
      00820D 5F               [ 1]  487 	clrw	x
      00820E 89               [ 2]  488 	pushw	x
      00820F CD 83 37         [ 4]  489 	call	__mullong
      008212 5B 08            [ 2]  490 	addw	sp, #8
      008214 4B 64            [ 1]  491 	push	#0x64
      008216 4B 00            [ 1]  492 	push	#0x00
      008218 4B 00            [ 1]  493 	push	#0x00
      00821A 4B 00            [ 1]  494 	push	#0x00
      00821C 89               [ 2]  495 	pushw	x
      00821D 90 89            [ 2]  496 	pushw	y
      00821F CD 82 B5         [ 4]  497 	call	__divulong
      008222 5B 08            [ 2]  498 	addw	sp, #8
                                    499 ;	1_wire.c: 163: printf("Température : %d.%02d °C\r\n", temp_x100 / 100, temp_x100 % 100);
      008224 89               [ 2]  500 	pushw	x
      008225 4B 64            [ 1]  501 	push	#0x64
      008227 4B 00            [ 1]  502 	push	#0x00
      008229 CD 83 B3         [ 4]  503 	call	__modsint
      00822C 1F 03            [ 2]  504 	ldw	(0x03, sp), x
      00822E 85               [ 2]  505 	popw	x
      00822F 4B 64            [ 1]  506 	push	#0x64
      008231 4B 00            [ 1]  507 	push	#0x00
      008233 CD 83 CB         [ 4]  508 	call	__divsint
      008236 16 01            [ 2]  509 	ldw	y, (0x01, sp)
      008238 90 89            [ 2]  510 	pushw	y
      00823A 89               [ 2]  511 	pushw	x
      00823B 4B 24            [ 1]  512 	push	#<(___str_0+0)
      00823D 4B 80            [ 1]  513 	push	#((___str_0+0) >> 8)
      00823F CD 83 26         [ 4]  514 	call	_printf
      008242 5B 06            [ 2]  515 	addw	sp, #6
                                    516 ;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008244 90 5F            [ 1]  517 	clrw	y
      008246 5F               [ 1]  518 	clrw	x
      008247                        519 00112$:
      008247 90 A3 8C C0      [ 2]  520 	cpw	y, #0x8cc0
      00824B 9F               [ 1]  521 	ld	a, xl
      00824C A2 0D            [ 1]  522 	sbc	a, #0x0d
      00824E 9E               [ 1]  523 	ld	a, xh
      00824F A2 00            [ 1]  524 	sbc	a, #0x00
      008251 24 8F            [ 1]  525 	jrnc	00102$
                                    526 ;	1_wire.c: 71: __asm__("nop");
      008253 9D               [ 1]  527 	nop
                                    528 ;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008254 90 5C            [ 1]  529 	incw	y
      008256 26 EF            [ 1]  530 	jrne	00112$
      008258 5C               [ 1]  531 	incw	x
      008259 20 EC            [ 2]  532 	jra	00112$
                                    533 ;	1_wire.c: 165: delay_ms(1000); // Pause entre chaque mesure
                                    534 ;	1_wire.c: 167: }
      00825B 5B 02            [ 2]  535 	addw	sp, #2
      00825D 81               [ 4]  536 	ret
                                    537 	.area CODE
                                    538 	.area CONST
                                    539 	.area CONST
      008024                        540 ___str_0:
      008024 54 65 6D 70            541 	.ascii "Temp"
      008028 C3                     542 	.db 0xc3
      008029 A9                     543 	.db 0xa9
      00802A 72 61 74 75 72 65 20   544 	.ascii "rature : %d.%02d "
             3A 20 25 64 2E 25 30
             32 64 20
      00803B C2                     545 	.db 0xc2
      00803C B0                     546 	.db 0xb0
      00803D 43                     547 	.ascii "C"
      00803E 0D                     548 	.db 0x0d
      00803F 0A                     549 	.db 0x0a
      008040 00                     550 	.db 0x00
                                    551 	.area CODE
                                    552 	.area INITIALIZER
                                    553 	.area CABS (ABS)
