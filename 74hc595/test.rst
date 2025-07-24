                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module test
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _shift_register_send
                                     13 	.globl _shift_register_init
                                     14 	.globl _delay_ms
                                     15 ;--------------------------------------------------------
                                     16 ; ram data
                                     17 ;--------------------------------------------------------
                                     18 	.area DATA
                                     19 ;--------------------------------------------------------
                                     20 ; ram data
                                     21 ;--------------------------------------------------------
                                     22 	.area INITIALIZED
                                     23 ;--------------------------------------------------------
                                     24 ; Stack segment in internal ram
                                     25 ;--------------------------------------------------------
                                     26 	.area	SSEG
      000001                         27 __start__stack:
      000001                         28 	.ds	1
                                     29 
                                     30 ;--------------------------------------------------------
                                     31 ; absolute external ram data
                                     32 ;--------------------------------------------------------
                                     33 	.area DABS (ABS)
                                     34 
                                     35 ; default segment ordering for linker
                                     36 	.area HOME
                                     37 	.area GSINIT
                                     38 	.area GSFINAL
                                     39 	.area CONST
                                     40 	.area INITIALIZER
                                     41 	.area CODE
                                     42 
                                     43 ;--------------------------------------------------------
                                     44 ; interrupt vector
                                     45 ;--------------------------------------------------------
                                     46 	.area HOME
      008000                         47 __interrupt_vect:
      008000 82 00 80 07             48 	int s_GSINIT ; reset
                                     49 ;--------------------------------------------------------
                                     50 ; global & static initialisations
                                     51 ;--------------------------------------------------------
                                     52 	.area HOME
                                     53 	.area GSINIT
                                     54 	.area GSFINAL
                                     55 	.area GSINIT
      008007                         56 __sdcc_init_data:
                                     57 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   58 	ldw x, #l_DATA
      00800A 27 07            [ 1]   59 	jreq	00002$
      00800C                         60 00001$:
      00800C 72 4F 00 00      [ 1]   61 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   62 	decw x
      008011 26 F9            [ 1]   63 	jrne	00001$
      008013                         64 00002$:
      008013 AE 00 00         [ 2]   65 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   66 	jreq	00004$
      008018                         67 00003$:
      008018 D6 80 23         [ 1]   68 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   69 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   70 	decw	x
      00801F 26 F7            [ 1]   71 	jrne	00003$
      008021                         72 00004$:
                                     73 ; stm8_genXINIT() end
                                     74 	.area GSFINAL
      008021 CC 80 04         [ 2]   75 	jp	__sdcc_program_startup
                                     76 ;--------------------------------------------------------
                                     77 ; Home
                                     78 ;--------------------------------------------------------
                                     79 	.area HOME
                                     80 	.area HOME
      008004                         81 __sdcc_program_startup:
      008004 CC 80 FE         [ 2]   82 	jp	_main
                                     83 ;	return from main will return to caller
                                     84 ;--------------------------------------------------------
                                     85 ; code
                                     86 ;--------------------------------------------------------
                                     87 	.area CODE
                                     88 ;	test.c: 5: void delay_ms(uint16_t ms) {
                                     89 ;	-----------------------------------------
                                     90 ;	 function delay_ms
                                     91 ;	-----------------------------------------
      008024                         92 _delay_ms:
      008024 52 06            [ 2]   93 	sub	sp, #6
      008026 1F 03            [ 2]   94 	ldw	(0x03, sp), x
                                     95 ;	test.c: 6: for (uint16_t i = 0; i < ms * 1000; i++)
      008028 5F               [ 1]   96 	clrw	x
      008029 1F 05            [ 2]   97 	ldw	(0x05, sp), x
      00802B                         98 00103$:
      00802B 1E 03            [ 2]   99 	ldw	x, (0x03, sp)
      00802D 89               [ 2]  100 	pushw	x
      00802E AE 03 E8         [ 2]  101 	ldw	x, #0x03e8
      008031 CD 81 38         [ 4]  102 	call	__mulint
      008034 1F 01            [ 2]  103 	ldw	(0x01, sp), x
      008036 1E 05            [ 2]  104 	ldw	x, (0x05, sp)
      008038 13 01            [ 2]  105 	cpw	x, (0x01, sp)
      00803A 24 08            [ 1]  106 	jrnc	00105$
                                    107 ;	test.c: 7: __asm__("nop");
      00803C 9D               [ 1]  108 	nop
                                    109 ;	test.c: 6: for (uint16_t i = 0; i < ms * 1000; i++)
      00803D 1E 05            [ 2]  110 	ldw	x, (0x05, sp)
      00803F 5C               [ 1]  111 	incw	x
      008040 1F 05            [ 2]  112 	ldw	(0x05, sp), x
      008042 20 E7            [ 2]  113 	jra	00103$
      008044                        114 00105$:
                                    115 ;	test.c: 8: }
      008044 5B 06            [ 2]  116 	addw	sp, #6
      008046 81               [ 4]  117 	ret
                                    118 ;	test.c: 10: void shift_register_init(void) {
                                    119 ;	-----------------------------------------
                                    120 ;	 function shift_register_init
                                    121 ;	-----------------------------------------
      008047                        122 _shift_register_init:
                                    123 ;	test.c: 11: PA_DDR |= (1 << 1) | (1 << 2) | (1 << 3);  // PA1, PA2, PA3 = output
      008047 C6 50 02         [ 1]  124 	ld	a, 0x5002
      00804A AA 0E            [ 1]  125 	or	a, #0x0e
      00804C C7 50 02         [ 1]  126 	ld	0x5002, a
                                    127 ;	test.c: 12: PA_CR1 |= (1 << 1) | (1 << 2) | (1 << 3);  // push-pull
      00804F C6 50 03         [ 1]  128 	ld	a, 0x5003
      008052 AA 0E            [ 1]  129 	or	a, #0x0e
      008054 C7 50 03         [ 1]  130 	ld	0x5003, a
                                    131 ;	test.c: 13: PA_ODR &= ~((1 << 1) | (1 << 2) | (1 << 3)); // start low
      008057 C6 50 00         [ 1]  132 	ld	a, 0x5000
      00805A A4 F1            [ 1]  133 	and	a, #0xf1
      00805C C7 50 00         [ 1]  134 	ld	0x5000, a
                                    135 ;	test.c: 14: }
      00805F 81               [ 4]  136 	ret
                                    137 ;	test.c: 16: void shift_register_send(uint8_t segments, uint8_t digits) {
                                    138 ;	-----------------------------------------
                                    139 ;	 function shift_register_send
                                    140 ;	-----------------------------------------
      008060                        141 _shift_register_send:
      008060 52 07            [ 2]  142 	sub	sp, #7
      008062 6B 07            [ 1]  143 	ld	(0x07, sp), a
                                    144 ;	test.c: 18: for (int8_t i = 7; i >= 0; i--) {
      008064 A6 07            [ 1]  145 	ld	a, #0x07
      008066 6B 06            [ 1]  146 	ld	(0x06, sp), a
      008068                        147 00110$:
      008068 0D 06            [ 1]  148 	tnz	(0x06, sp)
      00806A 2B 3C            [ 1]  149 	jrmi	00104$
                                    150 ;	test.c: 19: if (segments & (1 << i)) PA_ODR |= (1 << 3);
      00806C 7B 06            [ 1]  151 	ld	a, (0x06, sp)
      00806E 5F               [ 1]  152 	clrw	x
      00806F 5C               [ 1]  153 	incw	x
      008070 4D               [ 1]  154 	tnz	a
      008071 27 04            [ 1]  155 	jreq	00151$
      008073                        156 00150$:
      008073 58               [ 2]  157 	sllw	x
      008074 4A               [ 1]  158 	dec	a
      008075 26 FC            [ 1]  159 	jrne	00150$
      008077                        160 00151$:
      008077 7B 07            [ 1]  161 	ld	a, (0x07, sp)
      008079 6B 03            [ 1]  162 	ld	(0x03, sp), a
      00807B 0F 02            [ 1]  163 	clr	(0x02, sp)
      00807D C6 50 00         [ 1]  164 	ld	a, 0x5000
      008080 88               [ 1]  165 	push	a
      008081 9F               [ 1]  166 	ld	a, xl
      008082 14 04            [ 1]  167 	and	a, (0x04, sp)
      008084 6B 06            [ 1]  168 	ld	(0x06, sp), a
      008086 9E               [ 1]  169 	ld	a, xh
      008087 14 03            [ 1]  170 	and	a, (0x03, sp)
      008089 6B 05            [ 1]  171 	ld	(0x05, sp), a
      00808B 84               [ 1]  172 	pop	a
      00808C 1E 04            [ 2]  173 	ldw	x, (0x04, sp)
      00808E 27 07            [ 1]  174 	jreq	00102$
      008090 AA 08            [ 1]  175 	or	a, #0x08
      008092 C7 50 00         [ 1]  176 	ld	0x5000, a
      008095 20 05            [ 2]  177 	jra	00103$
      008097                        178 00102$:
                                    179 ;	test.c: 20: else                     PA_ODR &= ~(1 << 3);
      008097 A4 F7            [ 1]  180 	and	a, #0xf7
      008099 C7 50 00         [ 1]  181 	ld	0x5000, a
      00809C                        182 00103$:
                                    183 ;	test.c: 21: PA_ODR |= (1 << 1); PA_ODR &= ~(1 << 1);
      00809C 72 12 50 00      [ 1]  184 	bset	0x5000, #1
      0080A0 72 13 50 00      [ 1]  185 	bres	0x5000, #1
                                    186 ;	test.c: 18: for (int8_t i = 7; i >= 0; i--) {
      0080A4 0A 06            [ 1]  187 	dec	(0x06, sp)
      0080A6 20 C0            [ 2]  188 	jra	00110$
      0080A8                        189 00104$:
                                    190 ;	test.c: 25: for (int8_t i = 7; i >= 0; i--) {
      0080A8 A6 07            [ 1]  191 	ld	a, #0x07
      0080AA 97               [ 1]  192 	ld	xl, a
      0080AB                        193 00113$:
                                    194 ;	test.c: 19: if (segments & (1 << i)) PA_ODR |= (1 << 3);
      0080AB C6 50 00         [ 1]  195 	ld	a, 0x5000
      0080AE 95               [ 1]  196 	ld	xh, a
                                    197 ;	test.c: 25: for (int8_t i = 7; i >= 0; i--) {
      0080AF 9F               [ 1]  198 	ld	a, xl
      0080B0 4D               [ 1]  199 	tnz	a
      0080B1 2B 3C            [ 1]  200 	jrmi	00108$
                                    201 ;	test.c: 26: if (digits & (1 << i)) PA_ODR |= (1 << 3);
      0080B3 9F               [ 1]  202 	ld	a, xl
      0080B4 90 AE 00 01      [ 2]  203 	ldw	y, #0x0001
      0080B8 17 01            [ 2]  204 	ldw	(0x01, sp), y
      0080BA 4D               [ 1]  205 	tnz	a
      0080BB 27 07            [ 1]  206 	jreq	00155$
      0080BD                        207 00154$:
      0080BD 08 02            [ 1]  208 	sll	(0x02, sp)
      0080BF 09 01            [ 1]  209 	rlc	(0x01, sp)
      0080C1 4A               [ 1]  210 	dec	a
      0080C2 26 F9            [ 1]  211 	jrne	00154$
      0080C4                        212 00155$:
      0080C4 7B 0A            [ 1]  213 	ld	a, (0x0a, sp)
      0080C6 0F 03            [ 1]  214 	clr	(0x03, sp)
      0080C8 14 02            [ 1]  215 	and	a, (0x02, sp)
      0080CA 6B 06            [ 1]  216 	ld	(0x06, sp), a
      0080CC 7B 03            [ 1]  217 	ld	a, (0x03, sp)
      0080CE 14 01            [ 1]  218 	and	a, (0x01, sp)
      0080D0 6B 05            [ 1]  219 	ld	(0x05, sp), a
      0080D2 16 05            [ 2]  220 	ldw	y, (0x05, sp)
      0080D4 27 08            [ 1]  221 	jreq	00106$
      0080D6 9E               [ 1]  222 	ld	a, xh
      0080D7 AA 08            [ 1]  223 	or	a, #0x08
      0080D9 C7 50 00         [ 1]  224 	ld	0x5000, a
      0080DC 20 06            [ 2]  225 	jra	00107$
      0080DE                        226 00106$:
                                    227 ;	test.c: 27: else                   PA_ODR &= ~(1 << 3);
      0080DE 9E               [ 1]  228 	ld	a, xh
      0080DF A4 F7            [ 1]  229 	and	a, #0xf7
      0080E1 C7 50 00         [ 1]  230 	ld	0x5000, a
      0080E4                        231 00107$:
                                    232 ;	test.c: 28: PA_ODR |= (1 << 1); PA_ODR &= ~(1 << 1);
      0080E4 72 12 50 00      [ 1]  233 	bset	0x5000, #1
      0080E8 72 13 50 00      [ 1]  234 	bres	0x5000, #1
                                    235 ;	test.c: 25: for (int8_t i = 7; i >= 0; i--) {
      0080EC 5A               [ 2]  236 	decw	x
      0080ED 20 BC            [ 2]  237 	jra	00113$
      0080EF                        238 00108$:
                                    239 ;	test.c: 32: PA_ODR |= (1 << 2);
      0080EF 9E               [ 1]  240 	ld	a, xh
      0080F0 AA 04            [ 1]  241 	or	a, #0x04
      0080F2 C7 50 00         [ 1]  242 	ld	0x5000, a
                                    243 ;	test.c: 33: PA_ODR &= ~(1 << 2);
      0080F5 72 15 50 00      [ 1]  244 	bres	0x5000, #2
                                    245 ;	test.c: 34: }
      0080F9 5B 07            [ 2]  246 	addw	sp, #7
      0080FB 85               [ 2]  247 	popw	x
      0080FC 84               [ 1]  248 	pop	a
      0080FD FC               [ 2]  249 	jp	(x)
                                    250 ;	test.c: 38: void main(void) {
                                    251 ;	-----------------------------------------
                                    252 ;	 function main
                                    253 ;	-----------------------------------------
      0080FE                        254 _main:
                                    255 ;	test.c: 39: shift_register_init();
      0080FE CD 80 47         [ 4]  256 	call	_shift_register_init
                                    257 ;	test.c: 41: while (1) {
      008101                        258 00102$:
                                    259 ;	test.c: 42: shift_register_send(0b11111111, 0b11101111); // Affiche "8" sur DS4
      008101 4B EF            [ 1]  260 	push	#0xef
      008103 A6 FF            [ 1]  261 	ld	a, #0xff
      008105 CD 80 60         [ 4]  262 	call	_shift_register_send
                                    263 ;	test.c: 43: delay_ms(2000);
      008108 AE 07 D0         [ 2]  264 	ldw	x, #0x07d0
      00810B CD 80 24         [ 4]  265 	call	_delay_ms
                                    266 ;	test.c: 44: shift_register_send(0b11111111, 0b11110111);
      00810E 4B F7            [ 1]  267 	push	#0xf7
      008110 A6 FF            [ 1]  268 	ld	a, #0xff
      008112 CD 80 60         [ 4]  269 	call	_shift_register_send
                                    270 ;	test.c: 45: delay_ms(2000);
      008115 AE 07 D0         [ 2]  271 	ldw	x, #0x07d0
      008118 CD 80 24         [ 4]  272 	call	_delay_ms
                                    273 ;	test.c: 46: shift_register_send(0b11111111, 0b11111011);
      00811B 4B FB            [ 1]  274 	push	#0xfb
      00811D A6 FF            [ 1]  275 	ld	a, #0xff
      00811F CD 80 60         [ 4]  276 	call	_shift_register_send
                                    277 ;	test.c: 47: delay_ms(2000);
      008122 AE 07 D0         [ 2]  278 	ldw	x, #0x07d0
      008125 CD 80 24         [ 4]  279 	call	_delay_ms
                                    280 ;	test.c: 48: shift_register_send(0b11111111, 0b11111101);
      008128 4B FD            [ 1]  281 	push	#0xfd
      00812A A6 FF            [ 1]  282 	ld	a, #0xff
      00812C CD 80 60         [ 4]  283 	call	_shift_register_send
                                    284 ;	test.c: 49: delay_ms(2000);
      00812F AE 07 D0         [ 2]  285 	ldw	x, #0x07d0
      008132 CD 80 24         [ 4]  286 	call	_delay_ms
      008135 20 CA            [ 2]  287 	jra	00102$
                                    288 ;	test.c: 52: }
      008137 81               [ 4]  289 	ret
                                    290 	.area CODE
                                    291 	.area CONST
                                    292 	.area INITIALIZER
                                    293 	.area CABS (ABS)
