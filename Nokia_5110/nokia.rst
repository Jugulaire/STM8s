                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module nokia
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _big_char_deg
                                     12 	.globl _big_char_dot
                                     13 	.globl _big_char_C
                                     14 	.globl _big_digit_9
                                     15 	.globl _big_digit_8
                                     16 	.globl _big_digit_7
                                     17 	.globl _big_digit_6
                                     18 	.globl _big_digit_5
                                     19 	.globl _big_digit_4
                                     20 	.globl _big_digit_3
                                     21 	.globl _big_digit_2
                                     22 	.globl _big_digit_1
                                     23 	.globl _big_digit_0
                                     24 	.globl _main
                                     25 	.globl _lcd_print_temperature
                                     26 	.globl _lcd_draw_char_small
                                     27 	.globl _lcd_draw_8x8_char
                                     28 	.globl _lcd_clear
                                     29 	.globl _lcd_init
                                     30 	.globl _lcd_write_data
                                     31 	.globl _lcd_write_cmd
                                     32 	.globl _lcd_send_byte
                                     33 	.globl _ds18b20_read_raw
                                     34 	.globl _ds18b20_start_conversion
                                     35 	.globl _onewire_read_byte
                                     36 	.globl _onewire_write_byte
                                     37 	.globl _onewire_read_bit
                                     38 	.globl _onewire_write_bit
                                     39 	.globl _onewire_reset
                                     40 	.globl _delay_ms
                                     41 	.globl _delay_us
                                     42 	.globl _sprintf
                                     43 	.globl _big_digits
                                     44 ;--------------------------------------------------------
                                     45 ; ram data
                                     46 ;--------------------------------------------------------
                                     47 	.area DATA
                                     48 ;--------------------------------------------------------
                                     49 ; ram data
                                     50 ;--------------------------------------------------------
                                     51 	.area INITIALIZED
      000001                         52 _big_digits::
      000001                         53 	.ds 20
                                     54 ;--------------------------------------------------------
                                     55 ; Stack segment in internal ram
                                     56 ;--------------------------------------------------------
                                     57 	.area	SSEG
      000015                         58 __start__stack:
      000015                         59 	.ds	1
                                     60 
                                     61 ;--------------------------------------------------------
                                     62 ; absolute external ram data
                                     63 ;--------------------------------------------------------
                                     64 	.area DABS (ABS)
                                     65 
                                     66 ; default segment ordering for linker
                                     67 	.area HOME
                                     68 	.area GSINIT
                                     69 	.area GSFINAL
                                     70 	.area CONST
                                     71 	.area INITIALIZER
                                     72 	.area CODE
                                     73 
                                     74 ;--------------------------------------------------------
                                     75 ; interrupt vector
                                     76 ;--------------------------------------------------------
                                     77 	.area HOME
      008000                         78 __interrupt_vect:
      008000 82 00 80 07             79 	int s_GSINIT ; reset
                                     80 ;--------------------------------------------------------
                                     81 ; global & static initialisations
                                     82 ;--------------------------------------------------------
                                     83 	.area HOME
                                     84 	.area GSINIT
                                     85 	.area GSFINAL
                                     86 	.area GSINIT
      008007                         87 __sdcc_init_data:
                                     88 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   89 	ldw x, #l_DATA
      00800A 27 07            [ 1]   90 	jreq	00002$
      00800C                         91 00001$:
      00800C 72 4F 00 00      [ 1]   92 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   93 	decw x
      008011 26 F9            [ 1]   94 	jrne	00001$
      008013                         95 00002$:
      008013 AE 00 14         [ 2]   96 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   97 	jreq	00004$
      008018                         98 00003$:
      008018 D6 80 A6         [ 1]   99 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]  100 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]  101 	decw	x
      00801F 26 F7            [ 1]  102 	jrne	00003$
      008021                        103 00004$:
                                    104 ; stm8_genXINIT() end
                                    105 	.area GSFINAL
      008021 CC 80 04         [ 2]  106 	jp	__sdcc_program_startup
                                    107 ;--------------------------------------------------------
                                    108 ; Home
                                    109 ;--------------------------------------------------------
                                    110 	.area HOME
                                    111 	.area HOME
      008004                        112 __sdcc_program_startup:
      008004 CC 84 31         [ 2]  113 	jp	_main
                                    114 ;	return from main will return to caller
                                    115 ;--------------------------------------------------------
                                    116 ; code
                                    117 ;--------------------------------------------------------
                                    118 	.area CODE
                                    119 ;	nokia.c: 42: void delay_us(uint16_t us) {
                                    120 ;	-----------------------------------------
                                    121 ;	 function delay_us
                                    122 ;	-----------------------------------------
      0080BB                        123 _delay_us:
                                    124 ;	nokia.c: 43: while(us--) {
      0080BB                        125 00101$:
      0080BB 90 93            [ 1]  126 	ldw	y, x
      0080BD 5A               [ 2]  127 	decw	x
      0080BE 90 5D            [ 2]  128 	tnzw	y
      0080C0 26 01            [ 1]  129 	jrne	00117$
      0080C2 81               [ 4]  130 	ret
      0080C3                        131 00117$:
                                    132 ;	nokia.c: 44: __asm__("nop"); __asm__("nop"); __asm__("nop");
      0080C3 9D               [ 1]  133 	nop
      0080C4 9D               [ 1]  134 	nop
      0080C5 9D               [ 1]  135 	nop
                                    136 ;	nokia.c: 45: __asm__("nop"); __asm__("nop"); __asm__("nop");
      0080C6 9D               [ 1]  137 	nop
      0080C7 9D               [ 1]  138 	nop
      0080C8 9D               [ 1]  139 	nop
      0080C9 20 F0            [ 2]  140 	jra	00101$
                                    141 ;	nokia.c: 47: }
      0080CB 81               [ 4]  142 	ret
                                    143 ;	nokia.c: 49: void delay_ms(uint16_t ms) {
                                    144 ;	-----------------------------------------
                                    145 ;	 function delay_ms
                                    146 ;	-----------------------------------------
      0080CC                        147 _delay_ms:
      0080CC 52 0A            [ 2]  148 	sub	sp, #10
      0080CE 1F 05            [ 2]  149 	ldw	(0x05, sp), x
                                    150 ;	nokia.c: 51: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080D0 5F               [ 1]  151 	clrw	x
      0080D1 1F 09            [ 2]  152 	ldw	(0x09, sp), x
      0080D3 1F 07            [ 2]  153 	ldw	(0x07, sp), x
      0080D5                        154 00103$:
      0080D5 1E 05            [ 2]  155 	ldw	x, (0x05, sp)
      0080D7 89               [ 2]  156 	pushw	x
      0080D8 AE 03 78         [ 2]  157 	ldw	x, #0x0378
      0080DB CD 84 84         [ 4]  158 	call	___muluint2ulong
      0080DE 5B 02            [ 2]  159 	addw	sp, #2
      0080E0 1F 03            [ 2]  160 	ldw	(0x03, sp), x
      0080E2 17 01            [ 2]  161 	ldw	(0x01, sp), y
      0080E4 1E 09            [ 2]  162 	ldw	x, (0x09, sp)
      0080E6 13 03            [ 2]  163 	cpw	x, (0x03, sp)
      0080E8 7B 08            [ 1]  164 	ld	a, (0x08, sp)
      0080EA 12 02            [ 1]  165 	sbc	a, (0x02, sp)
      0080EC 7B 07            [ 1]  166 	ld	a, (0x07, sp)
      0080EE 12 01            [ 1]  167 	sbc	a, (0x01, sp)
      0080F0 24 0F            [ 1]  168 	jrnc	00105$
                                    169 ;	nokia.c: 52: __asm__("nop");
      0080F2 9D               [ 1]  170 	nop
                                    171 ;	nokia.c: 51: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080F3 1E 09            [ 2]  172 	ldw	x, (0x09, sp)
      0080F5 5C               [ 1]  173 	incw	x
      0080F6 1F 09            [ 2]  174 	ldw	(0x09, sp), x
      0080F8 26 DB            [ 1]  175 	jrne	00103$
      0080FA 1E 07            [ 2]  176 	ldw	x, (0x07, sp)
      0080FC 5C               [ 1]  177 	incw	x
      0080FD 1F 07            [ 2]  178 	ldw	(0x07, sp), x
      0080FF 20 D4            [ 2]  179 	jra	00103$
      008101                        180 00105$:
                                    181 ;	nokia.c: 53: }
      008101 5B 0A            [ 2]  182 	addw	sp, #10
      008103 81               [ 4]  183 	ret
                                    184 ;	nokia.c: 56: uint8_t onewire_reset(void) {
                                    185 ;	-----------------------------------------
                                    186 ;	 function onewire_reset
                                    187 ;	-----------------------------------------
      008104                        188 _onewire_reset:
                                    189 ;	nokia.c: 57: DS_OUTPUT(); DS_LOW();
      008104 72 1A 50 07      [ 1]  190 	bset	0x5007, #5
      008108 72 1B 50 05      [ 1]  191 	bres	0x5005, #5
                                    192 ;	nokia.c: 58: delay_us(480);
      00810C AE 01 E0         [ 2]  193 	ldw	x, #0x01e0
      00810F CD 80 BB         [ 4]  194 	call	_delay_us
                                    195 ;	nokia.c: 59: DS_INPUT();
      008112 72 1B 50 07      [ 1]  196 	bres	0x5007, #5
                                    197 ;	nokia.c: 60: delay_us(70);
      008116 AE 00 46         [ 2]  198 	ldw	x, #0x0046
      008119 CD 80 BB         [ 4]  199 	call	_delay_us
                                    200 ;	nokia.c: 61: uint8_t presence = !DS_READ();
      00811C C6 50 06         [ 1]  201 	ld	a, 0x5006
      00811F 4E               [ 1]  202 	swap	a
      008120 44               [ 1]  203 	srl	a
      008121 A4 01            [ 1]  204 	and	a, #0x01
      008123 A8 01            [ 1]  205 	xor	a, #0x01
                                    206 ;	nokia.c: 62: delay_us(410);
      008125 88               [ 1]  207 	push	a
      008126 AE 01 9A         [ 2]  208 	ldw	x, #0x019a
      008129 CD 80 BB         [ 4]  209 	call	_delay_us
      00812C 84               [ 1]  210 	pop	a
                                    211 ;	nokia.c: 63: return presence;
                                    212 ;	nokia.c: 64: }
      00812D 81               [ 4]  213 	ret
                                    214 ;	nokia.c: 66: void onewire_write_bit(uint8_t bit) {
                                    215 ;	-----------------------------------------
                                    216 ;	 function onewire_write_bit
                                    217 ;	-----------------------------------------
      00812E                        218 _onewire_write_bit:
      00812E 88               [ 1]  219 	push	a
      00812F 6B 01            [ 1]  220 	ld	(0x01, sp), a
                                    221 ;	nokia.c: 67: DS_OUTPUT(); DS_LOW();
      008131 72 1A 50 07      [ 1]  222 	bset	0x5007, #5
      008135 72 1B 50 05      [ 1]  223 	bres	0x5005, #5
                                    224 ;	nokia.c: 68: delay_us(bit ? 6 : 60);
      008139 0D 01            [ 1]  225 	tnz	(0x01, sp)
      00813B 27 04            [ 1]  226 	jreq	00103$
      00813D AE 00 06         [ 2]  227 	ldw	x, #0x0006
      008140 BC                     228 	.byte 0xbc
      008141                        229 00103$:
      008141 AE 00 3C         [ 2]  230 	ldw	x, #0x003c
      008144                        231 00104$:
      008144 CD 80 BB         [ 4]  232 	call	_delay_us
                                    233 ;	nokia.c: 69: DS_INPUT();
      008147 72 1B 50 07      [ 1]  234 	bres	0x5007, #5
                                    235 ;	nokia.c: 70: delay_us(bit ? 64 : 10);
      00814B 0D 01            [ 1]  236 	tnz	(0x01, sp)
      00814D 27 05            [ 1]  237 	jreq	00105$
      00814F AE 00 40         [ 2]  238 	ldw	x, #0x0040
      008152 20 03            [ 2]  239 	jra	00106$
      008154                        240 00105$:
      008154 AE 00 0A         [ 2]  241 	ldw	x, #0x000a
      008157                        242 00106$:
      008157 84               [ 1]  243 	pop	a
      008158 CC 80 BB         [ 2]  244 	jp	_delay_us
                                    245 ;	nokia.c: 71: }
      00815B 84               [ 1]  246 	pop	a
      00815C 81               [ 4]  247 	ret
                                    248 ;	nokia.c: 73: uint8_t onewire_read_bit(void) {
                                    249 ;	-----------------------------------------
                                    250 ;	 function onewire_read_bit
                                    251 ;	-----------------------------------------
      00815D                        252 _onewire_read_bit:
                                    253 ;	nokia.c: 75: DS_OUTPUT(); DS_LOW();
      00815D 72 1A 50 07      [ 1]  254 	bset	0x5007, #5
      008161 72 1B 50 05      [ 1]  255 	bres	0x5005, #5
                                    256 ;	nokia.c: 76: delay_us(6);
      008165 AE 00 06         [ 2]  257 	ldw	x, #0x0006
      008168 CD 80 BB         [ 4]  258 	call	_delay_us
                                    259 ;	nokia.c: 77: DS_INPUT();
      00816B 72 1B 50 07      [ 1]  260 	bres	0x5007, #5
                                    261 ;	nokia.c: 78: delay_us(9);
      00816F AE 00 09         [ 2]  262 	ldw	x, #0x0009
      008172 CD 80 BB         [ 4]  263 	call	_delay_us
                                    264 ;	nokia.c: 79: bit = (DS_READ() ? 1 : 0);
      008175 72 0B 50 06 03   [ 2]  265 	btjf	0x5006, #5, 00103$
      00817A 5F               [ 1]  266 	clrw	x
      00817B 5C               [ 1]  267 	incw	x
      00817C 21                     268 	.byte 0x21
      00817D                        269 00103$:
      00817D 5F               [ 1]  270 	clrw	x
      00817E                        271 00104$:
      00817E 9F               [ 1]  272 	ld	a, xl
                                    273 ;	nokia.c: 80: delay_us(55);
      00817F 88               [ 1]  274 	push	a
      008180 AE 00 37         [ 2]  275 	ldw	x, #0x0037
      008183 CD 80 BB         [ 4]  276 	call	_delay_us
      008186 84               [ 1]  277 	pop	a
                                    278 ;	nokia.c: 81: return bit;
                                    279 ;	nokia.c: 82: }
      008187 81               [ 4]  280 	ret
                                    281 ;	nokia.c: 84: void onewire_write_byte(uint8_t byte) {
                                    282 ;	-----------------------------------------
                                    283 ;	 function onewire_write_byte
                                    284 ;	-----------------------------------------
      008188                        285 _onewire_write_byte:
      008188 52 02            [ 2]  286 	sub	sp, #2
      00818A 6B 01            [ 1]  287 	ld	(0x01, sp), a
                                    288 ;	nokia.c: 85: for (uint8_t i = 0; i < 8; i++) {
      00818C 0F 02            [ 1]  289 	clr	(0x02, sp)
      00818E                        290 00103$:
      00818E 7B 02            [ 1]  291 	ld	a, (0x02, sp)
      008190 A1 08            [ 1]  292 	cp	a, #0x08
      008192 24 0D            [ 1]  293 	jrnc	00105$
                                    294 ;	nokia.c: 86: onewire_write_bit(byte & 0x01);
      008194 7B 01            [ 1]  295 	ld	a, (0x01, sp)
      008196 A4 01            [ 1]  296 	and	a, #0x01
      008198 CD 81 2E         [ 4]  297 	call	_onewire_write_bit
                                    298 ;	nokia.c: 87: byte >>= 1;
      00819B 04 01            [ 1]  299 	srl	(0x01, sp)
                                    300 ;	nokia.c: 85: for (uint8_t i = 0; i < 8; i++) {
      00819D 0C 02            [ 1]  301 	inc	(0x02, sp)
      00819F 20 ED            [ 2]  302 	jra	00103$
      0081A1                        303 00105$:
                                    304 ;	nokia.c: 89: }
      0081A1 5B 02            [ 2]  305 	addw	sp, #2
      0081A3 81               [ 4]  306 	ret
                                    307 ;	nokia.c: 91: uint8_t onewire_read_byte(void) {
                                    308 ;	-----------------------------------------
                                    309 ;	 function onewire_read_byte
                                    310 ;	-----------------------------------------
      0081A4                        311 _onewire_read_byte:
      0081A4 52 02            [ 2]  312 	sub	sp, #2
                                    313 ;	nokia.c: 92: uint8_t byte = 0;
      0081A6 0F 01            [ 1]  314 	clr	(0x01, sp)
                                    315 ;	nokia.c: 93: for (uint8_t i = 0; i < 8; i++) {
      0081A8 0F 02            [ 1]  316 	clr	(0x02, sp)
      0081AA                        317 00105$:
      0081AA 7B 02            [ 1]  318 	ld	a, (0x02, sp)
      0081AC A1 08            [ 1]  319 	cp	a, #0x08
      0081AE 24 11            [ 1]  320 	jrnc	00103$
                                    321 ;	nokia.c: 94: byte >>= 1;
      0081B0 04 01            [ 1]  322 	srl	(0x01, sp)
                                    323 ;	nokia.c: 95: if (onewire_read_bit()) byte |= 0x80;
      0081B2 CD 81 5D         [ 4]  324 	call	_onewire_read_bit
      0081B5 4D               [ 1]  325 	tnz	a
      0081B6 27 05            [ 1]  326 	jreq	00106$
      0081B8 08 01            [ 1]  327 	sll	(0x01, sp)
      0081BA 99               [ 1]  328 	scf
      0081BB 06 01            [ 1]  329 	rrc	(0x01, sp)
      0081BD                        330 00106$:
                                    331 ;	nokia.c: 93: for (uint8_t i = 0; i < 8; i++) {
      0081BD 0C 02            [ 1]  332 	inc	(0x02, sp)
      0081BF 20 E9            [ 2]  333 	jra	00105$
      0081C1                        334 00103$:
                                    335 ;	nokia.c: 97: return byte;
      0081C1 7B 01            [ 1]  336 	ld	a, (0x01, sp)
                                    337 ;	nokia.c: 98: }
      0081C3 5B 02            [ 2]  338 	addw	sp, #2
      0081C5 81               [ 4]  339 	ret
                                    340 ;	nokia.c: 100: void ds18b20_start_conversion(void) {
                                    341 ;	-----------------------------------------
                                    342 ;	 function ds18b20_start_conversion
                                    343 ;	-----------------------------------------
      0081C6                        344 _ds18b20_start_conversion:
                                    345 ;	nokia.c: 101: onewire_reset();
      0081C6 CD 81 04         [ 4]  346 	call	_onewire_reset
                                    347 ;	nokia.c: 102: onewire_write_byte(0xCC);
      0081C9 A6 CC            [ 1]  348 	ld	a, #0xcc
      0081CB CD 81 88         [ 4]  349 	call	_onewire_write_byte
                                    350 ;	nokia.c: 103: onewire_write_byte(0x44);
      0081CE A6 44            [ 1]  351 	ld	a, #0x44
                                    352 ;	nokia.c: 104: }
      0081D0 CC 81 88         [ 2]  353 	jp	_onewire_write_byte
                                    354 ;	nokia.c: 106: int16_t ds18b20_read_raw(void) {
                                    355 ;	-----------------------------------------
                                    356 ;	 function ds18b20_read_raw
                                    357 ;	-----------------------------------------
      0081D3                        358 _ds18b20_read_raw:
      0081D3 52 04            [ 2]  359 	sub	sp, #4
                                    360 ;	nokia.c: 107: onewire_reset();
      0081D5 CD 81 04         [ 4]  361 	call	_onewire_reset
                                    362 ;	nokia.c: 108: onewire_write_byte(0xCC);
      0081D8 A6 CC            [ 1]  363 	ld	a, #0xcc
      0081DA CD 81 88         [ 4]  364 	call	_onewire_write_byte
                                    365 ;	nokia.c: 109: onewire_write_byte(0xBE);
      0081DD A6 BE            [ 1]  366 	ld	a, #0xbe
      0081DF CD 81 88         [ 4]  367 	call	_onewire_write_byte
                                    368 ;	nokia.c: 110: uint8_t lsb = onewire_read_byte();
      0081E2 CD 81 A4         [ 4]  369 	call	_onewire_read_byte
                                    370 ;	nokia.c: 111: uint8_t msb = onewire_read_byte();
      0081E5 88               [ 1]  371 	push	a
      0081E6 CD 81 A4         [ 4]  372 	call	_onewire_read_byte
      0081E9 95               [ 1]  373 	ld	xh, a
      0081EA 84               [ 1]  374 	pop	a
                                    375 ;	nokia.c: 112: return ((int16_t)msb << 8) | lsb;
      0081EB 0F 02            [ 1]  376 	clr	(0x02, sp)
      0081ED 0F 03            [ 1]  377 	clr	(0x03, sp)
      0081EF 1A 02            [ 1]  378 	or	a, (0x02, sp)
      0081F1 02               [ 1]  379 	rlwa	x
      0081F2 1A 03            [ 1]  380 	or	a, (0x03, sp)
      0081F4 95               [ 1]  381 	ld	xh, a
                                    382 ;	nokia.c: 113: }
      0081F5 5B 04            [ 2]  383 	addw	sp, #4
      0081F7 81               [ 4]  384 	ret
                                    385 ;	nokia.c: 117: void lcd_send_byte(uint8_t data) {
                                    386 ;	-----------------------------------------
                                    387 ;	 function lcd_send_byte
                                    388 ;	-----------------------------------------
      0081F8                        389 _lcd_send_byte:
      0081F8 88               [ 1]  390 	push	a
      0081F9 95               [ 1]  391 	ld	xh, a
                                    392 ;	nokia.c: 118: for (uint8_t i = 0; i < 8; i++) {
      0081FA 0F 01            [ 1]  393 	clr	(0x01, sp)
      0081FC                        394 00106$:
      0081FC 7B 01            [ 1]  395 	ld	a, (0x01, sp)
      0081FE A1 08            [ 1]  396 	cp	a, #0x08
      008200 24 21            [ 1]  397 	jrnc	00108$
                                    398 ;	nokia.c: 119: if (data & 0x80) LCD_DIN_HIGH();  // Si bit courant = 1, ligne DIN à 1
      008202 C6 50 0A         [ 1]  399 	ld	a, 0x500a
      008205 5D               [ 2]  400 	tnzw	x
      008206 2A 07            [ 1]  401 	jrpl	00102$
      008208 AA 40            [ 1]  402 	or	a, #0x40
      00820A C7 50 0A         [ 1]  403 	ld	0x500a, a
      00820D 20 05            [ 2]  404 	jra	00103$
      00820F                        405 00102$:
                                    406 ;	nokia.c: 120: else LCD_DIN_LOW();               // Sinon ligne DIN à 0
      00820F A4 BF            [ 1]  407 	and	a, #0xbf
      008211 C7 50 0A         [ 1]  408 	ld	0x500a, a
      008214                        409 00103$:
                                    410 ;	nokia.c: 122: LCD_CLK_HIGH();  // Front montant : le LCD lit le bit ici
      008214 72 1A 50 0A      [ 1]  411 	bset	0x500a, #5
                                    412 ;	nokia.c: 123: LCD_CLK_LOW();   // Front descendant : prêt pour le bit suivant
      008218 72 1B 50 0A      [ 1]  413 	bres	0x500a, #5
                                    414 ;	nokia.c: 125: data <<= 1;  // Décale vers la gauche pour le prochain bit
      00821C 9E               [ 1]  415 	ld	a, xh
      00821D 48               [ 1]  416 	sll	a
      00821E 95               [ 1]  417 	ld	xh, a
                                    418 ;	nokia.c: 118: for (uint8_t i = 0; i < 8; i++) {
      00821F 0C 01            [ 1]  419 	inc	(0x01, sp)
      008221 20 D9            [ 2]  420 	jra	00106$
      008223                        421 00108$:
                                    422 ;	nokia.c: 127: }
      008223 84               [ 1]  423 	pop	a
      008224 81               [ 4]  424 	ret
                                    425 ;	nokia.c: 131: void lcd_write_cmd(uint8_t cmd) {
                                    426 ;	-----------------------------------------
                                    427 ;	 function lcd_write_cmd
                                    428 ;	-----------------------------------------
      008225                        429 _lcd_write_cmd:
      008225 97               [ 1]  430 	ld	xl, a
                                    431 ;	nokia.c: 132: LCD_DC_LOW();     // On sélectionne le mode "commande"
      008226 72 19 50 0A      [ 1]  432 	bres	0x500a, #4
                                    433 ;	nokia.c: 133: LCD_CE_LOW();     // Active la communication avec l'écran
      00822A 72 13 50 0F      [ 1]  434 	bres	0x500f, #1
                                    435 ;	nokia.c: 134: lcd_send_byte(cmd); // Envoie la commande
      00822E 9F               [ 1]  436 	ld	a, xl
      00822F CD 81 F8         [ 4]  437 	call	_lcd_send_byte
                                    438 ;	nokia.c: 135: LCD_CE_HIGH();    // Termine la communication
      008232 72 12 50 0F      [ 1]  439 	bset	0x500f, #1
                                    440 ;	nokia.c: 136: }
      008236 81               [ 4]  441 	ret
                                    442 ;	nokia.c: 140: void lcd_write_data(uint8_t data) {
                                    443 ;	-----------------------------------------
                                    444 ;	 function lcd_write_data
                                    445 ;	-----------------------------------------
      008237                        446 _lcd_write_data:
      008237 97               [ 1]  447 	ld	xl, a
                                    448 ;	nokia.c: 141: LCD_DC_HIGH();     // Mode "donnée"
      008238 72 18 50 0A      [ 1]  449 	bset	0x500a, #4
                                    450 ;	nokia.c: 142: LCD_CE_LOW();      // Active la communication avec l'écran
      00823C 72 13 50 0F      [ 1]  451 	bres	0x500f, #1
                                    452 ;	nokia.c: 143: lcd_send_byte(data);  // Envoie la donnée (1 octet = 8 pixels verticaux)
      008240 9F               [ 1]  453 	ld	a, xl
      008241 CD 81 F8         [ 4]  454 	call	_lcd_send_byte
                                    455 ;	nokia.c: 144: LCD_CE_HIGH();     // Termine la communication
      008244 72 12 50 0F      [ 1]  456 	bset	0x500f, #1
                                    457 ;	nokia.c: 145: }
      008248 81               [ 4]  458 	ret
                                    459 ;	nokia.c: 149: void lcd_init(void) {
                                    460 ;	-----------------------------------------
                                    461 ;	 function lcd_init
                                    462 ;	-----------------------------------------
      008249                        463 _lcd_init:
                                    464 ;	nokia.c: 151: PC_DDR |= (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7);
      008249 C6 50 0C         [ 1]  465 	ld	a, 0x500c
      00824C AA F0            [ 1]  466 	or	a, #0xf0
      00824E C7 50 0C         [ 1]  467 	ld	0x500c, a
                                    468 ;	nokia.c: 152: PC_CR1 |= (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7);
      008251 C6 50 0D         [ 1]  469 	ld	a, 0x500d
      008254 AA F0            [ 1]  470 	or	a, #0xf0
      008256 C7 50 0D         [ 1]  471 	ld	0x500d, a
                                    472 ;	nokia.c: 155: PD_DDR |= (1 << 1);
      008259 72 12 50 11      [ 1]  473 	bset	0x5011, #1
                                    474 ;	nokia.c: 156: PD_CR1 |= (1 << 1);
      00825D 72 12 50 12      [ 1]  475 	bset	0x5012, #1
                                    476 ;	nokia.c: 159: LCD_RST_LOW();     // Maintient RST à 0
      008261 72 1F 50 0A      [ 1]  477 	bres	0x500a, #7
                                    478 ;	nokia.c: 160: delay_ms(100);     // Attend 100 ms
      008265 AE 00 64         [ 2]  479 	ldw	x, #0x0064
      008268 CD 80 CC         [ 4]  480 	call	_delay_ms
                                    481 ;	nokia.c: 161: LCD_RST_HIGH();    // Libère RST → redémarrage du LCD
      00826B 72 1E 50 0A      [ 1]  482 	bset	0x500a, #7
                                    483 ;	nokia.c: 164: lcd_write_cmd(0x21); // Mode étendu (permet config contraste, température...)
      00826F A6 21            [ 1]  484 	ld	a, #0x21
      008271 CD 82 25         [ 4]  485 	call	_lcd_write_cmd
                                    486 ;	nokia.c: 165: lcd_write_cmd(0xB0); // Contraste (valeur entre 0x80 et 0xBF, à adapter si besoin)
      008274 A6 B0            [ 1]  487 	ld	a, #0xb0
      008276 CD 82 25         [ 4]  488 	call	_lcd_write_cmd
                                    489 ;	nokia.c: 166: lcd_write_cmd(0x04); // Coefficient de température (valeur recommandée)
      008279 A6 04            [ 1]  490 	ld	a, #0x04
      00827B CD 82 25         [ 4]  491 	call	_lcd_write_cmd
                                    492 ;	nokia.c: 167: lcd_write_cmd(0x14); // Biais LCD (rapport tension segments)
      00827E A6 14            [ 1]  493 	ld	a, #0x14
      008280 CD 82 25         [ 4]  494 	call	_lcd_write_cmd
                                    495 ;	nokia.c: 168: lcd_write_cmd(0x20); // Retour en mode basique
      008283 A6 20            [ 1]  496 	ld	a, #0x20
      008285 CD 82 25         [ 4]  497 	call	_lcd_write_cmd
                                    498 ;	nokia.c: 169: lcd_write_cmd(0x0C); // Affichage normal (pas d’inversion, pas de tout-éteint)
      008288 A6 0C            [ 1]  499 	ld	a, #0x0c
                                    500 ;	nokia.c: 170: }
      00828A CC 82 25         [ 2]  501 	jp	_lcd_write_cmd
                                    502 ;	nokia.c: 174: void lcd_clear(void) {
                                    503 ;	-----------------------------------------
                                    504 ;	 function lcd_clear
                                    505 ;	-----------------------------------------
      00828D                        506 _lcd_clear:
                                    507 ;	nokia.c: 175: for (uint16_t i = 0; i < 504; i++) {
      00828D 5F               [ 1]  508 	clrw	x
      00828E                        509 00103$:
      00828E 90 93            [ 1]  510 	ldw	y, x
      008290 90 A3 01 F8      [ 2]  511 	cpw	y, #0x01f8
      008294 25 01            [ 1]  512 	jrc	00118$
      008296 81               [ 4]  513 	ret
      008297                        514 00118$:
                                    515 ;	nokia.c: 176: lcd_write_data(0x00); // Chaque octet = 8 pixels verticaux noirs
      008297 89               [ 2]  516 	pushw	x
      008298 4F               [ 1]  517 	clr	a
      008299 CD 82 37         [ 4]  518 	call	_lcd_write_data
      00829C 85               [ 2]  519 	popw	x
                                    520 ;	nokia.c: 175: for (uint16_t i = 0; i < 504; i++) {
      00829D 5C               [ 1]  521 	incw	x
      00829E 20 EE            [ 2]  522 	jra	00103$
                                    523 ;	nokia.c: 178: }
      0082A0 81               [ 4]  524 	ret
                                    525 ;	nokia.c: 183: void lcd_draw_8x8_char(const uint8_t* glyph, uint8_t x, uint8_t y) {
                                    526 ;	-----------------------------------------
                                    527 ;	 function lcd_draw_8x8_char
                                    528 ;	-----------------------------------------
      0082A1                        529 _lcd_draw_8x8_char:
      0082A1 52 08            [ 2]  530 	sub	sp, #8
      0082A3 1F 04            [ 2]  531 	ldw	(0x04, sp), x
      0082A5 6B 03            [ 1]  532 	ld	(0x03, sp), a
                                    533 ;	nokia.c: 184: for (uint8_t col = 0; col < 8; col++) {
      0082A7 0F 06            [ 1]  534 	clr	(0x06, sp)
      0082A9                        535 00109$:
      0082A9 7B 06            [ 1]  536 	ld	a, (0x06, sp)
      0082AB A1 08            [ 1]  537 	cp	a, #0x08
      0082AD 24 6B            [ 1]  538 	jrnc	00111$
                                    539 ;	nokia.c: 185: uint8_t out = 0;
      0082AF 0F 07            [ 1]  540 	clr	(0x07, sp)
                                    541 ;	nokia.c: 186: for (uint8_t row = 0; row < 8; row++) {
      0082B1 A6 07            [ 1]  542 	ld	a, #0x07
      0082B3 10 06            [ 1]  543 	sub	a, (0x06, sp)
      0082B5 5F               [ 1]  544 	clrw	x
      0082B6 5C               [ 1]  545 	incw	x
      0082B7 1F 01            [ 2]  546 	ldw	(0x01, sp), x
      0082B9 4D               [ 1]  547 	tnz	a
      0082BA 27 07            [ 1]  548 	jreq	00142$
      0082BC                        549 00141$:
      0082BC 08 02            [ 1]  550 	sll	(0x02, sp)
      0082BE 09 01            [ 1]  551 	rlc	(0x01, sp)
      0082C0 4A               [ 1]  552 	dec	a
      0082C1 26 F9            [ 1]  553 	jrne	00141$
      0082C3                        554 00142$:
      0082C3 0F 08            [ 1]  555 	clr	(0x08, sp)
      0082C5                        556 00106$:
      0082C5 7B 08            [ 1]  557 	ld	a, (0x08, sp)
      0082C7 A1 08            [ 1]  558 	cp	a, #0x08
      0082C9 24 2A            [ 1]  559 	jrnc	00103$
                                    560 ;	nokia.c: 187: if (glyph[row] & (1 << (7 - col))) {
      0082CB 5F               [ 1]  561 	clrw	x
      0082CC 7B 08            [ 1]  562 	ld	a, (0x08, sp)
      0082CE 97               [ 1]  563 	ld	xl, a
      0082CF 72 FB 04         [ 2]  564 	addw	x, (0x04, sp)
      0082D2 F6               [ 1]  565 	ld	a, (x)
      0082D3 5F               [ 1]  566 	clrw	x
      0082D4 14 02            [ 1]  567 	and	a, (0x02, sp)
      0082D6 01               [ 1]  568 	rrwa	x
      0082D7 14 01            [ 1]  569 	and	a, (0x01, sp)
      0082D9 97               [ 1]  570 	ld	xl, a
      0082DA 5D               [ 2]  571 	tnzw	x
      0082DB 27 14            [ 1]  572 	jreq	00107$
                                    573 ;	nokia.c: 188: out |= (1 << row);  // Transpose bit : ligne → colonne
      0082DD 7B 08            [ 1]  574 	ld	a, (0x08, sp)
      0082DF 97               [ 1]  575 	ld	xl, a
      0082E0 A6 01            [ 1]  576 	ld	a, #0x01
      0082E2 88               [ 1]  577 	push	a
      0082E3 9F               [ 1]  578 	ld	a, xl
      0082E4 4D               [ 1]  579 	tnz	a
      0082E5 27 05            [ 1]  580 	jreq	00146$
      0082E7                        581 00145$:
      0082E7 08 01            [ 1]  582 	sll	(1, sp)
      0082E9 4A               [ 1]  583 	dec	a
      0082EA 26 FB            [ 1]  584 	jrne	00145$
      0082EC                        585 00146$:
      0082EC 84               [ 1]  586 	pop	a
      0082ED 1A 07            [ 1]  587 	or	a, (0x07, sp)
      0082EF 6B 07            [ 1]  588 	ld	(0x07, sp), a
      0082F1                        589 00107$:
                                    590 ;	nokia.c: 186: for (uint8_t row = 0; row < 8; row++) {
      0082F1 0C 08            [ 1]  591 	inc	(0x08, sp)
      0082F3 20 D0            [ 2]  592 	jra	00106$
      0082F5                        593 00103$:
                                    594 ;	nokia.c: 193: lcd_write_cmd(0x40 | (y / 8));   // Page Y (chaque page = 8 lignes)
      0082F5 7B 0B            [ 1]  595 	ld	a, (0x0b, sp)
      0082F7 5F               [ 1]  596 	clrw	x
      0082F8 97               [ 1]  597 	ld	xl, a
      0082F9 5D               [ 2]  598 	tnzw	x
      0082FA 2A 03            [ 1]  599 	jrpl	00147$
      0082FC 1C 00 07         [ 2]  600 	addw	x, #0x0007
      0082FF                        601 00147$:
      0082FF 57               [ 2]  602 	sraw	x
      008300 57               [ 2]  603 	sraw	x
      008301 57               [ 2]  604 	sraw	x
      008302 9F               [ 1]  605 	ld	a, xl
      008303 AA 40            [ 1]  606 	or	a, #0x40
      008305 CD 82 25         [ 4]  607 	call	_lcd_write_cmd
                                    608 ;	nokia.c: 194: lcd_write_cmd(0x80 | (x + col)); // Colonne X + décalage actuel
      008308 7B 03            [ 1]  609 	ld	a, (0x03, sp)
      00830A 1B 06            [ 1]  610 	add	a, (0x06, sp)
      00830C AA 80            [ 1]  611 	or	a, #0x80
      00830E CD 82 25         [ 4]  612 	call	_lcd_write_cmd
                                    613 ;	nokia.c: 196: lcd_write_data(out); // Envoie 1 colonne verticale de 8 pixels
      008311 7B 07            [ 1]  614 	ld	a, (0x07, sp)
      008313 CD 82 37         [ 4]  615 	call	_lcd_write_data
                                    616 ;	nokia.c: 184: for (uint8_t col = 0; col < 8; col++) {
      008316 0C 06            [ 1]  617 	inc	(0x06, sp)
      008318 20 8F            [ 2]  618 	jra	00109$
      00831A                        619 00111$:
                                    620 ;	nokia.c: 198: }
      00831A 5B 08            [ 2]  621 	addw	sp, #8
      00831C 85               [ 2]  622 	popw	x
      00831D 84               [ 1]  623 	pop	a
      00831E FC               [ 2]  624 	jp	(x)
                                    625 ;	nokia.c: 203: void lcd_draw_char_small(const uint8_t *data, uint8_t x, uint8_t page) {
                                    626 ;	-----------------------------------------
                                    627 ;	 function lcd_draw_char_small
                                    628 ;	-----------------------------------------
      00831F                        629 _lcd_draw_char_small:
      00831F 52 03            [ 2]  630 	sub	sp, #3
      008321 1F 01            [ 2]  631 	ldw	(0x01, sp), x
                                    632 ;	nokia.c: 204: lcd_write_cmd(0x80 | x);           // Position horizontale (X)
      008323 AA 80            [ 1]  633 	or	a, #0x80
      008325 CD 82 25         [ 4]  634 	call	_lcd_write_cmd
                                    635 ;	nokia.c: 205: lcd_write_cmd(0x40 | page);        // Position verticale (page Y de 8 lignes)
      008328 7B 06            [ 1]  636 	ld	a, (0x06, sp)
      00832A AA 40            [ 1]  637 	or	a, #0x40
      00832C CD 82 25         [ 4]  638 	call	_lcd_write_cmd
                                    639 ;	nokia.c: 207: for (uint8_t i = 0; i < 5; i++) {
      00832F 0F 03            [ 1]  640 	clr	(0x03, sp)
      008331                        641 00103$:
      008331 7B 03            [ 1]  642 	ld	a, (0x03, sp)
      008333 A1 05            [ 1]  643 	cp	a, #0x05
      008335 24 0F            [ 1]  644 	jrnc	00101$
                                    645 ;	nokia.c: 208: lcd_write_data(data[i]);       // Envoie les 5 colonnes du caractère
      008337 5F               [ 1]  646 	clrw	x
      008338 7B 03            [ 1]  647 	ld	a, (0x03, sp)
      00833A 97               [ 1]  648 	ld	xl, a
      00833B 72 FB 01         [ 2]  649 	addw	x, (0x01, sp)
      00833E F6               [ 1]  650 	ld	a, (x)
      00833F CD 82 37         [ 4]  651 	call	_lcd_write_data
                                    652 ;	nokia.c: 207: for (uint8_t i = 0; i < 5; i++) {
      008342 0C 03            [ 1]  653 	inc	(0x03, sp)
      008344 20 EB            [ 2]  654 	jra	00103$
      008346                        655 00101$:
                                    656 ;	nokia.c: 210: lcd_write_data(0x00); // Ajoute un espace de 1 colonne après
      008346 4F               [ 1]  657 	clr	a
      008347 1E 04            [ 2]  658 	ldw	x, (4, sp)
      008349 1F 05            [ 2]  659 	ldw	(5, sp), x
      00834B 5B 04            [ 2]  660 	addw	sp, #4
                                    661 ;	nokia.c: 211: }
      00834D CC 82 37         [ 2]  662 	jp	_lcd_write_data
      008350 84               [ 1]  663 	pop	a
      008351 FC               [ 2]  664 	jp	(x)
                                    665 ;	nokia.c: 215: void lcd_print_temperature(int16_t temp_x100, uint8_t x, uint8_t y) {
                                    666 ;	-----------------------------------------
                                    667 ;	 function lcd_print_temperature
                                    668 ;	-----------------------------------------
      008352                        669 _lcd_print_temperature:
      008352 52 0F            [ 2]  670 	sub	sp, #15
      008354 6B 0E            [ 1]  671 	ld	(0x0e, sp), a
                                    672 ;	nokia.c: 219: int int_part = temp_x100 / 100;
      008356 89               [ 2]  673 	pushw	x
      008357 4B 64            [ 1]  674 	push	#0x64
      008359 4B 00            [ 1]  675 	push	#0x00
      00835B CD 86 0F         [ 4]  676 	call	__divsint
      00835E 51               [ 1]  677 	exgw	x, y
      00835F 85               [ 2]  678 	popw	x
      008360 17 01            [ 2]  679 	ldw	(0x01, sp), y
                                    680 ;	nokia.c: 220: int frac_part = temp_x100 % 100;
      008362 89               [ 2]  681 	pushw	x
      008363 4B 64            [ 1]  682 	push	#0x64
      008365 4B 00            [ 1]  683 	push	#0x00
      008367 CD 85 7B         [ 4]  684 	call	__modsint
      00836A 51               [ 1]  685 	exgw	x, y
      00836B 85               [ 2]  686 	popw	x
      00836C 17 0C            [ 2]  687 	ldw	(0x0c, sp), y
                                    688 ;	nokia.c: 222: if (temp_x100 < 0) {
      00836E 5D               [ 2]  689 	tnzw	x
      00836F 2A 1E            [ 1]  690 	jrpl	00102$
                                    691 ;	nokia.c: 223: int_part = -int_part;
      008371 1E 01            [ 2]  692 	ldw	x, (0x01, sp)
      008373 50               [ 2]  693 	negw	x
                                    694 ;	nokia.c: 224: frac_part = -frac_part;
      008374 16 0C            [ 2]  695 	ldw	y, (0x0c, sp)
      008376 90 50            [ 2]  696 	negw	y
                                    697 ;	nokia.c: 225: buf[0] = '-';
      008378 A6 2D            [ 1]  698 	ld	a, #0x2d
      00837A 6B 03            [ 1]  699 	ld	(0x03, sp), a
                                    700 ;	nokia.c: 226: sprintf(buf + 1, "%d.%02d", int_part, frac_part);
      00837C 90 89            [ 2]  701 	pushw	y
      00837E 89               [ 2]  702 	pushw	x
      00837F 4B 94            [ 1]  703 	push	#<(___str_0+0)
      008381 4B 80            [ 1]  704 	push	#((___str_0+0) >> 8)
      008383 96               [ 1]  705 	ldw	x, sp
      008384 1C 00 0A         [ 2]  706 	addw	x, #10
      008387 89               [ 2]  707 	pushw	x
      008388 CD 85 0A         [ 4]  708 	call	_sprintf
      00838B 5B 08            [ 2]  709 	addw	sp, #8
      00838D 20 14            [ 2]  710 	jra	00103$
      00838F                        711 00102$:
                                    712 ;	nokia.c: 228: sprintf(buf, "%d.%02d", int_part, frac_part);
      00838F 1E 0C            [ 2]  713 	ldw	x, (0x0c, sp)
      008391 89               [ 2]  714 	pushw	x
      008392 1E 03            [ 2]  715 	ldw	x, (0x03, sp)
      008394 89               [ 2]  716 	pushw	x
      008395 4B 94            [ 1]  717 	push	#<(___str_0+0)
      008397 4B 80            [ 1]  718 	push	#((___str_0+0) >> 8)
      008399 96               [ 1]  719 	ldw	x, sp
      00839A 1C 00 09         [ 2]  720 	addw	x, #9
      00839D 89               [ 2]  721 	pushw	x
      00839E CD 85 0A         [ 4]  722 	call	_sprintf
      0083A1 5B 08            [ 2]  723 	addw	sp, #8
      0083A3                        724 00103$:
                                    725 ;	nokia.c: 231: uint8_t cursor = x; // Position de départ
      0083A3 7B 0E            [ 1]  726 	ld	a, (0x0e, sp)
      0083A5 6B 0B            [ 1]  727 	ld	(0x0b, sp), a
                                    728 ;	nokia.c: 234: for (uint8_t i = 0; buf[i] != '\0'; i++) {
      0083A7 0F 0F            [ 1]  729 	clr	(0x0f, sp)
      0083A9                        730 00115$:
      0083A9 5F               [ 1]  731 	clrw	x
      0083AA 7B 0F            [ 1]  732 	ld	a, (0x0f, sp)
      0083AC 97               [ 1]  733 	ld	xl, a
      0083AD 89               [ 2]  734 	pushw	x
      0083AE 96               [ 1]  735 	ldw	x, sp
      0083AF 1C 00 05         [ 2]  736 	addw	x, #5
      0083B2 72 FB 01         [ 2]  737 	addw	x, (1, sp)
      0083B5 5B 02            [ 2]  738 	addw	sp, #2
      0083B7 F6               [ 1]  739 	ld	a, (x)
      0083B8 97               [ 1]  740 	ld	xl, a
                                    741 ;	nokia.c: 255: cursor += 8; // Avance de 8 pixels pour le prochain caractère
      0083B9 7B 0B            [ 1]  742 	ld	a, (0x0b, sp)
      0083BB AB 08            [ 1]  743 	add	a, #0x08
      0083BD 6B 0C            [ 1]  744 	ld	(0x0c, sp), a
                                    745 ;	nokia.c: 234: for (uint8_t i = 0; buf[i] != '\0'; i++) {
      0083BF 9F               [ 1]  746 	ld	a, xl
      0083C0 4D               [ 1]  747 	tnz	a
      0083C1 27 51            [ 1]  748 	jreq	00113$
                                    749 ;	nokia.c: 235: char c = buf[i];
      0083C3 9F               [ 1]  750 	ld	a, xl
                                    751 ;	nokia.c: 237: if (c >= '0' && c <= '9') {
      0083C4 6B 0D            [ 1]  752 	ld	(0x0d, sp), a
      0083C6 A1 30            [ 1]  753 	cp	a, #0x30
      0083C8 25 1E            [ 1]  754 	jrc	00110$
      0083CA 7B 0D            [ 1]  755 	ld	a, (0x0d, sp)
      0083CC A1 39            [ 1]  756 	cp	a, #0x39
      0083CE 22 18            [ 1]  757 	jrugt	00110$
                                    758 ;	nokia.c: 238: lcd_draw_8x8_char(big_digits[c - '0'], cursor, y);
      0083D0 7B 0D            [ 1]  759 	ld	a, (0x0d, sp)
      0083D2 A0 30            [ 1]  760 	sub	a, #0x30
      0083D4 97               [ 1]  761 	ld	xl, a
      0083D5 49               [ 1]  762 	rlc	a
      0083D6 4F               [ 1]  763 	clr	a
      0083D7 A2 00            [ 1]  764 	sbc	a, #0x00
      0083D9 95               [ 1]  765 	ld	xh, a
      0083DA 58               [ 2]  766 	sllw	x
      0083DB DE 00 01         [ 2]  767 	ldw	x, (_big_digits+0, x)
      0083DE 7B 12            [ 1]  768 	ld	a, (0x12, sp)
      0083E0 88               [ 1]  769 	push	a
      0083E1 7B 0C            [ 1]  770 	ld	a, (0x0c, sp)
      0083E3 CD 82 A1         [ 4]  771 	call	_lcd_draw_8x8_char
      0083E6 20 24            [ 2]  772 	jra	00111$
      0083E8                        773 00110$:
                                    774 ;	nokia.c: 239: } else if (c == '.') {
      0083E8 7B 0D            [ 1]  775 	ld	a, (0x0d, sp)
      0083EA A1 2E            [ 1]  776 	cp	a, #0x2e
      0083EC 26 0D            [ 1]  777 	jrne	00107$
                                    778 ;	nokia.c: 240: lcd_draw_8x8_char(big_char_dot, cursor, y);
      0083EE 7B 12            [ 1]  779 	ld	a, (0x12, sp)
      0083F0 88               [ 1]  780 	push	a
      0083F1 7B 0C            [ 1]  781 	ld	a, (0x0c, sp)
      0083F3 AE 80 7C         [ 2]  782 	ldw	x, #(_big_char_dot+0)
      0083F6 CD 82 A1         [ 4]  783 	call	_lcd_draw_8x8_char
      0083F9 20 11            [ 2]  784 	jra	00111$
      0083FB                        785 00107$:
                                    786 ;	nokia.c: 241: } else if (c == '-') {
      0083FB 7B 0D            [ 1]  787 	ld	a, (0x0d, sp)
      0083FD A1 2D            [ 1]  788 	cp	a, #0x2d
      0083FF 26 0B            [ 1]  789 	jrne	00111$
                                    790 ;	nokia.c: 252: lcd_draw_8x8_char(minus, cursor, y);
      008401 7B 12            [ 1]  791 	ld	a, (0x12, sp)
      008403 88               [ 1]  792 	push	a
      008404 7B 0C            [ 1]  793 	ld	a, (0x0c, sp)
      008406 AE 80 8C         [ 2]  794 	ldw	x, #(_lcd_print_temperature_minus_262145_71+0)
      008409 CD 82 A1         [ 4]  795 	call	_lcd_draw_8x8_char
      00840C                        796 00111$:
                                    797 ;	nokia.c: 255: cursor += 8; // Avance de 8 pixels pour le prochain caractère
      00840C 7B 0C            [ 1]  798 	ld	a, (0x0c, sp)
      00840E 6B 0B            [ 1]  799 	ld	(0x0b, sp), a
                                    800 ;	nokia.c: 234: for (uint8_t i = 0; buf[i] != '\0'; i++) {
      008410 0C 0F            [ 1]  801 	inc	(0x0f, sp)
      008412 20 95            [ 2]  802 	jra	00115$
      008414                        803 00113$:
                                    804 ;	nokia.c: 259: lcd_draw_8x8_char(big_char_deg, cursor, y);
      008414 7B 12            [ 1]  805 	ld	a, (0x12, sp)
      008416 88               [ 1]  806 	push	a
      008417 7B 0C            [ 1]  807 	ld	a, (0x0c, sp)
      008419 AE 80 84         [ 2]  808 	ldw	x, #(_big_char_deg+0)
      00841C CD 82 A1         [ 4]  809 	call	_lcd_draw_8x8_char
                                    810 ;	nokia.c: 260: cursor += 8;
      00841F 7B 0C            [ 1]  811 	ld	a, (0x0c, sp)
      008421 97               [ 1]  812 	ld	xl, a
                                    813 ;	nokia.c: 261: lcd_draw_8x8_char(big_char_C, cursor, y);
      008422 7B 12            [ 1]  814 	ld	a, (0x12, sp)
      008424 88               [ 1]  815 	push	a
      008425 9F               [ 1]  816 	ld	a, xl
      008426 AE 80 74         [ 2]  817 	ldw	x, #(_big_char_C+0)
      008429 CD 82 A1         [ 4]  818 	call	_lcd_draw_8x8_char
                                    819 ;	nokia.c: 262: }
      00842C 5B 0F            [ 2]  820 	addw	sp, #15
      00842E 85               [ 2]  821 	popw	x
      00842F 84               [ 1]  822 	pop	a
      008430 FC               [ 2]  823 	jp	(x)
                                    824 ;	nokia.c: 267: void main() {
                                    825 ;	-----------------------------------------
                                    826 ;	 function main
                                    827 ;	-----------------------------------------
      008431                        828 _main:
                                    829 ;	nokia.c: 269: CLK_CKDIVR = 0x00; // forcer la frequence CPU
      008431 35 00 50 C6      [ 1]  830 	mov	0x50c6+0, #0x00
                                    831 ;	nokia.c: 273: PB_DDR &= ~(1 << DS_PIN);    // Direction = entrée
      008435 72 1B 50 07      [ 1]  832 	bres	0x5007, #5
                                    833 ;	nokia.c: 274: PB_CR1 |= (1 << DS_PIN);     // Active le pull-up (résistance interne à Vcc)
      008439 72 1A 50 08      [ 1]  834 	bset	0x5008, #5
                                    835 ;	nokia.c: 278: lcd_init();   // Envoie la séquence d’initialisation au LCD PCD8544
      00843D CD 82 49         [ 4]  836 	call	_lcd_init
                                    837 ;	nokia.c: 279: lcd_clear();  // Efface tout l’écran
      008440 CD 82 8D         [ 4]  838 	call	_lcd_clear
                                    839 ;	nokia.c: 282: while (1) {
      008443                        840 00102$:
                                    841 ;	nokia.c: 284: ds18b20_start_conversion(); // Envoie la commande "Convert T"
      008443 CD 81 C6         [ 4]  842 	call	_ds18b20_start_conversion
                                    843 ;	nokia.c: 285: delay_ms(750);              // Attente du temps de conversion (max 750 ms)
      008446 AE 02 EE         [ 2]  844 	ldw	x, #0x02ee
      008449 CD 80 CC         [ 4]  845 	call	_delay_ms
                                    846 ;	nokia.c: 288: int16_t raw = ds18b20_read_raw(); // Lit les 16 bits bruts (valeur signée)
      00844C CD 81 D3         [ 4]  847 	call	_ds18b20_read_raw
                                    848 ;	nokia.c: 292: int16_t temp_x100 = (raw * 625UL) / 100;
      00844F 90 5F            [ 1]  849 	clrw	y
      008451 5D               [ 2]  850 	tnzw	x
      008452 2A 02            [ 1]  851 	jrpl	00111$
      008454 90 5A            [ 2]  852 	decw	y
      008456                        853 00111$:
      008456 89               [ 2]  854 	pushw	x
      008457 90 89            [ 2]  855 	pushw	y
      008459 4B 71            [ 1]  856 	push	#0x71
      00845B 4B 02            [ 1]  857 	push	#0x02
      00845D 5F               [ 1]  858 	clrw	x
      00845E 89               [ 2]  859 	pushw	x
      00845F CD 85 93         [ 4]  860 	call	__mullong
      008462 5B 08            [ 2]  861 	addw	sp, #8
      008464 4B 64            [ 1]  862 	push	#0x64
      008466 4B 00            [ 1]  863 	push	#0x00
      008468 4B 00            [ 1]  864 	push	#0x00
      00846A 4B 00            [ 1]  865 	push	#0x00
      00846C 89               [ 2]  866 	pushw	x
      00846D 90 89            [ 2]  867 	pushw	y
      00846F CD 85 22         [ 4]  868 	call	__divulong
      008472 5B 08            [ 2]  869 	addw	sp, #8
                                    870 ;	nokia.c: 295: lcd_print_temperature(temp_x100, 16, 16);
      008474 4B 10            [ 1]  871 	push	#0x10
      008476 A6 10            [ 1]  872 	ld	a, #0x10
      008478 CD 83 52         [ 4]  873 	call	_lcd_print_temperature
                                    874 ;	nokia.c: 299: delay_ms(1000); // Rafraîchissement toutes les secondes
      00847B AE 03 E8         [ 2]  875 	ldw	x, #0x03e8
      00847E CD 80 CC         [ 4]  876 	call	_delay_ms
      008481 20 C0            [ 2]  877 	jra	00102$
                                    878 ;	nokia.c: 301: }
      008483 81               [ 4]  879 	ret
                                    880 	.area CODE
                                    881 	.area CONST
      008024                        882 _big_digit_0:
      008024 3C                     883 	.db #0x3c	; 60
      008025 66                     884 	.db #0x66	; 102	'f'
      008026 C3                     885 	.db #0xc3	; 195
      008027 C3                     886 	.db #0xc3	; 195
      008028 C3                     887 	.db #0xc3	; 195
      008029 C3                     888 	.db #0xc3	; 195
      00802A 66                     889 	.db #0x66	; 102	'f'
      00802B 3C                     890 	.db #0x3c	; 60
      00802C                        891 _big_digit_1:
      00802C 18                     892 	.db #0x18	; 24
      00802D 38                     893 	.db #0x38	; 56	'8'
      00802E 78                     894 	.db #0x78	; 120	'x'
      00802F 18                     895 	.db #0x18	; 24
      008030 18                     896 	.db #0x18	; 24
      008031 18                     897 	.db #0x18	; 24
      008032 18                     898 	.db #0x18	; 24
      008033 7E                     899 	.db #0x7e	; 126
      008034                        900 _big_digit_2:
      008034 7C                     901 	.db #0x7c	; 124
      008035 C6                     902 	.db #0xc6	; 198
      008036 06                     903 	.db #0x06	; 6
      008037 0C                     904 	.db #0x0c	; 12
      008038 30                     905 	.db #0x30	; 48	'0'
      008039 60                     906 	.db #0x60	; 96
      00803A FE                     907 	.db #0xfe	; 254
      00803B FE                     908 	.db #0xfe	; 254
      00803C                        909 _big_digit_3:
      00803C 7C                     910 	.db #0x7c	; 124
      00803D C6                     911 	.db #0xc6	; 198
      00803E 06                     912 	.db #0x06	; 6
      00803F 3C                     913 	.db #0x3c	; 60
      008040 06                     914 	.db #0x06	; 6
      008041 06                     915 	.db #0x06	; 6
      008042 C6                     916 	.db #0xc6	; 198
      008043 7C                     917 	.db #0x7c	; 124
      008044                        918 _big_digit_4:
      008044 0C                     919 	.db #0x0c	; 12
      008045 1C                     920 	.db #0x1c	; 28
      008046 3C                     921 	.db #0x3c	; 60
      008047 6C                     922 	.db #0x6c	; 108	'l'
      008048 CC                     923 	.db #0xcc	; 204
      008049 FE                     924 	.db #0xfe	; 254
      00804A 0C                     925 	.db #0x0c	; 12
      00804B 0C                     926 	.db #0x0c	; 12
      00804C                        927 _big_digit_5:
      00804C FE                     928 	.db #0xfe	; 254
      00804D C0                     929 	.db #0xc0	; 192
      00804E FC                     930 	.db #0xfc	; 252
      00804F 06                     931 	.db #0x06	; 6
      008050 06                     932 	.db #0x06	; 6
      008051 06                     933 	.db #0x06	; 6
      008052 C6                     934 	.db #0xc6	; 198
      008053 7C                     935 	.db #0x7c	; 124
      008054                        936 _big_digit_6:
      008054 3C                     937 	.db #0x3c	; 60
      008055 60                     938 	.db #0x60	; 96
      008056 C0                     939 	.db #0xc0	; 192
      008057 FC                     940 	.db #0xfc	; 252
      008058 C6                     941 	.db #0xc6	; 198
      008059 C6                     942 	.db #0xc6	; 198
      00805A 66                     943 	.db #0x66	; 102	'f'
      00805B 3C                     944 	.db #0x3c	; 60
      00805C                        945 _big_digit_7:
      00805C FE                     946 	.db #0xfe	; 254
      00805D 06                     947 	.db #0x06	; 6
      00805E 0C                     948 	.db #0x0c	; 12
      00805F 18                     949 	.db #0x18	; 24
      008060 30                     950 	.db #0x30	; 48	'0'
      008061 60                     951 	.db #0x60	; 96
      008062 C0                     952 	.db #0xc0	; 192
      008063 C0                     953 	.db #0xc0	; 192
      008064                        954 _big_digit_8:
      008064 7C                     955 	.db #0x7c	; 124
      008065 C6                     956 	.db #0xc6	; 198
      008066 C6                     957 	.db #0xc6	; 198
      008067 7C                     958 	.db #0x7c	; 124
      008068 C6                     959 	.db #0xc6	; 198
      008069 C6                     960 	.db #0xc6	; 198
      00806A C6                     961 	.db #0xc6	; 198
      00806B 7C                     962 	.db #0x7c	; 124
      00806C                        963 _big_digit_9:
      00806C 3C                     964 	.db #0x3c	; 60
      00806D 66                     965 	.db #0x66	; 102	'f'
      00806E C6                     966 	.db #0xc6	; 198
      00806F 7E                     967 	.db #0x7e	; 126
      008070 06                     968 	.db #0x06	; 6
      008071 0C                     969 	.db #0x0c	; 12
      008072 18                     970 	.db #0x18	; 24
      008073 70                     971 	.db #0x70	; 112	'p'
      008074                        972 _big_char_C:
      008074 3E                     973 	.db #0x3e	; 62
      008075 60                     974 	.db #0x60	; 96
      008076 C0                     975 	.db #0xc0	; 192
      008077 C0                     976 	.db #0xc0	; 192
      008078 C0                     977 	.db #0xc0	; 192
      008079 C0                     978 	.db #0xc0	; 192
      00807A 60                     979 	.db #0x60	; 96
      00807B 3E                     980 	.db #0x3e	; 62
      00807C                        981 _big_char_dot:
      00807C 00                     982 	.db #0x00	; 0
      00807D 00                     983 	.db #0x00	; 0
      00807E 00                     984 	.db #0x00	; 0
      00807F 00                     985 	.db #0x00	; 0
      008080 00                     986 	.db #0x00	; 0
      008081 00                     987 	.db #0x00	; 0
      008082 18                     988 	.db #0x18	; 24
      008083 18                     989 	.db #0x18	; 24
      008084                        990 _big_char_deg:
      008084 1C                     991 	.db #0x1c	; 28
      008085 22                     992 	.db #0x22	; 34
      008086 22                     993 	.db #0x22	; 34
      008087 1C                     994 	.db #0x1c	; 28
      008088 00                     995 	.db #0x00	; 0
      008089 00                     996 	.db #0x00	; 0
      00808A 00                     997 	.db #0x00	; 0
      00808B 00                     998 	.db #0x00	; 0
      00808C                        999 _lcd_print_temperature_minus_262145_71:
      00808C 00                    1000 	.db #0x00	; 0
      00808D 00                    1001 	.db #0x00	; 0
      00808E 00                    1002 	.db #0x00	; 0
      00808F FE                    1003 	.db #0xfe	; 254
      008090 FE                    1004 	.db #0xfe	; 254
      008091 00                    1005 	.db #0x00	; 0
      008092 00                    1006 	.db #0x00	; 0
      008093 00                    1007 	.db #0x00	; 0
                                   1008 	.area CONST
      008094                       1009 ___str_0:
      008094 25 64 2E 25 30 32 64  1010 	.ascii "%d.%02d"
      00809B 00                    1011 	.db 0x00
                                   1012 	.area CODE
                                   1013 	.area INITIALIZER
      0080A7                       1014 __xinit__big_digits:
      0080A7 80 24                 1015 	.dw _big_digit_0
      0080A9 80 2C                 1016 	.dw _big_digit_1
      0080AB 80 34                 1017 	.dw _big_digit_2
      0080AD 80 3C                 1018 	.dw _big_digit_3
      0080AF 80 44                 1019 	.dw _big_digit_4
      0080B1 80 4C                 1020 	.dw _big_digit_5
      0080B3 80 54                 1021 	.dw _big_digit_6
      0080B5 80 5C                 1022 	.dw _big_digit_7
      0080B7 80 64                 1023 	.dw _big_digit_8
      0080B9 80 6C                 1024 	.dw _big_digit_9
                                   1025 	.area CABS (ABS)
