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
                                     19 	.globl _ds18b20_read_raw
                                     20 	.globl _ds18b20_start_conversion
                                     21 	.globl _onewire_read_byte
                                     22 	.globl _onewire_write_byte
                                     23 	.globl _onewire_read_bit
                                     24 	.globl _onewire_write_bit
                                     25 	.globl _onewire_reset
                                     26 	.globl _delay_us
                                     27 ;--------------------------------------------------------
                                     28 ; ram data
                                     29 ;--------------------------------------------------------
                                     30 	.area DATA
                                     31 ;--------------------------------------------------------
                                     32 ; ram data
                                     33 ;--------------------------------------------------------
                                     34 	.area INITIALIZED
                                     35 ;--------------------------------------------------------
                                     36 ; Stack segment in internal ram
                                     37 ;--------------------------------------------------------
                                     38 	.area	SSEG
      000001                         39 __start__stack:
      000001                         40 	.ds	1
                                     41 
                                     42 ;--------------------------------------------------------
                                     43 ; absolute external ram data
                                     44 ;--------------------------------------------------------
                                     45 	.area DABS (ABS)
                                     46 
                                     47 ; default segment ordering for linker
                                     48 	.area HOME
                                     49 	.area GSINIT
                                     50 	.area GSFINAL
                                     51 	.area CONST
                                     52 	.area INITIALIZER
                                     53 	.area CODE
                                     54 
                                     55 ;--------------------------------------------------------
                                     56 ; interrupt vector
                                     57 ;--------------------------------------------------------
                                     58 	.area HOME
      008000                         59 __interrupt_vect:
      008000 82 00 80 07             60 	int s_GSINIT ; reset
                                     61 ;--------------------------------------------------------
                                     62 ; global & static initialisations
                                     63 ;--------------------------------------------------------
                                     64 	.area HOME
                                     65 	.area GSINIT
                                     66 	.area GSFINAL
                                     67 	.area GSINIT
      008007                         68 __sdcc_init_data:
                                     69 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   70 	ldw x, #l_DATA
      00800A 27 07            [ 1]   71 	jreq	00002$
      00800C                         72 00001$:
      00800C 72 4F 00 00      [ 1]   73 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   74 	decw x
      008011 26 F9            [ 1]   75 	jrne	00001$
      008013                         76 00002$:
      008013 AE 00 00         [ 2]   77 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   78 	jreq	00004$
      008018                         79 00003$:
      008018 D6 80 2D         [ 1]   80 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   81 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   82 	decw	x
      00801F 26 F7            [ 1]   83 	jrne	00003$
      008021                         84 00004$:
                                     85 ; stm8_genXINIT() end
                                     86 	.area GSFINAL
      008021 CC 80 04         [ 2]   87 	jp	__sdcc_program_startup
                                     88 ;--------------------------------------------------------
                                     89 ; Home
                                     90 ;--------------------------------------------------------
                                     91 	.area HOME
                                     92 	.area HOME
      008004                         93 __sdcc_program_startup:
      008004 CC 82 9C         [ 2]   94 	jp	_main
                                     95 ;	return from main will return to caller
                                     96 ;--------------------------------------------------------
                                     97 ; code
                                     98 ;--------------------------------------------------------
                                     99 	.area CODE
                                    100 ;	main.c: 31: void delay_us(uint16_t us) {
                                    101 ;	-----------------------------------------
                                    102 ;	 function delay_us
                                    103 ;	-----------------------------------------
      00802E                        104 _delay_us:
                                    105 ;	main.c: 32: while(us--) {
      00802E                        106 00101$:
      00802E 90 93            [ 1]  107 	ldw	y, x
      008030 5A               [ 2]  108 	decw	x
      008031 90 5D            [ 2]  109 	tnzw	y
      008033 26 01            [ 1]  110 	jrne	00117$
      008035 81               [ 4]  111 	ret
      008036                        112 00117$:
                                    113 ;	main.c: 33: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008036 9D               [ 1]  114 	nop
      008037 9D               [ 1]  115 	nop
      008038 9D               [ 1]  116 	nop
                                    117 ;	main.c: 34: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008039 9D               [ 1]  118 	nop
      00803A 9D               [ 1]  119 	nop
      00803B 9D               [ 1]  120 	nop
      00803C 20 F0            [ 2]  121 	jra	00101$
                                    122 ;	main.c: 36: }
      00803E 81               [ 4]  123 	ret
                                    124 ;	main.c: 39: static inline void delay_ms(uint16_t ms) {
                                    125 ;	-----------------------------------------
                                    126 ;	 function delay_ms
                                    127 ;	-----------------------------------------
      00803F                        128 _delay_ms:
      00803F 52 0A            [ 2]  129 	sub	sp, #10
      008041 1F 05            [ 2]  130 	ldw	(0x05, sp), x
                                    131 ;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008043 5F               [ 1]  132 	clrw	x
      008044 1F 09            [ 2]  133 	ldw	(0x09, sp), x
      008046 1F 07            [ 2]  134 	ldw	(0x07, sp), x
      008048                        135 00103$:
      008048 1E 05            [ 2]  136 	ldw	x, (0x05, sp)
      00804A 89               [ 2]  137 	pushw	x
      00804B AE 03 78         [ 2]  138 	ldw	x, #0x0378
      00804E CD 83 15         [ 4]  139 	call	___muluint2ulong
      008051 5B 02            [ 2]  140 	addw	sp, #2
      008053 1F 03            [ 2]  141 	ldw	(0x03, sp), x
      008055 17 01            [ 2]  142 	ldw	(0x01, sp), y
      008057 1E 09            [ 2]  143 	ldw	x, (0x09, sp)
      008059 13 03            [ 2]  144 	cpw	x, (0x03, sp)
      00805B 7B 08            [ 1]  145 	ld	a, (0x08, sp)
      00805D 12 02            [ 1]  146 	sbc	a, (0x02, sp)
      00805F 7B 07            [ 1]  147 	ld	a, (0x07, sp)
      008061 12 01            [ 1]  148 	sbc	a, (0x01, sp)
      008063 24 0F            [ 1]  149 	jrnc	00105$
                                    150 ;	main.c: 42: __asm__("nop");
      008065 9D               [ 1]  151 	nop
                                    152 ;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008066 1E 09            [ 2]  153 	ldw	x, (0x09, sp)
      008068 5C               [ 1]  154 	incw	x
      008069 1F 09            [ 2]  155 	ldw	(0x09, sp), x
      00806B 26 DB            [ 1]  156 	jrne	00103$
      00806D 1E 07            [ 2]  157 	ldw	x, (0x07, sp)
      00806F 5C               [ 1]  158 	incw	x
      008070 1F 07            [ 2]  159 	ldw	(0x07, sp), x
      008072 20 D4            [ 2]  160 	jra	00103$
      008074                        161 00105$:
                                    162 ;	main.c: 43: }
      008074 5B 0A            [ 2]  163 	addw	sp, #10
      008076 81               [ 4]  164 	ret
                                    165 ;	main.c: 48: uint8_t onewire_reset(void) {
                                    166 ;	-----------------------------------------
                                    167 ;	 function onewire_reset
                                    168 ;	-----------------------------------------
      008077                        169 _onewire_reset:
                                    170 ;	main.c: 49: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
      008077 72 16 50 11      [ 1]  171 	bset	0x5011, #3
      00807B 72 17 50 0F      [ 1]  172 	bres	0x500f, #3
                                    173 ;	main.c: 50: delay_us(480);
      00807F AE 01 E0         [ 2]  174 	ldw	x, #0x01e0
      008082 CD 80 2E         [ 4]  175 	call	_delay_us
                                    176 ;	main.c: 51: DS_INPUT();                    // Relâche la ligne
      008085 72 17 50 11      [ 1]  177 	bres	0x5011, #3
                                    178 ;	main.c: 52: delay_us(70);                  // Attend la réponse du capteur
      008089 AE 00 46         [ 2]  179 	ldw	x, #0x0046
      00808C CD 80 2E         [ 4]  180 	call	_delay_us
                                    181 ;	main.c: 53: uint8_t presence = !DS_READ(); // 0 = présence détectée
      00808F C6 50 10         [ 1]  182 	ld	a, 0x5010
      008092 4E               [ 1]  183 	swap	a
      008093 48               [ 1]  184 	sll	a
      008094 4F               [ 1]  185 	clr	a
      008095 49               [ 1]  186 	rlc	a
      008096 A0 01            [ 1]  187 	sub	a, #0x01
      008098 4F               [ 1]  188 	clr	a
      008099 49               [ 1]  189 	rlc	a
                                    190 ;	main.c: 54: delay_us(410);                 // Fin du timing 1-Wire
      00809A 88               [ 1]  191 	push	a
      00809B AE 01 9A         [ 2]  192 	ldw	x, #0x019a
      00809E CD 80 2E         [ 4]  193 	call	_delay_us
      0080A1 84               [ 1]  194 	pop	a
                                    195 ;	main.c: 55: return presence;
                                    196 ;	main.c: 56: }
      0080A2 81               [ 4]  197 	ret
                                    198 ;	main.c: 59: void onewire_write_bit(uint8_t bit) {
                                    199 ;	-----------------------------------------
                                    200 ;	 function onewire_write_bit
                                    201 ;	-----------------------------------------
      0080A3                        202 _onewire_write_bit:
      0080A3 88               [ 1]  203 	push	a
      0080A4 6B 01            [ 1]  204 	ld	(0x01, sp), a
                                    205 ;	main.c: 60: DS_OUTPUT(); DS_LOW();
      0080A6 72 16 50 11      [ 1]  206 	bset	0x5011, #3
      0080AA 72 17 50 0F      [ 1]  207 	bres	0x500f, #3
                                    208 ;	main.c: 61: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
      0080AE 0D 01            [ 1]  209 	tnz	(0x01, sp)
      0080B0 27 04            [ 1]  210 	jreq	00103$
      0080B2 AE 00 06         [ 2]  211 	ldw	x, #0x0006
      0080B5 BC                     212 	.byte 0xbc
      0080B6                        213 00103$:
      0080B6 AE 00 3C         [ 2]  214 	ldw	x, #0x003c
      0080B9                        215 00104$:
      0080B9 CD 80 2E         [ 4]  216 	call	_delay_us
                                    217 ;	main.c: 62: DS_INPUT();                    // Libère la ligne
      0080BC 72 17 50 11      [ 1]  218 	bres	0x5011, #3
                                    219 ;	main.c: 63: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
      0080C0 0D 01            [ 1]  220 	tnz	(0x01, sp)
      0080C2 27 05            [ 1]  221 	jreq	00105$
      0080C4 AE 00 40         [ 2]  222 	ldw	x, #0x0040
      0080C7 20 03            [ 2]  223 	jra	00106$
      0080C9                        224 00105$:
      0080C9 AE 00 0A         [ 2]  225 	ldw	x, #0x000a
      0080CC                        226 00106$:
      0080CC 84               [ 1]  227 	pop	a
      0080CD CC 80 2E         [ 2]  228 	jp	_delay_us
                                    229 ;	main.c: 64: }
      0080D0 84               [ 1]  230 	pop	a
      0080D1 81               [ 4]  231 	ret
                                    232 ;	main.c: 67: uint8_t onewire_read_bit(void) {
                                    233 ;	-----------------------------------------
                                    234 ;	 function onewire_read_bit
                                    235 ;	-----------------------------------------
      0080D2                        236 _onewire_read_bit:
                                    237 ;	main.c: 69: DS_OUTPUT(); DS_LOW();
      0080D2 72 16 50 11      [ 1]  238 	bset	0x5011, #3
      0080D6 72 17 50 0F      [ 1]  239 	bres	0x500f, #3
                                    240 ;	main.c: 70: delay_us(6);                   // Pulse d'initiation de lecture
      0080DA AE 00 06         [ 2]  241 	ldw	x, #0x0006
      0080DD CD 80 2E         [ 4]  242 	call	_delay_us
                                    243 ;	main.c: 71: DS_INPUT();                    // Libère la ligne pour lire
      0080E0 72 17 50 11      [ 1]  244 	bres	0x5011, #3
                                    245 ;	main.c: 72: delay_us(9);                   // Délai standard
      0080E4 AE 00 09         [ 2]  246 	ldw	x, #0x0009
      0080E7 CD 80 2E         [ 4]  247 	call	_delay_us
                                    248 ;	main.c: 73: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
      0080EA 72 07 50 10 03   [ 2]  249 	btjf	0x5010, #3, 00103$
      0080EF 5F               [ 1]  250 	clrw	x
      0080F0 5C               [ 1]  251 	incw	x
      0080F1 21                     252 	.byte 0x21
      0080F2                        253 00103$:
      0080F2 5F               [ 1]  254 	clrw	x
      0080F3                        255 00104$:
      0080F3 9F               [ 1]  256 	ld	a, xl
                                    257 ;	main.c: 74: delay_us(55);                  // Fin du slot
      0080F4 88               [ 1]  258 	push	a
      0080F5 AE 00 37         [ 2]  259 	ldw	x, #0x0037
      0080F8 CD 80 2E         [ 4]  260 	call	_delay_us
      0080FB 84               [ 1]  261 	pop	a
                                    262 ;	main.c: 75: return bit;
                                    263 ;	main.c: 76: }
      0080FC 81               [ 4]  264 	ret
                                    265 ;	main.c: 79: void onewire_write_byte(uint8_t byte) {
                                    266 ;	-----------------------------------------
                                    267 ;	 function onewire_write_byte
                                    268 ;	-----------------------------------------
      0080FD                        269 _onewire_write_byte:
      0080FD 52 02            [ 2]  270 	sub	sp, #2
      0080FF 6B 01            [ 1]  271 	ld	(0x01, sp), a
                                    272 ;	main.c: 80: for (uint8_t i = 0; i < 8; i++) {
      008101 0F 02            [ 1]  273 	clr	(0x02, sp)
      008103                        274 00103$:
      008103 7B 02            [ 1]  275 	ld	a, (0x02, sp)
      008105 A1 08            [ 1]  276 	cp	a, #0x08
      008107 24 0D            [ 1]  277 	jrnc	00105$
                                    278 ;	main.c: 81: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
      008109 7B 01            [ 1]  279 	ld	a, (0x01, sp)
      00810B A4 01            [ 1]  280 	and	a, #0x01
      00810D CD 80 A3         [ 4]  281 	call	_onewire_write_bit
                                    282 ;	main.c: 82: byte >>= 1;
      008110 04 01            [ 1]  283 	srl	(0x01, sp)
                                    284 ;	main.c: 80: for (uint8_t i = 0; i < 8; i++) {
      008112 0C 02            [ 1]  285 	inc	(0x02, sp)
      008114 20 ED            [ 2]  286 	jra	00103$
      008116                        287 00105$:
                                    288 ;	main.c: 84: }
      008116 5B 02            [ 2]  289 	addw	sp, #2
      008118 81               [ 4]  290 	ret
                                    291 ;	main.c: 87: uint8_t onewire_read_byte(void) {
                                    292 ;	-----------------------------------------
                                    293 ;	 function onewire_read_byte
                                    294 ;	-----------------------------------------
      008119                        295 _onewire_read_byte:
      008119 52 02            [ 2]  296 	sub	sp, #2
                                    297 ;	main.c: 88: uint8_t byte = 0;
      00811B 0F 01            [ 1]  298 	clr	(0x01, sp)
                                    299 ;	main.c: 89: for (uint8_t i = 0; i < 8; i++) {
      00811D 0F 02            [ 1]  300 	clr	(0x02, sp)
      00811F                        301 00105$:
      00811F 7B 02            [ 1]  302 	ld	a, (0x02, sp)
      008121 A1 08            [ 1]  303 	cp	a, #0x08
      008123 24 11            [ 1]  304 	jrnc	00103$
                                    305 ;	main.c: 90: byte >>= 1;
      008125 04 01            [ 1]  306 	srl	(0x01, sp)
                                    307 ;	main.c: 91: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
      008127 CD 80 D2         [ 4]  308 	call	_onewire_read_bit
      00812A 4D               [ 1]  309 	tnz	a
      00812B 27 05            [ 1]  310 	jreq	00106$
      00812D 08 01            [ 1]  311 	sll	(0x01, sp)
      00812F 99               [ 1]  312 	scf
      008130 06 01            [ 1]  313 	rrc	(0x01, sp)
      008132                        314 00106$:
                                    315 ;	main.c: 89: for (uint8_t i = 0; i < 8; i++) {
      008132 0C 02            [ 1]  316 	inc	(0x02, sp)
      008134 20 E9            [ 2]  317 	jra	00105$
      008136                        318 00103$:
                                    319 ;	main.c: 93: return byte;
      008136 7B 01            [ 1]  320 	ld	a, (0x01, sp)
                                    321 ;	main.c: 94: }
      008138 5B 02            [ 2]  322 	addw	sp, #2
      00813A 81               [ 4]  323 	ret
                                    324 ;	main.c: 97: void ds18b20_start_conversion(void) {
                                    325 ;	-----------------------------------------
                                    326 ;	 function ds18b20_start_conversion
                                    327 ;	-----------------------------------------
      00813B                        328 _ds18b20_start_conversion:
                                    329 ;	main.c: 98: onewire_reset();
      00813B CD 80 77         [ 4]  330 	call	_onewire_reset
                                    331 ;	main.c: 99: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
      00813E A6 CC            [ 1]  332 	ld	a, #0xcc
      008140 CD 80 FD         [ 4]  333 	call	_onewire_write_byte
                                    334 ;	main.c: 100: onewire_write_byte(0x44); // Convert T (lance mesure)
      008143 A6 44            [ 1]  335 	ld	a, #0x44
                                    336 ;	main.c: 101: }
      008145 CC 80 FD         [ 2]  337 	jp	_onewire_write_byte
                                    338 ;	main.c: 104: int16_t ds18b20_read_raw(void) {
                                    339 ;	-----------------------------------------
                                    340 ;	 function ds18b20_read_raw
                                    341 ;	-----------------------------------------
      008148                        342 _ds18b20_read_raw:
      008148 52 04            [ 2]  343 	sub	sp, #4
                                    344 ;	main.c: 105: onewire_reset();
      00814A CD 80 77         [ 4]  345 	call	_onewire_reset
                                    346 ;	main.c: 106: onewire_write_byte(0xCC); // Skip ROM
      00814D A6 CC            [ 1]  347 	ld	a, #0xcc
      00814F CD 80 FD         [ 4]  348 	call	_onewire_write_byte
                                    349 ;	main.c: 107: onewire_write_byte(0xBE); // Read Scratchpad
      008152 A6 BE            [ 1]  350 	ld	a, #0xbe
      008154 CD 80 FD         [ 4]  351 	call	_onewire_write_byte
                                    352 ;	main.c: 109: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
      008157 CD 81 19         [ 4]  353 	call	_onewire_read_byte
                                    354 ;	main.c: 110: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
      00815A 88               [ 1]  355 	push	a
      00815B CD 81 19         [ 4]  356 	call	_onewire_read_byte
      00815E 95               [ 1]  357 	ld	xh, a
      00815F 84               [ 1]  358 	pop	a
                                    359 ;	main.c: 112: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
      008160 0F 02            [ 1]  360 	clr	(0x02, sp)
      008162 0F 03            [ 1]  361 	clr	(0x03, sp)
      008164 1A 02            [ 1]  362 	or	a, (0x02, sp)
      008166 02               [ 1]  363 	rlwa	x
      008167 1A 03            [ 1]  364 	or	a, (0x03, sp)
      008169 95               [ 1]  365 	ld	xh, a
                                    366 ;	main.c: 113: }
      00816A 5B 04            [ 2]  367 	addw	sp, #4
      00816C 81               [ 4]  368 	ret
                                    369 ;	main.c: 131: void tm_delay() {
                                    370 ;	-----------------------------------------
                                    371 ;	 function tm_delay
                                    372 ;	-----------------------------------------
      00816D                        373 _tm_delay:
      00816D 52 02            [ 2]  374 	sub	sp, #2
                                    375 ;	main.c: 132: for (volatile int i = 0; i < 50; i++) __asm__("nop");
      00816F 5F               [ 1]  376 	clrw	x
      008170 1F 01            [ 2]  377 	ldw	(0x01, sp), x
      008172                        378 00103$:
      008172 1E 01            [ 2]  379 	ldw	x, (0x01, sp)
      008174 A3 00 32         [ 2]  380 	cpw	x, #0x0032
      008177 2E 08            [ 1]  381 	jrsge	00105$
      008179 9D               [ 1]  382 	nop
      00817A 1E 01            [ 2]  383 	ldw	x, (0x01, sp)
      00817C 5C               [ 1]  384 	incw	x
      00817D 1F 01            [ 2]  385 	ldw	(0x01, sp), x
      00817F 20 F1            [ 2]  386 	jra	00103$
      008181                        387 00105$:
                                    388 ;	main.c: 133: }
      008181 5B 02            [ 2]  389 	addw	sp, #2
      008183 81               [ 4]  390 	ret
                                    391 ;	main.c: 135: void tm_start() {
                                    392 ;	-----------------------------------------
                                    393 ;	 function tm_start
                                    394 ;	-----------------------------------------
      008184                        395 _tm_start:
                                    396 ;	main.c: 136: TM_DIO_DDR |= (1 << TM_DIO_PIN);
      008184 72 12 50 02      [ 1]  397 	bset	0x5002, #1
                                    398 ;	main.c: 137: TM_CLK_DDR |= (1 << TM_CLK_PIN);
      008188 72 14 50 02      [ 1]  399 	bset	0x5002, #2
                                    400 ;	main.c: 138: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      00818C 72 12 50 00      [ 1]  401 	bset	0x5000, #1
                                    402 ;	main.c: 139: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      008190 72 14 50 00      [ 1]  403 	bset	0x5000, #2
                                    404 ;	main.c: 140: tm_delay();
      008194 CD 81 6D         [ 4]  405 	call	_tm_delay
                                    406 ;	main.c: 141: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      008197 72 13 50 00      [ 1]  407 	bres	0x5000, #1
                                    408 ;	main.c: 142: tm_delay();
      00819B CD 81 6D         [ 4]  409 	call	_tm_delay
                                    410 ;	main.c: 143: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      00819E 72 15 50 00      [ 1]  411 	bres	0x5000, #2
                                    412 ;	main.c: 144: }
      0081A2 81               [ 4]  413 	ret
                                    414 ;	main.c: 146: void tm_stop() {
                                    415 ;	-----------------------------------------
                                    416 ;	 function tm_stop
                                    417 ;	-----------------------------------------
      0081A3                        418 _tm_stop:
                                    419 ;	main.c: 147: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0081A3 72 15 50 00      [ 1]  420 	bres	0x5000, #2
                                    421 ;	main.c: 148: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      0081A7 72 13 50 00      [ 1]  422 	bres	0x5000, #1
                                    423 ;	main.c: 149: tm_delay();
      0081AB CD 81 6D         [ 4]  424 	call	_tm_delay
                                    425 ;	main.c: 150: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      0081AE 72 14 50 00      [ 1]  426 	bset	0x5000, #2
                                    427 ;	main.c: 151: tm_delay();
      0081B2 CD 81 6D         [ 4]  428 	call	_tm_delay
                                    429 ;	main.c: 152: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      0081B5 72 12 50 00      [ 1]  430 	bset	0x5000, #1
                                    431 ;	main.c: 153: }
      0081B9 81               [ 4]  432 	ret
                                    433 ;	main.c: 155: void tm_write_byte(uint8_t b) {
                                    434 ;	-----------------------------------------
                                    435 ;	 function tm_write_byte
                                    436 ;	-----------------------------------------
      0081BA                        437 _tm_write_byte:
      0081BA 52 02            [ 2]  438 	sub	sp, #2
      0081BC 6B 01            [ 1]  439 	ld	(0x01, sp), a
                                    440 ;	main.c: 156: for (uint8_t i = 0; i < 8; i++) {
      0081BE 0F 02            [ 1]  441 	clr	(0x02, sp)
      0081C0                        442 00106$:
                                    443 ;	main.c: 157: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0081C0 C6 50 00         [ 1]  444 	ld	a, 0x5000
      0081C3 A4 FB            [ 1]  445 	and	a, #0xfb
                                    446 ;	main.c: 156: for (uint8_t i = 0; i < 8; i++) {
      0081C5 88               [ 1]  447 	push	a
      0081C6 7B 03            [ 1]  448 	ld	a, (0x03, sp)
      0081C8 A1 08            [ 1]  449 	cp	a, #0x08
      0081CA 84               [ 1]  450 	pop	a
      0081CB 24 29            [ 1]  451 	jrnc	00104$
                                    452 ;	main.c: 157: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0081CD C7 50 00         [ 1]  453 	ld	0x5000, a
      0081D0 C6 50 00         [ 1]  454 	ld	a, 0x5000
                                    455 ;	main.c: 158: if (b & 0x01)
      0081D3 88               [ 1]  456 	push	a
      0081D4 7B 02            [ 1]  457 	ld	a, (0x02, sp)
      0081D6 44               [ 1]  458 	srl	a
      0081D7 84               [ 1]  459 	pop	a
      0081D8 24 07            [ 1]  460 	jrnc	00102$
                                    461 ;	main.c: 159: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      0081DA AA 02            [ 1]  462 	or	a, #0x02
      0081DC C7 50 00         [ 1]  463 	ld	0x5000, a
      0081DF 20 05            [ 2]  464 	jra	00103$
      0081E1                        465 00102$:
                                    466 ;	main.c: 161: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      0081E1 A4 FD            [ 1]  467 	and	a, #0xfd
      0081E3 C7 50 00         [ 1]  468 	ld	0x5000, a
      0081E6                        469 00103$:
                                    470 ;	main.c: 162: tm_delay();
      0081E6 CD 81 6D         [ 4]  471 	call	_tm_delay
                                    472 ;	main.c: 163: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      0081E9 72 14 50 00      [ 1]  473 	bset	0x5000, #2
                                    474 ;	main.c: 164: tm_delay();
      0081ED CD 81 6D         [ 4]  475 	call	_tm_delay
                                    476 ;	main.c: 165: b >>= 1;
      0081F0 04 01            [ 1]  477 	srl	(0x01, sp)
                                    478 ;	main.c: 156: for (uint8_t i = 0; i < 8; i++) {
      0081F2 0C 02            [ 1]  479 	inc	(0x02, sp)
      0081F4 20 CA            [ 2]  480 	jra	00106$
      0081F6                        481 00104$:
                                    482 ;	main.c: 169: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0081F6 C7 50 00         [ 1]  483 	ld	0x5000, a
                                    484 ;	main.c: 170: TM_DIO_DDR &= ~(1 << TM_DIO_PIN); // entrée
      0081F9 72 13 50 02      [ 1]  485 	bres	0x5002, #1
                                    486 ;	main.c: 171: tm_delay();
      0081FD CD 81 6D         [ 4]  487 	call	_tm_delay
                                    488 ;	main.c: 172: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      008200 72 14 50 00      [ 1]  489 	bset	0x5000, #2
                                    490 ;	main.c: 173: tm_delay();
      008204 CD 81 6D         [ 4]  491 	call	_tm_delay
                                    492 ;	main.c: 174: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008207 72 15 50 00      [ 1]  493 	bres	0x5000, #2
                                    494 ;	main.c: 175: TM_DIO_DDR |= (1 << TM_DIO_PIN); // repasse en sortie
      00820B 72 12 50 02      [ 1]  495 	bset	0x5002, #1
                                    496 ;	main.c: 176: }
      00820F 5B 02            [ 2]  497 	addw	sp, #2
      008211 81               [ 4]  498 	ret
                                    499 ;	main.c: 179: void tm_set_segments(uint8_t *segments, uint8_t length) {
                                    500 ;	-----------------------------------------
                                    501 ;	 function tm_set_segments
                                    502 ;	-----------------------------------------
      008212                        503 _tm_set_segments:
      008212 52 04            [ 2]  504 	sub	sp, #4
      008214 1F 02            [ 2]  505 	ldw	(0x02, sp), x
      008216 6B 01            [ 1]  506 	ld	(0x01, sp), a
                                    507 ;	main.c: 180: tm_start();
      008218 CD 81 84         [ 4]  508 	call	_tm_start
                                    509 ;	main.c: 181: tm_write_byte(0x40); // Commande : auto-increment mode
      00821B A6 40            [ 1]  510 	ld	a, #0x40
      00821D CD 81 BA         [ 4]  511 	call	_tm_write_byte
                                    512 ;	main.c: 182: tm_stop();
      008220 CD 81 A3         [ 4]  513 	call	_tm_stop
                                    514 ;	main.c: 184: tm_start();
      008223 CD 81 84         [ 4]  515 	call	_tm_start
                                    516 ;	main.c: 185: tm_write_byte(0xC0); // Adresse de départ = 0
      008226 A6 C0            [ 1]  517 	ld	a, #0xc0
      008228 CD 81 BA         [ 4]  518 	call	_tm_write_byte
                                    519 ;	main.c: 186: for (uint8_t i = 0; i < length; i++) {
      00822B 0F 04            [ 1]  520 	clr	(0x04, sp)
      00822D                        521 00103$:
      00822D 7B 04            [ 1]  522 	ld	a, (0x04, sp)
      00822F 11 01            [ 1]  523 	cp	a, (0x01, sp)
      008231 24 0F            [ 1]  524 	jrnc	00101$
                                    525 ;	main.c: 187: tm_write_byte(segments[i]);
      008233 5F               [ 1]  526 	clrw	x
      008234 7B 04            [ 1]  527 	ld	a, (0x04, sp)
      008236 97               [ 1]  528 	ld	xl, a
      008237 72 FB 02         [ 2]  529 	addw	x, (0x02, sp)
      00823A F6               [ 1]  530 	ld	a, (x)
      00823B CD 81 BA         [ 4]  531 	call	_tm_write_byte
                                    532 ;	main.c: 186: for (uint8_t i = 0; i < length; i++) {
      00823E 0C 04            [ 1]  533 	inc	(0x04, sp)
      008240 20 EB            [ 2]  534 	jra	00103$
      008242                        535 00101$:
                                    536 ;	main.c: 189: tm_stop();
      008242 CD 81 A3         [ 4]  537 	call	_tm_stop
                                    538 ;	main.c: 191: tm_start();
      008245 CD 81 84         [ 4]  539 	call	_tm_start
                                    540 ;	main.c: 192: tm_write_byte(0x88 | 0x07); // Affichage ON, luminosité max (0x00 à 0x07)
      008248 A6 8F            [ 1]  541 	ld	a, #0x8f
      00824A CD 81 BA         [ 4]  542 	call	_tm_write_byte
                                    543 ;	main.c: 193: tm_stop();
      00824D 5B 04            [ 2]  544 	addw	sp, #4
                                    545 ;	main.c: 194: }
      00824F CC 81 A3         [ 2]  546 	jp	_tm_stop
                                    547 ;	main.c: 197: void tm_display_temp_x100(int temp_x100) {
                                    548 ;	-----------------------------------------
                                    549 ;	 function tm_display_temp_x100
                                    550 ;	-----------------------------------------
      008252                        551 _tm_display_temp_x100:
      008252 52 0A            [ 2]  552 	sub	sp, #10
                                    553 ;	main.c: 198: int val = temp_x100;
      008254 1F 05            [ 2]  554 	ldw	(0x05, sp), x
                                    555 ;	main.c: 199: if (val < 0) val = -val;  // Ignore le signe ici (optionnel à améliorer)
      008256 5D               [ 2]  556 	tnzw	x
      008257 2A 03            [ 1]  557 	jrpl	00111$
      008259 50               [ 2]  558 	negw	x
      00825A 1F 05            [ 2]  559 	ldw	(0x05, sp), x
                                    560 ;	main.c: 203: for (int i = 3; i >= 0; i--) {
      00825C                        561 00111$:
      00825C AE 00 03         [ 2]  562 	ldw	x, #0x0003
      00825F 1F 09            [ 2]  563 	ldw	(0x09, sp), x
      008261                        564 00105$:
      008261 0D 09            [ 1]  565 	tnz	(0x09, sp)
      008263 2B 28            [ 1]  566 	jrmi	00103$
                                    567 ;	main.c: 204: digits[i] = digit_to_segment[val % 10];
      008265 96               [ 1]  568 	ldw	x, sp
      008266 5C               [ 1]  569 	incw	x
      008267 72 FB 09         [ 2]  570 	addw	x, (0x09, sp)
      00826A 1F 07            [ 2]  571 	ldw	(0x07, sp), x
      00826C 4B 0A            [ 1]  572 	push	#0x0a
      00826E 4B 00            [ 1]  573 	push	#0x00
      008270 1E 07            [ 2]  574 	ldw	x, (0x07, sp)
      008272 CD 83 C5         [ 4]  575 	call	__modsint
      008275 D6 80 24         [ 1]  576 	ld	a, (_digit_to_segment+0, x)
      008278 1E 07            [ 2]  577 	ldw	x, (0x07, sp)
      00827A F7               [ 1]  578 	ld	(x), a
                                    579 ;	main.c: 205: val /= 10;
      00827B 4B 0A            [ 1]  580 	push	#0x0a
      00827D 4B 00            [ 1]  581 	push	#0x00
      00827F 1E 07            [ 2]  582 	ldw	x, (0x07, sp)
      008281 CD 84 59         [ 4]  583 	call	__divsint
      008284 1F 05            [ 2]  584 	ldw	(0x05, sp), x
                                    585 ;	main.c: 203: for (int i = 3; i >= 0; i--) {
      008286 1E 09            [ 2]  586 	ldw	x, (0x09, sp)
      008288 5A               [ 2]  587 	decw	x
      008289 1F 09            [ 2]  588 	ldw	(0x09, sp), x
      00828B 20 D4            [ 2]  589 	jra	00105$
      00828D                        590 00103$:
                                    591 ;	main.c: 209: digits[1] |= 0x80;
      00828D 09 02            [ 1]  592 	rlc	(0x02, sp)
      00828F 99               [ 1]  593 	scf
      008290 06 02            [ 1]  594 	rrc	(0x02, sp)
                                    595 ;	main.c: 211: tm_set_segments(digits, 4);
      008292 A6 04            [ 1]  596 	ld	a, #0x04
      008294 96               [ 1]  597 	ldw	x, sp
      008295 5C               [ 1]  598 	incw	x
      008296 CD 82 12         [ 4]  599 	call	_tm_set_segments
                                    600 ;	main.c: 212: }
      008299 5B 0A            [ 2]  601 	addw	sp, #10
      00829B 81               [ 4]  602 	ret
                                    603 ;	main.c: 215: void main() {
                                    604 ;	-----------------------------------------
                                    605 ;	 function main
                                    606 ;	-----------------------------------------
      00829C                        607 _main:
                                    608 ;	main.c: 217: CLK_CKDIVR = 0x00; // forcer la frequence CPU
      00829C 35 00 50 C6      [ 1]  609 	mov	0x50c6+0, #0x00
                                    610 ;	main.c: 220: PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
      0082A0 C6 50 02         [ 1]  611 	ld	a, 0x5002
      0082A3 AA 06            [ 1]  612 	or	a, #0x06
      0082A5 C7 50 02         [ 1]  613 	ld	0x5002, a
                                    614 ;	main.c: 221: PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull
      0082A8 C6 50 03         [ 1]  615 	ld	a, 0x5003
      0082AB AA 06            [ 1]  616 	or	a, #0x06
      0082AD C7 50 03         [ 1]  617 	ld	0x5003, a
                                    618 ;	main.c: 223: PD_DDR &= ~(1 << 3);    // PD3 en entrée
      0082B0 72 17 50 11      [ 1]  619 	bres	0x5011, #3
                                    620 ;	main.c: 224: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
      0082B4 72 16 50 12      [ 1]  621 	bset	0x5012, #3
                                    622 ;	main.c: 227: while (1) {
      0082B8                        623 00102$:
                                    624 ;	main.c: 228: ds18b20_start_conversion(); // Démarre une conversion de température
      0082B8 CD 81 3B         [ 4]  625 	call	_ds18b20_start_conversion
                                    626 ;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082BB 90 5F            [ 1]  627 	clrw	y
      0082BD 5F               [ 1]  628 	clrw	x
      0082BE                        629 00109$:
      0082BE 90 A3 29 90      [ 2]  630 	cpw	y, #0x2990
      0082C2 9F               [ 1]  631 	ld	a, xl
      0082C3 A2 0A            [ 1]  632 	sbc	a, #0x0a
      0082C5 9E               [ 1]  633 	ld	a, xh
      0082C6 A2 00            [ 1]  634 	sbc	a, #0x00
      0082C8 24 08            [ 1]  635 	jrnc	00105$
                                    636 ;	main.c: 42: __asm__("nop");
      0082CA 9D               [ 1]  637 	nop
                                    638 ;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082CB 90 5C            [ 1]  639 	incw	y
      0082CD 26 EF            [ 1]  640 	jrne	00109$
      0082CF 5C               [ 1]  641 	incw	x
      0082D0 20 EC            [ 2]  642 	jra	00109$
                                    643 ;	main.c: 229: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
      0082D2                        644 00105$:
                                    645 ;	main.c: 231: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
      0082D2 CD 81 48         [ 4]  646 	call	_ds18b20_read_raw
                                    647 ;	main.c: 234: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
      0082D5 90 5F            [ 1]  648 	clrw	y
      0082D7 5D               [ 2]  649 	tnzw	x
      0082D8 2A 02            [ 1]  650 	jrpl	00144$
      0082DA 90 5A            [ 2]  651 	decw	y
      0082DC                        652 00144$:
      0082DC 89               [ 2]  653 	pushw	x
      0082DD 90 89            [ 2]  654 	pushw	y
      0082DF 4B 71            [ 1]  655 	push	#0x71
      0082E1 4B 02            [ 1]  656 	push	#0x02
      0082E3 5F               [ 1]  657 	clrw	x
      0082E4 89               [ 2]  658 	pushw	x
      0082E5 CD 83 DD         [ 4]  659 	call	__mullong
      0082E8 5B 08            [ 2]  660 	addw	sp, #8
      0082EA 4B 64            [ 1]  661 	push	#0x64
      0082EC 4B 00            [ 1]  662 	push	#0x00
      0082EE 4B 00            [ 1]  663 	push	#0x00
      0082F0 4B 00            [ 1]  664 	push	#0x00
      0082F2 89               [ 2]  665 	pushw	x
      0082F3 90 89            [ 2]  666 	pushw	y
      0082F5 CD 83 6C         [ 4]  667 	call	__divulong
      0082F8 5B 08            [ 2]  668 	addw	sp, #8
                                    669 ;	main.c: 237: tm_display_temp_x100(temp_x100);
      0082FA CD 82 52         [ 4]  670 	call	_tm_display_temp_x100
                                    671 ;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0082FD 90 5F            [ 1]  672 	clrw	y
      0082FF 5F               [ 1]  673 	clrw	x
      008300                        674 00112$:
      008300 90 A3 8C C0      [ 2]  675 	cpw	y, #0x8cc0
      008304 9F               [ 1]  676 	ld	a, xl
      008305 A2 0D            [ 1]  677 	sbc	a, #0x0d
      008307 9E               [ 1]  678 	ld	a, xh
      008308 A2 00            [ 1]  679 	sbc	a, #0x00
      00830A 24 AC            [ 1]  680 	jrnc	00102$
                                    681 ;	main.c: 42: __asm__("nop");
      00830C 9D               [ 1]  682 	nop
                                    683 ;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00830D 90 5C            [ 1]  684 	incw	y
      00830F 26 EF            [ 1]  685 	jrne	00112$
      008311 5C               [ 1]  686 	incw	x
      008312 20 EC            [ 2]  687 	jra	00112$
                                    688 ;	main.c: 239: delay_ms(1000); // Pause entre chaque mesure
                                    689 ;	main.c: 241: }
      008314 81               [ 4]  690 	ret
                                    691 	.area CODE
                                    692 	.area CONST
      008024                        693 _digit_to_segment:
      008024 3F                     694 	.db #0x3f	; 63
      008025 06                     695 	.db #0x06	; 6
      008026 5B                     696 	.db #0x5b	; 91
      008027 4F                     697 	.db #0x4f	; 79	'O'
      008028 66                     698 	.db #0x66	; 102	'f'
      008029 6D                     699 	.db #0x6d	; 109	'm'
      00802A 7D                     700 	.db #0x7d	; 125
      00802B 07                     701 	.db #0x07	; 7
      00802C 7F                     702 	.db #0x7f	; 127
      00802D 6F                     703 	.db #0x6f	; 111	'o'
                                    704 	.area INITIALIZER
                                    705 	.area CABS (ABS)
