                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module ADC
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _adc_init
                                     13 	.globl _adc_read
                                     14 	.globl _uart_read
                                     15 	.globl _uart_write
                                     16 	.globl _uart_config
                                     17 	.globl _printf
                                     18 	.globl _putchar
                                     19 ;--------------------------------------------------------
                                     20 ; ram data
                                     21 ;--------------------------------------------------------
                                     22 	.area DATA
                                     23 ;--------------------------------------------------------
                                     24 ; ram data
                                     25 ;--------------------------------------------------------
                                     26 	.area INITIALIZED
                                     27 ;--------------------------------------------------------
                                     28 ; Stack segment in internal ram
                                     29 ;--------------------------------------------------------
                                     30 	.area	SSEG
      000001                         31 __start__stack:
      000001                         32 	.ds	1
                                     33 
                                     34 ;--------------------------------------------------------
                                     35 ; absolute external ram data
                                     36 ;--------------------------------------------------------
                                     37 	.area DABS (ABS)
                                     38 
                                     39 ; default segment ordering for linker
                                     40 	.area HOME
                                     41 	.area GSINIT
                                     42 	.area GSFINAL
                                     43 	.area CONST
                                     44 	.area INITIALIZER
                                     45 	.area CODE
                                     46 
                                     47 ;--------------------------------------------------------
                                     48 ; interrupt vector
                                     49 ;--------------------------------------------------------
                                     50 	.area HOME
      008000                         51 __interrupt_vect:
      008000 82 00 80 07             52 	int s_GSINIT ; reset
                                     53 ;--------------------------------------------------------
                                     54 ; global & static initialisations
                                     55 ;--------------------------------------------------------
                                     56 	.area HOME
                                     57 	.area GSINIT
                                     58 	.area GSFINAL
                                     59 	.area GSINIT
      008007                         60 __sdcc_init_data:
                                     61 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   62 	ldw x, #l_DATA
      00800A 27 07            [ 1]   63 	jreq	00002$
      00800C                         64 00001$:
      00800C 72 4F 00 00      [ 1]   65 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   66 	decw x
      008011 26 F9            [ 1]   67 	jrne	00001$
      008013                         68 00002$:
      008013 AE 00 00         [ 2]   69 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   70 	jreq	00004$
      008018                         71 00003$:
      008018 D6 80 42         [ 1]   72 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   73 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   74 	decw	x
      00801F 26 F7            [ 1]   75 	jrne	00003$
      008021                         76 00004$:
                                     77 ; stm8_genXINIT() end
                                     78 	.area GSFINAL
      008021 CC 80 04         [ 2]   79 	jp	__sdcc_program_startup
                                     80 ;--------------------------------------------------------
                                     81 ; Home
                                     82 ;--------------------------------------------------------
                                     83 	.area HOME
                                     84 	.area HOME
      008004                         85 __sdcc_program_startup:
      008004 CC 81 24         [ 2]   86 	jp	_main
                                     87 ;	return from main will return to caller
                                     88 ;--------------------------------------------------------
                                     89 ; code
                                     90 ;--------------------------------------------------------
                                     91 	.area CODE
                                     92 ;	ADC.c: 6: void uart_config() {
                                     93 ;	-----------------------------------------
                                     94 ;	 function uart_config
                                     95 ;	-----------------------------------------
      008043                         96 _uart_config:
                                     97 ;	ADC.c: 7: CLK_CKDIVR = 0x00; // force 16 mhz 
      008043 35 00 50 C6      [ 1]   98 	mov	0x50c6+0, #0x00
                                     99 ;	ADC.c: 15: uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
      008047 A6 68            [ 1]  100 	ld	a, #0x68
      008049 97               [ 1]  101 	ld	xl, a
                                    102 ;	ADC.c: 16: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8
      00804A A6 83            [ 1]  103 	ld	a, #0x83
      00804C A4 0F            [ 1]  104 	and	a, #0x0f
                                    105 ;	ADC.c: 18: UART1_BRR1 = brr1;
      00804E 90 AE 52 32      [ 2]  106 	ldw	y, #0x5232
      008052 88               [ 1]  107 	push	a
      008053 9F               [ 1]  108 	ld	a, xl
      008054 90 F7            [ 1]  109 	ld	(y), a
      008056 84               [ 1]  110 	pop	a
                                    111 ;	ADC.c: 19: UART1_BRR2 = brr2;
      008057 C7 52 33         [ 1]  112 	ld	0x5233, a
                                    113 ;	ADC.c: 20: UART1_CR1 = 0x00;    // 8 data bits, no parity
      00805A 35 00 52 34      [ 1]  114 	mov	0x5234+0, #0x00
                                    115 ;	ADC.c: 21: UART1_CR3 = 0x00;    // 1 stop bit
      00805E 35 00 52 36      [ 1]  116 	mov	0x5236+0, #0x00
                                    117 ;	ADC.c: 22: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
      008062 35 0C 52 35      [ 1]  118 	mov	0x5235+0, #0x0c
                                    119 ;	ADC.c: 24: (void)UART1_SR;
      008066 C6 52 30         [ 1]  120 	ld	a, 0x5230
                                    121 ;	ADC.c: 25: (void)UART1_DR;
      008069 C6 52 31         [ 1]  122 	ld	a, 0x5231
                                    123 ;	ADC.c: 26: }
      00806C 81               [ 4]  124 	ret
                                    125 ;	ADC.c: 28: void uart_write(uint8_t data) {
                                    126 ;	-----------------------------------------
                                    127 ;	 function uart_write
                                    128 ;	-----------------------------------------
      00806D                        129 _uart_write:
                                    130 ;	ADC.c: 29: UART1_DR = data;
      00806D C7 52 31         [ 1]  131 	ld	0x5231, a
                                    132 ;	ADC.c: 30: PB_ODR &= ~(1 << 5);  // LED OFF
      008070 72 1B 50 05      [ 1]  133 	bres	0x5005, #5
                                    134 ;	ADC.c: 31: while (!(UART1_SR & (1 << UART1_SR_TC)));
      008074                        135 00101$:
      008074 72 0D 52 30 FB   [ 2]  136 	btjf	0x5230, #6, 00101$
                                    137 ;	ADC.c: 32: PB_ODR |= (1 << 5);   // LED ON
      008079 72 1A 50 05      [ 1]  138 	bset	0x5005, #5
                                    139 ;	ADC.c: 33: }
      00807D 81               [ 4]  140 	ret
                                    141 ;	ADC.c: 35: uint8_t uart_read() {
                                    142 ;	-----------------------------------------
                                    143 ;	 function uart_read
                                    144 ;	-----------------------------------------
      00807E                        145 _uart_read:
                                    146 ;	ADC.c: 36: while (!(UART1_SR & (1 << UART1_SR_RXNE)));
      00807E                        147 00101$:
      00807E 72 0B 52 30 FB   [ 2]  148 	btjf	0x5230, #5, 00101$
                                    149 ;	ADC.c: 37: return UART1_DR;
      008083 C6 52 31         [ 1]  150 	ld	a, 0x5231
                                    151 ;	ADC.c: 38: }
      008086 81               [ 4]  152 	ret
                                    153 ;	ADC.c: 40: int putchar(int c) {
                                    154 ;	-----------------------------------------
                                    155 ;	 function putchar
                                    156 ;	-----------------------------------------
      008087                        157 _putchar:
      008087 9F               [ 1]  158 	ld	a, xl
                                    159 ;	ADC.c: 41: uart_write(c);
      008088 CD 80 6D         [ 4]  160 	call	_uart_write
                                    161 ;	ADC.c: 42: return 0;
      00808B 5F               [ 1]  162 	clrw	x
                                    163 ;	ADC.c: 43: }
      00808C 81               [ 4]  164 	ret
                                    165 ;	ADC.c: 45: static inline void delay_ms(uint16_t ms) {
                                    166 ;	-----------------------------------------
                                    167 ;	 function delay_ms
                                    168 ;	-----------------------------------------
      00808D                        169 _delay_ms:
      00808D 52 0A            [ 2]  170 	sub	sp, #10
      00808F 1F 05            [ 2]  171 	ldw	(0x05, sp), x
                                    172 ;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008091 5F               [ 1]  173 	clrw	x
      008092 1F 09            [ 2]  174 	ldw	(0x09, sp), x
      008094 1F 07            [ 2]  175 	ldw	(0x07, sp), x
      008096                        176 00103$:
      008096 1E 05            [ 2]  177 	ldw	x, (0x05, sp)
      008098 89               [ 2]  178 	pushw	x
      008099 AE 03 78         [ 2]  179 	ldw	x, #0x0378
      00809C CD 81 75         [ 4]  180 	call	___muluint2ulong
      00809F 5B 02            [ 2]  181 	addw	sp, #2
      0080A1 1F 03            [ 2]  182 	ldw	(0x03, sp), x
      0080A3 17 01            [ 2]  183 	ldw	(0x01, sp), y
      0080A5 1E 09            [ 2]  184 	ldw	x, (0x09, sp)
      0080A7 13 03            [ 2]  185 	cpw	x, (0x03, sp)
      0080A9 7B 08            [ 1]  186 	ld	a, (0x08, sp)
      0080AB 12 02            [ 1]  187 	sbc	a, (0x02, sp)
      0080AD 7B 07            [ 1]  188 	ld	a, (0x07, sp)
      0080AF 12 01            [ 1]  189 	sbc	a, (0x01, sp)
      0080B1 24 0F            [ 1]  190 	jrnc	00105$
                                    191 ;	ADC.c: 48: __asm__("nop");
      0080B3 9D               [ 1]  192 	nop
                                    193 ;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080B4 1E 09            [ 2]  194 	ldw	x, (0x09, sp)
      0080B6 5C               [ 1]  195 	incw	x
      0080B7 1F 09            [ 2]  196 	ldw	(0x09, sp), x
      0080B9 26 DB            [ 1]  197 	jrne	00103$
      0080BB 1E 07            [ 2]  198 	ldw	x, (0x07, sp)
      0080BD 5C               [ 1]  199 	incw	x
      0080BE 1F 07            [ 2]  200 	ldw	(0x07, sp), x
      0080C0 20 D4            [ 2]  201 	jra	00103$
      0080C2                        202 00105$:
                                    203 ;	ADC.c: 49: }
      0080C2 5B 0A            [ 2]  204 	addw	sp, #10
      0080C4 81               [ 4]  205 	ret
                                    206 ;	ADC.c: 52: uint16_t adc_read(uint8_t channel) {
                                    207 ;	-----------------------------------------
                                    208 ;	 function adc_read
                                    209 ;	-----------------------------------------
      0080C5                        210 _adc_read:
      0080C5 52 04            [ 2]  211 	sub	sp, #4
                                    212 ;	ADC.c: 53: if (channel > 7) return 0; // Sanity check
      0080C7 97               [ 1]  213 	ld	xl, a
      0080C8 A1 07            [ 1]  214 	cp	a, #0x07
      0080CA 23 03            [ 2]  215 	jrule	00102$
      0080CC 5F               [ 1]  216 	clrw	x
      0080CD 20 2F            [ 2]  217 	jra	00106$
      0080CF                        218 00102$:
                                    219 ;	ADC.c: 56: ADC1_CSR = (ADC1_CSR & 0xF8) | (channel & 0x07);
      0080CF C6 54 00         [ 1]  220 	ld	a, 0x5400
      0080D2 A4 F8            [ 1]  221 	and	a, #0xf8
      0080D4 6B 04            [ 1]  222 	ld	(0x04, sp), a
      0080D6 9F               [ 1]  223 	ld	a, xl
      0080D7 A4 07            [ 1]  224 	and	a, #0x07
      0080D9 1A 04            [ 1]  225 	or	a, (0x04, sp)
      0080DB C7 54 00         [ 1]  226 	ld	0x5400, a
                                    227 ;	ADC.c: 59: ADC1_CR1 |= (1 << ADC1_CR1_ADON);
      0080DE 72 10 54 01      [ 1]  228 	bset	0x5401, #0
                                    229 ;	ADC.c: 62: while (!(ADC1_CSR & (1 << ADC1_CSR_EOC)));
      0080E2                        230 00103$:
      0080E2 C6 54 00         [ 1]  231 	ld	a, 0x5400
      0080E5 2A FB            [ 1]  232 	jrpl	00103$
                                    233 ;	ADC.c: 65: uint8_t adcL = ADC1_DRL;
      0080E7 C6 54 05         [ 1]  234 	ld	a, 0x5405
      0080EA 97               [ 1]  235 	ld	xl, a
                                    236 ;	ADC.c: 66: uint8_t adcH = ADC1_DRH;
      0080EB C6 54 04         [ 1]  237 	ld	a, 0x5404
      0080EE 95               [ 1]  238 	ld	xh, a
                                    239 ;	ADC.c: 69: ADC1_CSR &= ~(1 << ADC1_CSR_EOC);
      0080EF 72 1F 54 00      [ 1]  240 	bres	0x5400, #7
                                    241 ;	ADC.c: 71: return ((uint16_t)adcH << 8) | adcL;
      0080F3 0F 02            [ 1]  242 	clr	(0x02, sp)
      0080F5 9F               [ 1]  243 	ld	a, xl
      0080F6 0F 03            [ 1]  244 	clr	(0x03, sp)
      0080F8 1A 02            [ 1]  245 	or	a, (0x02, sp)
      0080FA 02               [ 1]  246 	rlwa	x
      0080FB 1A 03            [ 1]  247 	or	a, (0x03, sp)
      0080FD 95               [ 1]  248 	ld	xh, a
      0080FE                        249 00106$:
                                    250 ;	ADC.c: 72: }
      0080FE 5B 04            [ 2]  251 	addw	sp, #4
      008100 81               [ 4]  252 	ret
                                    253 ;	ADC.c: 74: void adc_init(uint8_t channel) {
                                    254 ;	-----------------------------------------
                                    255 ;	 function adc_init
                                    256 ;	-----------------------------------------
      008101                        257 _adc_init:
      008101 88               [ 1]  258 	push	a
                                    259 ;	ADC.c: 75: if (channel > 7) return; // Sanity check pour STM8S103
      008102 97               [ 1]  260 	ld	xl, a
      008103 A1 07            [ 1]  261 	cp	a, #0x07
      008105 22 1B            [ 1]  262 	jrugt	00103$
                                    263 ;	ADC.c: 77: CLK_PCKENR2 |= (1 << 3); // Activer horloge ADC1
      008107 72 16 50 CA      [ 1]  264 	bset	0x50ca, #3
                                    265 ;	ADC.c: 80: ADC1_CSR = (ADC1_CSR & 0xF8) | (channel & 0x07);
      00810B C6 54 00         [ 1]  266 	ld	a, 0x5400
      00810E A4 F8            [ 1]  267 	and	a, #0xf8
      008110 6B 01            [ 1]  268 	ld	(0x01, sp), a
      008112 9F               [ 1]  269 	ld	a, xl
      008113 A4 07            [ 1]  270 	and	a, #0x07
      008115 1A 01            [ 1]  271 	or	a, (0x01, sp)
      008117 C7 54 00         [ 1]  272 	ld	0x5400, a
                                    273 ;	ADC.c: 83: ADC1_CR2 |= (1 << ADC1_CR2_ALIGN);
      00811A 72 16 54 02      [ 1]  274 	bset	0x5402, #3
                                    275 ;	ADC.c: 86: ADC1_CR1 |= (1 << ADC1_CR1_ADON);
      00811E 72 10 54 01      [ 1]  276 	bset	0x5401, #0
      008122                        277 00103$:
                                    278 ;	ADC.c: 87: }
      008122 84               [ 1]  279 	pop	a
      008123 81               [ 4]  280 	ret
                                    281 ;	ADC.c: 90: void main() {
                                    282 ;	-----------------------------------------
                                    283 ;	 function main
                                    284 ;	-----------------------------------------
      008124                        285 _main:
      008124 52 02            [ 2]  286 	sub	sp, #2
                                    287 ;	ADC.c: 92: uart_config();   // UART pour debug série
      008126 CD 80 43         [ 4]  288 	call	_uart_config
                                    289 ;	ADC.c: 93: adc_init(4);      // Initialise ADC sur PD3 (ADC2)
      008129 A6 04            [ 1]  290 	ld	a, #0x04
      00812B CD 81 01         [ 4]  291 	call	_adc_init
                                    292 ;	ADC.c: 95: while (1) {
      00812E                        293 00102$:
                                    294 ;	ADC.c: 96: uint16_t value = adc_read(4);  // Lecture
      00812E A6 04            [ 1]  295 	ld	a, #0x04
      008130 CD 80 C5         [ 4]  296 	call	_adc_read
                                    297 ;	ADC.c: 97: uint16_t millivolts = (value * 5000UL) / 1023;
      008133 1F 01            [ 2]  298 	ldw	(0x01, sp), x
      008135 89               [ 2]  299 	pushw	x
      008136 AE 13 88         [ 2]  300 	ldw	x, #0x1388
      008139 CD 81 75         [ 4]  301 	call	___muluint2ulong
      00813C 5B 02            [ 2]  302 	addw	sp, #2
      00813E 4B FF            [ 1]  303 	push	#0xff
      008140 4B 03            [ 1]  304 	push	#0x03
      008142 4B 00            [ 1]  305 	push	#0x00
      008144 4B 00            [ 1]  306 	push	#0x00
      008146 89               [ 2]  307 	pushw	x
      008147 90 89            [ 2]  308 	pushw	y
      008149 CD 81 CC         [ 4]  309 	call	__divulong
      00814C 5B 08            [ 2]  310 	addw	sp, #8
                                    311 ;	ADC.c: 98: printf("ADC:%u,Voltage:%u\r\n", value, millivolts);
      00814E 89               [ 2]  312 	pushw	x
      00814F 1E 03            [ 2]  313 	ldw	x, (0x03, sp)
      008151 89               [ 2]  314 	pushw	x
      008152 4B 24            [ 1]  315 	push	#<(___str_0+0)
      008154 4B 80            [ 1]  316 	push	#((___str_0+0) >> 8)
      008156 CD 82 3D         [ 4]  317 	call	_printf
      008159 5B 06            [ 2]  318 	addw	sp, #6
                                    319 ;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00815B 90 5F            [ 1]  320 	clrw	y
      00815D 5F               [ 1]  321 	clrw	x
      00815E                        322 00107$:
      00815E 90 A3 53 20      [ 2]  323 	cpw	y, #0x5320
      008162 9F               [ 1]  324 	ld	a, xl
      008163 A2 14            [ 1]  325 	sbc	a, #0x14
      008165 9E               [ 1]  326 	ld	a, xh
      008166 A2 00            [ 1]  327 	sbc	a, #0x00
      008168 24 C4            [ 1]  328 	jrnc	00102$
                                    329 ;	ADC.c: 48: __asm__("nop");
      00816A 9D               [ 1]  330 	nop
                                    331 ;	ADC.c: 47: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00816B 90 5C            [ 1]  332 	incw	y
      00816D 26 EF            [ 1]  333 	jrne	00107$
      00816F 5C               [ 1]  334 	incw	x
      008170 20 EC            [ 2]  335 	jra	00107$
                                    336 ;	ADC.c: 99: delay_ms(1500); // mini delay
                                    337 ;	ADC.c: 101: }
      008172 5B 02            [ 2]  338 	addw	sp, #2
      008174 81               [ 4]  339 	ret
                                    340 	.area CODE
                                    341 	.area CONST
                                    342 	.area CONST
      008024                        343 ___str_0:
      008024 41 44 43 3A 25 75 2C   344 	.ascii "ADC:%u,Voltage:%u"
             56 6F 6C 74 61 67 65
             3A 25 75
      008035 0D                     345 	.db 0x0d
      008036 0A                     346 	.db 0x0a
      008037 00                     347 	.db 0x00
                                    348 	.area CODE
                                    349 	.area INITIALIZER
                                    350 	.area CABS (ABS)
