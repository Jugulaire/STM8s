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
                                     13 	.globl _cc_send_temp_x100
                                     14 	.globl _tm_display_temp_x100
                                     15 	.globl _tm_set_segments
                                     16 	.globl _tm_write_byte
                                     17 	.globl _tm_stop
                                     18 	.globl _tm_start
                                     19 	.globl _tm_delay
                                     20 	.globl _ds18b20_read_raw
                                     21 	.globl _ds18b20_start_conversion
                                     22 	.globl _onewire_read_byte
                                     23 	.globl _onewire_write_byte
                                     24 	.globl _onewire_read_bit
                                     25 	.globl _onewire_write_bit
                                     26 	.globl _onewire_reset
                                     27 	.globl _delay_us
                                     28 	.globl _printf
                                     29 	.globl _putchar
                                     30 ;--------------------------------------------------------
                                     31 ; ram data
                                     32 ;--------------------------------------------------------
                                     33 	.area DATA
                                     34 ;--------------------------------------------------------
                                     35 ; ram data
                                     36 ;--------------------------------------------------------
                                     37 	.area INITIALIZED
                                     38 ;--------------------------------------------------------
                                     39 ; Stack segment in internal ram
                                     40 ;--------------------------------------------------------
                                     41 	.area	SSEG
      000001                         42 __start__stack:
      000001                         43 	.ds	1
                                     44 
                                     45 ;--------------------------------------------------------
                                     46 ; absolute external ram data
                                     47 ;--------------------------------------------------------
                                     48 	.area DABS (ABS)
                                     49 
                                     50 ; default segment ordering for linker
                                     51 	.area HOME
                                     52 	.area GSINIT
                                     53 	.area GSFINAL
                                     54 	.area CONST
                                     55 	.area INITIALIZER
                                     56 	.area CODE
                                     57 
                                     58 ;--------------------------------------------------------
                                     59 ; interrupt vector
                                     60 ;--------------------------------------------------------
                                     61 	.area HOME
      008000                         62 __interrupt_vect:
      008000 82 00 80 07             63 	int s_GSINIT ; reset
                                     64 ;--------------------------------------------------------
                                     65 ; global & static initialisations
                                     66 ;--------------------------------------------------------
                                     67 	.area HOME
                                     68 	.area GSINIT
                                     69 	.area GSFINAL
                                     70 	.area GSINIT
      008007                         71 __sdcc_init_data:
                                     72 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   73 	ldw x, #l_DATA
      00800A 27 07            [ 1]   74 	jreq	00002$
      00800C                         75 00001$:
      00800C 72 4F 00 00      [ 1]   76 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   77 	decw x
      008011 26 F9            [ 1]   78 	jrne	00001$
      008013                         79 00002$:
      008013 AE 00 00         [ 2]   80 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   81 	jreq	00004$
      008018                         82 00003$:
      008018 D6 80 60         [ 1]   83 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   84 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   85 	decw	x
      00801F 26 F7            [ 1]   86 	jrne	00003$
      008021                         87 00004$:
                                     88 ; stm8_genXINIT() end
                                     89 	.area GSFINAL
      008021 CC 80 04         [ 2]   90 	jp	__sdcc_program_startup
                                     91 ;--------------------------------------------------------
                                     92 ; Home
                                     93 ;--------------------------------------------------------
                                     94 	.area HOME
                                     95 	.area HOME
      008004                         96 __sdcc_program_startup:
      008004 CC 86 59         [ 2]   97 	jp	_main
                                     98 ;	return from main will return to caller
                                     99 ;--------------------------------------------------------
                                    100 ; code
                                    101 ;--------------------------------------------------------
                                    102 	.area CODE
                                    103 ;	main.c: 10: static void uart_init(void){
                                    104 ;	-----------------------------------------
                                    105 ;	 function uart_init
                                    106 ;	-----------------------------------------
      008061                        107 _uart_init:
                                    108 ;	main.c: 11: CLK_CKDIVR = 0x00;
      008061 35 00 50 C6      [ 1]  109 	mov	0x50c6+0, #0x00
                                    110 ;	main.c: 13: UART1_BRR1 = (div >> 4) & 0xFF;
      008065 A6 68            [ 1]  111 	ld	a, #0x68
      008067 C7 52 32         [ 1]  112 	ld	0x5232, a
                                    113 ;	main.c: 14: UART1_BRR2 = ((div & 0x0F) | ((div >> 8) & 0xF0));
      00806A A6 83            [ 1]  114 	ld	a, #0x83
      00806C A4 0F            [ 1]  115 	and	a, #0x0f
      00806E C7 52 33         [ 1]  116 	ld	0x5233, a
                                    117 ;	main.c: 15: UART1_CR1 = 0x00; UART1_CR3 = 0x00;
      008071 35 00 52 34      [ 1]  118 	mov	0x5234+0, #0x00
      008075 35 00 52 36      [ 1]  119 	mov	0x5236+0, #0x00
                                    120 ;	main.c: 16: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
      008079 35 0C 52 35      [ 1]  121 	mov	0x5235+0, #0x0c
                                    122 ;	main.c: 17: (void)UART1_SR; (void)UART1_DR;
      00807D C6 52 30         [ 1]  123 	ld	a, 0x5230
      008080 C6 52 31         [ 1]  124 	ld	a, 0x5231
                                    125 ;	main.c: 18: }
      008083 81               [ 4]  126 	ret
                                    127 ;	main.c: 19: int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; } // Gestion des printf 
                                    128 ;	-----------------------------------------
                                    129 ;	 function putchar
                                    130 ;	-----------------------------------------
      008084                        131 _putchar:
      008084                        132 00101$:
      008084 C6 52 30         [ 1]  133 	ld	a, 0x5230
      008087 2A FB            [ 1]  134 	jrpl	00101$
      008089 9F               [ 1]  135 	ld	a, xl
      00808A C7 52 31         [ 1]  136 	ld	0x5231, a
      00808D 5F               [ 1]  137 	clrw	x
      00808E 81               [ 4]  138 	ret
                                    139 ;	main.c: 42: void delay_us(uint16_t us) {
                                    140 ;	-----------------------------------------
                                    141 ;	 function delay_us
                                    142 ;	-----------------------------------------
      00808F                        143 _delay_us:
                                    144 ;	main.c: 43: while(us--) {
      00808F                        145 00101$:
      00808F 90 93            [ 1]  146 	ldw	y, x
      008091 5A               [ 2]  147 	decw	x
      008092 90 5D            [ 2]  148 	tnzw	y
      008094 26 01            [ 1]  149 	jrne	00117$
      008096 81               [ 4]  150 	ret
      008097                        151 00117$:
                                    152 ;	main.c: 44: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008097 9D               [ 1]  153 	nop
      008098 9D               [ 1]  154 	nop
      008099 9D               [ 1]  155 	nop
                                    156 ;	main.c: 45: __asm__("nop"); __asm__("nop"); __asm__("nop");
      00809A 9D               [ 1]  157 	nop
      00809B 9D               [ 1]  158 	nop
      00809C 9D               [ 1]  159 	nop
      00809D 20 F0            [ 2]  160 	jra	00101$
                                    161 ;	main.c: 47: }
      00809F 81               [ 4]  162 	ret
                                    163 ;	main.c: 50: static inline void delay_ms(uint16_t ms) {
                                    164 ;	-----------------------------------------
                                    165 ;	 function delay_ms
                                    166 ;	-----------------------------------------
      0080A0                        167 _delay_ms:
      0080A0 52 0A            [ 2]  168 	sub	sp, #10
      0080A2 1F 05            [ 2]  169 	ldw	(0x05, sp), x
                                    170 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080A4 5F               [ 1]  171 	clrw	x
      0080A5 1F 09            [ 2]  172 	ldw	(0x09, sp), x
      0080A7 1F 07            [ 2]  173 	ldw	(0x07, sp), x
      0080A9                        174 00103$:
      0080A9 1E 05            [ 2]  175 	ldw	x, (0x05, sp)
      0080AB 89               [ 2]  176 	pushw	x
      0080AC AE 03 78         [ 2]  177 	ldw	x, #0x0378
      0080AF CD 87 07         [ 4]  178 	call	___muluint2ulong
      0080B2 5B 02            [ 2]  179 	addw	sp, #2
      0080B4 1F 03            [ 2]  180 	ldw	(0x03, sp), x
      0080B6 17 01            [ 2]  181 	ldw	(0x01, sp), y
      0080B8 1E 09            [ 2]  182 	ldw	x, (0x09, sp)
      0080BA 13 03            [ 2]  183 	cpw	x, (0x03, sp)
      0080BC 7B 08            [ 1]  184 	ld	a, (0x08, sp)
      0080BE 12 02            [ 1]  185 	sbc	a, (0x02, sp)
      0080C0 7B 07            [ 1]  186 	ld	a, (0x07, sp)
      0080C2 12 01            [ 1]  187 	sbc	a, (0x01, sp)
      0080C4 24 0F            [ 1]  188 	jrnc	00105$
                                    189 ;	main.c: 53: __asm__("nop");
      0080C6 9D               [ 1]  190 	nop
                                    191 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080C7 1E 09            [ 2]  192 	ldw	x, (0x09, sp)
      0080C9 5C               [ 1]  193 	incw	x
      0080CA 1F 09            [ 2]  194 	ldw	(0x09, sp), x
      0080CC 26 DB            [ 1]  195 	jrne	00103$
      0080CE 1E 07            [ 2]  196 	ldw	x, (0x07, sp)
      0080D0 5C               [ 1]  197 	incw	x
      0080D1 1F 07            [ 2]  198 	ldw	(0x07, sp), x
      0080D3 20 D4            [ 2]  199 	jra	00103$
      0080D5                        200 00105$:
                                    201 ;	main.c: 54: }
      0080D5 5B 0A            [ 2]  202 	addw	sp, #10
      0080D7 81               [ 4]  203 	ret
                                    204 ;	main.c: 59: uint8_t onewire_reset(void) {
                                    205 ;	-----------------------------------------
                                    206 ;	 function onewire_reset
                                    207 ;	-----------------------------------------
      0080D8                        208 _onewire_reset:
                                    209 ;	main.c: 60: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
      0080D8 72 16 50 11      [ 1]  210 	bset	0x5011, #3
      0080DC 72 17 50 0F      [ 1]  211 	bres	0x500f, #3
                                    212 ;	main.c: 61: delay_us(480);
      0080E0 AE 01 E0         [ 2]  213 	ldw	x, #0x01e0
      0080E3 CD 80 8F         [ 4]  214 	call	_delay_us
                                    215 ;	main.c: 62: DS_INPUT();                    // Relâche la ligne
      0080E6 72 17 50 11      [ 1]  216 	bres	0x5011, #3
                                    217 ;	main.c: 63: delay_us(70);                  // Attend la réponse du capteur
      0080EA AE 00 46         [ 2]  218 	ldw	x, #0x0046
      0080ED CD 80 8F         [ 4]  219 	call	_delay_us
                                    220 ;	main.c: 64: uint8_t presence = !DS_READ(); // 0 = présence détectée
      0080F0 C6 50 10         [ 1]  221 	ld	a, 0x5010
      0080F3 4E               [ 1]  222 	swap	a
      0080F4 48               [ 1]  223 	sll	a
      0080F5 4F               [ 1]  224 	clr	a
      0080F6 49               [ 1]  225 	rlc	a
      0080F7 A0 01            [ 1]  226 	sub	a, #0x01
      0080F9 4F               [ 1]  227 	clr	a
      0080FA 49               [ 1]  228 	rlc	a
                                    229 ;	main.c: 65: delay_us(410);                 // Fin du timing 1-Wire
      0080FB 88               [ 1]  230 	push	a
      0080FC AE 01 9A         [ 2]  231 	ldw	x, #0x019a
      0080FF CD 80 8F         [ 4]  232 	call	_delay_us
      008102 84               [ 1]  233 	pop	a
                                    234 ;	main.c: 66: return presence;
                                    235 ;	main.c: 67: }
      008103 81               [ 4]  236 	ret
                                    237 ;	main.c: 70: void onewire_write_bit(uint8_t bit) {
                                    238 ;	-----------------------------------------
                                    239 ;	 function onewire_write_bit
                                    240 ;	-----------------------------------------
      008104                        241 _onewire_write_bit:
      008104 88               [ 1]  242 	push	a
      008105 6B 01            [ 1]  243 	ld	(0x01, sp), a
                                    244 ;	main.c: 71: DS_OUTPUT(); DS_LOW();
      008107 72 16 50 11      [ 1]  245 	bset	0x5011, #3
      00810B 72 17 50 0F      [ 1]  246 	bres	0x500f, #3
                                    247 ;	main.c: 72: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
      00810F 0D 01            [ 1]  248 	tnz	(0x01, sp)
      008111 27 04            [ 1]  249 	jreq	00103$
      008113 AE 00 06         [ 2]  250 	ldw	x, #0x0006
      008116 BC                     251 	.byte 0xbc
      008117                        252 00103$:
      008117 AE 00 3C         [ 2]  253 	ldw	x, #0x003c
      00811A                        254 00104$:
      00811A CD 80 8F         [ 4]  255 	call	_delay_us
                                    256 ;	main.c: 73: DS_INPUT();                    // Libère la ligne
      00811D 72 17 50 11      [ 1]  257 	bres	0x5011, #3
                                    258 ;	main.c: 74: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
      008121 0D 01            [ 1]  259 	tnz	(0x01, sp)
      008123 27 05            [ 1]  260 	jreq	00105$
      008125 AE 00 40         [ 2]  261 	ldw	x, #0x0040
      008128 20 03            [ 2]  262 	jra	00106$
      00812A                        263 00105$:
      00812A AE 00 0A         [ 2]  264 	ldw	x, #0x000a
      00812D                        265 00106$:
      00812D 84               [ 1]  266 	pop	a
      00812E CC 80 8F         [ 2]  267 	jp	_delay_us
                                    268 ;	main.c: 75: }
      008131 84               [ 1]  269 	pop	a
      008132 81               [ 4]  270 	ret
                                    271 ;	main.c: 78: uint8_t onewire_read_bit(void) {
                                    272 ;	-----------------------------------------
                                    273 ;	 function onewire_read_bit
                                    274 ;	-----------------------------------------
      008133                        275 _onewire_read_bit:
                                    276 ;	main.c: 80: DS_OUTPUT(); DS_LOW();
      008133 72 16 50 11      [ 1]  277 	bset	0x5011, #3
      008137 72 17 50 0F      [ 1]  278 	bres	0x500f, #3
                                    279 ;	main.c: 81: delay_us(6);                   // Pulse d'initiation de lecture
      00813B AE 00 06         [ 2]  280 	ldw	x, #0x0006
      00813E CD 80 8F         [ 4]  281 	call	_delay_us
                                    282 ;	main.c: 82: DS_INPUT();                    // Libère la ligne pour lire
      008141 72 17 50 11      [ 1]  283 	bres	0x5011, #3
                                    284 ;	main.c: 83: delay_us(9);                   // Délai standard
      008145 AE 00 09         [ 2]  285 	ldw	x, #0x0009
      008148 CD 80 8F         [ 4]  286 	call	_delay_us
                                    287 ;	main.c: 84: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
      00814B 72 07 50 10 03   [ 2]  288 	btjf	0x5010, #3, 00103$
      008150 5F               [ 1]  289 	clrw	x
      008151 5C               [ 1]  290 	incw	x
      008152 21                     291 	.byte 0x21
      008153                        292 00103$:
      008153 5F               [ 1]  293 	clrw	x
      008154                        294 00104$:
      008154 9F               [ 1]  295 	ld	a, xl
                                    296 ;	main.c: 85: delay_us(55);                  // Fin du slot
      008155 88               [ 1]  297 	push	a
      008156 AE 00 37         [ 2]  298 	ldw	x, #0x0037
      008159 CD 80 8F         [ 4]  299 	call	_delay_us
      00815C 84               [ 1]  300 	pop	a
                                    301 ;	main.c: 86: return bit;
                                    302 ;	main.c: 87: }
      00815D 81               [ 4]  303 	ret
                                    304 ;	main.c: 90: void onewire_write_byte(uint8_t byte) {
                                    305 ;	-----------------------------------------
                                    306 ;	 function onewire_write_byte
                                    307 ;	-----------------------------------------
      00815E                        308 _onewire_write_byte:
      00815E 52 02            [ 2]  309 	sub	sp, #2
      008160 6B 01            [ 1]  310 	ld	(0x01, sp), a
                                    311 ;	main.c: 91: for (uint8_t i = 0; i < 8; i++) {
      008162 0F 02            [ 1]  312 	clr	(0x02, sp)
      008164                        313 00103$:
      008164 7B 02            [ 1]  314 	ld	a, (0x02, sp)
      008166 A1 08            [ 1]  315 	cp	a, #0x08
      008168 24 0D            [ 1]  316 	jrnc	00105$
                                    317 ;	main.c: 92: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
      00816A 7B 01            [ 1]  318 	ld	a, (0x01, sp)
      00816C A4 01            [ 1]  319 	and	a, #0x01
      00816E CD 81 04         [ 4]  320 	call	_onewire_write_bit
                                    321 ;	main.c: 93: byte >>= 1;
      008171 04 01            [ 1]  322 	srl	(0x01, sp)
                                    323 ;	main.c: 91: for (uint8_t i = 0; i < 8; i++) {
      008173 0C 02            [ 1]  324 	inc	(0x02, sp)
      008175 20 ED            [ 2]  325 	jra	00103$
      008177                        326 00105$:
                                    327 ;	main.c: 95: }
      008177 5B 02            [ 2]  328 	addw	sp, #2
      008179 81               [ 4]  329 	ret
                                    330 ;	main.c: 98: uint8_t onewire_read_byte(void) {
                                    331 ;	-----------------------------------------
                                    332 ;	 function onewire_read_byte
                                    333 ;	-----------------------------------------
      00817A                        334 _onewire_read_byte:
      00817A 52 02            [ 2]  335 	sub	sp, #2
                                    336 ;	main.c: 99: uint8_t byte = 0;
      00817C 0F 01            [ 1]  337 	clr	(0x01, sp)
                                    338 ;	main.c: 100: for (uint8_t i = 0; i < 8; i++) {
      00817E 0F 02            [ 1]  339 	clr	(0x02, sp)
      008180                        340 00105$:
      008180 7B 02            [ 1]  341 	ld	a, (0x02, sp)
      008182 A1 08            [ 1]  342 	cp	a, #0x08
      008184 24 11            [ 1]  343 	jrnc	00103$
                                    344 ;	main.c: 101: byte >>= 1;
      008186 04 01            [ 1]  345 	srl	(0x01, sp)
                                    346 ;	main.c: 102: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
      008188 CD 81 33         [ 4]  347 	call	_onewire_read_bit
      00818B 4D               [ 1]  348 	tnz	a
      00818C 27 05            [ 1]  349 	jreq	00106$
      00818E 08 01            [ 1]  350 	sll	(0x01, sp)
      008190 99               [ 1]  351 	scf
      008191 06 01            [ 1]  352 	rrc	(0x01, sp)
      008193                        353 00106$:
                                    354 ;	main.c: 100: for (uint8_t i = 0; i < 8; i++) {
      008193 0C 02            [ 1]  355 	inc	(0x02, sp)
      008195 20 E9            [ 2]  356 	jra	00105$
      008197                        357 00103$:
                                    358 ;	main.c: 104: return byte;
      008197 7B 01            [ 1]  359 	ld	a, (0x01, sp)
                                    360 ;	main.c: 105: }
      008199 5B 02            [ 2]  361 	addw	sp, #2
      00819B 81               [ 4]  362 	ret
                                    363 ;	main.c: 108: void ds18b20_start_conversion(void) {
                                    364 ;	-----------------------------------------
                                    365 ;	 function ds18b20_start_conversion
                                    366 ;	-----------------------------------------
      00819C                        367 _ds18b20_start_conversion:
                                    368 ;	main.c: 109: onewire_reset();
      00819C CD 80 D8         [ 4]  369 	call	_onewire_reset
                                    370 ;	main.c: 110: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
      00819F A6 CC            [ 1]  371 	ld	a, #0xcc
      0081A1 CD 81 5E         [ 4]  372 	call	_onewire_write_byte
                                    373 ;	main.c: 111: onewire_write_byte(0x44); // Convert T (lance mesure)
      0081A4 A6 44            [ 1]  374 	ld	a, #0x44
                                    375 ;	main.c: 112: }
      0081A6 CC 81 5E         [ 2]  376 	jp	_onewire_write_byte
                                    377 ;	main.c: 115: int16_t ds18b20_read_raw(void) {
                                    378 ;	-----------------------------------------
                                    379 ;	 function ds18b20_read_raw
                                    380 ;	-----------------------------------------
      0081A9                        381 _ds18b20_read_raw:
      0081A9 52 04            [ 2]  382 	sub	sp, #4
                                    383 ;	main.c: 116: onewire_reset();
      0081AB CD 80 D8         [ 4]  384 	call	_onewire_reset
                                    385 ;	main.c: 117: onewire_write_byte(0xCC); // Skip ROM
      0081AE A6 CC            [ 1]  386 	ld	a, #0xcc
      0081B0 CD 81 5E         [ 4]  387 	call	_onewire_write_byte
                                    388 ;	main.c: 118: onewire_write_byte(0xBE); // Read Scratchpad
      0081B3 A6 BE            [ 1]  389 	ld	a, #0xbe
      0081B5 CD 81 5E         [ 4]  390 	call	_onewire_write_byte
                                    391 ;	main.c: 120: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
      0081B8 CD 81 7A         [ 4]  392 	call	_onewire_read_byte
                                    393 ;	main.c: 121: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
      0081BB 88               [ 1]  394 	push	a
      0081BC CD 81 7A         [ 4]  395 	call	_onewire_read_byte
      0081BF 95               [ 1]  396 	ld	xh, a
      0081C0 84               [ 1]  397 	pop	a
                                    398 ;	main.c: 123: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
      0081C1 0F 02            [ 1]  399 	clr	(0x02, sp)
      0081C3 0F 03            [ 1]  400 	clr	(0x03, sp)
      0081C5 1A 02            [ 1]  401 	or	a, (0x02, sp)
      0081C7 02               [ 1]  402 	rlwa	x
      0081C8 1A 03            [ 1]  403 	or	a, (0x03, sp)
      0081CA 95               [ 1]  404 	ld	xh, a
                                    405 ;	main.c: 124: }
      0081CB 5B 04            [ 2]  406 	addw	sp, #4
      0081CD 81               [ 4]  407 	ret
                                    408 ;	main.c: 142: void tm_delay() {
                                    409 ;	-----------------------------------------
                                    410 ;	 function tm_delay
                                    411 ;	-----------------------------------------
      0081CE                        412 _tm_delay:
      0081CE 52 02            [ 2]  413 	sub	sp, #2
                                    414 ;	main.c: 143: for (volatile int i = 0; i < 50; i++) __asm__("nop");
      0081D0 5F               [ 1]  415 	clrw	x
      0081D1 1F 01            [ 2]  416 	ldw	(0x01, sp), x
      0081D3                        417 00103$:
      0081D3 1E 01            [ 2]  418 	ldw	x, (0x01, sp)
      0081D5 A3 00 32         [ 2]  419 	cpw	x, #0x0032
      0081D8 2E 08            [ 1]  420 	jrsge	00105$
      0081DA 9D               [ 1]  421 	nop
      0081DB 1E 01            [ 2]  422 	ldw	x, (0x01, sp)
      0081DD 5C               [ 1]  423 	incw	x
      0081DE 1F 01            [ 2]  424 	ldw	(0x01, sp), x
      0081E0 20 F1            [ 2]  425 	jra	00103$
      0081E2                        426 00105$:
                                    427 ;	main.c: 144: }
      0081E2 5B 02            [ 2]  428 	addw	sp, #2
      0081E4 81               [ 4]  429 	ret
                                    430 ;	main.c: 146: void tm_start() {
                                    431 ;	-----------------------------------------
                                    432 ;	 function tm_start
                                    433 ;	-----------------------------------------
      0081E5                        434 _tm_start:
                                    435 ;	main.c: 147: TM_DIO_DDR |= (1 << TM_DIO_PIN);
      0081E5 72 12 50 02      [ 1]  436 	bset	0x5002, #1
                                    437 ;	main.c: 148: TM_CLK_DDR |= (1 << TM_CLK_PIN);
      0081E9 72 14 50 02      [ 1]  438 	bset	0x5002, #2
                                    439 ;	main.c: 149: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      0081ED 72 12 50 00      [ 1]  440 	bset	0x5000, #1
                                    441 ;	main.c: 150: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      0081F1 72 14 50 00      [ 1]  442 	bset	0x5000, #2
                                    443 ;	main.c: 151: tm_delay();
      0081F5 CD 81 CE         [ 4]  444 	call	_tm_delay
                                    445 ;	main.c: 152: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      0081F8 72 13 50 00      [ 1]  446 	bres	0x5000, #1
                                    447 ;	main.c: 153: tm_delay();
      0081FC CD 81 CE         [ 4]  448 	call	_tm_delay
                                    449 ;	main.c: 154: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      0081FF 72 15 50 00      [ 1]  450 	bres	0x5000, #2
                                    451 ;	main.c: 155: }
      008203 81               [ 4]  452 	ret
                                    453 ;	main.c: 157: void tm_stop() {
                                    454 ;	-----------------------------------------
                                    455 ;	 function tm_stop
                                    456 ;	-----------------------------------------
      008204                        457 _tm_stop:
                                    458 ;	main.c: 158: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008204 72 15 50 00      [ 1]  459 	bres	0x5000, #2
                                    460 ;	main.c: 159: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      008208 72 13 50 00      [ 1]  461 	bres	0x5000, #1
                                    462 ;	main.c: 160: tm_delay();
      00820C CD 81 CE         [ 4]  463 	call	_tm_delay
                                    464 ;	main.c: 161: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      00820F 72 14 50 00      [ 1]  465 	bset	0x5000, #2
                                    466 ;	main.c: 162: tm_delay();
      008213 CD 81 CE         [ 4]  467 	call	_tm_delay
                                    468 ;	main.c: 163: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      008216 72 12 50 00      [ 1]  469 	bset	0x5000, #1
                                    470 ;	main.c: 164: }
      00821A 81               [ 4]  471 	ret
                                    472 ;	main.c: 166: void tm_write_byte(uint8_t b) {
                                    473 ;	-----------------------------------------
                                    474 ;	 function tm_write_byte
                                    475 ;	-----------------------------------------
      00821B                        476 _tm_write_byte:
      00821B 52 02            [ 2]  477 	sub	sp, #2
      00821D 6B 01            [ 1]  478 	ld	(0x01, sp), a
                                    479 ;	main.c: 167: for (uint8_t i = 0; i < 8; i++) {
      00821F 0F 02            [ 1]  480 	clr	(0x02, sp)
      008221                        481 00106$:
                                    482 ;	main.c: 168: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008221 C6 50 00         [ 1]  483 	ld	a, 0x5000
      008224 A4 FB            [ 1]  484 	and	a, #0xfb
                                    485 ;	main.c: 167: for (uint8_t i = 0; i < 8; i++) {
      008226 88               [ 1]  486 	push	a
      008227 7B 03            [ 1]  487 	ld	a, (0x03, sp)
      008229 A1 08            [ 1]  488 	cp	a, #0x08
      00822B 84               [ 1]  489 	pop	a
      00822C 24 29            [ 1]  490 	jrnc	00104$
                                    491 ;	main.c: 168: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      00822E C7 50 00         [ 1]  492 	ld	0x5000, a
      008231 C6 50 00         [ 1]  493 	ld	a, 0x5000
                                    494 ;	main.c: 169: if (b & 0x01)
      008234 88               [ 1]  495 	push	a
      008235 7B 02            [ 1]  496 	ld	a, (0x02, sp)
      008237 44               [ 1]  497 	srl	a
      008238 84               [ 1]  498 	pop	a
      008239 24 07            [ 1]  499 	jrnc	00102$
                                    500 ;	main.c: 170: TM_DIO_PORT |= (1 << TM_DIO_PIN);
      00823B AA 02            [ 1]  501 	or	a, #0x02
      00823D C7 50 00         [ 1]  502 	ld	0x5000, a
      008240 20 05            [ 2]  503 	jra	00103$
      008242                        504 00102$:
                                    505 ;	main.c: 172: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
      008242 A4 FD            [ 1]  506 	and	a, #0xfd
      008244 C7 50 00         [ 1]  507 	ld	0x5000, a
      008247                        508 00103$:
                                    509 ;	main.c: 173: tm_delay();
      008247 CD 81 CE         [ 4]  510 	call	_tm_delay
                                    511 ;	main.c: 174: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      00824A 72 14 50 00      [ 1]  512 	bset	0x5000, #2
                                    513 ;	main.c: 175: tm_delay();
      00824E CD 81 CE         [ 4]  514 	call	_tm_delay
                                    515 ;	main.c: 176: b >>= 1;
      008251 04 01            [ 1]  516 	srl	(0x01, sp)
                                    517 ;	main.c: 167: for (uint8_t i = 0; i < 8; i++) {
      008253 0C 02            [ 1]  518 	inc	(0x02, sp)
      008255 20 CA            [ 2]  519 	jra	00106$
      008257                        520 00104$:
                                    521 ;	main.c: 180: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008257 C7 50 00         [ 1]  522 	ld	0x5000, a
                                    523 ;	main.c: 181: TM_DIO_DDR &= ~(1 << TM_DIO_PIN); // entrée
      00825A 72 13 50 02      [ 1]  524 	bres	0x5002, #1
                                    525 ;	main.c: 182: tm_delay();
      00825E CD 81 CE         [ 4]  526 	call	_tm_delay
                                    527 ;	main.c: 183: TM_CLK_PORT |= (1 << TM_CLK_PIN);
      008261 72 14 50 00      [ 1]  528 	bset	0x5000, #2
                                    529 ;	main.c: 184: tm_delay();
      008265 CD 81 CE         [ 4]  530 	call	_tm_delay
                                    531 ;	main.c: 185: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
      008268 72 15 50 00      [ 1]  532 	bres	0x5000, #2
                                    533 ;	main.c: 186: TM_DIO_DDR |= (1 << TM_DIO_PIN); // repasse en sortie
      00826C 72 12 50 02      [ 1]  534 	bset	0x5002, #1
                                    535 ;	main.c: 187: }
      008270 5B 02            [ 2]  536 	addw	sp, #2
      008272 81               [ 4]  537 	ret
                                    538 ;	main.c: 190: void tm_set_segments(uint8_t *segments, uint8_t length) {
                                    539 ;	-----------------------------------------
                                    540 ;	 function tm_set_segments
                                    541 ;	-----------------------------------------
      008273                        542 _tm_set_segments:
      008273 52 04            [ 2]  543 	sub	sp, #4
      008275 1F 02            [ 2]  544 	ldw	(0x02, sp), x
      008277 6B 01            [ 1]  545 	ld	(0x01, sp), a
                                    546 ;	main.c: 191: tm_start();
      008279 CD 81 E5         [ 4]  547 	call	_tm_start
                                    548 ;	main.c: 192: tm_write_byte(0x40); // Commande : auto-increment mode
      00827C A6 40            [ 1]  549 	ld	a, #0x40
      00827E CD 82 1B         [ 4]  550 	call	_tm_write_byte
                                    551 ;	main.c: 193: tm_stop();
      008281 CD 82 04         [ 4]  552 	call	_tm_stop
                                    553 ;	main.c: 195: tm_start();
      008284 CD 81 E5         [ 4]  554 	call	_tm_start
                                    555 ;	main.c: 196: tm_write_byte(0xC0); // Adresse de départ = 0
      008287 A6 C0            [ 1]  556 	ld	a, #0xc0
      008289 CD 82 1B         [ 4]  557 	call	_tm_write_byte
                                    558 ;	main.c: 197: for (uint8_t i = 0; i < length; i++) {
      00828C 0F 04            [ 1]  559 	clr	(0x04, sp)
      00828E                        560 00103$:
      00828E 7B 04            [ 1]  561 	ld	a, (0x04, sp)
      008290 11 01            [ 1]  562 	cp	a, (0x01, sp)
      008292 24 0F            [ 1]  563 	jrnc	00101$
                                    564 ;	main.c: 198: tm_write_byte(segments[i]);
      008294 5F               [ 1]  565 	clrw	x
      008295 7B 04            [ 1]  566 	ld	a, (0x04, sp)
      008297 97               [ 1]  567 	ld	xl, a
      008298 72 FB 02         [ 2]  568 	addw	x, (0x02, sp)
      00829B F6               [ 1]  569 	ld	a, (x)
      00829C CD 82 1B         [ 4]  570 	call	_tm_write_byte
                                    571 ;	main.c: 197: for (uint8_t i = 0; i < length; i++) {
      00829F 0C 04            [ 1]  572 	inc	(0x04, sp)
      0082A1 20 EB            [ 2]  573 	jra	00103$
      0082A3                        574 00101$:
                                    575 ;	main.c: 200: tm_stop();
      0082A3 CD 82 04         [ 4]  576 	call	_tm_stop
                                    577 ;	main.c: 202: tm_start();
      0082A6 CD 81 E5         [ 4]  578 	call	_tm_start
                                    579 ;	main.c: 203: tm_write_byte(0x88 | 0x07); // Affichage ON, luminosité max (0x00 à 0x07)
      0082A9 A6 8F            [ 1]  580 	ld	a, #0x8f
      0082AB CD 82 1B         [ 4]  581 	call	_tm_write_byte
                                    582 ;	main.c: 204: tm_stop();
      0082AE 5B 04            [ 2]  583 	addw	sp, #4
                                    584 ;	main.c: 205: }
      0082B0 CC 82 04         [ 2]  585 	jp	_tm_stop
                                    586 ;	main.c: 208: void tm_display_temp_x100(int temp_x100) {
                                    587 ;	-----------------------------------------
                                    588 ;	 function tm_display_temp_x100
                                    589 ;	-----------------------------------------
      0082B3                        590 _tm_display_temp_x100:
      0082B3 52 0A            [ 2]  591 	sub	sp, #10
                                    592 ;	main.c: 209: int val = temp_x100;
      0082B5 1F 05            [ 2]  593 	ldw	(0x05, sp), x
                                    594 ;	main.c: 210: if (val < 0) val = -val;  // Ignore le signe ici (optionnel à améliorer)
      0082B7 5D               [ 2]  595 	tnzw	x
      0082B8 2A 03            [ 1]  596 	jrpl	00111$
      0082BA 50               [ 2]  597 	negw	x
      0082BB 1F 05            [ 2]  598 	ldw	(0x05, sp), x
                                    599 ;	main.c: 214: for (int i = 3; i >= 0; i--) {
      0082BD                        600 00111$:
      0082BD AE 00 03         [ 2]  601 	ldw	x, #0x0003
      0082C0 1F 09            [ 2]  602 	ldw	(0x09, sp), x
      0082C2                        603 00105$:
      0082C2 0D 09            [ 1]  604 	tnz	(0x09, sp)
      0082C4 2B 28            [ 1]  605 	jrmi	00103$
                                    606 ;	main.c: 215: digits[i] = digit_to_segment[val % 10];
      0082C6 96               [ 1]  607 	ldw	x, sp
      0082C7 5C               [ 1]  608 	incw	x
      0082C8 72 FB 09         [ 2]  609 	addw	x, (0x09, sp)
      0082CB 1F 07            [ 2]  610 	ldw	(0x07, sp), x
      0082CD 4B 0A            [ 1]  611 	push	#0x0a
      0082CF 4B 00            [ 1]  612 	push	#0x00
      0082D1 1E 07            [ 2]  613 	ldw	x, (0x07, sp)
      0082D3 CD 87 E0         [ 4]  614 	call	__modsint
      0082D6 D6 80 24         [ 1]  615 	ld	a, (_digit_to_segment+0, x)
      0082D9 1E 07            [ 2]  616 	ldw	x, (0x07, sp)
      0082DB F7               [ 1]  617 	ld	(x), a
                                    618 ;	main.c: 216: val /= 10;
      0082DC 4B 0A            [ 1]  619 	push	#0x0a
      0082DE 4B 00            [ 1]  620 	push	#0x00
      0082E0 1E 07            [ 2]  621 	ldw	x, (0x07, sp)
      0082E2 CD 88 74         [ 4]  622 	call	__divsint
      0082E5 1F 05            [ 2]  623 	ldw	(0x05, sp), x
                                    624 ;	main.c: 214: for (int i = 3; i >= 0; i--) {
      0082E7 1E 09            [ 2]  625 	ldw	x, (0x09, sp)
      0082E9 5A               [ 2]  626 	decw	x
      0082EA 1F 09            [ 2]  627 	ldw	(0x09, sp), x
      0082EC 20 D4            [ 2]  628 	jra	00105$
      0082EE                        629 00103$:
                                    630 ;	main.c: 220: digits[1] |= 0x80;
      0082EE 09 02            [ 1]  631 	rlc	(0x02, sp)
      0082F0 99               [ 1]  632 	scf
      0082F1 06 02            [ 1]  633 	rrc	(0x02, sp)
                                    634 ;	main.c: 222: tm_set_segments(digits, 4);
      0082F3 A6 04            [ 1]  635 	ld	a, #0x04
      0082F5 96               [ 1]  636 	ldw	x, sp
      0082F6 5C               [ 1]  637 	incw	x
      0082F7 CD 82 73         [ 4]  638 	call	_tm_set_segments
                                    639 ;	main.c: 223: }
      0082FA 5B 0A            [ 2]  640 	addw	sp, #10
      0082FC 81               [ 4]  641 	ret
                                    642 ;	main.c: 240: static void gpio_init(void){
                                    643 ;	-----------------------------------------
                                    644 ;	 function gpio_init
                                    645 ;	-----------------------------------------
      0082FD                        646 _gpio_init:
                                    647 ;	main.c: 242: PC_DDR |= (1<<5) | (1<<MOSI_BIT);
      0082FD C6 50 0C         [ 1]  648 	ld	a, 0x500c
      008300 AA 60            [ 1]  649 	or	a, #0x60
      008302 C7 50 0C         [ 1]  650 	ld	0x500c, a
                                    651 ;	main.c: 243: PC_CR1 |= (1<<5) | (1<<MOSI_BIT);
      008305 C6 50 0D         [ 1]  652 	ld	a, 0x500d
      008308 AA 60            [ 1]  653 	or	a, #0x60
      00830A C7 50 0D         [ 1]  654 	ld	0x500d, a
                                    655 ;	main.c: 245: PC_DDR &= (uint8_t)~(1<<MISO_BIT);
      00830D 72 1F 50 0C      [ 1]  656 	bres	0x500c, #7
                                    657 ;	main.c: 246: PC_CR1 &= (uint8_t)~(1<<MISO_BIT);
      008311 72 1F 50 0D      [ 1]  658 	bres	0x500d, #7
                                    659 ;	main.c: 248: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
      008315 72 14 50 11      [ 1]  660 	bset	0x5011, #2
      008319 72 14 50 12      [ 1]  661 	bset	0x5012, #2
      00831D 72 14 50 0F      [ 1]  662 	bset	0x500f, #2
                                    663 ;	main.c: 250: PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
      008321 72 19 50 11      [ 1]  664 	bres	0x5011, #4
      008325 72 19 50 12      [ 1]  665 	bres	0x5012, #4
                                    666 ;	main.c: 252: PD_DDR &= (uint8_t)~(1<<3);
      008329 72 17 50 11      [ 1]  667 	bres	0x5011, #3
                                    668 ;	main.c: 253: PD_CR1 |= (1<<3);
      00832D 72 16 50 12      [ 1]  669 	bset	0x5012, #3
                                    670 ;	main.c: 254: }
      008331 81               [ 4]  671 	ret
                                    672 ;	main.c: 257: static void spi_init(void){
                                    673 ;	-----------------------------------------
                                    674 ;	 function spi_init
                                    675 ;	-----------------------------------------
      008332                        676 _spi_init:
                                    677 ;	main.c: 259: SPI_CR1 = (1<<SPI_CR1_MSTR) | (1<<SPI_CR1_BR2) | (1<<SPI_CR1_BR1) | (1<<SPI_CR1_BR0);
      008332 35 3C 52 00      [ 1]  678 	mov	0x5200+0, #0x3c
                                    679 ;	main.c: 260: SPI_CR2 = (1<<SPI_CR2_SSM) | (1<<SPI_CR2_SSI);
      008336 35 03 52 01      [ 1]  680 	mov	0x5201+0, #0x03
                                    681 ;	main.c: 261: SPI_CR1 |= (1<<SPI_CR1_SPE);
      00833A 72 1C 52 00      [ 1]  682 	bset	0x5200, #6
                                    683 ;	main.c: 262: }
      00833E 81               [ 4]  684 	ret
                                    685 ;	main.c: 263: static uint8_t spi_txrx(uint8_t v){
                                    686 ;	-----------------------------------------
                                    687 ;	 function spi_txrx
                                    688 ;	-----------------------------------------
      00833F                        689 _spi_txrx:
                                    690 ;	main.c: 264: SPI_DR = v;
      00833F C7 52 04         [ 1]  691 	ld	0x5204, a
                                    692 ;	main.c: 265: while(!(SPI_SR & (1<<SPI_SR_TXE)));
      008342                        693 00101$:
      008342 72 03 52 03 FB   [ 2]  694 	btjf	0x5203, #1, 00101$
                                    695 ;	main.c: 266: while(!(SPI_SR & (1<<SPI_SR_RXNE)));
      008347                        696 00104$:
      008347 72 01 52 03 FB   [ 2]  697 	btjf	0x5203, #0, 00104$
                                    698 ;	main.c: 267: return SPI_DR;
      00834C C6 52 04         [ 1]  699 	ld	a, 0x5204
                                    700 ;	main.c: 268: }
      00834F 81               [ 4]  701 	ret
                                    702 ;	main.c: 269: static void spi_wait_idle(void){ while(SPI_SR & (1<<SPI_SR_BSY)); }
                                    703 ;	-----------------------------------------
                                    704 ;	 function spi_wait_idle
                                    705 ;	-----------------------------------------
      008350                        706 _spi_wait_idle:
      008350                        707 00101$:
      008350 C6 52 03         [ 1]  708 	ld	a, 0x5203
      008353 2B FB            [ 1]  709 	jrmi	00101$
      008355 81               [ 4]  710 	ret
                                    711 ;	main.c: 289: static uint8_t cc_select(void){
                                    712 ;	-----------------------------------------
                                    713 ;	 function cc_select
                                    714 ;	-----------------------------------------
      008356                        715 _cc_select:
      008356 52 04            [ 2]  716 	sub	sp, #4
                                    717 ;	main.c: 290: CSN_LOW();
      008358 72 15 50 0F      [ 1]  718 	bres	0x500f, #2
                                    719 ;	main.c: 293: while(MISO_IS_HIGH()){
      00835C 5F               [ 1]  720 	clrw	x
      00835D 1F 03            [ 2]  721 	ldw	(0x03, sp), x
      00835F 1F 01            [ 2]  722 	ldw	(0x01, sp), x
      008361                        723 00103$:
      008361 C6 50 0B         [ 1]  724 	ld	a, 0x500b
      008364 2A 20            [ 1]  725 	jrpl	00105$
                                    726 ;	main.c: 294: if(++guard>100000UL){ CSN_HIGH(); return 0; }
      008366 1E 03            [ 2]  727 	ldw	x, (0x03, sp)
      008368 5C               [ 1]  728 	incw	x
      008369 1F 03            [ 2]  729 	ldw	(0x03, sp), x
      00836B 26 05            [ 1]  730 	jrne	00124$
      00836D 1E 01            [ 2]  731 	ldw	x, (0x01, sp)
      00836F 5C               [ 1]  732 	incw	x
      008370 1F 01            [ 2]  733 	ldw	(0x01, sp), x
      008372                        734 00124$:
      008372 AE 86 A0         [ 2]  735 	ldw	x, #0x86a0
      008375 13 03            [ 2]  736 	cpw	x, (0x03, sp)
      008377 A6 01            [ 1]  737 	ld	a, #0x01
      008379 12 02            [ 1]  738 	sbc	a, (0x02, sp)
      00837B 4F               [ 1]  739 	clr	a
      00837C 12 01            [ 1]  740 	sbc	a, (0x01, sp)
      00837E 24 E1            [ 1]  741 	jrnc	00103$
      008380 72 14 50 0F      [ 1]  742 	bset	0x500f, #2
      008384 4F               [ 1]  743 	clr	a
                                    744 ;	main.c: 296: return 1;
      008385 C5                     745 	.byte 0xc5
      008386                        746 00105$:
      008386 A6 01            [ 1]  747 	ld	a, #0x01
      008388                        748 00106$:
                                    749 ;	main.c: 297: }
      008388 5B 04            [ 2]  750 	addw	sp, #4
      00838A 81               [ 4]  751 	ret
                                    752 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
                                    753 ;	-----------------------------------------
                                    754 ;	 function cc_deselect
                                    755 ;	-----------------------------------------
      00838B                        756 _cc_deselect:
      00838B CD 83 50         [ 4]  757 	call	_spi_wait_idle
      00838E 72 14 50 0F      [ 1]  758 	bset	0x500f, #2
      008392 81               [ 4]  759 	ret
                                    760 ;	main.c: 300: static uint8_t cc_strobe(uint8_t st){
                                    761 ;	-----------------------------------------
                                    762 ;	 function cc_strobe
                                    763 ;	-----------------------------------------
      008393                        764 _cc_strobe:
      008393 52 02            [ 2]  765 	sub	sp, #2
      008395 6B 02            [ 1]  766 	ld	(0x02, sp), a
                                    767 ;	main.c: 301: if(!cc_select()) return 0xFF;
      008397 CD 83 56         [ 4]  768 	call	_cc_select
      00839A 4D               [ 1]  769 	tnz	a
      00839B 26 04            [ 1]  770 	jrne	00102$
      00839D A6 FF            [ 1]  771 	ld	a, #0xff
      00839F 20 10            [ 2]  772 	jra	00104$
      0083A1                        773 00102$:
                                    774 ;	main.c: 302: uint8_t s = spi_txrx(st);
      0083A1 7B 02            [ 1]  775 	ld	a, (0x02, sp)
      0083A3 CD 83 3F         [ 4]  776 	call	_spi_txrx
      0083A6 6B 01            [ 1]  777 	ld	(0x01, sp), a
                                    778 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0083A8 CD 83 50         [ 4]  779 	call	_spi_wait_idle
      0083AB 72 14 50 0F      [ 1]  780 	bset	0x500f, #2
                                    781 ;	main.c: 304: return s;
      0083AF 7B 01            [ 1]  782 	ld	a, (0x01, sp)
      0083B1                        783 00104$:
                                    784 ;	main.c: 305: }
      0083B1 5B 02            [ 2]  785 	addw	sp, #2
      0083B3 81               [ 4]  786 	ret
                                    787 ;	main.c: 306: static void cc_write_reg(uint8_t a, uint8_t v){
                                    788 ;	-----------------------------------------
                                    789 ;	 function cc_write_reg
                                    790 ;	-----------------------------------------
      0083B4                        791 _cc_write_reg:
      0083B4 88               [ 1]  792 	push	a
      0083B5 6B 01            [ 1]  793 	ld	(0x01, sp), a
                                    794 ;	main.c: 307: if(!cc_select()) return;
      0083B7 CD 83 56         [ 4]  795 	call	_cc_select
      0083BA 4D               [ 1]  796 	tnz	a
      0083BB 27 15            [ 1]  797 	jreq	00104$
                                    798 ;	main.c: 308: spi_txrx(a); spi_txrx(v);
      0083BD 7B 01            [ 1]  799 	ld	a, (0x01, sp)
      0083BF CD 83 3F         [ 4]  800 	call	_spi_txrx
      0083C2 7B 04            [ 1]  801 	ld	a, (0x04, sp)
      0083C4 CD 83 3F         [ 4]  802 	call	_spi_txrx
                                    803 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0083C7 CD 83 50         [ 4]  804 	call	_spi_wait_idle
      0083CA C6 50 0F         [ 1]  805 	ld	a, 0x500f
      0083CD AA 04            [ 1]  806 	or	a, #0x04
      0083CF C7 50 0F         [ 1]  807 	ld	0x500f, a
                                    808 ;	main.c: 309: cc_deselect();
      0083D2                        809 00104$:
                                    810 ;	main.c: 310: }
      0083D2 84               [ 1]  811 	pop	a
      0083D3 85               [ 2]  812 	popw	x
      0083D4 84               [ 1]  813 	pop	a
      0083D5 FC               [ 2]  814 	jp	(x)
                                    815 ;	main.c: 311: static uint8_t cc_read_status(uint8_t addr){
                                    816 ;	-----------------------------------------
                                    817 ;	 function cc_read_status
                                    818 ;	-----------------------------------------
      0083D6                        819 _cc_read_status:
      0083D6 52 02            [ 2]  820 	sub	sp, #2
      0083D8 6B 02            [ 1]  821 	ld	(0x02, sp), a
                                    822 ;	main.c: 312: if(!cc_select()) return 0xFF;
      0083DA CD 83 56         [ 4]  823 	call	_cc_select
      0083DD 4D               [ 1]  824 	tnz	a
      0083DE 26 04            [ 1]  825 	jrne	00102$
      0083E0 A6 FF            [ 1]  826 	ld	a, #0xff
      0083E2 20 17            [ 2]  827 	jra	00104$
      0083E4                        828 00102$:
                                    829 ;	main.c: 313: (void)spi_txrx(addr | 0xC0);   // READ | BURST pour status regs
      0083E4 7B 02            [ 1]  830 	ld	a, (0x02, sp)
      0083E6 AA C0            [ 1]  831 	or	a, #0xc0
      0083E8 CD 83 3F         [ 4]  832 	call	_spi_txrx
                                    833 ;	main.c: 314: uint8_t v = spi_txrx(0xFF);
      0083EB A6 FF            [ 1]  834 	ld	a, #0xff
      0083ED CD 83 3F         [ 4]  835 	call	_spi_txrx
      0083F0 6B 01            [ 1]  836 	ld	(0x01, sp), a
                                    837 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0083F2 CD 83 50         [ 4]  838 	call	_spi_wait_idle
      0083F5 72 14 50 0F      [ 1]  839 	bset	0x500f, #2
                                    840 ;	main.c: 316: return v;
      0083F9 7B 01            [ 1]  841 	ld	a, (0x01, sp)
      0083FB                        842 00104$:
                                    843 ;	main.c: 317: }
      0083FB 5B 02            [ 2]  844 	addw	sp, #2
      0083FD 81               [ 4]  845 	ret
                                    846 ;	main.c: 320: static void cc_reset(void){
                                    847 ;	-----------------------------------------
                                    848 ;	 function cc_reset
                                    849 ;	-----------------------------------------
      0083FE                        850 _cc_reset:
                                    851 ;	main.c: 321: CSN_HIGH(); delay_ms(5);
      0083FE 72 14 50 0F      [ 1]  852 	bset	0x500f, #2
                                    853 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008402 90 5F            [ 1]  854 	clrw	y
      008404 5F               [ 1]  855 	clrw	x
      008405                        856 00113$:
      008405 90 A3 11 58      [ 2]  857 	cpw	y, #0x1158
      008409 9F               [ 1]  858 	ld	a, xl
      00840A A2 00            [ 1]  859 	sbc	a, #0x00
      00840C 9E               [ 1]  860 	ld	a, xh
      00840D A2 00            [ 1]  861 	sbc	a, #0x00
      00840F 24 08            [ 1]  862 	jrnc	00104$
                                    863 ;	main.c: 53: __asm__("nop");
      008411 9D               [ 1]  864 	nop
                                    865 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008412 90 5C            [ 1]  866 	incw	y
      008414 26 EF            [ 1]  867 	jrne	00113$
      008416 5C               [ 1]  868 	incw	x
      008417 20 EC            [ 2]  869 	jra	00113$
                                    870 ;	main.c: 321: CSN_HIGH(); delay_ms(5);
      008419                        871 00104$:
                                    872 ;	main.c: 322: CSN_LOW();  delay_ms(5);
      008419 72 15 50 0F      [ 1]  873 	bres	0x500f, #2
                                    874 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00841D 90 5F            [ 1]  875 	clrw	y
      00841F 5F               [ 1]  876 	clrw	x
      008420                        877 00116$:
      008420 90 A3 11 58      [ 2]  878 	cpw	y, #0x1158
      008424 9F               [ 1]  879 	ld	a, xl
      008425 A2 00            [ 1]  880 	sbc	a, #0x00
      008427 9E               [ 1]  881 	ld	a, xh
      008428 A2 00            [ 1]  882 	sbc	a, #0x00
      00842A 24 08            [ 1]  883 	jrnc	00106$
                                    884 ;	main.c: 53: __asm__("nop");
      00842C 9D               [ 1]  885 	nop
                                    886 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00842D 90 5C            [ 1]  887 	incw	y
      00842F 26 EF            [ 1]  888 	jrne	00116$
      008431 5C               [ 1]  889 	incw	x
      008432 20 EC            [ 2]  890 	jra	00116$
                                    891 ;	main.c: 322: CSN_LOW();  delay_ms(5);
      008434                        892 00106$:
                                    893 ;	main.c: 323: CSN_HIGH(); delay_ms(5);
      008434 72 14 50 0F      [ 1]  894 	bset	0x500f, #2
                                    895 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008438 90 5F            [ 1]  896 	clrw	y
      00843A 5F               [ 1]  897 	clrw	x
      00843B                        898 00119$:
      00843B 90 A3 11 58      [ 2]  899 	cpw	y, #0x1158
      00843F 9F               [ 1]  900 	ld	a, xl
      008440 A2 00            [ 1]  901 	sbc	a, #0x00
      008442 9E               [ 1]  902 	ld	a, xh
      008443 A2 00            [ 1]  903 	sbc	a, #0x00
      008445 24 08            [ 1]  904 	jrnc	00108$
                                    905 ;	main.c: 53: __asm__("nop");
      008447 9D               [ 1]  906 	nop
                                    907 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008448 90 5C            [ 1]  908 	incw	y
      00844A 26 EF            [ 1]  909 	jrne	00119$
      00844C 5C               [ 1]  910 	incw	x
      00844D 20 EC            [ 2]  911 	jra	00119$
                                    912 ;	main.c: 323: CSN_HIGH(); delay_ms(5);
      00844F                        913 00108$:
                                    914 ;	main.c: 324: if(cc_select()){ spi_txrx(SRES); cc_deselect(); }
      00844F CD 83 56         [ 4]  915 	call	_cc_select
      008452 4D               [ 1]  916 	tnz	a
      008453 27 0C            [ 1]  917 	jreq	00134$
      008455 A6 30            [ 1]  918 	ld	a, #0x30
      008457 CD 83 3F         [ 4]  919 	call	_spi_txrx
                                    920 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      00845A CD 83 50         [ 4]  921 	call	_spi_wait_idle
      00845D 72 14 50 0F      [ 1]  922 	bset	0x500f, #2
                                    923 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008461                        924 00134$:
      008461 90 5F            [ 1]  925 	clrw	y
      008463 5F               [ 1]  926 	clrw	x
      008464                        927 00122$:
      008464 90 A3 11 58      [ 2]  928 	cpw	y, #0x1158
      008468 9F               [ 1]  929 	ld	a, xl
      008469 A2 00            [ 1]  930 	sbc	a, #0x00
      00846B 9E               [ 1]  931 	ld	a, xh
      00846C A2 00            [ 1]  932 	sbc	a, #0x00
      00846E 25 01            [ 1]  933 	jrc	00182$
      008470 81               [ 4]  934 	ret
      008471                        935 00182$:
                                    936 ;	main.c: 53: __asm__("nop");
      008471 9D               [ 1]  937 	nop
                                    938 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008472 90 5C            [ 1]  939 	incw	y
      008474 26 EE            [ 1]  940 	jrne	00122$
      008476 5C               [ 1]  941 	incw	x
      008477 20 EB            [ 2]  942 	jra	00122$
                                    943 ;	main.c: 325: delay_ms(5);
                                    944 ;	main.c: 326: }
      008479 81               [ 4]  945 	ret
                                    946 ;	main.c: 328: static void cc_write_patble(uint8_t pa){
                                    947 ;	-----------------------------------------
                                    948 ;	 function cc_write_patble
                                    949 ;	-----------------------------------------
      00847A                        950 _cc_write_patble:
      00847A 88               [ 1]  951 	push	a
      00847B 6B 01            [ 1]  952 	ld	(0x01, sp), a
                                    953 ;	main.c: 329: if(!cc_select()) return;
      00847D CD 83 56         [ 4]  954 	call	_cc_select
      008480 4D               [ 1]  955 	tnz	a
      008481 27 1B            [ 1]  956 	jreq	00108$
                                    957 ;	main.c: 330: spi_txrx(PATABLE | CC_BURST);
      008483 A6 7E            [ 1]  958 	ld	a, #0x7e
      008485 CD 83 3F         [ 4]  959 	call	_spi_txrx
                                    960 ;	main.c: 331: for(uint8_t i=0;i<8;i++) spi_txrx(pa);
      008488 4F               [ 1]  961 	clr	a
      008489                        962 00106$:
      008489 A1 08            [ 1]  963 	cp	a, #0x08
      00848B 24 0A            [ 1]  964 	jrnc	00103$
      00848D 88               [ 1]  965 	push	a
      00848E 7B 02            [ 1]  966 	ld	a, (0x02, sp)
      008490 CD 83 3F         [ 4]  967 	call	_spi_txrx
      008493 84               [ 1]  968 	pop	a
      008494 4C               [ 1]  969 	inc	a
      008495 20 F2            [ 2]  970 	jra	00106$
      008497                        971 00103$:
                                    972 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      008497 CD 83 50         [ 4]  973 	call	_spi_wait_idle
      00849A 72 14 50 0F      [ 1]  974 	bset	0x500f, #2
                                    975 ;	main.c: 332: cc_deselect();
      00849E                        976 00108$:
                                    977 ;	main.c: 333: }
      00849E 84               [ 1]  978 	pop	a
      00849F 81               [ 4]  979 	ret
                                    980 ;	main.c: 335: static void cc_config_868(void){
                                    981 ;	-----------------------------------------
                                    982 ;	 function cc_config_868
                                    983 ;	-----------------------------------------
      0084A0                        984 _cc_config_868:
                                    985 ;	main.c: 337: cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
      0084A0 4B 29            [ 1]  986 	push	#0x29
      0084A2 4F               [ 1]  987 	clr	a
      0084A3 CD 83 B4         [ 4]  988 	call	_cc_write_reg
      0084A6 4B 06            [ 1]  989 	push	#0x06
      0084A8 A6 02            [ 1]  990 	ld	a, #0x02
      0084AA CD 83 B4         [ 4]  991 	call	_cc_write_reg
      0084AD 4B 47            [ 1]  992 	push	#0x47
      0084AF A6 03            [ 1]  993 	ld	a, #0x03
      0084B1 CD 83 B4         [ 4]  994 	call	_cc_write_reg
                                    995 ;	main.c: 338: cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
      0084B4 4B 3D            [ 1]  996 	push	#0x3d
      0084B6 A6 06            [ 1]  997 	ld	a, #0x06
      0084B8 CD 83 B4         [ 4]  998 	call	_cc_write_reg
      0084BB 4B 04            [ 1]  999 	push	#0x04
      0084BD A6 07            [ 1] 1000 	ld	a, #0x07
      0084BF CD 83 B4         [ 4] 1001 	call	_cc_write_reg
      0084C2 4B 05            [ 1] 1002 	push	#0x05
      0084C4 A6 08            [ 1] 1003 	ld	a, #0x08
      0084C6 CD 83 B4         [ 4] 1004 	call	_cc_write_reg
                                   1005 ;	main.c: 339: cc_write_reg(0x0B,0x06);
      0084C9 4B 06            [ 1] 1006 	push	#0x06
      0084CB A6 0B            [ 1] 1007 	ld	a, #0x0b
      0084CD CD 83 B4         [ 4] 1008 	call	_cc_write_reg
                                   1009 ;	main.c: 340: cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
      0084D0 4B 21            [ 1] 1010 	push	#0x21
      0084D2 A6 0D            [ 1] 1011 	ld	a, #0x0d
      0084D4 CD 83 B4         [ 4] 1012 	call	_cc_write_reg
      0084D7 4B 65            [ 1] 1013 	push	#0x65
      0084D9 A6 0E            [ 1] 1014 	ld	a, #0x0e
      0084DB CD 83 B4         [ 4] 1015 	call	_cc_write_reg
      0084DE 4B 6A            [ 1] 1016 	push	#0x6a
      0084E0 A6 0F            [ 1] 1017 	ld	a, #0x0f
      0084E2 CD 83 B4         [ 4] 1018 	call	_cc_write_reg
                                   1019 ;	main.c: 341: cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
      0084E5 4B F5            [ 1] 1020 	push	#0xf5
      0084E7 A6 10            [ 1] 1021 	ld	a, #0x10
      0084E9 CD 83 B4         [ 4] 1022 	call	_cc_write_reg
      0084EC 4B 83            [ 1] 1023 	push	#0x83
      0084EE A6 11            [ 1] 1024 	ld	a, #0x11
      0084F0 CD 83 B4         [ 4] 1025 	call	_cc_write_reg
      0084F3 4B 13            [ 1] 1026 	push	#0x13
      0084F5 A6 12            [ 1] 1027 	ld	a, #0x12
      0084F7 CD 83 B4         [ 4] 1028 	call	_cc_write_reg
                                   1029 ;	main.c: 342: cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
      0084FA 4B 22            [ 1] 1030 	push	#0x22
      0084FC A6 13            [ 1] 1031 	ld	a, #0x13
      0084FE CD 83 B4         [ 4] 1032 	call	_cc_write_reg
      008501 4B F8            [ 1] 1033 	push	#0xf8
      008503 A6 14            [ 1] 1034 	ld	a, #0x14
      008505 CD 83 B4         [ 4] 1035 	call	_cc_write_reg
                                   1036 ;	main.c: 343: cc_write_reg(0x15,0x15);
      008508 4B 15            [ 1] 1037 	push	#0x15
      00850A A6 15            [ 1] 1038 	ld	a, #0x15
      00850C CD 83 B4         [ 4] 1039 	call	_cc_write_reg
                                   1040 ;	main.c: 344: cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
      00850F 4B 18            [ 1] 1041 	push	#0x18
      008511 A6 18            [ 1] 1042 	ld	a, #0x18
      008513 CD 83 B4         [ 4] 1043 	call	_cc_write_reg
      008516 4B 16            [ 1] 1044 	push	#0x16
      008518 A6 19            [ 1] 1045 	ld	a, #0x19
      00851A CD 83 B4         [ 4] 1046 	call	_cc_write_reg
                                   1047 ;	main.c: 345: cc_write_reg(0x1B,0x43);
      00851D 4B 43            [ 1] 1048 	push	#0x43
      00851F A6 1B            [ 1] 1049 	ld	a, #0x1b
      008521 CD 83 B4         [ 4] 1050 	call	_cc_write_reg
                                   1051 ;	main.c: 346: cc_write_reg(0x22,0x11);
      008524 4B 11            [ 1] 1052 	push	#0x11
      008526 A6 22            [ 1] 1053 	ld	a, #0x22
      008528 CD 83 B4         [ 4] 1054 	call	_cc_write_reg
                                   1055 ;	main.c: 347: cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
      00852B 4B E9            [ 1] 1056 	push	#0xe9
      00852D A6 23            [ 1] 1057 	ld	a, #0x23
      00852F CD 83 B4         [ 4] 1058 	call	_cc_write_reg
      008532 4B 2A            [ 1] 1059 	push	#0x2a
      008534 A6 24            [ 1] 1060 	ld	a, #0x24
      008536 CD 83 B4         [ 4] 1061 	call	_cc_write_reg
      008539 4B 00            [ 1] 1062 	push	#0x00
      00853B A6 25            [ 1] 1063 	ld	a, #0x25
      00853D CD 83 B4         [ 4] 1064 	call	_cc_write_reg
      008540 4B 1F            [ 1] 1065 	push	#0x1f
      008542 A6 26            [ 1] 1066 	ld	a, #0x26
      008544 CD 83 B4         [ 4] 1067 	call	_cc_write_reg
                                   1068 ;	main.c: 348: cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
      008547 4B 81            [ 1] 1069 	push	#0x81
      008549 A6 2C            [ 1] 1070 	ld	a, #0x2c
      00854B CD 83 B4         [ 4] 1071 	call	_cc_write_reg
      00854E 4B 35            [ 1] 1072 	push	#0x35
      008550 A6 2D            [ 1] 1073 	ld	a, #0x2d
      008552 CD 83 B4         [ 4] 1074 	call	_cc_write_reg
      008555 4B 09            [ 1] 1075 	push	#0x09
      008557 A6 2E            [ 1] 1076 	ld	a, #0x2e
      008559 CD 83 B4         [ 4] 1077 	call	_cc_write_reg
                                   1078 ;	main.c: 349: cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
      00855C A6 36            [ 1] 1079 	ld	a, #0x36
      00855E CD 83 93         [ 4] 1080 	call	_cc_strobe
      008561 A6 3A            [ 1] 1081 	ld	a, #0x3a
      008563 CD 83 93         [ 4] 1082 	call	_cc_strobe
      008566 A6 3B            [ 1] 1083 	ld	a, #0x3b
      008568 CD 83 93         [ 4] 1084 	call	_cc_strobe
                                   1085 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00856B 90 5F            [ 1] 1086 	clrw	y
      00856D 5F               [ 1] 1087 	clrw	x
      00856E                       1088 00104$:
      00856E 90 A3 06 F0      [ 2] 1089 	cpw	y, #0x06f0
      008572 9F               [ 1] 1090 	ld	a, xl
      008573 A2 00            [ 1] 1091 	sbc	a, #0x00
      008575 9E               [ 1] 1092 	ld	a, xh
      008576 A2 00            [ 1] 1093 	sbc	a, #0x00
      008578 24 08            [ 1] 1094 	jrnc	00102$
                                   1095 ;	main.c: 53: __asm__("nop");
      00857A 9D               [ 1] 1096 	nop
                                   1097 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00857B 90 5C            [ 1] 1098 	incw	y
      00857D 26 EF            [ 1] 1099 	jrne	00104$
      00857F 5C               [ 1] 1100 	incw	x
      008580 20 EC            [ 2] 1101 	jra	00104$
                                   1102 ;	main.c: 350: delay_ms(2);
      008582                       1103 00102$:
                                   1104 ;	main.c: 352: cc_write_patble(0xC0);      // mets 0x84 pour tester “0 dBm”, 0xC8 si tu veux un cran de plus
      008582 A6 C0            [ 1] 1105 	ld	a, #0xc0
                                   1106 ;	main.c: 353: }
      008584 CC 84 7A         [ 2] 1107 	jp	_cc_write_patble
                                   1108 ;	main.c: 356: static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
                                   1109 ;	-----------------------------------------
                                   1110 ;	 function cc_send_packet
                                   1111 ;	-----------------------------------------
      008587                       1112 _cc_send_packet:
      008587 52 07            [ 2] 1113 	sub	sp, #7
      008589 1F 02            [ 2] 1114 	ldw	(0x02, sp), x
                                   1115 ;	main.c: 357: if(len==0 || len>61) return 0;
      00858B 6B 01            [ 1] 1116 	ld	(0x01, sp), a
      00858D 27 06            [ 1] 1117 	jreq	00101$
      00858F 7B 01            [ 1] 1118 	ld	a, (0x01, sp)
      008591 A1 3D            [ 1] 1119 	cp	a, #0x3d
      008593 23 03            [ 2] 1120 	jrule	00102$
      008595                       1121 00101$:
      008595 4F               [ 1] 1122 	clr	a
      008596 20 61            [ 2] 1123 	jra	00116$
      008598                       1124 00102$:
                                   1125 ;	main.c: 358: cc_strobe(SIDLE); 
      008598 A6 36            [ 1] 1126 	ld	a, #0x36
      00859A CD 83 93         [ 4] 1127 	call	_cc_strobe
                                   1128 ;	main.c: 359: cc_strobe(SFTX);
      00859D A6 3B            [ 1] 1129 	ld	a, #0x3b
      00859F CD 83 93         [ 4] 1130 	call	_cc_strobe
                                   1131 ;	main.c: 361: if(!cc_select()) return 0;
      0085A2 CD 83 56         [ 4] 1132 	call	_cc_select
      0085A5 4D               [ 1] 1133 	tnz	a
      0085A6 26 03            [ 1] 1134 	jrne	00105$
      0085A8 4F               [ 1] 1135 	clr	a
      0085A9 20 4E            [ 2] 1136 	jra	00116$
      0085AB                       1137 00105$:
                                   1138 ;	main.c: 362: spi_txrx(TXFIFO | CC_BURST);
      0085AB A6 7F            [ 1] 1139 	ld	a, #0x7f
      0085AD CD 83 3F         [ 4] 1140 	call	_spi_txrx
                                   1141 ;	main.c: 363: spi_txrx(len);
      0085B0 7B 01            [ 1] 1142 	ld	a, (0x01, sp)
      0085B2 CD 83 3F         [ 4] 1143 	call	_spi_txrx
                                   1144 ;	main.c: 364: for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
      0085B5 0F 07            [ 1] 1145 	clr	(0x07, sp)
      0085B7                       1146 00111$:
      0085B7 7B 07            [ 1] 1147 	ld	a, (0x07, sp)
      0085B9 11 01            [ 1] 1148 	cp	a, (0x01, sp)
      0085BB 24 0F            [ 1] 1149 	jrnc	00106$
      0085BD 5F               [ 1] 1150 	clrw	x
      0085BE 7B 07            [ 1] 1151 	ld	a, (0x07, sp)
      0085C0 97               [ 1] 1152 	ld	xl, a
      0085C1 72 FB 02         [ 2] 1153 	addw	x, (0x02, sp)
      0085C4 F6               [ 1] 1154 	ld	a, (x)
      0085C5 CD 83 3F         [ 4] 1155 	call	_spi_txrx
      0085C8 0C 07            [ 1] 1156 	inc	(0x07, sp)
      0085CA 20 EB            [ 2] 1157 	jra	00111$
      0085CC                       1158 00106$:
                                   1159 ;	main.c: 298: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0085CC CD 83 50         [ 4] 1160 	call	_spi_wait_idle
      0085CF 72 14 50 0F      [ 1] 1161 	bset	0x500f, #2
                                   1162 ;	main.c: 367: cc_strobe(STX);
      0085D3 A6 35            [ 1] 1163 	ld	a, #0x35
      0085D5 CD 83 93         [ 4] 1164 	call	_cc_strobe
                                   1165 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0085D8 90 5F            [ 1] 1166 	clrw	y
      0085DA 5F               [ 1] 1167 	clrw	x
      0085DB 1F 04            [ 2] 1168 	ldw	(0x04, sp), x
      0085DD                       1169 00114$:
      0085DD 90 A3 11 58      [ 2] 1170 	cpw	y, #0x1158
      0085E1 7B 05            [ 1] 1171 	ld	a, (0x05, sp)
      0085E3 A2 00            [ 1] 1172 	sbc	a, #0x00
      0085E5 7B 04            [ 1] 1173 	ld	a, (0x04, sp)
      0085E7 A2 00            [ 1] 1174 	sbc	a, #0x00
      0085E9 24 0C            [ 1] 1175 	jrnc	00109$
                                   1176 ;	main.c: 53: __asm__("nop");
      0085EB 9D               [ 1] 1177 	nop
                                   1178 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0085EC 90 5C            [ 1] 1179 	incw	y
      0085EE 26 ED            [ 1] 1180 	jrne	00114$
      0085F0 1E 04            [ 2] 1181 	ldw	x, (0x04, sp)
      0085F2 5C               [ 1] 1182 	incw	x
      0085F3 1F 04            [ 2] 1183 	ldw	(0x04, sp), x
      0085F5 20 E6            [ 2] 1184 	jra	00114$
                                   1185 ;	main.c: 370: delay_ms(5);
      0085F7                       1186 00109$:
                                   1187 ;	main.c: 371: return 1;
      0085F7 A6 01            [ 1] 1188 	ld	a, #0x01
      0085F9                       1189 00116$:
                                   1190 ;	main.c: 372: }
      0085F9 5B 07            [ 2] 1191 	addw	sp, #7
      0085FB 81               [ 4] 1192 	ret
                                   1193 ;	main.c: 375: void cc_send_temp_x100(int16_t temp_x100) {
                                   1194 ;	-----------------------------------------
                                   1195 ;	 function cc_send_temp_x100
                                   1196 ;	-----------------------------------------
      0085FC                       1197 _cc_send_temp_x100:
      0085FC 52 08            [ 2] 1198 	sub	sp, #8
                                   1199 ;	main.c: 377: int16_t temp_x10 = temp_x100 / 10;
      0085FE 4B 0A            [ 1] 1200 	push	#0x0a
      008600 4B 00            [ 1] 1201 	push	#0x00
      008602 CD 88 74         [ 4] 1202 	call	__divsint
      008605 1F 05            [ 2] 1203 	ldw	(0x05, sp), x
                                   1204 ;	main.c: 380: pkt[0] = NODE_ID;                        // Identifiant du capteur
      008607 A6 01            [ 1] 1205 	ld	a, #0x01
      008609 6B 01            [ 1] 1206 	ld	(0x01, sp), a
                                   1207 ;	main.c: 381: pkt[1] = (uint8_t)(temp_x10 >> 8);       // MSB
      00860B 7B 05            [ 1] 1208 	ld	a, (0x05, sp)
      00860D 6B 07            [ 1] 1209 	ld	(0x07, sp), a
      00860F 6B 02            [ 1] 1210 	ld	(0x02, sp), a
                                   1211 ;	main.c: 382: pkt[2] = (uint8_t)(temp_x10 & 0xFF);     // LSB
      008611 7B 06            [ 1] 1212 	ld	a, (0x06, sp)
      008613 6B 08            [ 1] 1213 	ld	(0x08, sp), a
      008615 6B 03            [ 1] 1214 	ld	(0x03, sp), a
                                   1215 ;	main.c: 383: pkt[3] = pkt[0] ^ pkt[1] ^ pkt[2];       // Checksum XOR
      008617 7B 01            [ 1] 1216 	ld	a, (0x01, sp)
      008619 18 07            [ 1] 1217 	xor	a, (0x07, sp)
      00861B 18 08            [ 1] 1218 	xor	a, (0x08, sp)
      00861D 6B 04            [ 1] 1219 	ld	(0x04, sp), a
                                   1220 ;	main.c: 385: uint8_t ok = cc_send_packet(pkt, sizeof(pkt));
      00861F A6 04            [ 1] 1221 	ld	a, #0x04
      008621 96               [ 1] 1222 	ldw	x, sp
      008622 5C               [ 1] 1223 	incw	x
      008623 CD 85 87         [ 4] 1224 	call	_cc_send_packet
                                   1225 ;	main.c: 389: ok ? "OK" : "FAIL");
      008626 4D               [ 1] 1226 	tnz	a
      008627 27 04            [ 1] 1227 	jreq	00103$
      008629 AE 80 4E         [ 2] 1228 	ldw	x, #___str_1+0
      00862C BC                    1229 	.byte 0xbc
      00862D                       1230 00103$:
      00862D AE 80 51         [ 2] 1231 	ldw	x, #(___str_2+0)
      008630                       1232 00104$:
      008630 1F 07            [ 2] 1233 	ldw	(0x07, sp), x
                                   1234 ;	main.c: 388: temp_x10/10, temp_x10%10,
      008632 1E 05            [ 2] 1235 	ldw	x, (0x05, sp)
      008634 89               [ 2] 1236 	pushw	x
      008635 4B 0A            [ 1] 1237 	push	#0x0a
      008637 4B 00            [ 1] 1238 	push	#0x00
      008639 CD 87 E0         [ 4] 1239 	call	__modsint
      00863C 1F 07            [ 2] 1240 	ldw	(0x07, sp), x
      00863E 85               [ 2] 1241 	popw	x
      00863F 4B 0A            [ 1] 1242 	push	#0x0a
      008641 4B 00            [ 1] 1243 	push	#0x00
                                   1244 ;	main.c: 387: printf("[RADIO] send %d.%01d°C -> %s\r\n",
      008643 CD 88 74         [ 4] 1245 	call	__divsint
      008646 16 07            [ 2] 1246 	ldw	y, (0x07, sp)
      008648 90 89            [ 2] 1247 	pushw	y
      00864A 16 07            [ 2] 1248 	ldw	y, (0x07, sp)
      00864C 90 89            [ 2] 1249 	pushw	y
      00864E 89               [ 2] 1250 	pushw	x
      00864F 4B 2E            [ 1] 1251 	push	#<(___str_0+0)
      008651 4B 80            [ 1] 1252 	push	#((___str_0+0) >> 8)
      008653 CD 87 CF         [ 4] 1253 	call	_printf
                                   1254 ;	main.c: 390: }
      008656 5B 10            [ 2] 1255 	addw	sp, #16
      008658 81               [ 4] 1256 	ret
                                   1257 ;	main.c: 392: void main() {
                                   1258 ;	-----------------------------------------
                                   1259 ;	 function main
                                   1260 ;	-----------------------------------------
      008659                       1261 _main:
      008659 52 06            [ 2] 1262 	sub	sp, #6
                                   1263 ;	main.c: 394: CLK_CKDIVR = 0x00; // forcer la frequence CPU
      00865B 35 00 50 C6      [ 1] 1264 	mov	0x50c6+0, #0x00
                                   1265 ;	main.c: 397: PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
      00865F C6 50 02         [ 1] 1266 	ld	a, 0x5002
      008662 AA 06            [ 1] 1267 	or	a, #0x06
      008664 C7 50 02         [ 1] 1268 	ld	0x5002, a
                                   1269 ;	main.c: 398: PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull
      008667 C6 50 03         [ 1] 1270 	ld	a, 0x5003
      00866A AA 06            [ 1] 1271 	or	a, #0x06
      00866C C7 50 03         [ 1] 1272 	ld	0x5003, a
                                   1273 ;	main.c: 400: PD_DDR &= ~(1 << 3);    // PD3 en entrée
      00866F 72 17 50 11      [ 1] 1274 	bres	0x5011, #3
                                   1275 ;	main.c: 401: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
      008673 72 16 50 12      [ 1] 1276 	bset	0x5012, #3
                                   1277 ;	main.c: 403: uart_init();
      008677 CD 80 61         [ 4] 1278 	call	_uart_init
                                   1279 ;	main.c: 404: gpio_init();
      00867A CD 82 FD         [ 4] 1280 	call	_gpio_init
                                   1281 ;	main.c: 405: spi_init();
      00867D CD 83 32         [ 4] 1282 	call	_spi_init
                                   1283 ;	main.c: 406: cc_reset();
      008680 CD 83 FE         [ 4] 1284 	call	_cc_reset
                                   1285 ;	main.c: 407: cc_config_868();
      008683 CD 84 A0         [ 4] 1286 	call	_cc_config_868
                                   1287 ;	main.c: 412: while (1) {
      008686 5F               [ 1] 1288 	clrw	x
      008687 1F 01            [ 2] 1289 	ldw	(0x01, sp), x
      008689                       1290 00104$:
                                   1291 ;	main.c: 413: ds18b20_start_conversion(); // Démarre une conversion de température
      008689 CD 81 9C         [ 4] 1292 	call	_ds18b20_start_conversion
                                   1293 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00868C 90 5F            [ 1] 1294 	clrw	y
      00868E 5F               [ 1] 1295 	clrw	x
      00868F 1F 03            [ 2] 1296 	ldw	(0x03, sp), x
      008691                       1297 00111$:
      008691 90 A3 29 90      [ 2] 1298 	cpw	y, #0x2990
      008695 7B 04            [ 1] 1299 	ld	a, (0x04, sp)
      008697 A2 0A            [ 1] 1300 	sbc	a, #0x0a
      008699 7B 03            [ 1] 1301 	ld	a, (0x03, sp)
      00869B A2 00            [ 1] 1302 	sbc	a, #0x00
      00869D 24 0C            [ 1] 1303 	jrnc	00107$
                                   1304 ;	main.c: 53: __asm__("nop");
      00869F 9D               [ 1] 1305 	nop
                                   1306 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0086A0 90 5C            [ 1] 1307 	incw	y
      0086A2 26 ED            [ 1] 1308 	jrne	00111$
      0086A4 1E 03            [ 2] 1309 	ldw	x, (0x03, sp)
      0086A6 5C               [ 1] 1310 	incw	x
      0086A7 1F 03            [ 2] 1311 	ldw	(0x03, sp), x
      0086A9 20 E6            [ 2] 1312 	jra	00111$
                                   1313 ;	main.c: 414: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
      0086AB                       1314 00107$:
                                   1315 ;	main.c: 416: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
      0086AB CD 81 A9         [ 4] 1316 	call	_ds18b20_read_raw
                                   1317 ;	main.c: 419: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
      0086AE 90 5F            [ 1] 1318 	clrw	y
      0086B0 5D               [ 2] 1319 	tnzw	x
      0086B1 2A 02            [ 1] 1320 	jrpl	00151$
      0086B3 90 5A            [ 2] 1321 	decw	y
      0086B5                       1322 00151$:
      0086B5 89               [ 2] 1323 	pushw	x
      0086B6 90 89            [ 2] 1324 	pushw	y
      0086B8 4B 71            [ 1] 1325 	push	#0x71
      0086BA 4B 02            [ 1] 1326 	push	#0x02
      0086BC 5F               [ 1] 1327 	clrw	x
      0086BD 89               [ 2] 1328 	pushw	x
      0086BE CD 87 F8         [ 4] 1329 	call	__mullong
      0086C1 5B 08            [ 2] 1330 	addw	sp, #8
      0086C3 4B 64            [ 1] 1331 	push	#0x64
      0086C5 4B 00            [ 1] 1332 	push	#0x00
      0086C7 4B 00            [ 1] 1333 	push	#0x00
      0086C9 4B 00            [ 1] 1334 	push	#0x00
      0086CB 89               [ 2] 1335 	pushw	x
      0086CC 90 89            [ 2] 1336 	pushw	y
      0086CE CD 87 5E         [ 4] 1337 	call	__divulong
      0086D1 5B 08            [ 2] 1338 	addw	sp, #8
                                   1339 ;	main.c: 422: tm_display_temp_x100(temp_x100);
      0086D3 1F 05            [ 2] 1340 	ldw	(0x05, sp), x
      0086D5 CD 82 B3         [ 4] 1341 	call	_tm_display_temp_x100
                                   1342 ;	main.c: 425: if (counter % 120 == 0) {
      0086D8 1E 01            [ 2] 1343 	ldw	x, (0x01, sp)
      0086DA 90 AE 00 78      [ 2] 1344 	ldw	y, #0x0078
      0086DE 65               [ 2] 1345 	divw	x, y
      0086DF 90 5D            [ 2] 1346 	tnzw	y
      0086E1 26 05            [ 1] 1347 	jrne	00102$
                                   1348 ;	main.c: 426: cc_send_temp_x100(temp_x100);
      0086E3 1E 05            [ 2] 1349 	ldw	x, (0x05, sp)
      0086E5 CD 85 FC         [ 4] 1350 	call	_cc_send_temp_x100
      0086E8                       1351 00102$:
                                   1352 ;	main.c: 429: counter++;
      0086E8 1E 01            [ 2] 1353 	ldw	x, (0x01, sp)
      0086EA 5C               [ 1] 1354 	incw	x
      0086EB 1F 01            [ 2] 1355 	ldw	(0x01, sp), x
                                   1356 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0086ED 90 5F            [ 1] 1357 	clrw	y
      0086EF 5F               [ 1] 1358 	clrw	x
      0086F0                       1359 00114$:
      0086F0 90 A3 8C C0      [ 2] 1360 	cpw	y, #0x8cc0
      0086F4 9F               [ 1] 1361 	ld	a, xl
      0086F5 A2 0D            [ 1] 1362 	sbc	a, #0x0d
      0086F7 9E               [ 1] 1363 	ld	a, xh
      0086F8 A2 00            [ 1] 1364 	sbc	a, #0x00
      0086FA 24 8D            [ 1] 1365 	jrnc	00104$
                                   1366 ;	main.c: 53: __asm__("nop");
      0086FC 9D               [ 1] 1367 	nop
                                   1368 ;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0086FD 90 5C            [ 1] 1369 	incw	y
      0086FF 26 EF            [ 1] 1370 	jrne	00114$
      008701 5C               [ 1] 1371 	incw	x
      008702 20 EC            [ 2] 1372 	jra	00114$
                                   1373 ;	main.c: 433: delay_ms(NODE_ID * 1000UL);
                                   1374 ;	main.c: 435: }
      008704 5B 06            [ 2] 1375 	addw	sp, #6
      008706 81               [ 4] 1376 	ret
                                   1377 	.area CODE
                                   1378 	.area CONST
      008024                       1379 _digit_to_segment:
      008024 3F                    1380 	.db #0x3f	; 63
      008025 06                    1381 	.db #0x06	; 6
      008026 5B                    1382 	.db #0x5b	; 91
      008027 4F                    1383 	.db #0x4f	; 79	'O'
      008028 66                    1384 	.db #0x66	; 102	'f'
      008029 6D                    1385 	.db #0x6d	; 109	'm'
      00802A 7D                    1386 	.db #0x7d	; 125
      00802B 07                    1387 	.db #0x07	; 7
      00802C 7F                    1388 	.db #0x7f	; 127
      00802D 6F                    1389 	.db #0x6f	; 111	'o'
                                   1390 	.area CONST
      00802E                       1391 ___str_0:
      00802E 5B 52 41 44 49 4F 5D  1392 	.ascii "[RADIO] send %d.%01d"
             20 73 65 6E 64 20 25
             64 2E 25 30 31 64
      008042 C2                    1393 	.db 0xc2
      008043 B0                    1394 	.db 0xb0
      008044 43 20 2D 3E 20 25 73  1395 	.ascii "C -> %s"
      00804B 0D                    1396 	.db 0x0d
      00804C 0A                    1397 	.db 0x0a
      00804D 00                    1398 	.db 0x00
                                   1399 	.area CODE
                                   1400 	.area CONST
      00804E                       1401 ___str_1:
      00804E 4F 4B                 1402 	.ascii "OK"
      008050 00                    1403 	.db 0x00
                                   1404 	.area CODE
                                   1405 	.area CONST
      008051                       1406 ___str_2:
      008051 46 41 49 4C           1407 	.ascii "FAIL"
      008055 00                    1408 	.db 0x00
                                   1409 	.area CODE
                                   1410 	.area INITIALIZER
                                   1411 	.area CABS (ABS)
