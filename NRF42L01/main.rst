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
                                     12 	.globl _puts
                                     13 	.globl _printf
                                     14 	.globl _putchar
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
      008018 D6 82 2D         [ 1]   68 	ld	a, (s_INITIALIZER - 1, x)
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
      008004 CC 88 BC         [ 2]   82 	jp	_main
                                     83 ;	return from main will return to caller
                                     84 ;--------------------------------------------------------
                                     85 ; code
                                     86 ;--------------------------------------------------------
                                     87 	.area CODE
                                     88 ;	main.c: 19: static inline void uart_config(void) {
                                     89 ;	-----------------------------------------
                                     90 ;	 function uart_config
                                     91 ;	-----------------------------------------
      00822E                         92 _uart_config:
                                     93 ;	main.c: 20: CLK_CKDIVR = 0x00; // 16 MHz
      00822E 35 00 50 C6      [ 1]   94 	mov	0x50c6+0, #0x00
                                     95 ;	main.c: 22: UART1_BRR1 = (usartdiv >> 4) & 0xFF;
      008232 A6 68            [ 1]   96 	ld	a, #0x68
      008234 C7 52 32         [ 1]   97 	ld	0x5232, a
                                     98 ;	main.c: 23: UART1_BRR2 = ((usartdiv & 0x0F) | ((usartdiv >> 8) & 0xF0));
      008237 A6 83            [ 1]   99 	ld	a, #0x83
      008239 A4 0F            [ 1]  100 	and	a, #0x0f
      00823B C7 52 33         [ 1]  101 	ld	0x5233, a
                                    102 ;	main.c: 24: UART1_CR1 = 0x00;
      00823E 35 00 52 34      [ 1]  103 	mov	0x5234+0, #0x00
                                    104 ;	main.c: 25: UART1_CR3 = 0x00;
      008242 35 00 52 36      [ 1]  105 	mov	0x5236+0, #0x00
                                    106 ;	main.c: 26: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
      008246 35 0C 52 35      [ 1]  107 	mov	0x5235+0, #0x0c
                                    108 ;	main.c: 27: (void)UART1_SR; (void)UART1_DR;
      00824A C6 52 30         [ 1]  109 	ld	a, 0x5230
      00824D C6 52 31         [ 1]  110 	ld	a, 0x5231
                                    111 ;	main.c: 28: }
      008250 81               [ 4]  112 	ret
                                    113 ;	main.c: 29: static inline void uart_write(uint8_t b){ UART1_DR=b; while(!(UART1_SR&(1<<UART1_SR_TC))); }
                                    114 ;	-----------------------------------------
                                    115 ;	 function uart_write
                                    116 ;	-----------------------------------------
      008251                        117 _uart_write:
      008251 C7 52 31         [ 1]  118 	ld	0x5231, a
      008254                        119 00101$:
      008254 72 0D 52 30 FB   [ 2]  120 	btjf	0x5230, #6, 00101$
      008259 81               [ 4]  121 	ret
                                    122 ;	main.c: 30: int putchar(int c){ uart_write((uint8_t)c); return 0; }
                                    123 ;	-----------------------------------------
                                    124 ;	 function putchar
                                    125 ;	-----------------------------------------
      00825A                        126 _putchar:
      00825A 9F               [ 1]  127 	ld	a, xl
                                    128 ;	main.c: 29: static inline void uart_write(uint8_t b){ UART1_DR=b; while(!(UART1_SR&(1<<UART1_SR_TC))); }
      00825B C7 52 31         [ 1]  129 	ld	0x5231, a
      00825E                        130 00101$:
      00825E 72 0D 52 30 FB   [ 2]  131 	btjf	0x5230, #6, 00101$
                                    132 ;	main.c: 30: int putchar(int c){ uart_write((uint8_t)c); return 0; }
      008263 5F               [ 1]  133 	clrw	x
      008264 81               [ 4]  134 	ret
                                    135 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
                                    136 ;	-----------------------------------------
                                    137 ;	 function delay_cycles
                                    138 ;	-----------------------------------------
      008265                        139 _delay_cycles:
      008265 52 02            [ 2]  140 	sub	sp, #2
      008267 1F 01            [ 2]  141 	ldw	(0x01, sp), x
      008269                        142 00101$:
      008269 16 01            [ 2]  143 	ldw	y, (0x01, sp)
      00826B 93               [ 1]  144 	ldw	x, y
      00826C 5A               [ 2]  145 	decw	x
      00826D 1F 01            [ 2]  146 	ldw	(0x01, sp), x
      00826F 90 5D            [ 2]  147 	tnzw	y
      008271 27 03            [ 1]  148 	jreq	00104$
      008273 9D               [ 1]  149 	nop
      008274 20 F3            [ 2]  150 	jra	00101$
      008276                        151 00104$:
      008276 5B 02            [ 2]  152 	addw	sp, #2
      008278 81               [ 4]  153 	ret
                                    154 ;	main.c: 33: static inline void delay_ms(uint16_t ms){
                                    155 ;	-----------------------------------------
                                    156 ;	 function delay_ms
                                    157 ;	-----------------------------------------
      008279                        158 _delay_ms:
      008279 52 0A            [ 2]  159 	sub	sp, #10
      00827B 1F 05            [ 2]  160 	ldw	(0x05, sp), x
                                    161 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      00827D 5F               [ 1]  162 	clrw	x
      00827E 1F 09            [ 2]  163 	ldw	(0x09, sp), x
      008280 1F 07            [ 2]  164 	ldw	(0x07, sp), x
      008282                        165 00103$:
      008282 1E 05            [ 2]  166 	ldw	x, (0x05, sp)
      008284 89               [ 2]  167 	pushw	x
      008285 AE 03 78         [ 2]  168 	ldw	x, #0x0378
      008288 CD 89 09         [ 4]  169 	call	___muluint2ulong
      00828B 5B 02            [ 2]  170 	addw	sp, #2
      00828D 1F 03            [ 2]  171 	ldw	(0x03, sp), x
      00828F 17 01            [ 2]  172 	ldw	(0x01, sp), y
      008291 1E 09            [ 2]  173 	ldw	x, (0x09, sp)
      008293 13 03            [ 2]  174 	cpw	x, (0x03, sp)
      008295 7B 08            [ 1]  175 	ld	a, (0x08, sp)
      008297 12 02            [ 1]  176 	sbc	a, (0x02, sp)
      008299 7B 07            [ 1]  177 	ld	a, (0x07, sp)
      00829B 12 01            [ 1]  178 	sbc	a, (0x01, sp)
      00829D 24 0F            [ 1]  179 	jrnc	00105$
      00829F 9D               [ 1]  180 	nop
      0082A0 1E 09            [ 2]  181 	ldw	x, (0x09, sp)
      0082A2 5C               [ 1]  182 	incw	x
      0082A3 1F 09            [ 2]  183 	ldw	(0x09, sp), x
      0082A5 26 DB            [ 1]  184 	jrne	00103$
      0082A7 1E 07            [ 2]  185 	ldw	x, (0x07, sp)
      0082A9 5C               [ 1]  186 	incw	x
      0082AA 1F 07            [ 2]  187 	ldw	(0x07, sp), x
      0082AC 20 D4            [ 2]  188 	jra	00103$
      0082AE                        189 00105$:
                                    190 ;	main.c: 35: }
      0082AE 5B 0A            [ 2]  191 	addw	sp, #10
      0082B0 81               [ 4]  192 	ret
                                    193 ;	main.c: 85: static void gpio_init_spi(void){
                                    194 ;	-----------------------------------------
                                    195 ;	 function gpio_init_spi
                                    196 ;	-----------------------------------------
      0082B1                        197 _gpio_init_spi:
                                    198 ;	main.c: 87: PC_DDR |= (1<<5)|(1<<6); PC_CR1 |= (1<<5)|(1<<6);
      0082B1 C6 50 0C         [ 1]  199 	ld	a, 0x500c
      0082B4 AA 60            [ 1]  200 	or	a, #0x60
      0082B6 C7 50 0C         [ 1]  201 	ld	0x500c, a
      0082B9 C6 50 0D         [ 1]  202 	ld	a, 0x500d
      0082BC AA 60            [ 1]  203 	or	a, #0x60
      0082BE C7 50 0D         [ 1]  204 	ld	0x500d, a
                                    205 ;	main.c: 89: PC_DDR &= (uint8_t)~(1<<7); PC_CR1 &= (uint8_t)~(1<<7);
      0082C1 72 1F 50 0C      [ 1]  206 	bres	0x500c, #7
      0082C5 72 1F 50 0D      [ 1]  207 	bres	0x500d, #7
                                    208 ;	main.c: 91: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
      0082C9 72 14 50 11      [ 1]  209 	bset	0x5011, #2
      0082CD 72 14 50 12      [ 1]  210 	bset	0x5012, #2
      0082D1 72 14 50 0F      [ 1]  211 	bset	0x500f, #2
                                    212 ;	main.c: 93: PD_DDR |= (1<<4); PD_CR1 |= (1<<4); CE_LOW();
      0082D5 72 18 50 11      [ 1]  213 	bset	0x5011, #4
      0082D9 72 18 50 12      [ 1]  214 	bset	0x5012, #4
      0082DD 72 19 50 0F      [ 1]  215 	bres	0x500f, #4
                                    216 ;	main.c: 94: }
      0082E1 81               [ 4]  217 	ret
                                    218 ;	main.c: 97: static void spi_init(void){
                                    219 ;	-----------------------------------------
                                    220 ;	 function spi_init
                                    221 ;	-----------------------------------------
      0082E2                        222 _spi_init:
                                    223 ;	main.c: 98: SPI_CR1 = BIT(SPI_CR1_MSTR) | BIT(SPI_CR1_BR2);   /* /64 */
      0082E2 35 24 52 00      [ 1]  224 	mov	0x5200+0, #0x24
                                    225 ;	main.c: 99: SPI_CR2 = BIT(SPI_CR2_SSM)  | BIT(SPI_CR2_SSI);
      0082E6 35 03 52 01      [ 1]  226 	mov	0x5201+0, #0x03
                                    227 ;	main.c: 100: SPI_CR1 |= BIT(SPI_CR1_SPE);
      0082EA 72 1C 52 00      [ 1]  228 	bset	0x5200, #6
                                    229 ;	main.c: 101: }
      0082EE 81               [ 4]  230 	ret
                                    231 ;	main.c: 102: static uint8_t spi_txrx(uint8_t v){
                                    232 ;	-----------------------------------------
                                    233 ;	 function spi_txrx
                                    234 ;	-----------------------------------------
      0082EF                        235 _spi_txrx:
                                    236 ;	main.c: 103: SPI_DR = v;
      0082EF C7 52 04         [ 1]  237 	ld	0x5204, a
                                    238 ;	main.c: 104: while(!(SPI_SR & BIT(SPI_SR_TXE)));
      0082F2                        239 00101$:
      0082F2 72 03 52 03 FB   [ 2]  240 	btjf	0x5203, #1, 00101$
                                    241 ;	main.c: 105: while(!(SPI_SR & BIT(SPI_SR_RXNE)));
      0082F7                        242 00104$:
      0082F7 72 01 52 03 FB   [ 2]  243 	btjf	0x5203, #0, 00104$
                                    244 ;	main.c: 106: return SPI_DR;
      0082FC C6 52 04         [ 1]  245 	ld	a, 0x5204
                                    246 ;	main.c: 107: }
      0082FF 81               [ 4]  247 	ret
                                    248 ;	main.c: 108: static void spi_wait_idle(void){ while(SPI_SR & BIT(SPI_SR_BSY)); }
                                    249 ;	-----------------------------------------
                                    250 ;	 function spi_wait_idle
                                    251 ;	-----------------------------------------
      008300                        252 _spi_wait_idle:
      008300                        253 00101$:
      008300 C6 52 03         [ 1]  254 	ld	a, 0x5203
      008303 2B FB            [ 1]  255 	jrmi	00101$
      008305 81               [ 4]  256 	ret
                                    257 ;	main.c: 111: static uint8_t nrf_read_reg(uint8_t reg){
                                    258 ;	-----------------------------------------
                                    259 ;	 function nrf_read_reg
                                    260 ;	-----------------------------------------
      008306                        261 _nrf_read_reg:
      008306 52 04            [ 2]  262 	sub	sp, #4
      008308 6B 04            [ 1]  263 	ld	(0x04, sp), a
                                    264 ;	main.c: 113: CSN_LOW(); delay_cycles(50);
      00830A C6 50 0F         [ 1]  265 	ld	a, 0x500f
      00830D A4 FB            [ 1]  266 	and	a, #0xfb
      00830F C7 50 0F         [ 1]  267 	ld	0x500f, a
      008312 AE 00 32         [ 2]  268 	ldw	x, #0x0032
      008315 1F 01            [ 2]  269 	ldw	(0x01, sp), x
                                    270 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      008317                        271 00101$:
      008317 16 01            [ 2]  272 	ldw	y, (0x01, sp)
      008319 93               [ 1]  273 	ldw	x, y
      00831A 5A               [ 2]  274 	decw	x
      00831B 1F 01            [ 2]  275 	ldw	(0x01, sp), x
      00831D 90 5D            [ 2]  276 	tnzw	y
      00831F 27 03            [ 1]  277 	jreq	00104$
      008321 9D               [ 1]  278 	nop
      008322 20 F3            [ 2]  279 	jra	00101$
                                    280 ;	main.c: 113: CSN_LOW(); delay_cycles(50);
      008324                        281 00104$:
                                    282 ;	main.c: 114: (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
      008324 7B 04            [ 1]  283 	ld	a, (0x04, sp)
      008326 A4 1F            [ 1]  284 	and	a, #0x1f
      008328 CD 82 EF         [ 4]  285 	call	_spi_txrx
                                    286 ;	main.c: 115: v = spi_txrx(0xFF);
      00832B A6 FF            [ 1]  287 	ld	a, #0xff
      00832D CD 82 EF         [ 4]  288 	call	_spi_txrx
      008330 6B 03            [ 1]  289 	ld	(0x03, sp), a
                                    290 ;	main.c: 116: spi_wait_idle(); delay_cycles(50);
      008332 CD 83 00         [ 4]  291 	call	_spi_wait_idle
      008335 AE 00 32         [ 2]  292 	ldw	x, #0x0032
      008338 1F 01            [ 2]  293 	ldw	(0x01, sp), x
                                    294 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      00833A                        295 00105$:
      00833A 16 01            [ 2]  296 	ldw	y, (0x01, sp)
      00833C 93               [ 1]  297 	ldw	x, y
      00833D 5A               [ 2]  298 	decw	x
      00833E 1F 01            [ 2]  299 	ldw	(0x01, sp), x
      008340 90 5D            [ 2]  300 	tnzw	y
      008342 27 03            [ 1]  301 	jreq	00108$
      008344 9D               [ 1]  302 	nop
      008345 20 F3            [ 2]  303 	jra	00105$
                                    304 ;	main.c: 116: spi_wait_idle(); delay_cycles(50);
      008347                        305 00108$:
                                    306 ;	main.c: 117: CSN_HIGH();
      008347 72 14 50 0F      [ 1]  307 	bset	0x500f, #2
                                    308 ;	main.c: 118: return v;
      00834B 7B 03            [ 1]  309 	ld	a, (0x03, sp)
                                    310 ;	main.c: 119: }
      00834D 5B 04            [ 2]  311 	addw	sp, #4
      00834F 81               [ 4]  312 	ret
                                    313 ;	main.c: 120: static void nrf_write_reg(uint8_t reg, uint8_t val){
                                    314 ;	-----------------------------------------
                                    315 ;	 function nrf_write_reg
                                    316 ;	-----------------------------------------
      008350                        317 _nrf_write_reg:
      008350 52 03            [ 2]  318 	sub	sp, #3
      008352 6B 03            [ 1]  319 	ld	(0x03, sp), a
                                    320 ;	main.c: 121: CSN_LOW(); delay_cycles(50);
      008354 C6 50 0F         [ 1]  321 	ld	a, 0x500f
      008357 A4 FB            [ 1]  322 	and	a, #0xfb
      008359 C7 50 0F         [ 1]  323 	ld	0x500f, a
      00835C AE 00 32         [ 2]  324 	ldw	x, #0x0032
      00835F 1F 01            [ 2]  325 	ldw	(0x01, sp), x
                                    326 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      008361                        327 00101$:
      008361 16 01            [ 2]  328 	ldw	y, (0x01, sp)
      008363 93               [ 1]  329 	ldw	x, y
      008364 5A               [ 2]  330 	decw	x
      008365 1F 01            [ 2]  331 	ldw	(0x01, sp), x
      008367 90 5D            [ 2]  332 	tnzw	y
      008369 27 03            [ 1]  333 	jreq	00104$
      00836B 9D               [ 1]  334 	nop
      00836C 20 F3            [ 2]  335 	jra	00101$
                                    336 ;	main.c: 121: CSN_LOW(); delay_cycles(50);
      00836E                        337 00104$:
                                    338 ;	main.c: 122: (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
      00836E 7B 03            [ 1]  339 	ld	a, (0x03, sp)
      008370 A4 1F            [ 1]  340 	and	a, #0x1f
      008372 AA 20            [ 1]  341 	or	a, #0x20
      008374 CD 82 EF         [ 4]  342 	call	_spi_txrx
                                    343 ;	main.c: 123: (void)spi_txrx(val);
      008377 7B 06            [ 1]  344 	ld	a, (0x06, sp)
      008379 CD 82 EF         [ 4]  345 	call	_spi_txrx
                                    346 ;	main.c: 124: spi_wait_idle(); delay_cycles(50);
      00837C CD 83 00         [ 4]  347 	call	_spi_wait_idle
      00837F AE 00 32         [ 2]  348 	ldw	x, #0x0032
      008382 1F 01            [ 2]  349 	ldw	(0x01, sp), x
                                    350 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      008384                        351 00105$:
      008384 16 01            [ 2]  352 	ldw	y, (0x01, sp)
      008386 93               [ 1]  353 	ldw	x, y
      008387 5A               [ 2]  354 	decw	x
      008388 1F 01            [ 2]  355 	ldw	(0x01, sp), x
      00838A 90 5D            [ 2]  356 	tnzw	y
      00838C 27 03            [ 1]  357 	jreq	00108$
      00838E 9D               [ 1]  358 	nop
      00838F 20 F3            [ 2]  359 	jra	00105$
                                    360 ;	main.c: 124: spi_wait_idle(); delay_cycles(50);
      008391                        361 00108$:
                                    362 ;	main.c: 125: CSN_HIGH();
      008391 72 14 50 0F      [ 1]  363 	bset	0x500f, #2
                                    364 ;	main.c: 126: }
      008395 5B 03            [ 2]  365 	addw	sp, #3
      008397 85               [ 2]  366 	popw	x
      008398 84               [ 1]  367 	pop	a
      008399 FC               [ 2]  368 	jp	(x)
                                    369 ;	main.c: 127: static void nrf_read_reg_n(uint8_t reg, uint8_t *buf, uint8_t len){
                                    370 ;	-----------------------------------------
                                    371 ;	 function nrf_read_reg_n
                                    372 ;	-----------------------------------------
      00839A                        373 _nrf_read_reg_n:
      00839A 52 06            [ 2]  374 	sub	sp, #6
      00839C 6B 05            [ 1]  375 	ld	(0x05, sp), a
      00839E 1F 03            [ 2]  376 	ldw	(0x03, sp), x
                                    377 ;	main.c: 128: CSN_LOW(); delay_cycles(50);
      0083A0 C6 50 0F         [ 1]  378 	ld	a, 0x500f
      0083A3 A4 FB            [ 1]  379 	and	a, #0xfb
      0083A5 C7 50 0F         [ 1]  380 	ld	0x500f, a
      0083A8 AE 00 32         [ 2]  381 	ldw	x, #0x0032
      0083AB 1F 01            [ 2]  382 	ldw	(0x01, sp), x
                                    383 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      0083AD                        384 00102$:
      0083AD 16 01            [ 2]  385 	ldw	y, (0x01, sp)
      0083AF 93               [ 1]  386 	ldw	x, y
      0083B0 5A               [ 2]  387 	decw	x
      0083B1 1F 01            [ 2]  388 	ldw	(0x01, sp), x
      0083B3 90 5D            [ 2]  389 	tnzw	y
      0083B5 27 03            [ 1]  390 	jreq	00105$
      0083B7 9D               [ 1]  391 	nop
      0083B8 20 F3            [ 2]  392 	jra	00102$
                                    393 ;	main.c: 128: CSN_LOW(); delay_cycles(50);
      0083BA                        394 00105$:
                                    395 ;	main.c: 129: (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
      0083BA 7B 05            [ 1]  396 	ld	a, (0x05, sp)
      0083BC A4 1F            [ 1]  397 	and	a, #0x1f
      0083BE CD 82 EF         [ 4]  398 	call	_spi_txrx
                                    399 ;	main.c: 130: for(uint8_t i=0;i<len;i++) buf[i] = spi_txrx(0xFF);
      0083C1 0F 06            [ 1]  400 	clr	(0x06, sp)
      0083C3                        401 00111$:
      0083C3 7B 06            [ 1]  402 	ld	a, (0x06, sp)
      0083C5 11 09            [ 1]  403 	cp	a, (0x09, sp)
      0083C7 24 13            [ 1]  404 	jrnc	00101$
      0083C9 5F               [ 1]  405 	clrw	x
      0083CA 7B 06            [ 1]  406 	ld	a, (0x06, sp)
      0083CC 97               [ 1]  407 	ld	xl, a
      0083CD 72 FB 03         [ 2]  408 	addw	x, (0x03, sp)
      0083D0 89               [ 2]  409 	pushw	x
      0083D1 A6 FF            [ 1]  410 	ld	a, #0xff
      0083D3 CD 82 EF         [ 4]  411 	call	_spi_txrx
      0083D6 85               [ 2]  412 	popw	x
      0083D7 F7               [ 1]  413 	ld	(x), a
      0083D8 0C 06            [ 1]  414 	inc	(0x06, sp)
      0083DA 20 E7            [ 2]  415 	jra	00111$
      0083DC                        416 00101$:
                                    417 ;	main.c: 131: spi_wait_idle(); delay_cycles(50);
      0083DC CD 83 00         [ 4]  418 	call	_spi_wait_idle
      0083DF AE 00 32         [ 2]  419 	ldw	x, #0x0032
      0083E2 1F 01            [ 2]  420 	ldw	(0x01, sp), x
                                    421 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      0083E4                        422 00106$:
      0083E4 16 01            [ 2]  423 	ldw	y, (0x01, sp)
      0083E6 93               [ 1]  424 	ldw	x, y
      0083E7 5A               [ 2]  425 	decw	x
      0083E8 1F 01            [ 2]  426 	ldw	(0x01, sp), x
      0083EA 90 5D            [ 2]  427 	tnzw	y
      0083EC 27 03            [ 1]  428 	jreq	00109$
      0083EE 9D               [ 1]  429 	nop
      0083EF 20 F3            [ 2]  430 	jra	00106$
                                    431 ;	main.c: 131: spi_wait_idle(); delay_cycles(50);
      0083F1                        432 00109$:
                                    433 ;	main.c: 132: CSN_HIGH();
      0083F1 72 14 50 0F      [ 1]  434 	bset	0x500f, #2
                                    435 ;	main.c: 133: }
      0083F5 5B 06            [ 2]  436 	addw	sp, #6
      0083F7 85               [ 2]  437 	popw	x
      0083F8 84               [ 1]  438 	pop	a
      0083F9 FC               [ 2]  439 	jp	(x)
                                    440 ;	main.c: 134: static void nrf_write_reg_n(uint8_t reg, const uint8_t *buf, uint8_t len){
                                    441 ;	-----------------------------------------
                                    442 ;	 function nrf_write_reg_n
                                    443 ;	-----------------------------------------
      0083FA                        444 _nrf_write_reg_n:
      0083FA 52 06            [ 2]  445 	sub	sp, #6
      0083FC 6B 05            [ 1]  446 	ld	(0x05, sp), a
      0083FE 1F 03            [ 2]  447 	ldw	(0x03, sp), x
                                    448 ;	main.c: 135: CSN_LOW(); delay_cycles(50);
      008400 C6 50 0F         [ 1]  449 	ld	a, 0x500f
      008403 A4 FB            [ 1]  450 	and	a, #0xfb
      008405 C7 50 0F         [ 1]  451 	ld	0x500f, a
      008408 AE 00 32         [ 2]  452 	ldw	x, #0x0032
      00840B 1F 01            [ 2]  453 	ldw	(0x01, sp), x
                                    454 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      00840D                        455 00102$:
      00840D 16 01            [ 2]  456 	ldw	y, (0x01, sp)
      00840F 93               [ 1]  457 	ldw	x, y
      008410 5A               [ 2]  458 	decw	x
      008411 1F 01            [ 2]  459 	ldw	(0x01, sp), x
      008413 90 5D            [ 2]  460 	tnzw	y
      008415 27 03            [ 1]  461 	jreq	00105$
      008417 9D               [ 1]  462 	nop
      008418 20 F3            [ 2]  463 	jra	00102$
                                    464 ;	main.c: 135: CSN_LOW(); delay_cycles(50);
      00841A                        465 00105$:
                                    466 ;	main.c: 136: (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
      00841A 7B 05            [ 1]  467 	ld	a, (0x05, sp)
      00841C A4 1F            [ 1]  468 	and	a, #0x1f
      00841E AA 20            [ 1]  469 	or	a, #0x20
      008420 CD 82 EF         [ 4]  470 	call	_spi_txrx
                                    471 ;	main.c: 137: for(uint8_t i=0;i<len;i++) (void)spi_txrx(buf[i]);
      008423 0F 06            [ 1]  472 	clr	(0x06, sp)
      008425                        473 00111$:
      008425 7B 06            [ 1]  474 	ld	a, (0x06, sp)
      008427 11 09            [ 1]  475 	cp	a, (0x09, sp)
      008429 24 0F            [ 1]  476 	jrnc	00101$
      00842B 5F               [ 1]  477 	clrw	x
      00842C 7B 06            [ 1]  478 	ld	a, (0x06, sp)
      00842E 97               [ 1]  479 	ld	xl, a
      00842F 72 FB 03         [ 2]  480 	addw	x, (0x03, sp)
      008432 F6               [ 1]  481 	ld	a, (x)
      008433 CD 82 EF         [ 4]  482 	call	_spi_txrx
      008436 0C 06            [ 1]  483 	inc	(0x06, sp)
      008438 20 EB            [ 2]  484 	jra	00111$
      00843A                        485 00101$:
                                    486 ;	main.c: 138: spi_wait_idle(); delay_cycles(50);
      00843A CD 83 00         [ 4]  487 	call	_spi_wait_idle
      00843D AE 00 32         [ 2]  488 	ldw	x, #0x0032
      008440 1F 01            [ 2]  489 	ldw	(0x01, sp), x
                                    490 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      008442                        491 00106$:
      008442 16 01            [ 2]  492 	ldw	y, (0x01, sp)
      008444 93               [ 1]  493 	ldw	x, y
      008445 5A               [ 2]  494 	decw	x
      008446 1F 01            [ 2]  495 	ldw	(0x01, sp), x
      008448 90 5D            [ 2]  496 	tnzw	y
      00844A 27 03            [ 1]  497 	jreq	00109$
      00844C 9D               [ 1]  498 	nop
      00844D 20 F3            [ 2]  499 	jra	00106$
                                    500 ;	main.c: 138: spi_wait_idle(); delay_cycles(50);
      00844F                        501 00109$:
                                    502 ;	main.c: 139: CSN_HIGH();
      00844F 72 14 50 0F      [ 1]  503 	bset	0x500f, #2
                                    504 ;	main.c: 140: }
      008453 5B 06            [ 2]  505 	addw	sp, #6
      008455 85               [ 2]  506 	popw	x
      008456 84               [ 1]  507 	pop	a
      008457 FC               [ 2]  508 	jp	(x)
                                    509 ;	main.c: 141: static uint8_t nrf_cmd(uint8_t cmd){
                                    510 ;	-----------------------------------------
                                    511 ;	 function nrf_cmd
                                    512 ;	-----------------------------------------
      008458                        513 _nrf_cmd:
      008458 52 04            [ 2]  514 	sub	sp, #4
      00845A 6B 04            [ 1]  515 	ld	(0x04, sp), a
                                    516 ;	main.c: 143: CSN_LOW(); delay_cycles(50);
      00845C C6 50 0F         [ 1]  517 	ld	a, 0x500f
      00845F A4 FB            [ 1]  518 	and	a, #0xfb
      008461 C7 50 0F         [ 1]  519 	ld	0x500f, a
      008464 AE 00 32         [ 2]  520 	ldw	x, #0x0032
      008467 1F 01            [ 2]  521 	ldw	(0x01, sp), x
                                    522 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      008469                        523 00101$:
      008469 16 01            [ 2]  524 	ldw	y, (0x01, sp)
      00846B 93               [ 1]  525 	ldw	x, y
      00846C 5A               [ 2]  526 	decw	x
      00846D 1F 01            [ 2]  527 	ldw	(0x01, sp), x
      00846F 90 5D            [ 2]  528 	tnzw	y
      008471 27 03            [ 1]  529 	jreq	00104$
      008473 9D               [ 1]  530 	nop
      008474 20 F3            [ 2]  531 	jra	00101$
                                    532 ;	main.c: 143: CSN_LOW(); delay_cycles(50);
      008476                        533 00104$:
                                    534 ;	main.c: 144: s = spi_txrx(cmd);
      008476 7B 04            [ 1]  535 	ld	a, (0x04, sp)
      008478 CD 82 EF         [ 4]  536 	call	_spi_txrx
      00847B 6B 03            [ 1]  537 	ld	(0x03, sp), a
                                    538 ;	main.c: 145: spi_wait_idle(); delay_cycles(50);
      00847D CD 83 00         [ 4]  539 	call	_spi_wait_idle
      008480 AE 00 32         [ 2]  540 	ldw	x, #0x0032
      008483 1F 01            [ 2]  541 	ldw	(0x01, sp), x
                                    542 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      008485                        543 00105$:
      008485 16 01            [ 2]  544 	ldw	y, (0x01, sp)
      008487 93               [ 1]  545 	ldw	x, y
      008488 5A               [ 2]  546 	decw	x
      008489 1F 01            [ 2]  547 	ldw	(0x01, sp), x
      00848B 90 5D            [ 2]  548 	tnzw	y
      00848D 27 03            [ 1]  549 	jreq	00108$
      00848F 9D               [ 1]  550 	nop
      008490 20 F3            [ 2]  551 	jra	00105$
                                    552 ;	main.c: 145: spi_wait_idle(); delay_cycles(50);
      008492                        553 00108$:
                                    554 ;	main.c: 146: CSN_HIGH();
      008492 72 14 50 0F      [ 1]  555 	bset	0x500f, #2
                                    556 ;	main.c: 147: return s;
      008496 7B 03            [ 1]  557 	ld	a, (0x03, sp)
                                    558 ;	main.c: 148: }
      008498 5B 04            [ 2]  559 	addw	sp, #4
      00849A 81               [ 4]  560 	ret
                                    561 ;	main.c: 151: static uint8_t nrf_status_raw(void){
                                    562 ;	-----------------------------------------
                                    563 ;	 function nrf_status_raw
                                    564 ;	-----------------------------------------
      00849B                        565 _nrf_status_raw:
      00849B 52 03            [ 2]  566 	sub	sp, #3
                                    567 ;	main.c: 153: CSN_LOW(); delay_cycles(50);
      00849D C6 50 0F         [ 1]  568 	ld	a, 0x500f
      0084A0 A4 FB            [ 1]  569 	and	a, #0xfb
      0084A2 C7 50 0F         [ 1]  570 	ld	0x500f, a
      0084A5 AE 00 32         [ 2]  571 	ldw	x, #0x0032
      0084A8 1F 01            [ 2]  572 	ldw	(0x01, sp), x
                                    573 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      0084AA                        574 00101$:
      0084AA 16 01            [ 2]  575 	ldw	y, (0x01, sp)
      0084AC 93               [ 1]  576 	ldw	x, y
      0084AD 5A               [ 2]  577 	decw	x
      0084AE 1F 01            [ 2]  578 	ldw	(0x01, sp), x
      0084B0 90 5D            [ 2]  579 	tnzw	y
      0084B2 27 03            [ 1]  580 	jreq	00104$
      0084B4 9D               [ 1]  581 	nop
      0084B5 20 F3            [ 2]  582 	jra	00101$
                                    583 ;	main.c: 153: CSN_LOW(); delay_cycles(50);
      0084B7                        584 00104$:
                                    585 ;	main.c: 154: s = spi_txrx(NRF_NOP);
      0084B7 A6 FF            [ 1]  586 	ld	a, #0xff
      0084B9 CD 82 EF         [ 4]  587 	call	_spi_txrx
      0084BC 6B 03            [ 1]  588 	ld	(0x03, sp), a
                                    589 ;	main.c: 155: spi_wait_idle(); delay_cycles(50);
      0084BE CD 83 00         [ 4]  590 	call	_spi_wait_idle
      0084C1 AE 00 32         [ 2]  591 	ldw	x, #0x0032
      0084C4 1F 01            [ 2]  592 	ldw	(0x01, sp), x
                                    593 ;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
      0084C6                        594 00105$:
      0084C6 16 01            [ 2]  595 	ldw	y, (0x01, sp)
      0084C8 93               [ 1]  596 	ldw	x, y
      0084C9 5A               [ 2]  597 	decw	x
      0084CA 1F 01            [ 2]  598 	ldw	(0x01, sp), x
      0084CC 90 5D            [ 2]  599 	tnzw	y
      0084CE 27 03            [ 1]  600 	jreq	00108$
      0084D0 9D               [ 1]  601 	nop
      0084D1 20 F3            [ 2]  602 	jra	00105$
                                    603 ;	main.c: 155: spi_wait_idle(); delay_cycles(50);
      0084D3                        604 00108$:
                                    605 ;	main.c: 156: CSN_HIGH(); return s;
      0084D3 72 14 50 0F      [ 1]  606 	bset	0x500f, #2
      0084D7 7B 03            [ 1]  607 	ld	a, (0x03, sp)
                                    608 ;	main.c: 157: }
      0084D9 5B 03            [ 2]  609 	addw	sp, #3
      0084DB 81               [ 4]  610 	ret
                                    611 ;	main.c: 158: static uint8_t nrf_bus_ok(void){
                                    612 ;	-----------------------------------------
                                    613 ;	 function nrf_bus_ok
                                    614 ;	-----------------------------------------
      0084DC                        615 _nrf_bus_ok:
                                    616 ;	main.c: 159: uint8_t s = nrf_status_raw();
      0084DC CD 84 9B         [ 4]  617 	call	_nrf_status_raw
                                    618 ;	main.c: 160: return (s != 0xFF && s != 0x00);
      0084DF A1 FF            [ 1]  619 	cp	a, #0xff
      0084E1 27 03            [ 1]  620 	jreq	00103$
      0084E3 4D               [ 1]  621 	tnz	a
      0084E4 26 02            [ 1]  622 	jrne	00104$
      0084E6                        623 00103$:
      0084E6 4F               [ 1]  624 	clr	a
      0084E7 81               [ 4]  625 	ret
      0084E8                        626 00104$:
      0084E8 A6 01            [ 1]  627 	ld	a, #0x01
                                    628 ;	main.c: 161: }
      0084EA 81               [ 4]  629 	ret
                                    630 ;	main.c: 163: static void nrf_dump_status(void){
                                    631 ;	-----------------------------------------
                                    632 ;	 function nrf_dump_status
                                    633 ;	-----------------------------------------
      0084EB                        634 _nrf_dump_status:
      0084EB 52 0A            [ 2]  635 	sub	sp, #10
                                    636 ;	main.c: 164: uint8_t s = nrf_status_raw();
      0084ED CD 84 9B         [ 4]  637 	call	_nrf_status_raw
                                    638 ;	main.c: 167: (s>>1)&0x07, !!(s&0x01));
      0084F0 97               [ 1]  639 	ld	xl, a
      0084F1 A4 01            [ 1]  640 	and	a, #0x01
      0084F3 A8 01            [ 1]  641 	xor	a, #0x01
      0084F5 A8 01            [ 1]  642 	xor	a, #0x01
      0084F7 6B 02            [ 1]  643 	ld	(0x02, sp), a
      0084F9 0F 01            [ 1]  644 	clr	(0x01, sp)
      0084FB 9F               [ 1]  645 	ld	a, xl
      0084FC 44               [ 1]  646 	srl	a
      0084FD 0F 09            [ 1]  647 	clr	(0x09, sp)
      0084FF A4 07            [ 1]  648 	and	a, #0x07
      008501 6B 04            [ 1]  649 	ld	(0x04, sp), a
      008503 0F 03            [ 1]  650 	clr	(0x03, sp)
                                    651 ;	main.c: 166: s, !!(s&(1<<RX_DR)), !!(s&(1<<TX_DS)), !!(s&(1<<MAX_RT)),
      008505 9F               [ 1]  652 	ld	a, xl
      008506 44               [ 1]  653 	srl	a
      008507 44               [ 1]  654 	srl	a
      008508 44               [ 1]  655 	srl	a
      008509 44               [ 1]  656 	srl	a
      00850A A4 01            [ 1]  657 	and	a, #0x01
      00850C A8 01            [ 1]  658 	xor	a, #0x01
      00850E A8 01            [ 1]  659 	xor	a, #0x01
      008510 6B 06            [ 1]  660 	ld	(0x06, sp), a
      008512 0F 05            [ 1]  661 	clr	(0x05, sp)
      008514 9F               [ 1]  662 	ld	a, xl
      008515 4E               [ 1]  663 	swap	a
      008516 44               [ 1]  664 	srl	a
      008517 A4 01            [ 1]  665 	and	a, #0x01
      008519 A8 01            [ 1]  666 	xor	a, #0x01
      00851B A8 01            [ 1]  667 	xor	a, #0x01
      00851D 6B 08            [ 1]  668 	ld	(0x08, sp), a
      00851F 0F 07            [ 1]  669 	clr	(0x07, sp)
      008521 9F               [ 1]  670 	ld	a, xl
      008522 48               [ 1]  671 	sll	a
      008523 48               [ 1]  672 	sll	a
      008524 4F               [ 1]  673 	clr	a
      008525 49               [ 1]  674 	rlc	a
      008526 A0 01            [ 1]  675 	sub	a, #0x01
      008528 4F               [ 1]  676 	clr	a
      008529 8C               [ 1]  677 	ccf
      00852A 49               [ 1]  678 	rlc	a
      00852B 0F 09            [ 1]  679 	clr	(0x09, sp)
      00852D 02               [ 1]  680 	rlwa	x
      00852E 4F               [ 1]  681 	clr	a
      00852F 01               [ 1]  682 	rrwa	x
                                    683 ;	main.c: 165: printf("\r\n[STATUS] 0x%02X  (RX_DR=%d TX_DS=%d MAX_RT=%d RX_PIPE=%u TX_FULL=%d)\r\n",
      008530 16 01            [ 2]  684 	ldw	y, (0x01, sp)
      008532 90 89            [ 2]  685 	pushw	y
      008534 16 05            [ 2]  686 	ldw	y, (0x05, sp)
      008536 90 89            [ 2]  687 	pushw	y
      008538 16 09            [ 2]  688 	ldw	y, (0x09, sp)
      00853A 90 89            [ 2]  689 	pushw	y
      00853C 16 0D            [ 2]  690 	ldw	y, (0x0d, sp)
      00853E 90 89            [ 2]  691 	pushw	y
      008540 88               [ 1]  692 	push	a
      008541 7B 12            [ 1]  693 	ld	a, (0x12, sp)
      008543 88               [ 1]  694 	push	a
      008544 89               [ 2]  695 	pushw	x
      008545 4B 29            [ 1]  696 	push	#<(___str_0+0)
      008547 4B 80            [ 1]  697 	push	#((___str_0+0) >> 8)
      008549 CD 89 94         [ 4]  698 	call	_printf
                                    699 ;	main.c: 168: }
      00854C 5B 18            [ 2]  700 	addw	sp, #24
      00854E 81               [ 4]  701 	ret
                                    702 ;	main.c: 169: static void nrf_dump_core_regs(void){
                                    703 ;	-----------------------------------------
                                    704 ;	 function nrf_dump_core_regs
                                    705 ;	-----------------------------------------
      00854F                        706 _nrf_dump_core_regs:
      00854F 52 1C            [ 2]  707 	sub	sp, #28
                                    708 ;	main.c: 170: uint8_t cfg = nrf_read_reg(NRF_REG_CONFIG);
      008551 4F               [ 1]  709 	clr	a
      008552 CD 83 06         [ 4]  710 	call	_nrf_read_reg
      008555 6B 1A            [ 1]  711 	ld	(0x1a, sp), a
                                    712 ;	main.c: 171: uint8_t rfch = nrf_read_reg(NRF_REG_RF_CH);
      008557 A6 05            [ 1]  713 	ld	a, #0x05
      008559 CD 83 06         [ 4]  714 	call	_nrf_read_reg
      00855C 6B 1B            [ 1]  715 	ld	(0x1b, sp), a
                                    716 ;	main.c: 172: uint8_t rfs  = nrf_read_reg(NRF_REG_RF_SETUP);
      00855E A6 06            [ 1]  717 	ld	a, #0x06
      008560 CD 83 06         [ 4]  718 	call	_nrf_read_reg
      008563 6B 1C            [ 1]  719 	ld	(0x1c, sp), a
                                    720 ;	main.c: 174: nrf_read_reg_n(NRF_REG_TX_ADDR, tx, 5);
      008565 4B 05            [ 1]  721 	push	#0x05
      008567 96               [ 1]  722 	ldw	x, sp
      008568 5C               [ 1]  723 	incw	x
      008569 5C               [ 1]  724 	incw	x
      00856A A6 10            [ 1]  725 	ld	a, #0x10
      00856C CD 83 9A         [ 4]  726 	call	_nrf_read_reg_n
                                    727 ;	main.c: 175: nrf_read_reg_n(NRF_REG_RX_ADDR_P0, rx0, 5);
      00856F 4B 05            [ 1]  728 	push	#0x05
      008571 96               [ 1]  729 	ldw	x, sp
      008572 1C 00 07         [ 2]  730 	addw	x, #7
      008575 A6 0A            [ 1]  731 	ld	a, #0x0a
      008577 CD 83 9A         [ 4]  732 	call	_nrf_read_reg_n
                                    733 ;	main.c: 177: printf("[CORE]   CONFIG=0x%02X  RF_CH=0x%02X  RF_SETUP=0x%02X\r\n", cfg, rfch, rfs);
      00857A 90 5F            [ 1]  734 	clrw	y
      00857C 7B 1C            [ 1]  735 	ld	a, (0x1c, sp)
      00857E 90 97            [ 1]  736 	ld	yl, a
      008580 5F               [ 1]  737 	clrw	x
      008581 7B 1B            [ 1]  738 	ld	a, (0x1b, sp)
      008583 97               [ 1]  739 	ld	xl, a
      008584 7B 1A            [ 1]  740 	ld	a, (0x1a, sp)
      008586 6B 1C            [ 1]  741 	ld	(0x1c, sp), a
      008588 0F 1B            [ 1]  742 	clr	(0x1b, sp)
      00858A 90 89            [ 2]  743 	pushw	y
      00858C 89               [ 2]  744 	pushw	x
      00858D 1E 1F            [ 2]  745 	ldw	x, (0x1f, sp)
      00858F 89               [ 2]  746 	pushw	x
      008590 4B 72            [ 1]  747 	push	#<(___str_1+0)
      008592 4B 80            [ 1]  748 	push	#((___str_1+0) >> 8)
      008594 CD 89 94         [ 4]  749 	call	_printf
      008597 5B 08            [ 2]  750 	addw	sp, #8
                                    751 ;	main.c: 179: tx[0],tx[1],tx[2],tx[3],tx[4], rx0[0],rx0[1],rx0[2],rx0[3],rx0[4]);
      008599 7B 0A            [ 1]  752 	ld	a, (0x0a, sp)
      00859B 5F               [ 1]  753 	clrw	x
      00859C 97               [ 1]  754 	ld	xl, a
      00859D 7B 09            [ 1]  755 	ld	a, (0x09, sp)
      00859F 6B 0C            [ 1]  756 	ld	(0x0c, sp), a
      0085A1 0F 0B            [ 1]  757 	clr	(0x0b, sp)
      0085A3 7B 08            [ 1]  758 	ld	a, (0x08, sp)
      0085A5 6B 0E            [ 1]  759 	ld	(0x0e, sp), a
      0085A7 0F 0D            [ 1]  760 	clr	(0x0d, sp)
      0085A9 7B 07            [ 1]  761 	ld	a, (0x07, sp)
      0085AB 6B 10            [ 1]  762 	ld	(0x10, sp), a
      0085AD 0F 0F            [ 1]  763 	clr	(0x0f, sp)
      0085AF 7B 06            [ 1]  764 	ld	a, (0x06, sp)
      0085B1 6B 12            [ 1]  765 	ld	(0x12, sp), a
      0085B3 0F 11            [ 1]  766 	clr	(0x11, sp)
      0085B5 7B 05            [ 1]  767 	ld	a, (0x05, sp)
      0085B7 6B 14            [ 1]  768 	ld	(0x14, sp), a
      0085B9 0F 13            [ 1]  769 	clr	(0x13, sp)
      0085BB 7B 04            [ 1]  770 	ld	a, (0x04, sp)
      0085BD 6B 16            [ 1]  771 	ld	(0x16, sp), a
      0085BF 0F 15            [ 1]  772 	clr	(0x15, sp)
      0085C1 7B 03            [ 1]  773 	ld	a, (0x03, sp)
      0085C3 6B 18            [ 1]  774 	ld	(0x18, sp), a
      0085C5 0F 17            [ 1]  775 	clr	(0x17, sp)
      0085C7 7B 02            [ 1]  776 	ld	a, (0x02, sp)
      0085C9 6B 1A            [ 1]  777 	ld	(0x1a, sp), a
      0085CB 0F 19            [ 1]  778 	clr	(0x19, sp)
      0085CD 7B 01            [ 1]  779 	ld	a, (0x01, sp)
      0085CF 0F 1B            [ 1]  780 	clr	(0x1b, sp)
                                    781 ;	main.c: 178: printf("[ADDR]   TX_ADDR=%02X %02X %02X %02X %02X  |  RX0=%02X %02X %02X %02X %02X\r\n",
      0085D1 89               [ 2]  782 	pushw	x
      0085D2 1E 0D            [ 2]  783 	ldw	x, (0x0d, sp)
      0085D4 89               [ 2]  784 	pushw	x
      0085D5 1E 11            [ 2]  785 	ldw	x, (0x11, sp)
      0085D7 89               [ 2]  786 	pushw	x
      0085D8 1E 15            [ 2]  787 	ldw	x, (0x15, sp)
      0085DA 89               [ 2]  788 	pushw	x
      0085DB 1E 19            [ 2]  789 	ldw	x, (0x19, sp)
      0085DD 89               [ 2]  790 	pushw	x
      0085DE 1E 1D            [ 2]  791 	ldw	x, (0x1d, sp)
      0085E0 89               [ 2]  792 	pushw	x
      0085E1 1E 21            [ 2]  793 	ldw	x, (0x21, sp)
      0085E3 89               [ 2]  794 	pushw	x
      0085E4 1E 25            [ 2]  795 	ldw	x, (0x25, sp)
      0085E6 89               [ 2]  796 	pushw	x
      0085E7 1E 29            [ 2]  797 	ldw	x, (0x29, sp)
      0085E9 89               [ 2]  798 	pushw	x
      0085EA 88               [ 1]  799 	push	a
      0085EB 7B 2E            [ 1]  800 	ld	a, (0x2e, sp)
      0085ED 88               [ 1]  801 	push	a
      0085EE 4B AA            [ 1]  802 	push	#<(___str_2+0)
      0085F0 4B 80            [ 1]  803 	push	#((___str_2+0) >> 8)
      0085F2 CD 89 94         [ 4]  804 	call	_printf
                                    805 ;	main.c: 180: }
      0085F5 5B 32            [ 2]  806 	addw	sp, #50
      0085F7 81               [ 4]  807 	ret
                                    808 ;	main.c: 181: static void nrf_dump_tx_regs(void){
                                    809 ;	-----------------------------------------
                                    810 ;	 function nrf_dump_tx_regs
                                    811 ;	-----------------------------------------
      0085F8                        812 _nrf_dump_tx_regs:
      0085F8 52 06            [ 2]  813 	sub	sp, #6
                                    814 ;	main.c: 182: uint8_t enaa = nrf_read_reg(NRF_REG_EN_AA);
      0085FA A6 01            [ 1]  815 	ld	a, #0x01
      0085FC CD 83 06         [ 4]  816 	call	_nrf_read_reg
      0085FF 6B 06            [ 1]  817 	ld	(0x06, sp), a
                                    818 ;	main.c: 183: uint8_t enrx = nrf_read_reg(NRF_REG_EN_RXADDR);
      008601 A6 02            [ 1]  819 	ld	a, #0x02
      008603 CD 83 06         [ 4]  820 	call	_nrf_read_reg
      008606 6B 05            [ 1]  821 	ld	(0x05, sp), a
                                    822 ;	main.c: 184: uint8_t retr = nrf_read_reg(NRF_REG_SETUP_RETR);
      008608 A6 04            [ 1]  823 	ld	a, #0x04
      00860A CD 83 06         [ 4]  824 	call	_nrf_read_reg
                                    825 ;	main.c: 185: uint8_t pw0  = nrf_read_reg(NRF_REG_RX_PW_P0);
      00860D 88               [ 1]  826 	push	a
      00860E A6 11            [ 1]  827 	ld	a, #0x11
      008610 CD 83 06         [ 4]  828 	call	_nrf_read_reg
      008613 90 97            [ 1]  829 	ld	yl, a
      008615 84               [ 1]  830 	pop	a
                                    831 ;	main.c: 187: enaa, enrx, retr, pw0);
      008616 0F 01            [ 1]  832 	clr	(0x01, sp)
      008618 5F               [ 1]  833 	clrw	x
      008619 97               [ 1]  834 	ld	xl, a
      00861A 7B 05            [ 1]  835 	ld	a, (0x05, sp)
      00861C 6B 04            [ 1]  836 	ld	(0x04, sp), a
      00861E 0F 03            [ 1]  837 	clr	(0x03, sp)
      008620 0F 05            [ 1]  838 	clr	(0x05, sp)
                                    839 ;	main.c: 186: printf("[TXCFG]  EN_AA=0x%02X  EN_RXADDR=0x%02X  SETUP_RETR=0x%02X  RX_PW_P0=%u\r\n",
      008622 90 9F            [ 1]  840 	ld	a, yl
      008624 88               [ 1]  841 	push	a
      008625 7B 02            [ 1]  842 	ld	a, (0x02, sp)
      008627 88               [ 1]  843 	push	a
      008628 89               [ 2]  844 	pushw	x
      008629 1E 07            [ 2]  845 	ldw	x, (0x07, sp)
      00862B 89               [ 2]  846 	pushw	x
      00862C 1E 0B            [ 2]  847 	ldw	x, (0x0b, sp)
      00862E 89               [ 2]  848 	pushw	x
      00862F 4B F7            [ 1]  849 	push	#<(___str_3+0)
      008631 4B 80            [ 1]  850 	push	#((___str_3+0) >> 8)
      008633 CD 89 94         [ 4]  851 	call	_printf
                                    852 ;	main.c: 188: }
      008636 5B 10            [ 2]  853 	addw	sp, #16
      008638 81               [ 4]  854 	ret
                                    855 ;	main.c: 189: static void nrf_dump_fifo(void){
                                    856 ;	-----------------------------------------
                                    857 ;	 function nrf_dump_fifo
                                    858 ;	-----------------------------------------
      008639                        859 _nrf_dump_fifo:
      008639 52 0A            [ 2]  860 	sub	sp, #10
                                    861 ;	main.c: 190: uint8_t f = nrf_read_reg(NRF_REG_FIFO_STATUS);
      00863B A6 17            [ 1]  862 	ld	a, #0x17
      00863D CD 83 06         [ 4]  863 	call	_nrf_read_reg
                                    864 ;	main.c: 192: f, !!(f&0x10), !!(f&0x20), !!(f&0x01), !!(f&0x02));
      008640 95               [ 1]  865 	ld	xh, a
      008641 44               [ 1]  866 	srl	a
      008642 A4 01            [ 1]  867 	and	a, #0x01
      008644 A8 01            [ 1]  868 	xor	a, #0x01
      008646 A8 01            [ 1]  869 	xor	a, #0x01
      008648 6B 02            [ 1]  870 	ld	(0x02, sp), a
      00864A 0F 01            [ 1]  871 	clr	(0x01, sp)
      00864C 9E               [ 1]  872 	ld	a, xh
      00864D A4 01            [ 1]  873 	and	a, #0x01
      00864F A8 01            [ 1]  874 	xor	a, #0x01
      008651 A8 01            [ 1]  875 	xor	a, #0x01
      008653 6B 04            [ 1]  876 	ld	(0x04, sp), a
      008655 0F 03            [ 1]  877 	clr	(0x03, sp)
      008657 9E               [ 1]  878 	ld	a, xh
      008658 4E               [ 1]  879 	swap	a
      008659 44               [ 1]  880 	srl	a
      00865A A4 01            [ 1]  881 	and	a, #0x01
      00865C A8 01            [ 1]  882 	xor	a, #0x01
      00865E A8 01            [ 1]  883 	xor	a, #0x01
      008660 97               [ 1]  884 	ld	xl, a
      008661 0F 05            [ 1]  885 	clr	(0x05, sp)
      008663 9E               [ 1]  886 	ld	a, xh
      008664 44               [ 1]  887 	srl	a
      008665 44               [ 1]  888 	srl	a
      008666 44               [ 1]  889 	srl	a
      008667 44               [ 1]  890 	srl	a
      008668 A4 01            [ 1]  891 	and	a, #0x01
      00866A A8 01            [ 1]  892 	xor	a, #0x01
      00866C A8 01            [ 1]  893 	xor	a, #0x01
      00866E 0F 07            [ 1]  894 	clr	(0x07, sp)
      008670 0F 09            [ 1]  895 	clr	(0x09, sp)
                                    896 ;	main.c: 191: printf("[FIFO]   0x%02X  TX_EMPTY=%d TX_FULL=%d  RX_EMPTY=%d RX_FULL=%d\r\n",
      008672 16 01            [ 2]  897 	ldw	y, (0x01, sp)
      008674 90 89            [ 2]  898 	pushw	y
      008676 16 05            [ 2]  899 	ldw	y, (0x05, sp)
      008678 90 89            [ 2]  900 	pushw	y
      00867A 89               [ 2]  901 	pushw	x
      00867B 5B 01            [ 2]  902 	addw	sp, #1
      00867D 41               [ 1]  903 	exg	a, xl
      00867E 7B 0A            [ 1]  904 	ld	a, (0x0a, sp)
      008680 41               [ 1]  905 	exg	a, xl
      008681 89               [ 2]  906 	pushw	x
      008682 5B 01            [ 2]  907 	addw	sp, #1
      008684 88               [ 1]  908 	push	a
      008685 7B 0E            [ 1]  909 	ld	a, (0x0e, sp)
      008687 88               [ 1]  910 	push	a
      008688 9E               [ 1]  911 	ld	a, xh
      008689 88               [ 1]  912 	push	a
      00868A 7B 12            [ 1]  913 	ld	a, (0x12, sp)
      00868C 88               [ 1]  914 	push	a
      00868D 4B 41            [ 1]  915 	push	#<(___str_4+0)
      00868F 4B 81            [ 1]  916 	push	#((___str_4+0) >> 8)
      008691 CD 89 94         [ 4]  917 	call	_printf
                                    918 ;	main.c: 193: }
      008694 5B 16            [ 2]  919 	addw	sp, #22
      008696 81               [ 4]  920 	ret
                                    921 ;	main.c: 196: static void nrf_set_common(uint8_t rf_ch){
                                    922 ;	-----------------------------------------
                                    923 ;	 function nrf_set_common
                                    924 ;	-----------------------------------------
      008697                        925 _nrf_set_common:
                                    926 ;	main.c: 197: nrf_write_reg(NRF_REG_SETUP_AW, 0x03);     // adresse 5B
      008697 88               [ 1]  927 	push	a
      008698 4B 03            [ 1]  928 	push	#0x03
      00869A A6 03            [ 1]  929 	ld	a, #0x03
      00869C CD 83 50         [ 4]  930 	call	_nrf_write_reg
      00869F A6 05            [ 1]  931 	ld	a, #0x05
      0086A1 CD 83 50         [ 4]  932 	call	_nrf_write_reg
                                    933 ;	main.c: 199: nrf_write_reg(NRF_REG_RF_SETUP, 0x06);     // 1Mbps, 0dBm
      0086A4 4B 06            [ 1]  934 	push	#0x06
      0086A6 A6 06            [ 1]  935 	ld	a, #0x06
      0086A8 CD 83 50         [ 4]  936 	call	_nrf_write_reg
                                    937 ;	main.c: 200: nrf_write_reg_n(NRF_REG_TX_ADDR,    ADDR_NODE1, 5);
      0086AB 4B 05            [ 1]  938 	push	#0x05
      0086AD AE 80 24         [ 2]  939 	ldw	x, #(_ADDR_NODE1+0)
      0086B0 A6 10            [ 1]  940 	ld	a, #0x10
      0086B2 CD 83 FA         [ 4]  941 	call	_nrf_write_reg_n
                                    942 ;	main.c: 201: nrf_write_reg_n(NRF_REG_RX_ADDR_P0, ADDR_NODE1, 5);
      0086B5 4B 05            [ 1]  943 	push	#0x05
      0086B7 AE 80 24         [ 2]  944 	ldw	x, #(_ADDR_NODE1+0)
      0086BA A6 0A            [ 1]  945 	ld	a, #0x0a
      0086BC CD 83 FA         [ 4]  946 	call	_nrf_write_reg_n
                                    947 ;	main.c: 202: nrf_write_reg(NRF_REG_STATUS, 0x70);       // clear IRQ
      0086BF 4B 70            [ 1]  948 	push	#0x70
      0086C1 A6 07            [ 1]  949 	ld	a, #0x07
      0086C3 CD 83 50         [ 4]  950 	call	_nrf_write_reg
                                    951 ;	main.c: 203: (void)nrf_cmd(NRF_CMD_FLUSH_RX);
      0086C6 A6 E2            [ 1]  952 	ld	a, #0xe2
      0086C8 CD 84 58         [ 4]  953 	call	_nrf_cmd
                                    954 ;	main.c: 204: (void)nrf_cmd(NRF_CMD_FLUSH_TX);
      0086CB A6 E1            [ 1]  955 	ld	a, #0xe1
      0086CD CD 84 58         [ 4]  956 	call	_nrf_cmd
                                    957 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      0086D0 90 5F            [ 1]  958 	clrw	y
      0086D2 5F               [ 1]  959 	clrw	x
      0086D3                        960 00104$:
      0086D3 90 A3 11 58      [ 2]  961 	cpw	y, #0x1158
      0086D7 9F               [ 1]  962 	ld	a, xl
      0086D8 A2 00            [ 1]  963 	sbc	a, #0x00
      0086DA 9E               [ 1]  964 	ld	a, xh
      0086DB A2 00            [ 1]  965 	sbc	a, #0x00
      0086DD 25 01            [ 1]  966 	jrc	00119$
      0086DF 81               [ 4]  967 	ret
      0086E0                        968 00119$:
      0086E0 9D               [ 1]  969 	nop
      0086E1 90 5C            [ 1]  970 	incw	y
      0086E3 26 EE            [ 1]  971 	jrne	00104$
      0086E5 5C               [ 1]  972 	incw	x
      0086E6 20 EB            [ 2]  973 	jra	00104$
                                    974 ;	main.c: 205: delay_ms(5);                                // tpd2stby
                                    975 ;	main.c: 206: }
      0086E8 81               [ 4]  976 	ret
                                    977 ;	main.c: 209: static void nrf_ptx_start_ack(void){
                                    978 ;	-----------------------------------------
                                    979 ;	 function nrf_ptx_start_ack
                                    980 ;	-----------------------------------------
      0086E9                        981 _nrf_ptx_start_ack:
                                    982 ;	main.c: 210: nrf_set_common(RF_CHAN);
      0086E9 A6 4C            [ 1]  983 	ld	a, #0x4c
      0086EB CD 86 97         [ 4]  984 	call	_nrf_set_common
                                    985 ;	main.c: 211: nrf_write_reg(NRF_REG_EN_AA,      0x01);
      0086EE 4B 01            [ 1]  986 	push	#0x01
      0086F0 A6 01            [ 1]  987 	ld	a, #0x01
      0086F2 CD 83 50         [ 4]  988 	call	_nrf_write_reg
                                    989 ;	main.c: 212: nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
      0086F5 4B 01            [ 1]  990 	push	#0x01
      0086F7 A6 02            [ 1]  991 	ld	a, #0x02
      0086F9 CD 83 50         [ 4]  992 	call	_nrf_write_reg
                                    993 ;	main.c: 213: nrf_write_reg(NRF_REG_RX_PW_P0,   PAYLOAD_LEN);
      0086FC 4B 20            [ 1]  994 	push	#0x20
      0086FE A6 11            [ 1]  995 	ld	a, #0x11
      008700 CD 83 50         [ 4]  996 	call	_nrf_write_reg
                                    997 ;	main.c: 214: nrf_write_reg(NRF_REG_SETUP_RETR, 0x5F);
      008703 4B 5F            [ 1]  998 	push	#0x5f
      008705 A6 04            [ 1]  999 	ld	a, #0x04
      008707 CD 83 50         [ 4] 1000 	call	_nrf_write_reg
                                   1001 ;	main.c: 215: nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP); // 0x0E
      00870A 4B 0E            [ 1] 1002 	push	#0x0e
      00870C 4F               [ 1] 1003 	clr	a
      00870D CD 83 50         [ 4] 1004 	call	_nrf_write_reg
                                   1005 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      008710 90 5F            [ 1] 1006 	clrw	y
      008712 5F               [ 1] 1007 	clrw	x
      008713                       1008 00104$:
      008713 90 A3 11 58      [ 2] 1009 	cpw	y, #0x1158
      008717 9F               [ 1] 1010 	ld	a, xl
      008718 A2 00            [ 1] 1011 	sbc	a, #0x00
      00871A 9E               [ 1] 1012 	ld	a, xh
      00871B A2 00            [ 1] 1013 	sbc	a, #0x00
      00871D 25 01            [ 1] 1014 	jrc	00119$
      00871F 81               [ 4] 1015 	ret
      008720                       1016 00119$:
      008720 9D               [ 1] 1017 	nop
      008721 90 5C            [ 1] 1018 	incw	y
      008723 26 EE            [ 1] 1019 	jrne	00104$
      008725 5C               [ 1] 1020 	incw	x
      008726 20 EB            [ 2] 1021 	jra	00104$
                                   1022 ;	main.c: 216: delay_ms(5);
                                   1023 ;	main.c: 217: }
      008728 81               [ 4] 1024 	ret
                                   1025 ;	main.c: 219: static void nrf_ptx_start_noack(void){
                                   1026 ;	-----------------------------------------
                                   1027 ;	 function nrf_ptx_start_noack
                                   1028 ;	-----------------------------------------
      008729                       1029 _nrf_ptx_start_noack:
                                   1030 ;	main.c: 220: nrf_set_common(RF_CHAN);
      008729 A6 4C            [ 1] 1031 	ld	a, #0x4c
      00872B CD 86 97         [ 4] 1032 	call	_nrf_set_common
                                   1033 ;	main.c: 221: nrf_write_reg(NRF_REG_EN_AA,      0x00);
      00872E 4B 00            [ 1] 1034 	push	#0x00
      008730 A6 01            [ 1] 1035 	ld	a, #0x01
      008732 CD 83 50         [ 4] 1036 	call	_nrf_write_reg
                                   1037 ;	main.c: 222: nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
      008735 4B 01            [ 1] 1038 	push	#0x01
      008737 A6 02            [ 1] 1039 	ld	a, #0x02
      008739 CD 83 50         [ 4] 1040 	call	_nrf_write_reg
                                   1041 ;	main.c: 223: nrf_write_reg(NRF_REG_SETUP_RETR, 0x00);
      00873C 4B 00            [ 1] 1042 	push	#0x00
      00873E A6 04            [ 1] 1043 	ld	a, #0x04
      008740 CD 83 50         [ 4] 1044 	call	_nrf_write_reg
                                   1045 ;	main.c: 224: nrf_write_reg(NRF_REG_RX_PW_P0,   PAYLOAD_LEN);
      008743 4B 20            [ 1] 1046 	push	#0x20
      008745 A6 11            [ 1] 1047 	ld	a, #0x11
      008747 CD 83 50         [ 4] 1048 	call	_nrf_write_reg
                                   1049 ;	main.c: 225: nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP); // 0x0E
      00874A 4B 0E            [ 1] 1050 	push	#0x0e
      00874C 4F               [ 1] 1051 	clr	a
      00874D CD 83 50         [ 4] 1052 	call	_nrf_write_reg
                                   1053 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      008750 90 5F            [ 1] 1054 	clrw	y
      008752 5F               [ 1] 1055 	clrw	x
      008753                       1056 00104$:
      008753 90 A3 11 58      [ 2] 1057 	cpw	y, #0x1158
      008757 9F               [ 1] 1058 	ld	a, xl
      008758 A2 00            [ 1] 1059 	sbc	a, #0x00
      00875A 9E               [ 1] 1060 	ld	a, xh
      00875B A2 00            [ 1] 1061 	sbc	a, #0x00
      00875D 25 01            [ 1] 1062 	jrc	00119$
      00875F 81               [ 4] 1063 	ret
      008760                       1064 00119$:
      008760 9D               [ 1] 1065 	nop
      008761 90 5C            [ 1] 1066 	incw	y
      008763 26 EE            [ 1] 1067 	jrne	00104$
      008765 5C               [ 1] 1068 	incw	x
      008766 20 EB            [ 2] 1069 	jra	00104$
                                   1070 ;	main.c: 226: delay_ms(5);
                                   1071 ;	main.c: 227: }
      008768 81               [ 4] 1072 	ret
                                   1073 ;	main.c: 229: static void nrf_prx_start(uint8_t payload_len){
                                   1074 ;	-----------------------------------------
                                   1075 ;	 function nrf_prx_start
                                   1076 ;	-----------------------------------------
      008769                       1077 _nrf_prx_start:
      008769 88               [ 1] 1078 	push	a
      00876A 6B 01            [ 1] 1079 	ld	(0x01, sp), a
                                   1080 ;	main.c: 230: nrf_set_common(RF_CHAN);
      00876C A6 4C            [ 1] 1081 	ld	a, #0x4c
      00876E CD 86 97         [ 4] 1082 	call	_nrf_set_common
                                   1083 ;	main.c: 231: nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
      008771 4B 01            [ 1] 1084 	push	#0x01
      008773 A6 02            [ 1] 1085 	ld	a, #0x02
      008775 CD 83 50         [ 4] 1086 	call	_nrf_write_reg
                                   1087 ;	main.c: 232: nrf_write_reg(NRF_REG_EN_AA,      0x01);
      008778 4B 01            [ 1] 1088 	push	#0x01
      00877A A6 01            [ 1] 1089 	ld	a, #0x01
      00877C CD 83 50         [ 4] 1090 	call	_nrf_write_reg
                                   1091 ;	main.c: 233: nrf_write_reg(NRF_REG_RX_PW_P0,   payload_len);
      00877F 7B 01            [ 1] 1092 	ld	a, (0x01, sp)
      008781 88               [ 1] 1093 	push	a
      008782 A6 11            [ 1] 1094 	ld	a, #0x11
      008784 CD 83 50         [ 4] 1095 	call	_nrf_write_reg
                                   1096 ;	main.c: 234: nrf_write_reg(NRF_REG_SETUP_RETR, 0x5F);
      008787 4B 5F            [ 1] 1097 	push	#0x5f
      008789 A6 04            [ 1] 1098 	ld	a, #0x04
      00878B CD 83 50         [ 4] 1099 	call	_nrf_write_reg
                                   1100 ;	main.c: 235: nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP | CFG_PRIM_RX); // 0x0F
      00878E 4B 0F            [ 1] 1101 	push	#0x0f
      008790 4F               [ 1] 1102 	clr	a
      008791 CD 83 50         [ 4] 1103 	call	_nrf_write_reg
                                   1104 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      008794 90 5F            [ 1] 1105 	clrw	y
      008796 5F               [ 1] 1106 	clrw	x
      008797                       1107 00104$:
      008797 90 A3 11 58      [ 2] 1108 	cpw	y, #0x1158
      00879B 9F               [ 1] 1109 	ld	a, xl
      00879C A2 00            [ 1] 1110 	sbc	a, #0x00
      00879E 9E               [ 1] 1111 	ld	a, xh
      00879F A2 00            [ 1] 1112 	sbc	a, #0x00
      0087A1 24 08            [ 1] 1113 	jrnc	00102$
      0087A3 9D               [ 1] 1114 	nop
      0087A4 90 5C            [ 1] 1115 	incw	y
      0087A6 26 EF            [ 1] 1116 	jrne	00104$
      0087A8 5C               [ 1] 1117 	incw	x
      0087A9 20 EC            [ 2] 1118 	jra	00104$
                                   1119 ;	main.c: 236: delay_ms(5);
      0087AB                       1120 00102$:
                                   1121 ;	main.c: 237: CE_HIGH();
      0087AB 72 18 50 0F      [ 1] 1122 	bset	0x500f, #4
                                   1123 ;	main.c: 238: }
      0087AF 84               [ 1] 1124 	pop	a
      0087B0 81               [ 4] 1125 	ret
                                   1126 ;	main.c: 241: static uint8_t nrf_tx32_and_pulse_ce(const uint8_t *data, uint8_t len){
                                   1127 ;	-----------------------------------------
                                   1128 ;	 function nrf_tx32_and_pulse_ce
                                   1129 ;	-----------------------------------------
      0087B1                       1130 _nrf_tx32_and_pulse_ce:
      0087B1 52 07            [ 2] 1131 	sub	sp, #7
      0087B3 1F 02            [ 2] 1132 	ldw	(0x02, sp), x
      0087B5 6B 01            [ 1] 1133 	ld	(0x01, sp), a
                                   1134 ;	main.c: 243: nrf_write_reg(NRF_REG_STATUS, 0x70);
      0087B7 4B 70            [ 1] 1135 	push	#0x70
      0087B9 A6 07            [ 1] 1136 	ld	a, #0x07
      0087BB CD 83 50         [ 4] 1137 	call	_nrf_write_reg
                                   1138 ;	main.c: 244: (void)nrf_cmd(NRF_CMD_FLUSH_TX);
      0087BE A6 E1            [ 1] 1139 	ld	a, #0xe1
      0087C0 CD 84 58         [ 4] 1140 	call	_nrf_cmd
                                   1141 ;	main.c: 247: CSN_LOW(); (void)spi_txrx(NRF_W_TX_PAYLOAD);
      0087C3 72 15 50 0F      [ 1] 1142 	bres	0x500f, #2
      0087C7 A6 A0            [ 1] 1143 	ld	a, #0xa0
      0087C9 CD 82 EF         [ 4] 1144 	call	_spi_txrx
                                   1145 ;	main.c: 248: for(uint8_t i=0;i<32;i++) (void)spi_txrx((i<len)?data[i]:0x00);
      0087CC 4F               [ 1] 1146 	clr	a
      0087CD                       1147 00112$:
      0087CD A1 20            [ 1] 1148 	cp	a, #0x20
      0087CF 24 1B            [ 1] 1149 	jrnc	00101$
      0087D1 11 01            [ 1] 1150 	cp	a, (0x01, sp)
      0087D3 24 0D            [ 1] 1151 	jrnc	00119$
      0087D5 5F               [ 1] 1152 	clrw	x
      0087D6 97               [ 1] 1153 	ld	xl, a
      0087D7 72 FB 02         [ 2] 1154 	addw	x, (0x02, sp)
      0087DA 88               [ 1] 1155 	push	a
      0087DB F6               [ 1] 1156 	ld	a, (x)
      0087DC 97               [ 1] 1157 	ld	xl, a
      0087DD 84               [ 1] 1158 	pop	a
      0087DE 02               [ 1] 1159 	rlwa	x
      0087DF 4F               [ 1] 1160 	clr	a
      0087E0 01               [ 1] 1161 	rrwa	x
      0087E1 21                    1162 	.byte 0x21
      0087E2                       1163 00119$:
      0087E2 5F               [ 1] 1164 	clrw	x
      0087E3                       1165 00120$:
      0087E3 88               [ 1] 1166 	push	a
      0087E4 9F               [ 1] 1167 	ld	a, xl
      0087E5 CD 82 EF         [ 4] 1168 	call	_spi_txrx
      0087E8 84               [ 1] 1169 	pop	a
      0087E9 4C               [ 1] 1170 	inc	a
      0087EA 20 E1            [ 2] 1171 	jra	00112$
      0087EC                       1172 00101$:
                                   1173 ;	main.c: 249: spi_wait_idle(); CSN_HIGH();
      0087EC CD 83 00         [ 4] 1174 	call	_spi_wait_idle
      0087EF 72 14 50 0F      [ 1] 1175 	bset	0x500f, #2
                                   1176 ;	main.c: 252: nrf_dump_fifo();
      0087F3 CD 86 39         [ 4] 1177 	call	_nrf_dump_fifo
                                   1178 ;	main.c: 255: CE_HIGH(); delay_ms(2); CE_LOW();
      0087F6 72 18 50 0F      [ 1] 1179 	bset	0x500f, #4
                                   1180 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      0087FA 90 5F            [ 1] 1181 	clrw	y
      0087FC 5F               [ 1] 1182 	clrw	x
      0087FD                       1183 00115$:
      0087FD 90 A3 06 F0      [ 2] 1184 	cpw	y, #0x06f0
      008801 9F               [ 1] 1185 	ld	a, xl
      008802 A2 00            [ 1] 1186 	sbc	a, #0x00
      008804 9E               [ 1] 1187 	ld	a, xh
      008805 A2 00            [ 1] 1188 	sbc	a, #0x00
      008807 24 08            [ 1] 1189 	jrnc	00110$
      008809 9D               [ 1] 1190 	nop
      00880A 90 5C            [ 1] 1191 	incw	y
      00880C 26 EF            [ 1] 1192 	jrne	00115$
      00880E 5C               [ 1] 1193 	incw	x
      00880F 20 EC            [ 2] 1194 	jra	00115$
                                   1195 ;	main.c: 255: CE_HIGH(); delay_ms(2); CE_LOW();
      008811                       1196 00110$:
      008811 72 19 50 0F      [ 1] 1197 	bres	0x500f, #4
                                   1198 ;	main.c: 259: while(guard++ < 60000UL){
      008815 90 5F            [ 1] 1199 	clrw	y
      008817 5F               [ 1] 1200 	clrw	x
      008818 1F 04            [ 2] 1201 	ldw	(0x04, sp), x
      00881A                       1202 00106$:
      00881A 90 A3 EA 60      [ 2] 1203 	cpw	y, #0xea60
      00881E 7B 05            [ 1] 1204 	ld	a, (0x05, sp)
      008820 A2 00            [ 1] 1205 	sbc	a, #0x00
      008822 7B 04            [ 1] 1206 	ld	a, (0x04, sp)
      008824 A2 00            [ 1] 1207 	sbc	a, #0x00
      008826 24 32            [ 1] 1208 	jrnc	00108$
      008828 90 5C            [ 1] 1209 	incw	y
      00882A 26 05            [ 1] 1210 	jrne	00173$
      00882C 1E 04            [ 2] 1211 	ldw	x, (0x04, sp)
      00882E 5C               [ 1] 1212 	incw	x
      00882F 1F 04            [ 2] 1213 	ldw	(0x04, sp), x
      008831                       1214 00173$:
                                   1215 ;	main.c: 260: uint8_t s = nrf_status_raw();
      008831 90 89            [ 2] 1216 	pushw	y
      008833 CD 84 9B         [ 4] 1217 	call	_nrf_status_raw
      008836 90 85            [ 2] 1218 	popw	y
                                   1219 ;	main.c: 261: if (s & (1<<TX_DS)) { nrf_write_reg(NRF_REG_STATUS,(1<<TX_DS)); return 1; }
      008838 A5 20            [ 1] 1220 	bcp	a, #0x20
      00883A 27 0B            [ 1] 1221 	jreq	00103$
      00883C 4B 20            [ 1] 1222 	push	#0x20
      00883E A6 07            [ 1] 1223 	ld	a, #0x07
      008840 CD 83 50         [ 4] 1224 	call	_nrf_write_reg
      008843 A6 01            [ 1] 1225 	ld	a, #0x01
      008845 20 19            [ 2] 1226 	jra	00117$
      008847                       1227 00103$:
                                   1228 ;	main.c: 262: if (s & (1<<MAX_RT)) { nrf_write_reg(NRF_REG_STATUS,(1<<MAX_RT)); (void)nrf_cmd(NRF_CMD_FLUSH_TX); return 0; }
      008847 A5 10            [ 1] 1229 	bcp	a, #0x10
      008849 27 CF            [ 1] 1230 	jreq	00106$
      00884B 4B 10            [ 1] 1231 	push	#0x10
      00884D A6 07            [ 1] 1232 	ld	a, #0x07
      00884F CD 83 50         [ 4] 1233 	call	_nrf_write_reg
      008852 A6 E1            [ 1] 1234 	ld	a, #0xe1
      008854 CD 84 58         [ 4] 1235 	call	_nrf_cmd
      008857 4F               [ 1] 1236 	clr	a
      008858 20 06            [ 2] 1237 	jra	00117$
      00885A                       1238 00108$:
                                   1239 ;	main.c: 265: (void)nrf_cmd(NRF_CMD_FLUSH_TX);
      00885A A6 E1            [ 1] 1240 	ld	a, #0xe1
      00885C CD 84 58         [ 4] 1241 	call	_nrf_cmd
                                   1242 ;	main.c: 266: return 0;
      00885F 4F               [ 1] 1243 	clr	a
      008860                       1244 00117$:
                                   1245 ;	main.c: 267: }
      008860 5B 07            [ 2] 1246 	addw	sp, #7
      008862 81               [ 4] 1247 	ret
                                   1248 ;	main.c: 269: static uint8_t nrf_ptx_send_noack(const uint8_t *data, uint8_t len){
                                   1249 ;	-----------------------------------------
                                   1250 ;	 function nrf_ptx_send_noack
                                   1251 ;	-----------------------------------------
      008863                       1252 _nrf_ptx_send_noack:
                                   1253 ;	main.c: 270: return nrf_tx32_and_pulse_ce(data, len); /* TX_DS quand la trame est émise */
                                   1254 ;	main.c: 271: }
      008863 CC 87 B1         [ 2] 1255 	jp	_nrf_tx32_and_pulse_ce
                                   1256 ;	main.c: 272: static uint8_t nrf_ptx_send_ack(const uint8_t *data, uint8_t len){
                                   1257 ;	-----------------------------------------
                                   1258 ;	 function nrf_ptx_send_ack
                                   1259 ;	-----------------------------------------
      008866                       1260 _nrf_ptx_send_ack:
                                   1261 ;	main.c: 273: return nrf_tx32_and_pulse_ce(data, len); /* TX_DS si ACK reçu, MAX_RT sinon */
                                   1262 ;	main.c: 274: }
      008866 CC 87 B1         [ 2] 1263 	jp	_nrf_tx32_and_pulse_ce
                                   1264 ;	main.c: 277: static void demo_tx_loop(void){
                                   1265 ;	-----------------------------------------
                                   1266 ;	 function demo_tx_loop
                                   1267 ;	-----------------------------------------
      008869                       1268 _demo_tx_loop:
                                   1269 ;	main.c: 280: printf("\r\n===== nRF24 TX NO-ACK @ch=%u, 1Mbps, CRC16 =====\r\n", RF_CHAN);
      008869 4B 4C            [ 1] 1270 	push	#0x4c
      00886B 4B 00            [ 1] 1271 	push	#0x00
      00886D 4B 83            [ 1] 1272 	push	#<(___str_5+0)
      00886F 4B 81            [ 1] 1273 	push	#((___str_5+0) >> 8)
      008871 CD 89 94         [ 4] 1274 	call	_printf
      008874 5B 04            [ 2] 1275 	addw	sp, #4
                                   1276 ;	main.c: 281: nrf_ptx_start_noack();
      008876 CD 87 29         [ 4] 1277 	call	_nrf_ptx_start_noack
                                   1278 ;	main.c: 282: nrf_dump_core_regs();
      008879 CD 85 4F         [ 4] 1279 	call	_nrf_dump_core_regs
                                   1280 ;	main.c: 283: nrf_dump_tx_regs();
      00887C CD 85 F8         [ 4] 1281 	call	_nrf_dump_tx_regs
                                   1282 ;	main.c: 284: nrf_dump_status();
      00887F CD 84 EB         [ 4] 1283 	call	_nrf_dump_status
      008882                       1284 00107$:
                                   1285 ;	main.c: 287: uint8_t ok = nrf_ptx_send_noack(msg, sizeof(msg));
      008882 A6 05            [ 1] 1286 	ld	a, #0x05
      008884 AE 89 04         [ 2] 1287 	ldw	x, #(_demo_tx_loop_msg_65536_142+0)
      008887 CD 88 63         [ 4] 1288 	call	_nrf_ptx_send_noack
                                   1289 ;	main.c: 288: printf("[NOACK] %s\r\n", ok ? "TX_DS" : "timeout");
      00888A 4D               [ 1] 1290 	tnz	a
      00888B 27 04            [ 1] 1291 	jreq	00111$
      00888D AE 81 C5         [ 2] 1292 	ldw	x, #___str_7+0
      008890 BC                    1293 	.byte 0xbc
      008891                       1294 00111$:
      008891 AE 81 CB         [ 2] 1295 	ldw	x, #(___str_8+0)
      008894                       1296 00112$:
      008894 89               [ 2] 1297 	pushw	x
      008895 4B B8            [ 1] 1298 	push	#<(___str_6+0)
      008897 4B 81            [ 1] 1299 	push	#((___str_6+0) >> 8)
      008899 CD 89 94         [ 4] 1300 	call	_printf
      00889C 5B 04            [ 2] 1301 	addw	sp, #4
                                   1302 ;	main.c: 289: nrf_dump_status();
      00889E CD 84 EB         [ 4] 1303 	call	_nrf_dump_status
                                   1304 ;	main.c: 290: nrf_dump_fifo();
      0088A1 CD 86 39         [ 4] 1305 	call	_nrf_dump_fifo
                                   1306 ;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
      0088A4 90 5F            [ 1] 1307 	clrw	y
      0088A6 5F               [ 1] 1308 	clrw	x
      0088A7                       1309 00105$:
      0088A7 90 A3 C6 60      [ 2] 1310 	cpw	y, #0xc660
      0088AB 9F               [ 1] 1311 	ld	a, xl
      0088AC A2 06            [ 1] 1312 	sbc	a, #0x06
      0088AE 9E               [ 1] 1313 	ld	a, xh
      0088AF A2 00            [ 1] 1314 	sbc	a, #0x00
      0088B1 24 CF            [ 1] 1315 	jrnc	00107$
      0088B3 9D               [ 1] 1316 	nop
      0088B4 90 5C            [ 1] 1317 	incw	y
      0088B6 26 EF            [ 1] 1318 	jrne	00105$
      0088B8 5C               [ 1] 1319 	incw	x
      0088B9 20 EC            [ 2] 1320 	jra	00105$
                                   1321 ;	main.c: 291: delay_ms(500);
                                   1322 ;	main.c: 293: }
      0088BB 81               [ 4] 1323 	ret
                                   1324 ;	main.c: 319: void main(void){
                                   1325 ;	-----------------------------------------
                                   1326 ;	 function main
                                   1327 ;	-----------------------------------------
      0088BC                       1328 _main:
                                   1329 ;	main.c: 20: CLK_CKDIVR = 0x00; // 16 MHz
      0088BC 35 00 50 C6      [ 1] 1330 	mov	0x50c6+0, #0x00
                                   1331 ;	main.c: 22: UART1_BRR1 = (usartdiv >> 4) & 0xFF;
      0088C0 A6 68            [ 1] 1332 	ld	a, #0x68
      0088C2 C7 52 32         [ 1] 1333 	ld	0x5232, a
                                   1334 ;	main.c: 23: UART1_BRR2 = ((usartdiv & 0x0F) | ((usartdiv >> 8) & 0xF0));
      0088C5 A6 83            [ 1] 1335 	ld	a, #0x83
      0088C7 A4 0F            [ 1] 1336 	and	a, #0x0f
      0088C9 C7 52 33         [ 1] 1337 	ld	0x5233, a
                                   1338 ;	main.c: 24: UART1_CR1 = 0x00;
      0088CC 35 00 52 34      [ 1] 1339 	mov	0x5234+0, #0x00
                                   1340 ;	main.c: 25: UART1_CR3 = 0x00;
      0088D0 35 00 52 36      [ 1] 1341 	mov	0x5236+0, #0x00
                                   1342 ;	main.c: 26: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
      0088D4 35 0C 52 35      [ 1] 1343 	mov	0x5235+0, #0x0c
                                   1344 ;	main.c: 27: (void)UART1_SR; (void)UART1_DR;
      0088D8 C6 52 30         [ 1] 1345 	ld	a, 0x5230
      0088DB C6 52 31         [ 1] 1346 	ld	a, 0x5231
                                   1347 ;	main.c: 321: printf("\r\n[STM8S] nRF24L01+ TX\r\n");
      0088DE AE 81 D3         [ 2] 1348 	ldw	x, #(___str_10+0)
      0088E1 CD 89 60         [ 4] 1349 	call	_puts
                                   1350 ;	main.c: 322: gpio_init_spi();
      0088E4 CD 82 B1         [ 4] 1351 	call	_gpio_init_spi
                                   1352 ;	main.c: 323: spi_init();
      0088E7 CD 82 E2         [ 4] 1353 	call	_spi_init
                                   1354 ;	main.c: 325: if(!nrf_bus_ok()){
      0088EA CD 84 DC         [ 4] 1355 	call	_nrf_bus_ok
      0088ED 4D               [ 1] 1356 	tnz	a
      0088EE 27 03            [ 1] 1357 	jreq	00119$
      0088F0 CC 88 69         [ 2] 1358 	jp	_demo_tx_loop
      0088F3                       1359 00119$:
                                   1360 ;	main.c: 326: printf("SPI KO: STATUS=0x%02X (verifie CSN/SCK/MOSI/MISO/VCC)\r\n", nrf_status_raw());
      0088F3 CD 84 9B         [ 4] 1361 	call	_nrf_status_raw
      0088F6 5F               [ 1] 1362 	clrw	x
      0088F7 97               [ 1] 1363 	ld	xl, a
      0088F8 89               [ 2] 1364 	pushw	x
      0088F9 4B EB            [ 1] 1365 	push	#<(___str_11+0)
      0088FB 4B 81            [ 1] 1366 	push	#((___str_11+0) >> 8)
      0088FD CD 89 94         [ 4] 1367 	call	_printf
      008900 5B 04            [ 2] 1368 	addw	sp, #4
                                   1369 ;	main.c: 327: while(1);
      008902                       1370 00102$:
                                   1371 ;	main.c: 330: demo_tx_loop(); /* NO-ACK par défaut (simple à valider) */
                                   1372 ;	main.c: 331: }
      008902 20 FE            [ 2] 1373 	jra	00102$
                                   1374 	.area CODE
                                   1375 	.area CONST
      008024                       1376 _ADDR_NODE1:
      008024 4E                    1377 	.db #0x4e	; 78	'N'
      008025 4F                    1378 	.db #0x4f	; 79	'O'
      008026 44                    1379 	.db #0x44	; 68	'D'
      008027 45                    1380 	.db #0x45	; 69	'E'
      008028 31                    1381 	.db #0x31	; 49	'1'
                                   1382 	.area CONST
      008029                       1383 ___str_0:
      008029 0D                    1384 	.db 0x0d
      00802A 0A                    1385 	.db 0x0a
      00802B 5B 53 54 41 54 55 53  1386 	.ascii "[STATUS] 0x%02X  (RX_DR=%d TX_DS=%d MAX_RT=%d RX_PIPE=%u TX_"
             5D 20 30 78 25 30 32
             58 20 20 28 52 58 5F
             44 52 3D 25 64 20 54
             58 5F 44 53 3D 25 64
             20 4D 41 58 5F 52 54
             3D 25 64 20 52 58 5F
             50 49 50 45 3D 25 75
             20 54 58 5F
      008067 46 55 4C 4C 3D 25 64  1387 	.ascii "FULL=%d)"
             29
      00806F 0D                    1388 	.db 0x0d
      008070 0A                    1389 	.db 0x0a
      008071 00                    1390 	.db 0x00
                                   1391 	.area CODE
                                   1392 	.area CONST
      008072                       1393 ___str_1:
      008072 5B 43 4F 52 45 5D 20  1394 	.ascii "[CORE]   CONFIG=0x%02X  RF_CH=0x%02X  RF_SETUP=0x%02X"
             20 20 43 4F 4E 46 49
             47 3D 30 78 25 30 32
             58 20 20 52 46 5F 43
             48 3D 30 78 25 30 32
             58 20 20 52 46 5F 53
             45 54 55 50 3D 30 78
             25 30 32 58
      0080A7 0D                    1395 	.db 0x0d
      0080A8 0A                    1396 	.db 0x0a
      0080A9 00                    1397 	.db 0x00
                                   1398 	.area CODE
                                   1399 	.area CONST
      0080AA                       1400 ___str_2:
      0080AA 5B 41 44 44 52 5D 20  1401 	.ascii "[ADDR]   TX_ADDR=%02X %02X %02X %02X %02X  |  RX0=%02X %02X "
             20 20 54 58 5F 41 44
             44 52 3D 25 30 32 58
             20 25 30 32 58 20 25
             30 32 58 20 25 30 32
             58 20 25 30 32 58 20
             20 7C 20 20 52 58 30
             3D 25 30 32 58 20 25
             30 32 58 20
      0080E6 25 30 32 58 20 25 30  1402 	.ascii "%02X %02X %02X"
             32 58 20 25 30 32 58
      0080F4 0D                    1403 	.db 0x0d
      0080F5 0A                    1404 	.db 0x0a
      0080F6 00                    1405 	.db 0x00
                                   1406 	.area CODE
                                   1407 	.area CONST
      0080F7                       1408 ___str_3:
      0080F7 5B 54 58 43 46 47 5D  1409 	.ascii "[TXCFG]  EN_AA=0x%02X  EN_RXADDR=0x%02X  SETUP_RETR=0x%02X  "
             20 20 45 4E 5F 41 41
             3D 30 78 25 30 32 58
             20 20 45 4E 5F 52 58
             41 44 44 52 3D 30 78
             25 30 32 58 20 20 53
             45 54 55 50 5F 52 45
             54 52 3D 30 78 25 30
             32 58 20 20
      008133 52 58 5F 50 57 5F 50  1410 	.ascii "RX_PW_P0=%u"
             30 3D 25 75
      00813E 0D                    1411 	.db 0x0d
      00813F 0A                    1412 	.db 0x0a
      008140 00                    1413 	.db 0x00
                                   1414 	.area CODE
                                   1415 	.area CONST
      008141                       1416 ___str_4:
      008141 5B 46 49 46 4F 5D 20  1417 	.ascii "[FIFO]   0x%02X  TX_EMPTY=%d TX_FULL=%d  RX_EMPTY=%d RX_FULL"
             20 20 30 78 25 30 32
             58 20 20 54 58 5F 45
             4D 50 54 59 3D 25 64
             20 54 58 5F 46 55 4C
             4C 3D 25 64 20 20 52
             58 5F 45 4D 50 54 59
             3D 25 64 20 52 58 5F
             46 55 4C 4C
      00817D 3D 25 64              1418 	.ascii "=%d"
      008180 0D                    1419 	.db 0x0d
      008181 0A                    1420 	.db 0x0a
      008182 00                    1421 	.db 0x00
                                   1422 	.area CODE
      008904                       1423 _demo_tx_loop_msg_65536_142:
      008904 48                    1424 	.db #0x48	; 72	'H'
      008905 45                    1425 	.db #0x45	; 69	'E'
      008906 4C                    1426 	.db #0x4c	; 76	'L'
      008907 4C                    1427 	.db #0x4c	; 76	'L'
      008908 4F                    1428 	.db #0x4f	; 79	'O'
                                   1429 	.area CONST
      008183                       1430 ___str_5:
      008183 0D                    1431 	.db 0x0d
      008184 0A                    1432 	.db 0x0a
      008185 3D 3D 3D 3D 3D 20 6E  1433 	.ascii "===== nRF24 TX NO-ACK @ch=%u, 1Mbps, CRC16 ====="
             52 46 32 34 20 54 58
             20 4E 4F 2D 41 43 4B
             20 40 63 68 3D 25 75
             2C 20 31 4D 62 70 73
             2C 20 43 52 43 31 36
             20 3D 3D 3D 3D 3D
      0081B5 0D                    1434 	.db 0x0d
      0081B6 0A                    1435 	.db 0x0a
      0081B7 00                    1436 	.db 0x00
                                   1437 	.area CODE
                                   1438 	.area CONST
      0081B8                       1439 ___str_6:
      0081B8 5B 4E 4F 41 43 4B 5D  1440 	.ascii "[NOACK] %s"
             20 25 73
      0081C2 0D                    1441 	.db 0x0d
      0081C3 0A                    1442 	.db 0x0a
      0081C4 00                    1443 	.db 0x00
                                   1444 	.area CODE
                                   1445 	.area CONST
      0081C5                       1446 ___str_7:
      0081C5 54 58 5F 44 53        1447 	.ascii "TX_DS"
      0081CA 00                    1448 	.db 0x00
                                   1449 	.area CODE
                                   1450 	.area CONST
      0081CB                       1451 ___str_8:
      0081CB 74 69 6D 65 6F 75 74  1452 	.ascii "timeout"
      0081D2 00                    1453 	.db 0x00
                                   1454 	.area CODE
                                   1455 	.area CONST
      0081D3                       1456 ___str_10:
      0081D3 0D                    1457 	.db 0x0d
      0081D4 0A                    1458 	.db 0x0a
      0081D5 5B 53 54 4D 38 53 5D  1459 	.ascii "[STM8S] nRF24L01+ TX"
             20 6E 52 46 32 34 4C
             30 31 2B 20 54 58
      0081E9 0D                    1460 	.db 0x0d
      0081EA 00                    1461 	.db 0x00
                                   1462 	.area CODE
                                   1463 	.area CONST
      0081EB                       1464 ___str_11:
      0081EB 53 50 49 20 4B 4F 3A  1465 	.ascii "SPI KO: STATUS=0x%02X (verifie CSN/SCK/MOSI/MISO/VCC)"
             20 53 54 41 54 55 53
             3D 30 78 25 30 32 58
             20 28 76 65 72 69 66
             69 65 20 43 53 4E 2F
             53 43 4B 2F 4D 4F 53
             49 2F 4D 49 53 4F 2F
             56 43 43 29
      008220 0D                    1466 	.db 0x0d
      008221 0A                    1467 	.db 0x0a
      008222 00                    1468 	.db 0x00
                                   1469 	.area CODE
                                   1470 	.area INITIALIZER
                                   1471 	.area CABS (ABS)
