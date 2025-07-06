                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module ext_interrupt_deep_sleep
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _button_handler
                                     13 	.globl _uart_read
                                     14 	.globl _uart_write
                                     15 	.globl _uart_config
                                     16 	.globl _puts
                                     17 	.globl _wake_pending
                                     18 	.globl _last_press_time
                                     19 	.globl _putchar
                                     20 ;--------------------------------------------------------
                                     21 ; ram data
                                     22 ;--------------------------------------------------------
                                     23 	.area DATA
      000001                         24 _button_handler_now_65536_22:
      000001                         25 	.ds 4
                                     26 ;--------------------------------------------------------
                                     27 ; ram data
                                     28 ;--------------------------------------------------------
                                     29 	.area INITIALIZED
      000005                         30 _last_press_time::
      000005                         31 	.ds 4
      000009                         32 _wake_pending::
      000009                         33 	.ds 1
                                     34 ;--------------------------------------------------------
                                     35 ; Stack segment in internal ram
                                     36 ;--------------------------------------------------------
                                     37 	.area	SSEG
      00000A                         38 __start__stack:
      00000A                         39 	.ds	1
                                     40 
                                     41 ;--------------------------------------------------------
                                     42 ; absolute external ram data
                                     43 ;--------------------------------------------------------
                                     44 	.area DABS (ABS)
                                     45 
                                     46 ; default segment ordering for linker
                                     47 	.area HOME
                                     48 	.area GSINIT
                                     49 	.area GSFINAL
                                     50 	.area CONST
                                     51 	.area INITIALIZER
                                     52 	.area CODE
                                     53 
                                     54 ;--------------------------------------------------------
                                     55 ; interrupt vector
                                     56 ;--------------------------------------------------------
                                     57 	.area HOME
      008000                         58 __interrupt_vect:
      008000 82 00 80 1B             59 	int s_GSINIT ; reset
      008004 82 00 00 00             60 	int 0x000000 ; trap
      008008 82 00 00 00             61 	int 0x000000 ; int0
      00800C 82 00 00 00             62 	int 0x000000 ; int1
      008010 82 00 00 00             63 	int 0x000000 ; int2
      008014 82 00 80 EA             64 	int _button_handler ; int3
                                     65 ;--------------------------------------------------------
                                     66 ; global & static initialisations
                                     67 ;--------------------------------------------------------
                                     68 	.area HOME
                                     69 	.area GSINIT
                                     70 	.area GSFINAL
                                     71 	.area GSINIT
      00801B                         72 __sdcc_init_data:
                                     73 ; stm8_genXINIT() start
      00801B AE 00 04         [ 2]   74 	ldw x, #l_DATA
      00801E 27 07            [ 1]   75 	jreq	00002$
      008020                         76 00001$:
      008020 72 4F 00 00      [ 1]   77 	clr (s_DATA - 1, x)
      008024 5A               [ 2]   78 	decw x
      008025 26 F9            [ 1]   79 	jrne	00001$
      008027                         80 00002$:
      008027 AE 00 05         [ 2]   81 	ldw	x, #l_INITIALIZER
      00802A 27 09            [ 1]   82 	jreq	00004$
      00802C                         83 00003$:
      00802C D6 80 62         [ 1]   84 	ld	a, (s_INITIALIZER - 1, x)
      00802F D7 00 04         [ 1]   85 	ld	(s_INITIALIZED - 1, x), a
      008032 5A               [ 2]   86 	decw	x
      008033 26 F7            [ 1]   87 	jrne	00003$
      008035                         88 00004$:
                                     89 ; stm8_genXINIT() end
                                     90 ;	ext_interrupt_deep_sleep.c: 55: static uint32_t now = 0;
      008035 5F               [ 1]   91 	clrw	x
      008036 CF 00 03         [ 2]   92 	ldw	_button_handler_now_65536_22+2, x
      008039 CF 00 01         [ 2]   93 	ldw	_button_handler_now_65536_22+0, x
                                     94 	.area GSFINAL
      00803C CC 80 18         [ 2]   95 	jp	__sdcc_program_startup
                                     96 ;--------------------------------------------------------
                                     97 ; Home
                                     98 ;--------------------------------------------------------
                                     99 	.area HOME
                                    100 	.area HOME
      008018                        101 __sdcc_program_startup:
      008018 CC 81 3E         [ 2]  102 	jp	_main
                                    103 ;	return from main will return to caller
                                    104 ;--------------------------------------------------------
                                    105 ; code
                                    106 ;--------------------------------------------------------
                                    107 	.area CODE
                                    108 ;	ext_interrupt_deep_sleep.c: 9: void uart_config() {
                                    109 ;	-----------------------------------------
                                    110 ;	 function uart_config
                                    111 ;	-----------------------------------------
      008068                        112 _uart_config:
                                    113 ;	ext_interrupt_deep_sleep.c: 10: CLK_CKDIVR = 0x00; // force 16 mhz 
      008068 35 00 50 C6      [ 1]  114 	mov	0x50c6+0, #0x00
                                    115 ;	ext_interrupt_deep_sleep.c: 18: uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
      00806C A6 68            [ 1]  116 	ld	a, #0x68
      00806E 97               [ 1]  117 	ld	xl, a
                                    118 ;	ext_interrupt_deep_sleep.c: 19: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8
      00806F A6 83            [ 1]  119 	ld	a, #0x83
      008071 A4 0F            [ 1]  120 	and	a, #0x0f
                                    121 ;	ext_interrupt_deep_sleep.c: 21: UART1_BRR1 = brr1;
      008073 90 AE 52 32      [ 2]  122 	ldw	y, #0x5232
      008077 88               [ 1]  123 	push	a
      008078 9F               [ 1]  124 	ld	a, xl
      008079 90 F7            [ 1]  125 	ld	(y), a
      00807B 84               [ 1]  126 	pop	a
                                    127 ;	ext_interrupt_deep_sleep.c: 22: UART1_BRR2 = brr2;
      00807C C7 52 33         [ 1]  128 	ld	0x5233, a
                                    129 ;	ext_interrupt_deep_sleep.c: 23: UART1_CR1 = 0x00;    // 8 data bits, no parity
      00807F 35 00 52 34      [ 1]  130 	mov	0x5234+0, #0x00
                                    131 ;	ext_interrupt_deep_sleep.c: 24: UART1_CR3 = 0x00;    // 1 stop bit
      008083 35 00 52 36      [ 1]  132 	mov	0x5236+0, #0x00
                                    133 ;	ext_interrupt_deep_sleep.c: 25: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
      008087 35 0C 52 35      [ 1]  134 	mov	0x5235+0, #0x0c
                                    135 ;	ext_interrupt_deep_sleep.c: 27: (void)UART1_SR;
      00808B C6 52 30         [ 1]  136 	ld	a, 0x5230
                                    137 ;	ext_interrupt_deep_sleep.c: 28: (void)UART1_DR;
      00808E C6 52 31         [ 1]  138 	ld	a, 0x5231
                                    139 ;	ext_interrupt_deep_sleep.c: 29: }
      008091 81               [ 4]  140 	ret
                                    141 ;	ext_interrupt_deep_sleep.c: 31: void uart_write(uint8_t data) {
                                    142 ;	-----------------------------------------
                                    143 ;	 function uart_write
                                    144 ;	-----------------------------------------
      008092                        145 _uart_write:
                                    146 ;	ext_interrupt_deep_sleep.c: 32: UART1_DR = data;
      008092 C7 52 31         [ 1]  147 	ld	0x5231, a
                                    148 ;	ext_interrupt_deep_sleep.c: 33: PB_ODR &= ~(1 << 5);  // LED OFF
      008095 72 1B 50 05      [ 1]  149 	bres	0x5005, #5
                                    150 ;	ext_interrupt_deep_sleep.c: 34: while (!(UART1_SR & (1 << UART1_SR_TC)));
      008099                        151 00101$:
      008099 72 0D 52 30 FB   [ 2]  152 	btjf	0x5230, #6, 00101$
                                    153 ;	ext_interrupt_deep_sleep.c: 35: PB_ODR |= (1 << 5);   // LED ON
      00809E 72 1A 50 05      [ 1]  154 	bset	0x5005, #5
                                    155 ;	ext_interrupt_deep_sleep.c: 36: }
      0080A2 81               [ 4]  156 	ret
                                    157 ;	ext_interrupt_deep_sleep.c: 38: uint8_t uart_read() {
                                    158 ;	-----------------------------------------
                                    159 ;	 function uart_read
                                    160 ;	-----------------------------------------
      0080A3                        161 _uart_read:
                                    162 ;	ext_interrupt_deep_sleep.c: 39: while (!(UART1_SR & (1 << UART1_SR_RXNE)));
      0080A3                        163 00101$:
      0080A3 72 0B 52 30 FB   [ 2]  164 	btjf	0x5230, #5, 00101$
                                    165 ;	ext_interrupt_deep_sleep.c: 40: return UART1_DR;
      0080A8 C6 52 31         [ 1]  166 	ld	a, 0x5231
                                    167 ;	ext_interrupt_deep_sleep.c: 41: }
      0080AB 81               [ 4]  168 	ret
                                    169 ;	ext_interrupt_deep_sleep.c: 43: int putchar(int c) {
                                    170 ;	-----------------------------------------
                                    171 ;	 function putchar
                                    172 ;	-----------------------------------------
      0080AC                        173 _putchar:
      0080AC 9F               [ 1]  174 	ld	a, xl
                                    175 ;	ext_interrupt_deep_sleep.c: 44: uart_write(c);
      0080AD CD 80 92         [ 4]  176 	call	_uart_write
                                    177 ;	ext_interrupt_deep_sleep.c: 45: return 0;
      0080B0 5F               [ 1]  178 	clrw	x
                                    179 ;	ext_interrupt_deep_sleep.c: 46: }
      0080B1 81               [ 4]  180 	ret
                                    181 ;	ext_interrupt_deep_sleep.c: 48: static inline void delay_ms(uint16_t ms) {
                                    182 ;	-----------------------------------------
                                    183 ;	 function delay_ms
                                    184 ;	-----------------------------------------
      0080B2                        185 _delay_ms:
      0080B2 52 0A            [ 2]  186 	sub	sp, #10
      0080B4 1F 05            [ 2]  187 	ldw	(0x05, sp), x
                                    188 ;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080B6 5F               [ 1]  189 	clrw	x
      0080B7 1F 09            [ 2]  190 	ldw	(0x09, sp), x
      0080B9 1F 07            [ 2]  191 	ldw	(0x07, sp), x
      0080BB                        192 00103$:
      0080BB 1E 05            [ 2]  193 	ldw	x, (0x05, sp)
      0080BD 89               [ 2]  194 	pushw	x
      0080BE AE 03 78         [ 2]  195 	ldw	x, #0x0378
      0080C1 CD 81 C2         [ 4]  196 	call	___muluint2ulong
      0080C4 5B 02            [ 2]  197 	addw	sp, #2
      0080C6 1F 03            [ 2]  198 	ldw	(0x03, sp), x
      0080C8 17 01            [ 2]  199 	ldw	(0x01, sp), y
      0080CA 1E 09            [ 2]  200 	ldw	x, (0x09, sp)
      0080CC 13 03            [ 2]  201 	cpw	x, (0x03, sp)
      0080CE 7B 08            [ 1]  202 	ld	a, (0x08, sp)
      0080D0 12 02            [ 1]  203 	sbc	a, (0x02, sp)
      0080D2 7B 07            [ 1]  204 	ld	a, (0x07, sp)
      0080D4 12 01            [ 1]  205 	sbc	a, (0x01, sp)
      0080D6 24 0F            [ 1]  206 	jrnc	00105$
                                    207 ;	ext_interrupt_deep_sleep.c: 51: __asm__("nop");
      0080D8 9D               [ 1]  208 	nop
                                    209 ;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080D9 1E 09            [ 2]  210 	ldw	x, (0x09, sp)
      0080DB 5C               [ 1]  211 	incw	x
      0080DC 1F 09            [ 2]  212 	ldw	(0x09, sp), x
      0080DE 26 DB            [ 1]  213 	jrne	00103$
      0080E0 1E 07            [ 2]  214 	ldw	x, (0x07, sp)
      0080E2 5C               [ 1]  215 	incw	x
      0080E3 1F 07            [ 2]  216 	ldw	(0x07, sp), x
      0080E5 20 D4            [ 2]  217 	jra	00103$
      0080E7                        218 00105$:
                                    219 ;	ext_interrupt_deep_sleep.c: 52: }
      0080E7 5B 0A            [ 2]  220 	addw	sp, #10
      0080E9 81               [ 4]  221 	ret
                                    222 ;	ext_interrupt_deep_sleep.c: 54: void button_handler(void) __interrupt(3) {
                                    223 ;	-----------------------------------------
                                    224 ;	 function button_handler
                                    225 ;	-----------------------------------------
      0080EA                        226 _button_handler:
      0080EA 52 04            [ 2]  227 	sub	sp, #4
                                    228 ;	ext_interrupt_deep_sleep.c: 56: now += 1;  // Incrémente à chaque IT, ou via timer en fond si dispo
      0080EC CE 00 03         [ 2]  229 	ldw	x, _button_handler_now_65536_22+2
      0080EF 1C 00 01         [ 2]  230 	addw	x, #0x0001
      0080F2 90 CE 00 01      [ 2]  231 	ldw	y, _button_handler_now_65536_22+0
      0080F6 24 02            [ 1]  232 	jrnc	00117$
      0080F8 90 5C            [ 1]  233 	incw	y
      0080FA                        234 00117$:
      0080FA CF 00 03         [ 2]  235 	ldw	_button_handler_now_65536_22+2, x
      0080FD 90 CF 00 01      [ 2]  236 	ldw	_button_handler_now_65536_22+0, y
                                    237 ;	ext_interrupt_deep_sleep.c: 57: if ((now - last_press_time) > 1) {  // 1 "ticks" d'écart
      008101 CE 00 03         [ 2]  238 	ldw	x, _button_handler_now_65536_22+2
      008104 72 B0 00 07      [ 2]  239 	subw	x, _last_press_time+2
      008108 1F 03            [ 2]  240 	ldw	(0x03, sp), x
      00810A C6 00 02         [ 1]  241 	ld	a, _button_handler_now_65536_22+1
      00810D C2 00 06         [ 1]  242 	sbc	a, _last_press_time+1
      008110 6B 02            [ 1]  243 	ld	(0x02, sp), a
      008112 C6 00 01         [ 1]  244 	ld	a, _button_handler_now_65536_22+0
      008115 C2 00 05         [ 1]  245 	sbc	a, _last_press_time+0
      008118 6B 01            [ 1]  246 	ld	(0x01, sp), a
      00811A 5F               [ 1]  247 	clrw	x
      00811B 5C               [ 1]  248 	incw	x
      00811C 13 03            [ 2]  249 	cpw	x, (0x03, sp)
      00811E 4F               [ 1]  250 	clr	a
      00811F 12 02            [ 1]  251 	sbc	a, (0x02, sp)
      008121 4F               [ 1]  252 	clr	a
      008122 12 01            [ 1]  253 	sbc	a, (0x01, sp)
      008124 24 15            [ 1]  254 	jrnc	00105$
                                    255 ;	ext_interrupt_deep_sleep.c: 58: if (!(PA_IDR & (1 << 3))) {
      008126 72 06 50 01 10   [ 2]  256 	btjt	0x5001, #3, 00105$
                                    257 ;	ext_interrupt_deep_sleep.c: 59: wake_pending = 1;  // Juste un flag de réveil
      00812B 35 01 00 09      [ 1]  258 	mov	_wake_pending+0, #0x01
                                    259 ;	ext_interrupt_deep_sleep.c: 60: last_press_time = now;
      00812F CE 00 03         [ 2]  260 	ldw	x, _button_handler_now_65536_22+2
      008132 CF 00 07         [ 2]  261 	ldw	_last_press_time+2, x
      008135 CE 00 01         [ 2]  262 	ldw	x, _button_handler_now_65536_22+0
      008138 CF 00 05         [ 2]  263 	ldw	_last_press_time+0, x
      00813B                        264 00105$:
                                    265 ;	ext_interrupt_deep_sleep.c: 63: }
      00813B 5B 04            [ 2]  266 	addw	sp, #4
      00813D 80               [11]  267 	iret
                                    268 ;	ext_interrupt_deep_sleep.c: 65: void main() {
                                    269 ;	-----------------------------------------
                                    270 ;	 function main
                                    271 ;	-----------------------------------------
      00813E                        272 _main:
                                    273 ;	ext_interrupt_deep_sleep.c: 67: uart_config();
      00813E CD 80 68         [ 4]  274 	call	_uart_config
                                    275 ;	ext_interrupt_deep_sleep.c: 69: PD_DDR |= (1 << 3);
      008141 72 16 50 11      [ 1]  276 	bset	0x5011, #3
                                    277 ;	ext_interrupt_deep_sleep.c: 70: PD_CR1 |= (1 << 3);
      008145 72 16 50 12      [ 1]  278 	bset	0x5012, #3
                                    279 ;	ext_interrupt_deep_sleep.c: 71: PD_ODR &= ~(1 << 3);  // LED éteinte
      008149 72 17 50 0F      [ 1]  280 	bres	0x500f, #3
                                    281 ;	ext_interrupt_deep_sleep.c: 74: PA_DDR &= ~(1 << 3);   // Entrée
      00814D 72 17 50 02      [ 1]  282 	bres	0x5002, #3
                                    283 ;	ext_interrupt_deep_sleep.c: 75: PA_CR1 |= (1 << 3);    // Pull-up
      008151 72 16 50 03      [ 1]  284 	bset	0x5003, #3
                                    285 ;	ext_interrupt_deep_sleep.c: 76: PA_CR2 |= (1 << 3);    // Active interruption pour PA3
      008155 C6 50 04         [ 1]  286 	ld	a, 0x5004
      008158 AA 08            [ 1]  287 	or	a, #0x08
      00815A C7 50 04         [ 1]  288 	ld	0x5004, a
                                    289 ;	ext_interrupt_deep_sleep.c: 79: EXTI_CR1 &= ~(0b11 << 0);   // Efface les bits PAIS[1:0]
      00815D C6 50 A0         [ 1]  290 	ld	a, 0x50a0
      008160 A4 FC            [ 1]  291 	and	a, #0xfc
      008162 C7 50 A0         [ 1]  292 	ld	0x50a0, a
                                    293 ;	ext_interrupt_deep_sleep.c: 80: EXTI_CR1 |=  (0b10 << 0);   // Met 10 = front descendant
      008165 C6 50 A0         [ 1]  294 	ld	a, 0x50a0
      008168 AA 02            [ 1]  295 	or	a, #0x02
      00816A C7 50 A0         [ 1]  296 	ld	0x50a0, a
                                    297 ;	ext_interrupt_deep_sleep.c: 82: __asm__("rim");  // autorise les interruptions
      00816D 9A               [ 1]  298 	rim
                                    299 ;	ext_interrupt_deep_sleep.c: 84: while (1) {
      00816E                        300 00104$:
                                    301 ;	ext_interrupt_deep_sleep.c: 85: __asm__("halt");  // Va en sommeil
      00816E 8E               [10]  302 	halt
                                    303 ;	ext_interrupt_deep_sleep.c: 87: if (wake_pending) {
      00816F 72 5D 00 09      [ 1]  304 	tnz	_wake_pending+0
      008173 27 F9            [ 1]  305 	jreq	00104$
                                    306 ;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008175 90 5F            [ 1]  307 	clrw	y
      008177 5F               [ 1]  308 	clrw	x
      008178                        309 00111$:
      008178 90 A3 11 58      [ 2]  310 	cpw	y, #0x1158
      00817C 9F               [ 1]  311 	ld	a, xl
      00817D A2 00            [ 1]  312 	sbc	a, #0x00
      00817F 9E               [ 1]  313 	ld	a, xh
      008180 A2 00            [ 1]  314 	sbc	a, #0x00
      008182 24 08            [ 1]  315 	jrnc	00107$
                                    316 ;	ext_interrupt_deep_sleep.c: 51: __asm__("nop");
      008184 9D               [ 1]  317 	nop
                                    318 ;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008185 90 5C            [ 1]  319 	incw	y
      008187 26 EF            [ 1]  320 	jrne	00111$
      008189 5C               [ 1]  321 	incw	x
      00818A 20 EC            [ 2]  322 	jra	00111$
                                    323 ;	ext_interrupt_deep_sleep.c: 88: delay_ms(5); // timer pour un filtre anti rebond
      00818C                        324 00107$:
                                    325 ;	ext_interrupt_deep_sleep.c: 89: wake_pending = 0;
      00818C 72 5F 00 09      [ 1]  326 	clr	_wake_pending+0
                                    327 ;	ext_interrupt_deep_sleep.c: 90: PD_ODR |= (1 << 3);  
      008190 72 16 50 0F      [ 1]  328 	bset	0x500f, #3
                                    329 ;	ext_interrupt_deep_sleep.c: 91: printf("Réveillé !\r\n");
      008194 AE 80 3F         [ 2]  330 	ldw	x, #(___str_1+0)
      008197 CD 82 19         [ 4]  331 	call	_puts
                                    332 ;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00819A 90 5F            [ 1]  333 	clrw	y
      00819C 5F               [ 1]  334 	clrw	x
      00819D                        335 00114$:
      00819D 90 A3 AD 70      [ 2]  336 	cpw	y, #0xad70
      0081A1 9F               [ 1]  337 	ld	a, xl
      0081A2 A2 00            [ 1]  338 	sbc	a, #0x00
      0081A4 9E               [ 1]  339 	ld	a, xh
      0081A5 A2 00            [ 1]  340 	sbc	a, #0x00
      0081A7 24 08            [ 1]  341 	jrnc	00109$
                                    342 ;	ext_interrupt_deep_sleep.c: 51: __asm__("nop");
      0081A9 9D               [ 1]  343 	nop
                                    344 ;	ext_interrupt_deep_sleep.c: 50: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0081AA 90 5C            [ 1]  345 	incw	y
      0081AC 26 EF            [ 1]  346 	jrne	00114$
      0081AE 5C               [ 1]  347 	incw	x
      0081AF 20 EC            [ 2]  348 	jra	00114$
                                    349 ;	ext_interrupt_deep_sleep.c: 92: delay_ms(50);
      0081B1                        350 00109$:
                                    351 ;	ext_interrupt_deep_sleep.c: 93: printf("ZZZzzzzzZZZZZzzzzZZZ\r\n");
      0081B1 AE 80 4D         [ 2]  352 	ldw	x, #(___str_3+0)
      0081B4 CD 82 19         [ 4]  353 	call	_puts
                                    354 ;	ext_interrupt_deep_sleep.c: 94: PD_ODR &= ~(1 << 3);
      0081B7 C6 50 0F         [ 1]  355 	ld	a, 0x500f
      0081BA A4 F7            [ 1]  356 	and	a, #0xf7
      0081BC C7 50 0F         [ 1]  357 	ld	0x500f, a
      0081BF 20 AD            [ 2]  358 	jra	00104$
                                    359 ;	ext_interrupt_deep_sleep.c: 98: }
      0081C1 81               [ 4]  360 	ret
                                    361 	.area CODE
                                    362 	.area CONST
                                    363 	.area CONST
      00803F                        364 ___str_1:
      00803F 52                     365 	.ascii "R"
      008040 C3                     366 	.db 0xc3
      008041 A9                     367 	.db 0xa9
      008042 76 65 69 6C 6C         368 	.ascii "veill"
      008047 C3                     369 	.db 0xc3
      008048 A9                     370 	.db 0xa9
      008049 20 21                  371 	.ascii " !"
      00804B 0D                     372 	.db 0x0d
      00804C 00                     373 	.db 0x00
                                    374 	.area CODE
                                    375 	.area CONST
      00804D                        376 ___str_3:
      00804D 5A 5A 5A 7A 7A 7A 7A   377 	.ascii "ZZZzzzzzZZZZZzzzzZZZ"
             7A 5A 5A 5A 5A 5A 7A
             7A 7A 7A 5A 5A 5A
      008061 0D                     378 	.db 0x0d
      008062 00                     379 	.db 0x00
                                    380 	.area CODE
                                    381 	.area INITIALIZER
      008063                        382 __xinit__last_press_time:
      008063 00 00 00 00            383 	.byte #0x00, #0x00, #0x00, #0x00	; 0
      008067                        384 __xinit__wake_pending:
      008067 00                     385 	.db #0x00	; 0
                                    386 	.area CABS (ABS)
