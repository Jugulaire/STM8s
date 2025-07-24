                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module test_temp
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _digit_segments
                                     12 	.globl _main
                                     13 	.globl _ds18b20_read_raw
                                     14 	.globl _ds18b20_start_conversion
                                     15 	.globl _onewire_read_byte
                                     16 	.globl _onewire_write_byte
                                     17 	.globl _onewire_read_bit
                                     18 	.globl _onewire_write_bit
                                     19 	.globl _onewire_reset
                                     20 	.globl _display_step
                                     21 	.globl _display_int
                                     22 	.globl _display_float
                                     23 	.globl _setup
                                     24 	.globl _delay_ms
                                     25 	.globl _delay_us
                                     26 	.globl _display_digit
                                     27 	.globl _disable_all_digits
                                     28 	.globl _latch
                                     29 	.globl _shift_out
                                     30 	.globl _uart_read
                                     31 	.globl _uart_write
                                     32 	.globl _uart_config
                                     33 	.globl _digits
                                     34 	.globl _putchar
                                     35 ;--------------------------------------------------------
                                     36 ; ram data
                                     37 ;--------------------------------------------------------
                                     38 	.area DATA
      000001                         39 _display_step_pos_65536_48:
      000001                         40 	.ds 1
                                     41 ;--------------------------------------------------------
                                     42 ; ram data
                                     43 ;--------------------------------------------------------
                                     44 	.area INITIALIZED
      000002                         45 _digits::
      000002                         46 	.ds 4
                                     47 ;--------------------------------------------------------
                                     48 ; Stack segment in internal ram
                                     49 ;--------------------------------------------------------
                                     50 	.area	SSEG
      000006                         51 __start__stack:
      000006                         52 	.ds	1
                                     53 
                                     54 ;--------------------------------------------------------
                                     55 ; absolute external ram data
                                     56 ;--------------------------------------------------------
                                     57 	.area DABS (ABS)
                                     58 
                                     59 ; default segment ordering for linker
                                     60 	.area HOME
                                     61 	.area GSINIT
                                     62 	.area GSFINAL
                                     63 	.area CONST
                                     64 	.area INITIALIZER
                                     65 	.area CODE
                                     66 
                                     67 ;--------------------------------------------------------
                                     68 ; interrupt vector
                                     69 ;--------------------------------------------------------
                                     70 	.area HOME
      008000                         71 __interrupt_vect:
      008000 82 00 80 07             72 	int s_GSINIT ; reset
                                     73 ;--------------------------------------------------------
                                     74 ; global & static initialisations
                                     75 ;--------------------------------------------------------
                                     76 	.area HOME
                                     77 	.area GSINIT
                                     78 	.area GSFINAL
                                     79 	.area GSINIT
      008007                         80 __sdcc_init_data:
                                     81 ; stm8_genXINIT() start
      008007 AE 00 01         [ 2]   82 	ldw x, #l_DATA
      00800A 27 07            [ 1]   83 	jreq	00002$
      00800C                         84 00001$:
      00800C 72 4F 00 00      [ 1]   85 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   86 	decw x
      008011 26 F9            [ 1]   87 	jrne	00001$
      008013                         88 00002$:
      008013 AE 00 04         [ 2]   89 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   90 	jreq	00004$
      008018                         91 00003$:
      008018 D6 80 31         [ 1]   92 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 01         [ 1]   93 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   94 	decw	x
      00801F 26 F7            [ 1]   95 	jrne	00003$
      008021                         96 00004$:
                                     97 ; stm8_genXINIT() end
                                     98 ;	test_temp.c: 235: static uint8_t pos = 0;
      008021 72 5F 00 01      [ 1]   99 	clr	_display_step_pos_65536_48+0
                                    100 	.area GSFINAL
      008025 CC 80 04         [ 2]  101 	jp	__sdcc_program_startup
                                    102 ;--------------------------------------------------------
                                    103 ; Home
                                    104 ;--------------------------------------------------------
                                    105 	.area HOME
                                    106 	.area HOME
      008004                        107 __sdcc_program_startup:
      008004 CC 84 D8         [ 2]  108 	jp	_main
                                    109 ;	return from main will return to caller
                                    110 ;--------------------------------------------------------
                                    111 ; code
                                    112 ;--------------------------------------------------------
                                    113 	.area CODE
                                    114 ;	test_temp.c: 27: void uart_config() {
                                    115 ;	-----------------------------------------
                                    116 ;	 function uart_config
                                    117 ;	-----------------------------------------
      008036                        118 _uart_config:
                                    119 ;	test_temp.c: 28: CLK_CKDIVR = 0x00; // Horloge non divisée (reste à 16 MHz)
      008036 35 00 50 C6      [ 1]  120 	mov	0x50c6+0, #0x00
                                    121 ;	test_temp.c: 33: uint8_t brr1 = (usartdiv >> 4) & 0xFF;
      00803A A6 68            [ 1]  122 	ld	a, #0x68
      00803C 97               [ 1]  123 	ld	xl, a
                                    124 ;	test_temp.c: 34: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);
      00803D A6 83            [ 1]  125 	ld	a, #0x83
      00803F A4 0F            [ 1]  126 	and	a, #0x0f
                                    127 ;	test_temp.c: 36: UART1_BRR1 = brr1;
      008041 90 AE 52 32      [ 2]  128 	ldw	y, #0x5232
      008045 88               [ 1]  129 	push	a
      008046 9F               [ 1]  130 	ld	a, xl
      008047 90 F7            [ 1]  131 	ld	(y), a
      008049 84               [ 1]  132 	pop	a
                                    133 ;	test_temp.c: 37: UART1_BRR2 = brr2;
      00804A C7 52 33         [ 1]  134 	ld	0x5233, a
                                    135 ;	test_temp.c: 39: UART1_CR1 = 0x00; // Pas de parité, 8 bits de données
      00804D 35 00 52 34      [ 1]  136 	mov	0x5234+0, #0x00
                                    137 ;	test_temp.c: 40: UART1_CR3 = 0x00; // 1 bit de stop
      008051 35 00 52 36      [ 1]  138 	mov	0x5236+0, #0x00
                                    139 ;	test_temp.c: 41: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // Active TX et RX
      008055 35 0C 52 35      [ 1]  140 	mov	0x5235+0, #0x0c
                                    141 ;	test_temp.c: 44: (void)UART1_SR;
      008059 C6 52 30         [ 1]  142 	ld	a, 0x5230
                                    143 ;	test_temp.c: 45: (void)UART1_DR;
      00805C C6 52 31         [ 1]  144 	ld	a, 0x5231
                                    145 ;	test_temp.c: 46: }
      00805F 81               [ 4]  146 	ret
                                    147 ;	test_temp.c: 49: void uart_write(uint8_t data) {
                                    148 ;	-----------------------------------------
                                    149 ;	 function uart_write
                                    150 ;	-----------------------------------------
      008060                        151 _uart_write:
                                    152 ;	test_temp.c: 50: UART1_DR = data;                    // Envoie l'octet
      008060 C7 52 31         [ 1]  153 	ld	0x5231, a
                                    154 ;	test_temp.c: 51: PB_ODR &= ~(1 << 5);                // Éteint une LED (facultatif pour debug)
      008063 72 1B 50 05      [ 1]  155 	bres	0x5005, #5
                                    156 ;	test_temp.c: 52: while (!(UART1_SR & (1 << UART1_SR_TC))); // Attente que la transmission soit terminée
      008067                        157 00101$:
      008067 72 0D 52 30 FB   [ 2]  158 	btjf	0x5230, #6, 00101$
                                    159 ;	test_temp.c: 53: PB_ODR |= (1 << 5);                 // Allume la LED (facultatif)
      00806C 72 1A 50 05      [ 1]  160 	bset	0x5005, #5
                                    161 ;	test_temp.c: 54: }
      008070 81               [ 4]  162 	ret
                                    163 ;	test_temp.c: 57: uint8_t uart_read() {
                                    164 ;	-----------------------------------------
                                    165 ;	 function uart_read
                                    166 ;	-----------------------------------------
      008071                        167 _uart_read:
                                    168 ;	test_temp.c: 58: while (!(UART1_SR & (1 << UART1_SR_RXNE))); // Attente réception
      008071                        169 00101$:
      008071 72 0B 52 30 FB   [ 2]  170 	btjf	0x5230, #5, 00101$
                                    171 ;	test_temp.c: 59: return UART1_DR;
      008076 C6 52 31         [ 1]  172 	ld	a, 0x5231
                                    173 ;	test_temp.c: 60: }
      008079 81               [ 4]  174 	ret
                                    175 ;	test_temp.c: 63: int putchar(int c) {
                                    176 ;	-----------------------------------------
                                    177 ;	 function putchar
                                    178 ;	-----------------------------------------
      00807A                        179 _putchar:
      00807A 9F               [ 1]  180 	ld	a, xl
                                    181 ;	test_temp.c: 64: uart_write(c);
      00807B CD 80 60         [ 4]  182 	call	_uart_write
                                    183 ;	test_temp.c: 65: return 0;
      00807E 5F               [ 1]  184 	clrw	x
                                    185 ;	test_temp.c: 66: }
      00807F 81               [ 4]  186 	ret
                                    187 ;	test_temp.c: 84: void shift_out(uint8_t val) {
                                    188 ;	-----------------------------------------
                                    189 ;	 function shift_out
                                    190 ;	-----------------------------------------
      008080                        191 _shift_out:
      008080 88               [ 1]  192 	push	a
      008081 95               [ 1]  193 	ld	xh, a
                                    194 ;	test_temp.c: 85: for (uint8_t i = 0; i < 8; i++) {
      008082 0F 01            [ 1]  195 	clr	(0x01, sp)
      008084                        196 00106$:
      008084 7B 01            [ 1]  197 	ld	a, (0x01, sp)
      008086 A1 08            [ 1]  198 	cp	a, #0x08
      008088 24 21            [ 1]  199 	jrnc	00108$
                                    200 ;	test_temp.c: 86: if (val & 0x80) PC_ODR |= (1 << 3);   // DATA HIGH
      00808A C6 50 0A         [ 1]  201 	ld	a, 0x500a
      00808D 5D               [ 2]  202 	tnzw	x
      00808E 2A 07            [ 1]  203 	jrpl	00102$
      008090 AA 08            [ 1]  204 	or	a, #0x08
      008092 C7 50 0A         [ 1]  205 	ld	0x500a, a
      008095 20 05            [ 2]  206 	jra	00103$
      008097                        207 00102$:
                                    208 ;	test_temp.c: 87: else            PC_ODR &= ~(1 << 3);  // DATA LOW
      008097 A4 F7            [ 1]  209 	and	a, #0xf7
      008099 C7 50 0A         [ 1]  210 	ld	0x500a, a
      00809C                        211 00103$:
                                    212 ;	test_temp.c: 89: PC_ODR |= (1 << 4);  // CLOCK HIGH
      00809C 72 18 50 0A      [ 1]  213 	bset	0x500a, #4
                                    214 ;	test_temp.c: 90: PC_ODR &= ~(1 << 4); // CLOCK LOW
      0080A0 72 19 50 0A      [ 1]  215 	bres	0x500a, #4
                                    216 ;	test_temp.c: 92: val <<= 1;
      0080A4 9E               [ 1]  217 	ld	a, xh
      0080A5 48               [ 1]  218 	sll	a
      0080A6 95               [ 1]  219 	ld	xh, a
                                    220 ;	test_temp.c: 85: for (uint8_t i = 0; i < 8; i++) {
      0080A7 0C 01            [ 1]  221 	inc	(0x01, sp)
      0080A9 20 D9            [ 2]  222 	jra	00106$
      0080AB                        223 00108$:
                                    224 ;	test_temp.c: 94: }
      0080AB 84               [ 1]  225 	pop	a
      0080AC 81               [ 4]  226 	ret
                                    227 ;	test_temp.c: 96: void latch() {
                                    228 ;	-----------------------------------------
                                    229 ;	 function latch
                                    230 ;	-----------------------------------------
      0080AD                        231 _latch:
                                    232 ;	test_temp.c: 97: PC_ODR |= (1 << 5);  // LATCH HIGH
      0080AD 72 1A 50 0A      [ 1]  233 	bset	0x500a, #5
                                    234 ;	test_temp.c: 98: PC_ODR &= ~(1 << 5); // LATCH LOW
      0080B1 72 1B 50 0A      [ 1]  235 	bres	0x500a, #5
                                    236 ;	test_temp.c: 99: }
      0080B5 81               [ 4]  237 	ret
                                    238 ;	test_temp.c: 102: void disable_all_digits() {
                                    239 ;	-----------------------------------------
                                    240 ;	 function disable_all_digits
                                    241 ;	-----------------------------------------
      0080B6                        242 _disable_all_digits:
                                    243 ;	test_temp.c: 104: PA_ODR |= (1 << 1); // D3
      0080B6 72 12 50 00      [ 1]  244 	bset	0x5000, #1
                                    245 ;	test_temp.c: 105: PA_ODR |= (1 << 2); // D1
      0080BA 72 14 50 00      [ 1]  246 	bset	0x5000, #2
                                    247 ;	test_temp.c: 106: PA_ODR |= (1 << 3); // D4
      0080BE 72 16 50 00      [ 1]  248 	bset	0x5000, #3
                                    249 ;	test_temp.c: 107: PD_ODR |= (1 << 4); // D2
      0080C2 72 18 50 0F      [ 1]  250 	bset	0x500f, #4
                                    251 ;	test_temp.c: 108: }
      0080C6 81               [ 4]  252 	ret
                                    253 ;	test_temp.c: 110: void display_digit(uint8_t value, uint8_t pos) {
                                    254 ;	-----------------------------------------
                                    255 ;	 function display_digit
                                    256 ;	-----------------------------------------
      0080C7                        257 _display_digit:
      0080C7 97               [ 1]  258 	ld	xl, a
                                    259 ;	test_temp.c: 112: PA_ODR |= (1 << 1); // D3
      0080C8 72 12 50 00      [ 1]  260 	bset	0x5000, #1
                                    261 ;	test_temp.c: 113: PA_ODR |= (1 << 2); // D1
      0080CC 72 14 50 00      [ 1]  262 	bset	0x5000, #2
                                    263 ;	test_temp.c: 114: PA_ODR |= (1 << 3); // D4
      0080D0 72 16 50 00      [ 1]  264 	bset	0x5000, #3
                                    265 ;	test_temp.c: 115: PD_ODR |= (1 << 4); // D2
      0080D4 72 18 50 0F      [ 1]  266 	bset	0x500f, #4
                                    267 ;	test_temp.c: 118: shift_out(digit_segments[value]);
      0080D8 4F               [ 1]  268 	clr	a
      0080D9 95               [ 1]  269 	ld	xh, a
      0080DA D6 80 28         [ 1]  270 	ld	a, (_digit_segments+0, x)
      0080DD CD 80 80         [ 4]  271 	call	_shift_out
                                    272 ;	test_temp.c: 119: latch();
      0080E0 CD 80 AD         [ 4]  273 	call	_latch
                                    274 ;	test_temp.c: 123: switch (pos) {
      0080E3 7B 03            [ 1]  275 	ld	a, (0x03, sp)
      0080E5 A1 00            [ 1]  276 	cp	a, #0x00
      0080E7 27 13            [ 1]  277 	jreq	00101$
      0080E9 7B 03            [ 1]  278 	ld	a, (0x03, sp)
      0080EB 4A               [ 1]  279 	dec	a
      0080EC 27 18            [ 1]  280 	jreq	00102$
      0080EE 7B 03            [ 1]  281 	ld	a, (0x03, sp)
      0080F0 A1 02            [ 1]  282 	cp	a, #0x02
      0080F2 27 1C            [ 1]  283 	jreq	00103$
      0080F4 7B 03            [ 1]  284 	ld	a, (0x03, sp)
      0080F6 A1 03            [ 1]  285 	cp	a, #0x03
      0080F8 27 20            [ 1]  286 	jreq	00104$
      0080FA 20 26            [ 2]  287 	jra	00106$
                                    288 ;	test_temp.c: 124: case 0: PA_ODR &= ~(1 << 3); break; // D4 → gauche
      0080FC                        289 00101$:
      0080FC C6 50 00         [ 1]  290 	ld	a, 0x5000
      0080FF A4 F7            [ 1]  291 	and	a, #0xf7
      008101 C7 50 00         [ 1]  292 	ld	0x5000, a
      008104 20 1C            [ 2]  293 	jra	00106$
                                    294 ;	test_temp.c: 125: case 1: PA_ODR &= ~(1 << 1); break; // D3
      008106                        295 00102$:
      008106 C6 50 00         [ 1]  296 	ld	a, 0x5000
      008109 A4 FD            [ 1]  297 	and	a, #0xfd
      00810B C7 50 00         [ 1]  298 	ld	0x5000, a
      00810E 20 12            [ 2]  299 	jra	00106$
                                    300 ;	test_temp.c: 126: case 2: PD_ODR &= ~(1 << 4); break; // D2
      008110                        301 00103$:
      008110 C6 50 0F         [ 1]  302 	ld	a, 0x500f
      008113 A4 EF            [ 1]  303 	and	a, #0xef
      008115 C7 50 0F         [ 1]  304 	ld	0x500f, a
      008118 20 08            [ 2]  305 	jra	00106$
                                    306 ;	test_temp.c: 127: case 3: PA_ODR &= ~(1 << 2); break; // D1 → droite
      00811A                        307 00104$:
      00811A C6 50 00         [ 1]  308 	ld	a, 0x5000
      00811D A4 FB            [ 1]  309 	and	a, #0xfb
      00811F C7 50 00         [ 1]  310 	ld	0x5000, a
                                    311 ;	test_temp.c: 128: }
      008122                        312 00106$:
                                    313 ;	test_temp.c: 130: }
      008122 85               [ 2]  314 	popw	x
      008123 84               [ 1]  315 	pop	a
      008124 FC               [ 2]  316 	jp	(x)
                                    317 ;	test_temp.c: 132: void delay_us(uint16_t us) {
                                    318 ;	-----------------------------------------
                                    319 ;	 function delay_us
                                    320 ;	-----------------------------------------
      008125                        321 _delay_us:
                                    322 ;	test_temp.c: 133: while(us--) {
      008125                        323 00101$:
      008125 90 93            [ 1]  324 	ldw	y, x
      008127 5A               [ 2]  325 	decw	x
      008128 90 5D            [ 2]  326 	tnzw	y
      00812A 26 01            [ 1]  327 	jrne	00117$
      00812C 81               [ 4]  328 	ret
      00812D                        329 00117$:
                                    330 ;	test_temp.c: 134: __asm__("nop"); __asm__("nop"); __asm__("nop");
      00812D 9D               [ 1]  331 	nop
      00812E 9D               [ 1]  332 	nop
      00812F 9D               [ 1]  333 	nop
                                    334 ;	test_temp.c: 135: __asm__("nop"); __asm__("nop"); __asm__("nop");
      008130 9D               [ 1]  335 	nop
      008131 9D               [ 1]  336 	nop
      008132 9D               [ 1]  337 	nop
      008133 20 F0            [ 2]  338 	jra	00101$
                                    339 ;	test_temp.c: 137: }
      008135 81               [ 4]  340 	ret
                                    341 ;	test_temp.c: 140: void delay_ms(uint16_t ms) {
                                    342 ;	-----------------------------------------
                                    343 ;	 function delay_ms
                                    344 ;	-----------------------------------------
      008136                        345 _delay_ms:
      008136 52 04            [ 2]  346 	sub	sp, #4
      008138 1F 03            [ 2]  347 	ldw	(0x03, sp), x
                                    348 ;	test_temp.c: 141: for (uint16_t i = 0; i < ms; i++) {
      00813A 5F               [ 1]  349 	clrw	x
      00813B                        350 00107$:
      00813B 13 03            [ 2]  351 	cpw	x, (0x03, sp)
      00813D 24 18            [ 1]  352 	jrnc	00109$
                                    353 ;	test_temp.c: 142: for (volatile uint16_t j = 0; j < 1000; j++)
      00813F 0F 02            [ 1]  354 	clr	(0x02, sp)
      008141 0F 01            [ 1]  355 	clr	(0x01, sp)
      008143                        356 00104$:
      008143 16 01            [ 2]  357 	ldw	y, (0x01, sp)
      008145 90 A3 03 E8      [ 2]  358 	cpw	y, #0x03e8
      008149 24 09            [ 1]  359 	jrnc	00108$
                                    360 ;	test_temp.c: 143: __asm__("nop");
      00814B 9D               [ 1]  361 	nop
                                    362 ;	test_temp.c: 142: for (volatile uint16_t j = 0; j < 1000; j++)
      00814C 16 01            [ 2]  363 	ldw	y, (0x01, sp)
      00814E 90 5C            [ 1]  364 	incw	y
      008150 17 01            [ 2]  365 	ldw	(0x01, sp), y
      008152 20 EF            [ 2]  366 	jra	00104$
      008154                        367 00108$:
                                    368 ;	test_temp.c: 141: for (uint16_t i = 0; i < ms; i++) {
      008154 5C               [ 1]  369 	incw	x
      008155 20 E4            [ 2]  370 	jra	00107$
      008157                        371 00109$:
                                    372 ;	test_temp.c: 145: }
      008157 5B 04            [ 2]  373 	addw	sp, #4
      008159 81               [ 4]  374 	ret
                                    375 ;	test_temp.c: 148: void setup() {
                                    376 ;	-----------------------------------------
                                    377 ;	 function setup
                                    378 ;	-----------------------------------------
      00815A                        379 _setup:
                                    380 ;	test_temp.c: 150: PC_DDR |= (1 << 3) | (1 << 4) | (1 << 5);
      00815A C6 50 0C         [ 1]  381 	ld	a, 0x500c
      00815D AA 38            [ 1]  382 	or	a, #0x38
      00815F C7 50 0C         [ 1]  383 	ld	0x500c, a
                                    384 ;	test_temp.c: 151: PC_CR1 |= (1 << 3) | (1 << 4) | (1 << 5);
      008162 C6 50 0D         [ 1]  385 	ld	a, 0x500d
      008165 AA 38            [ 1]  386 	or	a, #0x38
      008167 C7 50 0D         [ 1]  387 	ld	0x500d, a
                                    388 ;	test_temp.c: 154: PA_DDR |= (1 << 1) | (1 << 2) | (1 << 3);
      00816A C6 50 02         [ 1]  389 	ld	a, 0x5002
      00816D AA 0E            [ 1]  390 	or	a, #0x0e
      00816F C7 50 02         [ 1]  391 	ld	0x5002, a
                                    392 ;	test_temp.c: 155: PA_CR1 |= (1 << 1) | (1 << 2) | (1 << 3);
      008172 C6 50 03         [ 1]  393 	ld	a, 0x5003
      008175 AA 0E            [ 1]  394 	or	a, #0x0e
      008177 C7 50 03         [ 1]  395 	ld	0x5003, a
                                    396 ;	test_temp.c: 158: PD_DDR |= (1 << 4);
      00817A 72 18 50 11      [ 1]  397 	bset	0x5011, #4
                                    398 ;	test_temp.c: 159: PD_CR1 |= (1 << 4);
      00817E 72 18 50 12      [ 1]  399 	bset	0x5012, #4
                                    400 ;	test_temp.c: 160: }
      008182 81               [ 4]  401 	ret
                                    402 ;	test_temp.c: 162: void display_float(float value) {
                                    403 ;	-----------------------------------------
                                    404 ;	 function display_float
                                    405 ;	-----------------------------------------
      008183                        406 _display_float:
      008183 52 06            [ 2]  407 	sub	sp, #6
                                    408 ;	test_temp.c: 163: if (value < 0 || value >= 100) return; // Ne supporte que 00.00 à 99.99
      008185 5F               [ 1]  409 	clrw	x
      008186 89               [ 2]  410 	pushw	x
      008187 5F               [ 1]  411 	clrw	x
      008188 89               [ 2]  412 	pushw	x
      008189 1E 0F            [ 2]  413 	ldw	x, (0x0f, sp)
      00818B 89               [ 2]  414 	pushw	x
      00818C 1E 0F            [ 2]  415 	ldw	x, (0x0f, sp)
      00818E 89               [ 2]  416 	pushw	x
      00818F CD 86 F9         [ 4]  417 	call	___fslt
      008192 6B 06            [ 1]  418 	ld	(0x06, sp), a
      008194 27 03            [ 1]  419 	jreq	00167$
      008196 CC 82 92         [ 2]  420 	jp	00119$
      008199                        421 00167$:
      008199 5F               [ 1]  422 	clrw	x
      00819A 89               [ 2]  423 	pushw	x
      00819B 4B C8            [ 1]  424 	push	#0xc8
      00819D 4B 42            [ 1]  425 	push	#0x42
      00819F 1E 0F            [ 2]  426 	ldw	x, (0x0f, sp)
      0081A1 89               [ 2]  427 	pushw	x
      0081A2 1E 0F            [ 2]  428 	ldw	x, (0x0f, sp)
      0081A4 89               [ 2]  429 	pushw	x
      0081A5 CD 86 F9         [ 4]  430 	call	___fslt
      0081A8 4D               [ 1]  431 	tnz	a
      0081A9 26 03            [ 1]  432 	jrne	00102$
      0081AB CC 82 92         [ 2]  433 	jp	00119$
      0081AE                        434 00102$:
                                    435 ;	test_temp.c: 165: uint16_t scaled = (uint16_t)(value * 100); // Ex: 34.56 → 3456
      0081AE 1E 0B            [ 2]  436 	ldw	x, (0x0b, sp)
      0081B0 89               [ 2]  437 	pushw	x
      0081B1 1E 0B            [ 2]  438 	ldw	x, (0x0b, sp)
      0081B3 89               [ 2]  439 	pushw	x
      0081B4 5F               [ 1]  440 	clrw	x
      0081B5 89               [ 2]  441 	pushw	x
      0081B6 4B C8            [ 1]  442 	push	#0xc8
      0081B8 4B 42            [ 1]  443 	push	#0x42
      0081BA CD 85 3F         [ 4]  444 	call	___fsmul
      0081BD 89               [ 2]  445 	pushw	x
      0081BE 90 89            [ 2]  446 	pushw	y
      0081C0 CD 87 E2         [ 4]  447 	call	___fs2uint
                                    448 ;	test_temp.c: 168: digits[0] = (scaled / 1000) % 10;
      0081C3 1F 05            [ 2]  449 	ldw	(0x05, sp), x
      0081C5 90 AE 03 E8      [ 2]  450 	ldw	y, #0x03e8
      0081C9 65               [ 2]  451 	divw	x, y
      0081CA 90 AE 00 0A      [ 2]  452 	ldw	y, #0x000a
      0081CE 65               [ 2]  453 	divw	x, y
      0081CF 90 9F            [ 1]  454 	ld	a, yl
      0081D1 6B 01            [ 1]  455 	ld	(0x01, sp), a
                                    456 ;	test_temp.c: 169: digits[1] = (scaled / 100) % 10;
      0081D3 1E 05            [ 2]  457 	ldw	x, (0x05, sp)
      0081D5 90 AE 00 64      [ 2]  458 	ldw	y, #0x0064
      0081D9 65               [ 2]  459 	divw	x, y
      0081DA 90 AE 00 0A      [ 2]  460 	ldw	y, #0x000a
      0081DE 65               [ 2]  461 	divw	x, y
      0081DF 90 9F            [ 1]  462 	ld	a, yl
      0081E1 6B 02            [ 1]  463 	ld	(0x02, sp), a
                                    464 ;	test_temp.c: 170: digits[2] = (scaled / 10) % 10;
      0081E3 1E 05            [ 2]  465 	ldw	x, (0x05, sp)
      0081E5 90 AE 00 0A      [ 2]  466 	ldw	y, #0x000a
      0081E9 65               [ 2]  467 	divw	x, y
      0081EA 90 AE 00 0A      [ 2]  468 	ldw	y, #0x000a
      0081EE 65               [ 2]  469 	divw	x, y
      0081EF 90 9F            [ 1]  470 	ld	a, yl
      0081F1 6B 03            [ 1]  471 	ld	(0x03, sp), a
                                    472 ;	test_temp.c: 171: digits[3] = scaled % 10;
      0081F3 1E 05            [ 2]  473 	ldw	x, (0x05, sp)
      0081F5 90 AE 00 0A      [ 2]  474 	ldw	y, #0x000a
      0081F9 65               [ 2]  475 	divw	x, y
      0081FA 90 9F            [ 1]  476 	ld	a, yl
      0081FC 6B 04            [ 1]  477 	ld	(0x04, sp), a
                                    478 ;	test_temp.c: 173: for (uint8_t i = 0; i < 4; i++) {
      0081FE 0F 06            [ 1]  479 	clr	(0x06, sp)
      008200                        480 00117$:
      008200 7B 06            [ 1]  481 	ld	a, (0x06, sp)
      008202 A1 04            [ 1]  482 	cp	a, #0x04
      008204 25 03            [ 1]  483 	jrc	00169$
      008206 CC 82 92         [ 2]  484 	jp	00119$
      008209                        485 00169$:
                                    486 ;	test_temp.c: 174: uint8_t seg = digit_segments[digits[i]];
      008209 5F               [ 1]  487 	clrw	x
      00820A 7B 06            [ 1]  488 	ld	a, (0x06, sp)
      00820C 97               [ 1]  489 	ld	xl, a
      00820D 89               [ 2]  490 	pushw	x
      00820E 96               [ 1]  491 	ldw	x, sp
      00820F 1C 00 03         [ 2]  492 	addw	x, #3
      008212 72 FB 01         [ 2]  493 	addw	x, (1, sp)
      008215 5B 02            [ 2]  494 	addw	sp, #2
      008217 F6               [ 1]  495 	ld	a, (x)
      008218 5F               [ 1]  496 	clrw	x
      008219 97               [ 1]  497 	ld	xl, a
      00821A 1C 80 28         [ 2]  498 	addw	x, #(_digit_segments+0)
      00821D F6               [ 1]  499 	ld	a, (x)
                                    500 ;	test_temp.c: 177: if (i == 1) seg |= 0x80;
      00821E 88               [ 1]  501 	push	a
      00821F 7B 07            [ 1]  502 	ld	a, (0x07, sp)
      008221 4A               [ 1]  503 	dec	a
      008222 84               [ 1]  504 	pop	a
      008223 26 07            [ 1]  505 	jrne	00171$
      008225 88               [ 1]  506 	push	a
      008226 A6 01            [ 1]  507 	ld	a, #0x01
      008228 6B 06            [ 1]  508 	ld	(0x06, sp), a
      00822A 84               [ 1]  509 	pop	a
      00822B C5                     510 	.byte 0xc5
      00822C                        511 00171$:
      00822C 0F 05            [ 1]  512 	clr	(0x05, sp)
      00822E                        513 00172$:
      00822E 0D 05            [ 1]  514 	tnz	(0x05, sp)
      008230 27 02            [ 1]  515 	jreq	00105$
      008232 AA 80            [ 1]  516 	or	a, #0x80
      008234                        517 00105$:
                                    518 ;	test_temp.c: 179: disable_all_digits();
      008234 88               [ 1]  519 	push	a
      008235 CD 80 B6         [ 4]  520 	call	_disable_all_digits
      008238 84               [ 1]  521 	pop	a
                                    522 ;	test_temp.c: 180: shift_out(seg);
      008239 CD 80 80         [ 4]  523 	call	_shift_out
                                    524 ;	test_temp.c: 181: latch();
      00823C CD 80 AD         [ 4]  525 	call	_latch
                                    526 ;	test_temp.c: 184: switch (i) {
      00823F 7B 06            [ 1]  527 	ld	a, (0x06, sp)
      008241 A0 03            [ 1]  528 	sub	a, #0x03
      008243 26 04            [ 1]  529 	jrne	00175$
      008245 4C               [ 1]  530 	inc	a
      008246 97               [ 1]  531 	ld	xl, a
      008247 20 02            [ 2]  532 	jra	00176$
      008249                        533 00175$:
      008249 4F               [ 1]  534 	clr	a
      00824A 97               [ 1]  535 	ld	xl, a
      00824B                        536 00176$:
      00824B 7B 06            [ 1]  537 	ld	a, (0x06, sp)
      00824D A1 00            [ 1]  538 	cp	a, #0x00
      00824F 27 10            [ 1]  539 	jreq	00106$
      008251 0D 05            [ 1]  540 	tnz	(0x05, sp)
      008253 26 12            [ 1]  541 	jrne	00107$
      008255 7B 06            [ 1]  542 	ld	a, (0x06, sp)
      008257 A1 02            [ 1]  543 	cp	a, #0x02
      008259 27 12            [ 1]  544 	jreq	00108$
      00825B 9F               [ 1]  545 	ld	a, xl
      00825C 4D               [ 1]  546 	tnz	a
      00825D 26 14            [ 1]  547 	jrne	00109$
      00825F 20 16            [ 2]  548 	jra	00110$
                                    549 ;	test_temp.c: 185: case 0: PA_ODR &= ~(1 << 3); break; // D4 (pos 0)
      008261                        550 00106$:
      008261 72 17 50 00      [ 1]  551 	bres	0x5000, #3
      008265 20 10            [ 2]  552 	jra	00110$
                                    553 ;	test_temp.c: 186: case 1: PA_ODR &= ~(1 << 1); break; // D3
      008267                        554 00107$:
      008267 72 13 50 00      [ 1]  555 	bres	0x5000, #1
      00826B 20 0A            [ 2]  556 	jra	00110$
                                    557 ;	test_temp.c: 187: case 2: PD_ODR &= ~(1 << 4); break; // D2
      00826D                        558 00108$:
      00826D 72 19 50 0F      [ 1]  559 	bres	0x500f, #4
      008271 20 04            [ 2]  560 	jra	00110$
                                    561 ;	test_temp.c: 188: case 3: PA_ODR &= ~(1 << 2); break; // D1
      008273                        562 00109$:
      008273 72 15 50 00      [ 1]  563 	bres	0x5000, #2
                                    564 ;	test_temp.c: 189: }
      008277                        565 00110$:
                                    566 ;	test_temp.c: 192: if (i == 1 || i == 3) delay_us(800); // digits 0 et 1 = 1ms
      008277 0D 05            [ 1]  567 	tnz	(0x05, sp)
      008279 26 04            [ 1]  568 	jrne	00111$
      00827B 9F               [ 1]  569 	ld	a, xl
      00827C 4D               [ 1]  570 	tnz	a
      00827D 27 08            [ 1]  571 	jreq	00112$
      00827F                        572 00111$:
      00827F AE 03 20         [ 2]  573 	ldw	x, #0x0320
      008282 CD 81 25         [ 4]  574 	call	_delay_us
      008285 20 06            [ 2]  575 	jra	00118$
      008287                        576 00112$:
                                    577 ;	test_temp.c: 193: else                  delay_us(400);  // autres = 0.7ms 
      008287 AE 01 90         [ 2]  578 	ldw	x, #0x0190
      00828A CD 81 25         [ 4]  579 	call	_delay_us
      00828D                        580 00118$:
                                    581 ;	test_temp.c: 173: for (uint8_t i = 0; i < 4; i++) {
      00828D 0C 06            [ 1]  582 	inc	(0x06, sp)
      00828F CC 82 00         [ 2]  583 	jp	00117$
      008292                        584 00119$:
                                    585 ;	test_temp.c: 196: }
      008292 1E 07            [ 2]  586 	ldw	x, (7, sp)
      008294 5B 0C            [ 2]  587 	addw	sp, #12
      008296 FC               [ 2]  588 	jp	(x)
                                    589 ;	test_temp.c: 198: void display_int(uint16_t temp_x100) {
                                    590 ;	-----------------------------------------
                                    591 ;	 function display_int
                                    592 ;	-----------------------------------------
      008297                        593 _display_int:
      008297 52 08            [ 2]  594 	sub	sp, #8
                                    595 ;	test_temp.c: 200: if (temp_x100 > 9999) temp_x100 = 9999;
      008299 90 93            [ 1]  596 	ldw	y, x
      00829B 90 A3 27 0F      [ 2]  597 	cpw	y, #0x270f
      00829F 23 03            [ 2]  598 	jrule	00102$
      0082A1 AE 27 0F         [ 2]  599 	ldw	x, #0x270f
      0082A4                        600 00102$:
                                    601 ;	test_temp.c: 203: uint8_t d0 = (temp_x100 / 1000) % 10;
      0082A4 1F 01            [ 2]  602 	ldw	(0x01, sp), x
      0082A6 90 AE 03 E8      [ 2]  603 	ldw	y, #0x03e8
      0082AA 65               [ 2]  604 	divw	x, y
      0082AB 90 AE 00 0A      [ 2]  605 	ldw	y, #0x000a
      0082AF 65               [ 2]  606 	divw	x, y
      0082B0 90 9F            [ 1]  607 	ld	a, yl
                                    608 ;	test_temp.c: 204: uint8_t d1 = (temp_x100 / 100) % 10;
      0082B2 1E 01            [ 2]  609 	ldw	x, (0x01, sp)
      0082B4 90 AE 00 64      [ 2]  610 	ldw	y, #0x0064
      0082B8 65               [ 2]  611 	divw	x, y
      0082B9 90 AE 00 0A      [ 2]  612 	ldw	y, #0x000a
      0082BD 65               [ 2]  613 	divw	x, y
      0082BE 61               [ 1]  614 	exg	a, yl
      0082BF 6B 08            [ 1]  615 	ld	(0x08, sp), a
      0082C1 61               [ 1]  616 	exg	a, yl
                                    617 ;	test_temp.c: 205: uint8_t d2 = (temp_x100 / 10) % 10;
      0082C2 1E 01            [ 2]  618 	ldw	x, (0x01, sp)
      0082C4 90 AE 00 0A      [ 2]  619 	ldw	y, #0x000a
      0082C8 65               [ 2]  620 	divw	x, y
      0082C9 90 AE 00 0A      [ 2]  621 	ldw	y, #0x000a
      0082CD 65               [ 2]  622 	divw	x, y
      0082CE 93               [ 1]  623 	ldw	x, y
                                    624 ;	test_temp.c: 206: uint8_t d3 = temp_x100 % 10;
      0082CF 89               [ 2]  625 	pushw	x
      0082D0 1E 03            [ 2]  626 	ldw	x, (0x03, sp)
      0082D2 90 AE 00 0A      [ 2]  627 	ldw	y, #0x000a
      0082D6 65               [ 2]  628 	divw	x, y
      0082D7 85               [ 2]  629 	popw	x
                                    630 ;	test_temp.c: 208: uint8_t digits[4] = { d0, d1, d2, d3 };
      0082D8 6B 03            [ 1]  631 	ld	(0x03, sp), a
      0082DA 7B 08            [ 1]  632 	ld	a, (0x08, sp)
      0082DC 6B 04            [ 1]  633 	ld	(0x04, sp), a
      0082DE 41               [ 1]  634 	exg	a, xl
      0082DF 6B 05            [ 1]  635 	ld	(0x05, sp), a
      0082E1 41               [ 1]  636 	exg	a, xl
      0082E2 61               [ 1]  637 	exg	a, yl
      0082E3 6B 06            [ 1]  638 	ld	(0x06, sp), a
      0082E5 61               [ 1]  639 	exg	a, yl
                                    640 ;	test_temp.c: 210: for (uint8_t i = 0; i < 4; i++) {
      0082E6 0F 08            [ 1]  641 	clr	(0x08, sp)
      0082E8                        642 00116$:
      0082E8 7B 08            [ 1]  643 	ld	a, (0x08, sp)
      0082EA A1 04            [ 1]  644 	cp	a, #0x04
      0082EC 25 03            [ 1]  645 	jrc	00167$
      0082EE CC 83 7A         [ 2]  646 	jp	00118$
      0082F1                        647 00167$:
                                    648 ;	test_temp.c: 211: uint8_t seg = digit_segments[digits[i]];
      0082F1 5F               [ 1]  649 	clrw	x
      0082F2 7B 08            [ 1]  650 	ld	a, (0x08, sp)
      0082F4 97               [ 1]  651 	ld	xl, a
      0082F5 89               [ 2]  652 	pushw	x
      0082F6 96               [ 1]  653 	ldw	x, sp
      0082F7 1C 00 05         [ 2]  654 	addw	x, #5
      0082FA 72 FB 01         [ 2]  655 	addw	x, (1, sp)
      0082FD 5B 02            [ 2]  656 	addw	sp, #2
      0082FF F6               [ 1]  657 	ld	a, (x)
      008300 5F               [ 1]  658 	clrw	x
      008301 97               [ 1]  659 	ld	xl, a
      008302 1C 80 28         [ 2]  660 	addw	x, #(_digit_segments+0)
      008305 F6               [ 1]  661 	ld	a, (x)
                                    662 ;	test_temp.c: 214: if (i == 1) seg |= 0x80;
      008306 88               [ 1]  663 	push	a
      008307 7B 09            [ 1]  664 	ld	a, (0x09, sp)
      008309 4A               [ 1]  665 	dec	a
      00830A 84               [ 1]  666 	pop	a
      00830B 26 07            [ 1]  667 	jrne	00169$
      00830D 88               [ 1]  668 	push	a
      00830E A6 01            [ 1]  669 	ld	a, #0x01
      008310 6B 08            [ 1]  670 	ld	(0x08, sp), a
      008312 84               [ 1]  671 	pop	a
      008313 C5                     672 	.byte 0xc5
      008314                        673 00169$:
      008314 0F 07            [ 1]  674 	clr	(0x07, sp)
      008316                        675 00170$:
      008316 0D 07            [ 1]  676 	tnz	(0x07, sp)
      008318 27 02            [ 1]  677 	jreq	00104$
      00831A AA 80            [ 1]  678 	or	a, #0x80
      00831C                        679 00104$:
                                    680 ;	test_temp.c: 216: disable_all_digits();
      00831C 88               [ 1]  681 	push	a
      00831D CD 80 B6         [ 4]  682 	call	_disable_all_digits
      008320 84               [ 1]  683 	pop	a
                                    684 ;	test_temp.c: 217: shift_out(seg);
      008321 CD 80 80         [ 4]  685 	call	_shift_out
                                    686 ;	test_temp.c: 218: latch();
      008324 CD 80 AD         [ 4]  687 	call	_latch
                                    688 ;	test_temp.c: 221: switch (i) {
      008327 7B 08            [ 1]  689 	ld	a, (0x08, sp)
      008329 A0 03            [ 1]  690 	sub	a, #0x03
      00832B 26 04            [ 1]  691 	jrne	00173$
      00832D 4C               [ 1]  692 	inc	a
      00832E 97               [ 1]  693 	ld	xl, a
      00832F 20 02            [ 2]  694 	jra	00174$
      008331                        695 00173$:
      008331 4F               [ 1]  696 	clr	a
      008332 97               [ 1]  697 	ld	xl, a
      008333                        698 00174$:
      008333 7B 08            [ 1]  699 	ld	a, (0x08, sp)
      008335 A1 00            [ 1]  700 	cp	a, #0x00
      008337 27 10            [ 1]  701 	jreq	00105$
      008339 0D 07            [ 1]  702 	tnz	(0x07, sp)
      00833B 26 12            [ 1]  703 	jrne	00106$
      00833D 7B 08            [ 1]  704 	ld	a, (0x08, sp)
      00833F A1 02            [ 1]  705 	cp	a, #0x02
      008341 27 12            [ 1]  706 	jreq	00107$
      008343 9F               [ 1]  707 	ld	a, xl
      008344 4D               [ 1]  708 	tnz	a
      008345 26 14            [ 1]  709 	jrne	00108$
      008347 20 16            [ 2]  710 	jra	00109$
                                    711 ;	test_temp.c: 222: case 0: PA_ODR &= ~(1 << 3); break; // D4
      008349                        712 00105$:
      008349 72 17 50 00      [ 1]  713 	bres	0x5000, #3
      00834D 20 10            [ 2]  714 	jra	00109$
                                    715 ;	test_temp.c: 223: case 1: PA_ODR &= ~(1 << 1); break; // D3
      00834F                        716 00106$:
      00834F 72 13 50 00      [ 1]  717 	bres	0x5000, #1
      008353 20 0A            [ 2]  718 	jra	00109$
                                    719 ;	test_temp.c: 224: case 2: PD_ODR &= ~(1 << 4); break; // D2
      008355                        720 00107$:
      008355 72 19 50 0F      [ 1]  721 	bres	0x500f, #4
      008359 20 04            [ 2]  722 	jra	00109$
                                    723 ;	test_temp.c: 225: case 3: PA_ODR &= ~(1 << 2); break; // D1
      00835B                        724 00108$:
      00835B 72 15 50 00      [ 1]  725 	bres	0x5000, #2
                                    726 ;	test_temp.c: 226: }
      00835F                        727 00109$:
                                    728 ;	test_temp.c: 229: if (i == 1 || i == 3) delay_us(800);
      00835F 0D 07            [ 1]  729 	tnz	(0x07, sp)
      008361 26 04            [ 1]  730 	jrne	00110$
      008363 9F               [ 1]  731 	ld	a, xl
      008364 4D               [ 1]  732 	tnz	a
      008365 27 08            [ 1]  733 	jreq	00111$
      008367                        734 00110$:
      008367 AE 03 20         [ 2]  735 	ldw	x, #0x0320
      00836A CD 81 25         [ 4]  736 	call	_delay_us
      00836D 20 06            [ 2]  737 	jra	00117$
      00836F                        738 00111$:
                                    739 ;	test_temp.c: 230: else                  delay_us(400);
      00836F AE 01 90         [ 2]  740 	ldw	x, #0x0190
      008372 CD 81 25         [ 4]  741 	call	_delay_us
      008375                        742 00117$:
                                    743 ;	test_temp.c: 210: for (uint8_t i = 0; i < 4; i++) {
      008375 0C 08            [ 1]  744 	inc	(0x08, sp)
      008377 CC 82 E8         [ 2]  745 	jp	00116$
      00837A                        746 00118$:
                                    747 ;	test_temp.c: 232: }
      00837A 5B 08            [ 2]  748 	addw	sp, #8
      00837C 81               [ 4]  749 	ret
                                    750 ;	test_temp.c: 234: void display_step() {
                                    751 ;	-----------------------------------------
                                    752 ;	 function display_step
                                    753 ;	-----------------------------------------
      00837D                        754 _display_step:
                                    755 ;	test_temp.c: 237: disable_all_digits();
      00837D CD 80 B6         [ 4]  756 	call	_disable_all_digits
                                    757 ;	test_temp.c: 239: uint8_t seg = digit_segments[digits[pos]];
      008380 5F               [ 1]  758 	clrw	x
      008381 C6 00 01         [ 1]  759 	ld	a, _display_step_pos_65536_48+0
      008384 97               [ 1]  760 	ld	xl, a
      008385 D6 00 02         [ 1]  761 	ld	a, (_digits+0, x)
      008388 5F               [ 1]  762 	clrw	x
      008389 97               [ 1]  763 	ld	xl, a
      00838A D6 80 28         [ 1]  764 	ld	a, (_digit_segments+0, x)
                                    765 ;	test_temp.c: 242: if (pos == 1) seg |= 0x80;
      00838D 88               [ 1]  766 	push	a
      00838E C6 00 01         [ 1]  767 	ld	a, _display_step_pos_65536_48+0
      008391 4A               [ 1]  768 	dec	a
      008392 84               [ 1]  769 	pop	a
      008393 26 02            [ 1]  770 	jrne	00102$
      008395 AA 80            [ 1]  771 	or	a, #0x80
      008397                        772 00102$:
                                    773 ;	test_temp.c: 244: shift_out(seg);
      008397 CD 80 80         [ 4]  774 	call	_shift_out
                                    775 ;	test_temp.c: 245: latch();
      00839A CD 80 AD         [ 4]  776 	call	_latch
                                    777 ;	test_temp.c: 248: switch (pos) {
      00839D C6 00 01         [ 1]  778 	ld	a, _display_step_pos_65536_48+0
      0083A0 A1 00            [ 1]  779 	cp	a, #0x00
      0083A2 27 16            [ 1]  780 	jreq	00103$
      0083A4 C6 00 01         [ 1]  781 	ld	a, _display_step_pos_65536_48+0
      0083A7 4A               [ 1]  782 	dec	a
      0083A8 27 16            [ 1]  783 	jreq	00104$
      0083AA C6 00 01         [ 1]  784 	ld	a, _display_step_pos_65536_48+0
      0083AD A1 02            [ 1]  785 	cp	a, #0x02
      0083AF 27 15            [ 1]  786 	jreq	00105$
      0083B1 C6 00 01         [ 1]  787 	ld	a, _display_step_pos_65536_48+0
      0083B4 A1 03            [ 1]  788 	cp	a, #0x03
      0083B6 27 14            [ 1]  789 	jreq	00106$
      0083B8 20 16            [ 2]  790 	jra	00107$
                                    791 ;	test_temp.c: 249: case 0: PA_ODR &= ~(1 << 3); break; // D4
      0083BA                        792 00103$:
      0083BA 72 17 50 00      [ 1]  793 	bres	0x5000, #3
      0083BE 20 10            [ 2]  794 	jra	00107$
                                    795 ;	test_temp.c: 250: case 1: PA_ODR &= ~(1 << 1); break; // D3
      0083C0                        796 00104$:
      0083C0 72 13 50 00      [ 1]  797 	bres	0x5000, #1
      0083C4 20 0A            [ 2]  798 	jra	00107$
                                    799 ;	test_temp.c: 251: case 2: PD_ODR &= ~(1 << 4); break; // D2
      0083C6                        800 00105$:
      0083C6 72 19 50 0F      [ 1]  801 	bres	0x500f, #4
      0083CA 20 04            [ 2]  802 	jra	00107$
                                    803 ;	test_temp.c: 252: case 3: PA_ODR &= ~(1 << 2); break; // D1
      0083CC                        804 00106$:
      0083CC 72 15 50 00      [ 1]  805 	bres	0x5000, #2
                                    806 ;	test_temp.c: 253: }
      0083D0                        807 00107$:
                                    808 ;	test_temp.c: 255: pos = (pos + 1) % 4; // Passe au digit suivant à chaque appel
      0083D0 C6 00 01         [ 1]  809 	ld	a, _display_step_pos_65536_48+0
      0083D3 5F               [ 1]  810 	clrw	x
      0083D4 97               [ 1]  811 	ld	xl, a
      0083D5 5C               [ 1]  812 	incw	x
      0083D6 4B 04            [ 1]  813 	push	#0x04
      0083D8 4B 00            [ 1]  814 	push	#0x00
      0083DA CD 88 02         [ 4]  815 	call	__modsint
      0083DD 9F               [ 1]  816 	ld	a, xl
      0083DE C7 00 01         [ 1]  817 	ld	_display_step_pos_65536_48+0, a
                                    818 ;	test_temp.c: 256: }
      0083E1 81               [ 4]  819 	ret
                                    820 ;	test_temp.c: 262: uint8_t onewire_reset(void) {
                                    821 ;	-----------------------------------------
                                    822 ;	 function onewire_reset
                                    823 ;	-----------------------------------------
      0083E2                        824 _onewire_reset:
                                    825 ;	test_temp.c: 263: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
      0083E2 72 16 50 11      [ 1]  826 	bset	0x5011, #3
      0083E6 72 17 50 0F      [ 1]  827 	bres	0x500f, #3
                                    828 ;	test_temp.c: 264: delay_us(480);
      0083EA AE 01 E0         [ 2]  829 	ldw	x, #0x01e0
      0083ED CD 81 25         [ 4]  830 	call	_delay_us
                                    831 ;	test_temp.c: 265: DS_INPUT();                    // Relâche la ligne
      0083F0 72 17 50 11      [ 1]  832 	bres	0x5011, #3
                                    833 ;	test_temp.c: 266: delay_us(70);                  // Attend la réponse du capteur
      0083F4 AE 00 46         [ 2]  834 	ldw	x, #0x0046
      0083F7 CD 81 25         [ 4]  835 	call	_delay_us
                                    836 ;	test_temp.c: 267: uint8_t presence = !DS_READ(); // 0 = présence détectée
      0083FA C6 50 10         [ 1]  837 	ld	a, 0x5010
      0083FD 4E               [ 1]  838 	swap	a
      0083FE 48               [ 1]  839 	sll	a
      0083FF 4F               [ 1]  840 	clr	a
      008400 49               [ 1]  841 	rlc	a
      008401 A0 01            [ 1]  842 	sub	a, #0x01
      008403 4F               [ 1]  843 	clr	a
      008404 49               [ 1]  844 	rlc	a
                                    845 ;	test_temp.c: 268: delay_us(410);                 // Fin du timing 1-Wire
      008405 88               [ 1]  846 	push	a
      008406 AE 01 9A         [ 2]  847 	ldw	x, #0x019a
      008409 CD 81 25         [ 4]  848 	call	_delay_us
      00840C 84               [ 1]  849 	pop	a
                                    850 ;	test_temp.c: 269: return presence;
                                    851 ;	test_temp.c: 270: }
      00840D 81               [ 4]  852 	ret
                                    853 ;	test_temp.c: 273: void onewire_write_bit(uint8_t bit) {
                                    854 ;	-----------------------------------------
                                    855 ;	 function onewire_write_bit
                                    856 ;	-----------------------------------------
      00840E                        857 _onewire_write_bit:
      00840E 88               [ 1]  858 	push	a
      00840F 6B 01            [ 1]  859 	ld	(0x01, sp), a
                                    860 ;	test_temp.c: 274: DS_OUTPUT(); DS_LOW();
      008411 72 16 50 11      [ 1]  861 	bset	0x5011, #3
      008415 72 17 50 0F      [ 1]  862 	bres	0x500f, #3
                                    863 ;	test_temp.c: 275: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
      008419 0D 01            [ 1]  864 	tnz	(0x01, sp)
      00841B 27 04            [ 1]  865 	jreq	00103$
      00841D AE 00 06         [ 2]  866 	ldw	x, #0x0006
      008420 BC                     867 	.byte 0xbc
      008421                        868 00103$:
      008421 AE 00 3C         [ 2]  869 	ldw	x, #0x003c
      008424                        870 00104$:
      008424 CD 81 25         [ 4]  871 	call	_delay_us
                                    872 ;	test_temp.c: 276: DS_INPUT();                    // Libère la ligne
      008427 72 17 50 11      [ 1]  873 	bres	0x5011, #3
                                    874 ;	test_temp.c: 277: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
      00842B 0D 01            [ 1]  875 	tnz	(0x01, sp)
      00842D 27 05            [ 1]  876 	jreq	00105$
      00842F AE 00 40         [ 2]  877 	ldw	x, #0x0040
      008432 20 03            [ 2]  878 	jra	00106$
      008434                        879 00105$:
      008434 AE 00 0A         [ 2]  880 	ldw	x, #0x000a
      008437                        881 00106$:
      008437 84               [ 1]  882 	pop	a
      008438 CC 81 25         [ 2]  883 	jp	_delay_us
                                    884 ;	test_temp.c: 278: }
      00843B 84               [ 1]  885 	pop	a
      00843C 81               [ 4]  886 	ret
                                    887 ;	test_temp.c: 281: uint8_t onewire_read_bit(void) {
                                    888 ;	-----------------------------------------
                                    889 ;	 function onewire_read_bit
                                    890 ;	-----------------------------------------
      00843D                        891 _onewire_read_bit:
                                    892 ;	test_temp.c: 283: DS_OUTPUT(); DS_LOW();
      00843D 72 16 50 11      [ 1]  893 	bset	0x5011, #3
      008441 72 17 50 0F      [ 1]  894 	bres	0x500f, #3
                                    895 ;	test_temp.c: 284: delay_us(6);                   // Pulse d'initiation de lecture
      008445 AE 00 06         [ 2]  896 	ldw	x, #0x0006
      008448 CD 81 25         [ 4]  897 	call	_delay_us
                                    898 ;	test_temp.c: 285: DS_INPUT();                    // Libère la ligne pour lire
      00844B 72 17 50 11      [ 1]  899 	bres	0x5011, #3
                                    900 ;	test_temp.c: 286: delay_us(9);                   // Délai standard
      00844F AE 00 09         [ 2]  901 	ldw	x, #0x0009
      008452 CD 81 25         [ 4]  902 	call	_delay_us
                                    903 ;	test_temp.c: 287: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
      008455 72 07 50 10 03   [ 2]  904 	btjf	0x5010, #3, 00103$
      00845A 5F               [ 1]  905 	clrw	x
      00845B 5C               [ 1]  906 	incw	x
      00845C 21                     907 	.byte 0x21
      00845D                        908 00103$:
      00845D 5F               [ 1]  909 	clrw	x
      00845E                        910 00104$:
      00845E 9F               [ 1]  911 	ld	a, xl
                                    912 ;	test_temp.c: 288: delay_us(55);                  // Fin du slot
      00845F 88               [ 1]  913 	push	a
      008460 AE 00 37         [ 2]  914 	ldw	x, #0x0037
      008463 CD 81 25         [ 4]  915 	call	_delay_us
      008466 84               [ 1]  916 	pop	a
                                    917 ;	test_temp.c: 289: return bit;
                                    918 ;	test_temp.c: 290: }
      008467 81               [ 4]  919 	ret
                                    920 ;	test_temp.c: 293: void onewire_write_byte(uint8_t byte) {
                                    921 ;	-----------------------------------------
                                    922 ;	 function onewire_write_byte
                                    923 ;	-----------------------------------------
      008468                        924 _onewire_write_byte:
      008468 52 02            [ 2]  925 	sub	sp, #2
      00846A 6B 01            [ 1]  926 	ld	(0x01, sp), a
                                    927 ;	test_temp.c: 294: for (uint8_t i = 0; i < 8; i++) {
      00846C 0F 02            [ 1]  928 	clr	(0x02, sp)
      00846E                        929 00103$:
      00846E 7B 02            [ 1]  930 	ld	a, (0x02, sp)
      008470 A1 08            [ 1]  931 	cp	a, #0x08
      008472 24 0D            [ 1]  932 	jrnc	00105$
                                    933 ;	test_temp.c: 295: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
      008474 7B 01            [ 1]  934 	ld	a, (0x01, sp)
      008476 A4 01            [ 1]  935 	and	a, #0x01
      008478 CD 84 0E         [ 4]  936 	call	_onewire_write_bit
                                    937 ;	test_temp.c: 296: byte >>= 1;
      00847B 04 01            [ 1]  938 	srl	(0x01, sp)
                                    939 ;	test_temp.c: 294: for (uint8_t i = 0; i < 8; i++) {
      00847D 0C 02            [ 1]  940 	inc	(0x02, sp)
      00847F 20 ED            [ 2]  941 	jra	00103$
      008481                        942 00105$:
                                    943 ;	test_temp.c: 298: }
      008481 5B 02            [ 2]  944 	addw	sp, #2
      008483 81               [ 4]  945 	ret
                                    946 ;	test_temp.c: 301: uint8_t onewire_read_byte(void) {
                                    947 ;	-----------------------------------------
                                    948 ;	 function onewire_read_byte
                                    949 ;	-----------------------------------------
      008484                        950 _onewire_read_byte:
      008484 52 02            [ 2]  951 	sub	sp, #2
                                    952 ;	test_temp.c: 302: uint8_t byte = 0;
      008486 0F 01            [ 1]  953 	clr	(0x01, sp)
                                    954 ;	test_temp.c: 303: for (uint8_t i = 0; i < 8; i++) {
      008488 0F 02            [ 1]  955 	clr	(0x02, sp)
      00848A                        956 00105$:
      00848A 7B 02            [ 1]  957 	ld	a, (0x02, sp)
      00848C A1 08            [ 1]  958 	cp	a, #0x08
      00848E 24 11            [ 1]  959 	jrnc	00103$
                                    960 ;	test_temp.c: 304: byte >>= 1;
      008490 04 01            [ 1]  961 	srl	(0x01, sp)
                                    962 ;	test_temp.c: 305: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
      008492 CD 84 3D         [ 4]  963 	call	_onewire_read_bit
      008495 4D               [ 1]  964 	tnz	a
      008496 27 05            [ 1]  965 	jreq	00106$
      008498 08 01            [ 1]  966 	sll	(0x01, sp)
      00849A 99               [ 1]  967 	scf
      00849B 06 01            [ 1]  968 	rrc	(0x01, sp)
      00849D                        969 00106$:
                                    970 ;	test_temp.c: 303: for (uint8_t i = 0; i < 8; i++) {
      00849D 0C 02            [ 1]  971 	inc	(0x02, sp)
      00849F 20 E9            [ 2]  972 	jra	00105$
      0084A1                        973 00103$:
                                    974 ;	test_temp.c: 307: return byte;
      0084A1 7B 01            [ 1]  975 	ld	a, (0x01, sp)
                                    976 ;	test_temp.c: 308: }
      0084A3 5B 02            [ 2]  977 	addw	sp, #2
      0084A5 81               [ 4]  978 	ret
                                    979 ;	test_temp.c: 311: void ds18b20_start_conversion(void) {
                                    980 ;	-----------------------------------------
                                    981 ;	 function ds18b20_start_conversion
                                    982 ;	-----------------------------------------
      0084A6                        983 _ds18b20_start_conversion:
                                    984 ;	test_temp.c: 312: onewire_reset();
      0084A6 CD 83 E2         [ 4]  985 	call	_onewire_reset
                                    986 ;	test_temp.c: 313: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
      0084A9 A6 CC            [ 1]  987 	ld	a, #0xcc
      0084AB CD 84 68         [ 4]  988 	call	_onewire_write_byte
                                    989 ;	test_temp.c: 314: onewire_write_byte(0x44); // Convert T (lance mesure)
      0084AE A6 44            [ 1]  990 	ld	a, #0x44
                                    991 ;	test_temp.c: 315: }
      0084B0 CC 84 68         [ 2]  992 	jp	_onewire_write_byte
                                    993 ;	test_temp.c: 318: int16_t ds18b20_read_raw(void) {
                                    994 ;	-----------------------------------------
                                    995 ;	 function ds18b20_read_raw
                                    996 ;	-----------------------------------------
      0084B3                        997 _ds18b20_read_raw:
      0084B3 52 04            [ 2]  998 	sub	sp, #4
                                    999 ;	test_temp.c: 319: onewire_reset();
      0084B5 CD 83 E2         [ 4] 1000 	call	_onewire_reset
                                   1001 ;	test_temp.c: 320: onewire_write_byte(0xCC); // Skip ROM
      0084B8 A6 CC            [ 1] 1002 	ld	a, #0xcc
      0084BA CD 84 68         [ 4] 1003 	call	_onewire_write_byte
                                   1004 ;	test_temp.c: 321: onewire_write_byte(0xBE); // Read Scratchpad
      0084BD A6 BE            [ 1] 1005 	ld	a, #0xbe
      0084BF CD 84 68         [ 4] 1006 	call	_onewire_write_byte
                                   1007 ;	test_temp.c: 323: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
      0084C2 CD 84 84         [ 4] 1008 	call	_onewire_read_byte
                                   1009 ;	test_temp.c: 324: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
      0084C5 88               [ 1] 1010 	push	a
      0084C6 CD 84 84         [ 4] 1011 	call	_onewire_read_byte
      0084C9 95               [ 1] 1012 	ld	xh, a
      0084CA 84               [ 1] 1013 	pop	a
                                   1014 ;	test_temp.c: 326: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
      0084CB 0F 02            [ 1] 1015 	clr	(0x02, sp)
      0084CD 0F 03            [ 1] 1016 	clr	(0x03, sp)
      0084CF 1A 02            [ 1] 1017 	or	a, (0x02, sp)
      0084D1 02               [ 1] 1018 	rlwa	x
      0084D2 1A 03            [ 1] 1019 	or	a, (0x03, sp)
      0084D4 95               [ 1] 1020 	ld	xh, a
                                   1021 ;	test_temp.c: 327: }
      0084D5 5B 04            [ 2] 1022 	addw	sp, #4
      0084D7 81               [ 4] 1023 	ret
                                   1024 ;	test_temp.c: 330: void main() {
                                   1025 ;	-----------------------------------------
                                   1026 ;	 function main
                                   1027 ;	-----------------------------------------
      0084D8                       1028 _main:
      0084D8 52 04            [ 2] 1029 	sub	sp, #4
                                   1030 ;	test_temp.c: 331: setup();
      0084DA CD 81 5A         [ 4] 1031 	call	_setup
                                   1032 ;	test_temp.c: 332: uart_config();
      0084DD CD 80 36         [ 4] 1033 	call	_uart_config
                                   1034 ;	test_temp.c: 334: PD_DDR &= ~(1 << 3);
      0084E0 72 17 50 11      [ 1] 1035 	bres	0x5011, #3
                                   1036 ;	test_temp.c: 335: PD_CR1 |= (1 << 3);
      0084E4 72 16 50 12      [ 1] 1037 	bset	0x5012, #3
                                   1038 ;	test_temp.c: 337: uint16_t temp_x100 = 2430; // Valeur de départ par défaut
      0084E8 AE 09 7E         [ 2] 1039 	ldw	x, #0x097e
      0084EB 1F 01            [ 2] 1040 	ldw	(0x01, sp), x
                                   1041 ;	test_temp.c: 338: uint16_t counter = 0;
      0084ED 5F               [ 1] 1042 	clrw	x
      0084EE 1F 03            [ 2] 1043 	ldw	(0x03, sp), x
                                   1044 ;	test_temp.c: 340: ds18b20_start_conversion(); // Démarre première conversion
      0084F0 CD 84 A6         [ 4] 1045 	call	_ds18b20_start_conversion
                                   1046 ;	test_temp.c: 342: while (1) {
      0084F3                       1047 00104$:
                                   1048 ;	test_temp.c: 344: display_int(temp_x100);
      0084F3 1E 01            [ 2] 1049 	ldw	x, (0x01, sp)
      0084F5 CD 82 97         [ 4] 1050 	call	_display_int
                                   1051 ;	test_temp.c: 346: delay_ms(5); // assez long pour multiplexage stable
      0084F8 AE 00 05         [ 2] 1052 	ldw	x, #0x0005
      0084FB CD 81 36         [ 4] 1053 	call	_delay_ms
                                   1054 ;	test_temp.c: 348: counter += 5;
      0084FE 1E 03            [ 2] 1055 	ldw	x, (0x03, sp)
      008500 1C 00 05         [ 2] 1056 	addw	x, #0x0005
                                   1057 ;	test_temp.c: 349: if (counter >= 750) {
      008503 1F 03            [ 2] 1058 	ldw	(0x03, sp), x
      008505 A3 02 EE         [ 2] 1059 	cpw	x, #0x02ee
      008508 25 E9            [ 1] 1060 	jrc	00104$
                                   1061 ;	test_temp.c: 350: counter = 0;
      00850A 5F               [ 1] 1062 	clrw	x
      00850B 1F 03            [ 2] 1063 	ldw	(0x03, sp), x
                                   1064 ;	test_temp.c: 353: int16_t raw = ds18b20_read_raw();
      00850D CD 84 B3         [ 4] 1065 	call	_ds18b20_read_raw
                                   1066 ;	test_temp.c: 354: temp_x100 = (raw * 625UL) / 100;
      008510 90 5F            [ 1] 1067 	clrw	y
      008512 5D               [ 2] 1068 	tnzw	x
      008513 2A 02            [ 1] 1069 	jrpl	00119$
      008515 90 5A            [ 2] 1070 	decw	y
      008517                       1071 00119$:
      008517 89               [ 2] 1072 	pushw	x
      008518 90 89            [ 2] 1073 	pushw	y
      00851A 4B 71            [ 1] 1074 	push	#0x71
      00851C 4B 02            [ 1] 1075 	push	#0x02
      00851E 5F               [ 1] 1076 	clrw	x
      00851F 89               [ 2] 1077 	pushw	x
      008520 CD 88 1A         [ 4] 1078 	call	__mullong
      008523 5B 08            [ 2] 1079 	addw	sp, #8
      008525 4B 64            [ 1] 1080 	push	#0x64
      008527 4B 00            [ 1] 1081 	push	#0x00
      008529 4B 00            [ 1] 1082 	push	#0x00
      00852B 4B 00            [ 1] 1083 	push	#0x00
      00852D 89               [ 2] 1084 	pushw	x
      00852E 90 89            [ 2] 1085 	pushw	y
      008530 CD 87 89         [ 4] 1086 	call	__divulong
      008533 5B 08            [ 2] 1087 	addw	sp, #8
      008535 1F 01            [ 2] 1088 	ldw	(0x01, sp), x
                                   1089 ;	test_temp.c: 357: ds18b20_start_conversion();
      008537 CD 84 A6         [ 4] 1090 	call	_ds18b20_start_conversion
      00853A 20 B7            [ 2] 1091 	jra	00104$
                                   1092 ;	test_temp.c: 360: }
      00853C 5B 04            [ 2] 1093 	addw	sp, #4
      00853E 81               [ 4] 1094 	ret
                                   1095 	.area CODE
                                   1096 	.area CONST
      008028                       1097 _digit_segments:
      008028 3F                    1098 	.db #0x3f	; 63
      008029 06                    1099 	.db #0x06	; 6
      00802A 5B                    1100 	.db #0x5b	; 91
      00802B 4F                    1101 	.db #0x4f	; 79	'O'
      00802C 66                    1102 	.db #0x66	; 102	'f'
      00802D 6D                    1103 	.db #0x6d	; 109	'm'
      00802E 7D                    1104 	.db #0x7d	; 125
      00802F 07                    1105 	.db #0x07	; 7
      008030 7F                    1106 	.db #0x7f	; 127
      008031 6F                    1107 	.db #0x6f	; 111	'o'
                                   1108 	.area INITIALIZER
      008032                       1109 __xinit__digits:
      008032 00                    1110 	.db #0x00	; 0
      008033 00                    1111 	.db #0x00	; 0
      008034 00                    1112 	.db #0x00	; 0
      008035 00                    1113 	.db #0x00	; 0
                                   1114 	.area CABS (ABS)
