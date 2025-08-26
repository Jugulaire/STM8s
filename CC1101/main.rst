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
                                     12 	.globl _printf
                                     13 	.globl _putchar
                                     14 ;--------------------------------------------------------
                                     15 ; ram data
                                     16 ;--------------------------------------------------------
                                     17 	.area DATA
                                     18 ;--------------------------------------------------------
                                     19 ; ram data
                                     20 ;--------------------------------------------------------
                                     21 	.area INITIALIZED
                                     22 ;--------------------------------------------------------
                                     23 ; Stack segment in internal ram
                                     24 ;--------------------------------------------------------
                                     25 	.area	SSEG
      000001                         26 __start__stack:
      000001                         27 	.ds	1
                                     28 
                                     29 ;--------------------------------------------------------
                                     30 ; absolute external ram data
                                     31 ;--------------------------------------------------------
                                     32 	.area DABS (ABS)
                                     33 
                                     34 ; default segment ordering for linker
                                     35 	.area HOME
                                     36 	.area GSINIT
                                     37 	.area GSFINAL
                                     38 	.area CONST
                                     39 	.area INITIALIZER
                                     40 	.area CODE
                                     41 
                                     42 ;--------------------------------------------------------
                                     43 ; interrupt vector
                                     44 ;--------------------------------------------------------
                                     45 	.area HOME
      008000                         46 __interrupt_vect:
      008000 82 00 80 07             47 	int s_GSINIT ; reset
                                     48 ;--------------------------------------------------------
                                     49 ; global & static initialisations
                                     50 ;--------------------------------------------------------
                                     51 	.area HOME
                                     52 	.area GSINIT
                                     53 	.area GSFINAL
                                     54 	.area GSINIT
      008007                         55 __sdcc_init_data:
                                     56 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   57 	ldw x, #l_DATA
      00800A 27 07            [ 1]   58 	jreq	00002$
      00800C                         59 00001$:
      00800C 72 4F 00 00      [ 1]   60 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   61 	decw x
      008011 26 F9            [ 1]   62 	jrne	00001$
      008013                         63 00002$:
      008013 AE 00 00         [ 2]   64 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   65 	jreq	00004$
      008018                         66 00003$:
      008018 D6 80 B9         [ 1]   67 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   68 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   69 	decw	x
      00801F 26 F7            [ 1]   70 	jrne	00003$
      008021                         71 00004$:
                                     72 ; stm8_genXINIT() end
                                     73 	.area GSFINAL
      008021 CC 80 04         [ 2]   74 	jp	__sdcc_program_startup
                                     75 ;--------------------------------------------------------
                                     76 ; Home
                                     77 ;--------------------------------------------------------
                                     78 	.area HOME
                                     79 	.area HOME
      008004                         80 __sdcc_program_startup:
      008004 CC 84 2F         [ 2]   81 	jp	_main
                                     82 ;	return from main will return to caller
                                     83 ;--------------------------------------------------------
                                     84 ; code
                                     85 ;--------------------------------------------------------
                                     86 	.area CODE
                                     87 ;	main.c: 19: static void uart_init(void){
                                     88 ;	-----------------------------------------
                                     89 ;	 function uart_init
                                     90 ;	-----------------------------------------
      0080BA                         91 _uart_init:
                                     92 ;	main.c: 20: CLK_CKDIVR = 0x00;
      0080BA 35 00 50 C6      [ 1]   93 	mov	0x50c6+0, #0x00
                                     94 ;	main.c: 22: UART1_BRR1 = (div >> 4) & 0xFF;
      0080BE A6 68            [ 1]   95 	ld	a, #0x68
      0080C0 C7 52 32         [ 1]   96 	ld	0x5232, a
                                     97 ;	main.c: 23: UART1_BRR2 = ((div & 0x0F) | ((div >> 8) & 0xF0));
      0080C3 A6 83            [ 1]   98 	ld	a, #0x83
      0080C5 A4 0F            [ 1]   99 	and	a, #0x0f
      0080C7 C7 52 33         [ 1]  100 	ld	0x5233, a
                                    101 ;	main.c: 24: UART1_CR1 = 0x00; UART1_CR3 = 0x00;
      0080CA 35 00 52 34      [ 1]  102 	mov	0x5234+0, #0x00
      0080CE 35 00 52 36      [ 1]  103 	mov	0x5236+0, #0x00
                                    104 ;	main.c: 25: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
      0080D2 35 0C 52 35      [ 1]  105 	mov	0x5235+0, #0x0c
                                    106 ;	main.c: 26: (void)UART1_SR; (void)UART1_DR;
      0080D6 C6 52 30         [ 1]  107 	ld	a, 0x5230
      0080D9 C6 52 31         [ 1]  108 	ld	a, 0x5231
                                    109 ;	main.c: 27: }
      0080DC 81               [ 4]  110 	ret
                                    111 ;	main.c: 28: int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; }
                                    112 ;	-----------------------------------------
                                    113 ;	 function putchar
                                    114 ;	-----------------------------------------
      0080DD                        115 _putchar:
      0080DD                        116 00101$:
      0080DD C6 52 30         [ 1]  117 	ld	a, 0x5230
      0080E0 2A FB            [ 1]  118 	jrpl	00101$
      0080E2 9F               [ 1]  119 	ld	a, xl
      0080E3 C7 52 31         [ 1]  120 	ld	0x5231, a
      0080E6 5F               [ 1]  121 	clrw	x
      0080E7 81               [ 4]  122 	ret
                                    123 ;	main.c: 29: static inline void delay_cycles(volatile uint16_t n){ while(n--) __asm__("nop"); }
                                    124 ;	-----------------------------------------
                                    125 ;	 function delay_cycles
                                    126 ;	-----------------------------------------
      0080E8                        127 _delay_cycles:
      0080E8 52 02            [ 2]  128 	sub	sp, #2
      0080EA 1F 01            [ 2]  129 	ldw	(0x01, sp), x
      0080EC                        130 00101$:
      0080EC 16 01            [ 2]  131 	ldw	y, (0x01, sp)
      0080EE 93               [ 1]  132 	ldw	x, y
      0080EF 5A               [ 2]  133 	decw	x
      0080F0 1F 01            [ 2]  134 	ldw	(0x01, sp), x
      0080F2 90 5D            [ 2]  135 	tnzw	y
      0080F4 27 03            [ 1]  136 	jreq	00104$
      0080F6 9D               [ 1]  137 	nop
      0080F7 20 F3            [ 2]  138 	jra	00101$
      0080F9                        139 00104$:
      0080F9 5B 02            [ 2]  140 	addw	sp, #2
      0080FB 81               [ 4]  141 	ret
                                    142 ;	main.c: 30: static void delay_ms(uint16_t ms){ for(uint32_t i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop"); }
                                    143 ;	-----------------------------------------
                                    144 ;	 function delay_ms
                                    145 ;	-----------------------------------------
      0080FC                        146 _delay_ms:
      0080FC 52 0A            [ 2]  147 	sub	sp, #10
      0080FE 1F 05            [ 2]  148 	ldw	(0x05, sp), x
      008100 5F               [ 1]  149 	clrw	x
      008101 1F 09            [ 2]  150 	ldw	(0x09, sp), x
      008103 1F 07            [ 2]  151 	ldw	(0x07, sp), x
      008105                        152 00103$:
      008105 1E 05            [ 2]  153 	ldw	x, (0x05, sp)
      008107 89               [ 2]  154 	pushw	x
      008108 AE 03 78         [ 2]  155 	ldw	x, #0x0378
      00810B CD 84 90         [ 4]  156 	call	___muluint2ulong
      00810E 5B 02            [ 2]  157 	addw	sp, #2
      008110 1F 03            [ 2]  158 	ldw	(0x03, sp), x
      008112 17 01            [ 2]  159 	ldw	(0x01, sp), y
      008114 1E 09            [ 2]  160 	ldw	x, (0x09, sp)
      008116 13 03            [ 2]  161 	cpw	x, (0x03, sp)
      008118 7B 08            [ 1]  162 	ld	a, (0x08, sp)
      00811A 12 02            [ 1]  163 	sbc	a, (0x02, sp)
      00811C 7B 07            [ 1]  164 	ld	a, (0x07, sp)
      00811E 12 01            [ 1]  165 	sbc	a, (0x01, sp)
      008120 24 0F            [ 1]  166 	jrnc	00105$
      008122 9D               [ 1]  167 	nop
      008123 1E 09            [ 2]  168 	ldw	x, (0x09, sp)
      008125 5C               [ 1]  169 	incw	x
      008126 1F 09            [ 2]  170 	ldw	(0x09, sp), x
      008128 26 DB            [ 1]  171 	jrne	00103$
      00812A 1E 07            [ 2]  172 	ldw	x, (0x07, sp)
      00812C 5C               [ 1]  173 	incw	x
      00812D 1F 07            [ 2]  174 	ldw	(0x07, sp), x
      00812F 20 D4            [ 2]  175 	jra	00103$
      008131                        176 00105$:
      008131 5B 0A            [ 2]  177 	addw	sp, #10
      008133 81               [ 4]  178 	ret
                                    179 ;	main.c: 46: static void gpio_init(void){
                                    180 ;	-----------------------------------------
                                    181 ;	 function gpio_init
                                    182 ;	-----------------------------------------
      008134                        183 _gpio_init:
                                    184 ;	main.c: 48: PC_DDR |= (1<<5) | (1<<MOSI_BIT);
      008134 C6 50 0C         [ 1]  185 	ld	a, 0x500c
      008137 AA 60            [ 1]  186 	or	a, #0x60
      008139 C7 50 0C         [ 1]  187 	ld	0x500c, a
                                    188 ;	main.c: 49: PC_CR1 |= (1<<5) | (1<<MOSI_BIT);
      00813C C6 50 0D         [ 1]  189 	ld	a, 0x500d
      00813F AA 60            [ 1]  190 	or	a, #0x60
      008141 C7 50 0D         [ 1]  191 	ld	0x500d, a
                                    192 ;	main.c: 51: PC_DDR &= (uint8_t)~(1<<MISO_BIT);
      008144 72 1F 50 0C      [ 1]  193 	bres	0x500c, #7
                                    194 ;	main.c: 52: PC_CR1 &= (uint8_t)~(1<<MISO_BIT);
      008148 72 1F 50 0D      [ 1]  195 	bres	0x500d, #7
                                    196 ;	main.c: 54: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
      00814C 72 14 50 11      [ 1]  197 	bset	0x5011, #2
      008150 72 14 50 12      [ 1]  198 	bset	0x5012, #2
      008154 72 14 50 0F      [ 1]  199 	bset	0x500f, #2
                                    200 ;	main.c: 56: PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
      008158 72 19 50 11      [ 1]  201 	bres	0x5011, #4
      00815C 72 19 50 12      [ 1]  202 	bres	0x5012, #4
                                    203 ;	main.c: 57: }
      008160 81               [ 4]  204 	ret
                                    205 ;	main.c: 59: static void spi_init(void){
                                    206 ;	-----------------------------------------
                                    207 ;	 function spi_init
                                    208 ;	-----------------------------------------
      008161                        209 _spi_init:
                                    210 ;	main.c: 61: SPI_CR1 = (1<<SPI_CR1_MSTR) | (1<<SPI_CR1_BR2) | (1<<SPI_CR1_BR1) | (1<<SPI_CR1_BR0);
      008161 35 3C 52 00      [ 1]  211 	mov	0x5200+0, #0x3c
                                    212 ;	main.c: 62: SPI_CR2 = (1<<SPI_CR2_SSM) | (1<<SPI_CR2_SSI);
      008165 35 03 52 01      [ 1]  213 	mov	0x5201+0, #0x03
                                    214 ;	main.c: 63: SPI_CR1 |= (1<<SPI_CR1_SPE);
      008169 72 1C 52 00      [ 1]  215 	bset	0x5200, #6
                                    216 ;	main.c: 64: }
      00816D 81               [ 4]  217 	ret
                                    218 ;	main.c: 65: static uint8_t spi_txrx(uint8_t v){
                                    219 ;	-----------------------------------------
                                    220 ;	 function spi_txrx
                                    221 ;	-----------------------------------------
      00816E                        222 _spi_txrx:
                                    223 ;	main.c: 66: SPI_DR = v;
      00816E C7 52 04         [ 1]  224 	ld	0x5204, a
                                    225 ;	main.c: 67: while(!(SPI_SR & (1<<SPI_SR_TXE)));
      008171                        226 00101$:
      008171 72 03 52 03 FB   [ 2]  227 	btjf	0x5203, #1, 00101$
                                    228 ;	main.c: 68: while(!(SPI_SR & (1<<SPI_SR_RXNE)));
      008176                        229 00104$:
      008176 72 01 52 03 FB   [ 2]  230 	btjf	0x5203, #0, 00104$
                                    231 ;	main.c: 69: return SPI_DR;
      00817B C6 52 04         [ 1]  232 	ld	a, 0x5204
                                    233 ;	main.c: 70: }
      00817E 81               [ 4]  234 	ret
                                    235 ;	main.c: 71: static void spi_wait_idle(void){ while(SPI_SR & (1<<SPI_SR_BSY)); }
                                    236 ;	-----------------------------------------
                                    237 ;	 function spi_wait_idle
                                    238 ;	-----------------------------------------
      00817F                        239 _spi_wait_idle:
      00817F                        240 00101$:
      00817F C6 52 03         [ 1]  241 	ld	a, 0x5203
      008182 2B FB            [ 1]  242 	jrmi	00101$
      008184 81               [ 4]  243 	ret
                                    244 ;	main.c: 86: static uint8_t cc_select(void){
                                    245 ;	-----------------------------------------
                                    246 ;	 function cc_select
                                    247 ;	-----------------------------------------
      008185                        248 _cc_select:
      008185 52 04            [ 2]  249 	sub	sp, #4
                                    250 ;	main.c: 87: CSN_LOW();
      008187 72 15 50 0F      [ 1]  251 	bres	0x500f, #2
                                    252 ;	main.c: 90: while(MISO_IS_HIGH()){
      00818B 5F               [ 1]  253 	clrw	x
      00818C 1F 03            [ 2]  254 	ldw	(0x03, sp), x
      00818E 1F 01            [ 2]  255 	ldw	(0x01, sp), x
      008190                        256 00103$:
      008190 C6 50 0B         [ 1]  257 	ld	a, 0x500b
      008193 2A 20            [ 1]  258 	jrpl	00105$
                                    259 ;	main.c: 91: if(++guard>100000UL){ CSN_HIGH(); return 0; }
      008195 1E 03            [ 2]  260 	ldw	x, (0x03, sp)
      008197 5C               [ 1]  261 	incw	x
      008198 1F 03            [ 2]  262 	ldw	(0x03, sp), x
      00819A 26 05            [ 1]  263 	jrne	00124$
      00819C 1E 01            [ 2]  264 	ldw	x, (0x01, sp)
      00819E 5C               [ 1]  265 	incw	x
      00819F 1F 01            [ 2]  266 	ldw	(0x01, sp), x
      0081A1                        267 00124$:
      0081A1 AE 86 A0         [ 2]  268 	ldw	x, #0x86a0
      0081A4 13 03            [ 2]  269 	cpw	x, (0x03, sp)
      0081A6 A6 01            [ 1]  270 	ld	a, #0x01
      0081A8 12 02            [ 1]  271 	sbc	a, (0x02, sp)
      0081AA 4F               [ 1]  272 	clr	a
      0081AB 12 01            [ 1]  273 	sbc	a, (0x01, sp)
      0081AD 24 E1            [ 1]  274 	jrnc	00103$
      0081AF 72 14 50 0F      [ 1]  275 	bset	0x500f, #2
      0081B3 4F               [ 1]  276 	clr	a
                                    277 ;	main.c: 93: return 1;
      0081B4 C5                     278 	.byte 0xc5
      0081B5                        279 00105$:
      0081B5 A6 01            [ 1]  280 	ld	a, #0x01
      0081B7                        281 00106$:
                                    282 ;	main.c: 94: }
      0081B7 5B 04            [ 2]  283 	addw	sp, #4
      0081B9 81               [ 4]  284 	ret
                                    285 ;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
                                    286 ;	-----------------------------------------
                                    287 ;	 function cc_deselect
                                    288 ;	-----------------------------------------
      0081BA                        289 _cc_deselect:
      0081BA CD 81 7F         [ 4]  290 	call	_spi_wait_idle
      0081BD 72 14 50 0F      [ 1]  291 	bset	0x500f, #2
      0081C1 81               [ 4]  292 	ret
                                    293 ;	main.c: 97: static uint8_t cc_strobe(uint8_t st){
                                    294 ;	-----------------------------------------
                                    295 ;	 function cc_strobe
                                    296 ;	-----------------------------------------
      0081C2                        297 _cc_strobe:
      0081C2 52 02            [ 2]  298 	sub	sp, #2
      0081C4 6B 02            [ 1]  299 	ld	(0x02, sp), a
                                    300 ;	main.c: 98: if(!cc_select()) return 0xFF;
      0081C6 CD 81 85         [ 4]  301 	call	_cc_select
      0081C9 4D               [ 1]  302 	tnz	a
      0081CA 26 04            [ 1]  303 	jrne	00102$
      0081CC A6 FF            [ 1]  304 	ld	a, #0xff
      0081CE 20 10            [ 2]  305 	jra	00104$
      0081D0                        306 00102$:
                                    307 ;	main.c: 99: uint8_t s = spi_txrx(st);
      0081D0 7B 02            [ 1]  308 	ld	a, (0x02, sp)
      0081D2 CD 81 6E         [ 4]  309 	call	_spi_txrx
      0081D5 6B 01            [ 1]  310 	ld	(0x01, sp), a
                                    311 ;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0081D7 CD 81 7F         [ 4]  312 	call	_spi_wait_idle
      0081DA 72 14 50 0F      [ 1]  313 	bset	0x500f, #2
                                    314 ;	main.c: 101: return s;
      0081DE 7B 01            [ 1]  315 	ld	a, (0x01, sp)
      0081E0                        316 00104$:
                                    317 ;	main.c: 102: }
      0081E0 5B 02            [ 2]  318 	addw	sp, #2
      0081E2 81               [ 4]  319 	ret
                                    320 ;	main.c: 103: static void cc_write_reg(uint8_t a, uint8_t v){
                                    321 ;	-----------------------------------------
                                    322 ;	 function cc_write_reg
                                    323 ;	-----------------------------------------
      0081E3                        324 _cc_write_reg:
      0081E3 88               [ 1]  325 	push	a
      0081E4 6B 01            [ 1]  326 	ld	(0x01, sp), a
                                    327 ;	main.c: 104: if(!cc_select()) return;
      0081E6 CD 81 85         [ 4]  328 	call	_cc_select
      0081E9 4D               [ 1]  329 	tnz	a
      0081EA 27 15            [ 1]  330 	jreq	00104$
                                    331 ;	main.c: 105: spi_txrx(a); spi_txrx(v);
      0081EC 7B 01            [ 1]  332 	ld	a, (0x01, sp)
      0081EE CD 81 6E         [ 4]  333 	call	_spi_txrx
      0081F1 7B 04            [ 1]  334 	ld	a, (0x04, sp)
      0081F3 CD 81 6E         [ 4]  335 	call	_spi_txrx
                                    336 ;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      0081F6 CD 81 7F         [ 4]  337 	call	_spi_wait_idle
      0081F9 C6 50 0F         [ 1]  338 	ld	a, 0x500f
      0081FC AA 04            [ 1]  339 	or	a, #0x04
      0081FE C7 50 0F         [ 1]  340 	ld	0x500f, a
                                    341 ;	main.c: 106: cc_deselect();
      008201                        342 00104$:
                                    343 ;	main.c: 107: }
      008201 84               [ 1]  344 	pop	a
      008202 85               [ 2]  345 	popw	x
      008203 84               [ 1]  346 	pop	a
      008204 FC               [ 2]  347 	jp	(x)
                                    348 ;	main.c: 108: static uint8_t cc_read_status(uint8_t addr){
                                    349 ;	-----------------------------------------
                                    350 ;	 function cc_read_status
                                    351 ;	-----------------------------------------
      008205                        352 _cc_read_status:
      008205 52 02            [ 2]  353 	sub	sp, #2
      008207 6B 02            [ 1]  354 	ld	(0x02, sp), a
                                    355 ;	main.c: 110: if(!cc_select()) return 0xFF;
      008209 CD 81 85         [ 4]  356 	call	_cc_select
      00820C 4D               [ 1]  357 	tnz	a
      00820D 26 04            [ 1]  358 	jrne	00102$
      00820F A6 FF            [ 1]  359 	ld	a, #0xff
      008211 20 17            [ 2]  360 	jra	00104$
      008213                        361 00102$:
                                    362 ;	main.c: 111: (void)spi_txrx(addr | 0xC0);   // 0x80 -> 0xC0
      008213 7B 02            [ 1]  363 	ld	a, (0x02, sp)
      008215 AA C0            [ 1]  364 	or	a, #0xc0
      008217 CD 81 6E         [ 4]  365 	call	_spi_txrx
                                    366 ;	main.c: 112: v = spi_txrx(0xFF);
      00821A A6 FF            [ 1]  367 	ld	a, #0xff
      00821C CD 81 6E         [ 4]  368 	call	_spi_txrx
      00821F 6B 01            [ 1]  369 	ld	(0x01, sp), a
                                    370 ;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      008221 CD 81 7F         [ 4]  371 	call	_spi_wait_idle
      008224 72 14 50 0F      [ 1]  372 	bset	0x500f, #2
                                    373 ;	main.c: 114: return v;
      008228 7B 01            [ 1]  374 	ld	a, (0x01, sp)
      00822A                        375 00104$:
                                    376 ;	main.c: 115: }
      00822A 5B 02            [ 2]  377 	addw	sp, #2
      00822C 81               [ 4]  378 	ret
                                    379 ;	main.c: 119: static void cc_reset(void){
                                    380 ;	-----------------------------------------
                                    381 ;	 function cc_reset
                                    382 ;	-----------------------------------------
      00822D                        383 _cc_reset:
                                    384 ;	main.c: 120: CSN_HIGH(); delay_ms(5);
      00822D 72 14 50 0F      [ 1]  385 	bset	0x500f, #2
      008231 AE 00 05         [ 2]  386 	ldw	x, #0x0005
      008234 CD 80 FC         [ 4]  387 	call	_delay_ms
                                    388 ;	main.c: 121: CSN_LOW();  delay_ms(5);
      008237 72 15 50 0F      [ 1]  389 	bres	0x500f, #2
      00823B AE 00 05         [ 2]  390 	ldw	x, #0x0005
      00823E CD 80 FC         [ 4]  391 	call	_delay_ms
                                    392 ;	main.c: 122: CSN_HIGH(); delay_ms(5);
      008241 C6 50 0F         [ 1]  393 	ld	a, 0x500f
      008244 AA 04            [ 1]  394 	or	a, #0x04
      008246 C7 50 0F         [ 1]  395 	ld	0x500f, a
      008249 AE 00 05         [ 2]  396 	ldw	x, #0x0005
      00824C CD 80 FC         [ 4]  397 	call	_delay_ms
                                    398 ;	main.c: 123: if(!cc_select()) return;
      00824F CD 81 85         [ 4]  399 	call	_cc_select
      008252 4D               [ 1]  400 	tnz	a
      008253 26 01            [ 1]  401 	jrne	00102$
      008255 81               [ 4]  402 	ret
      008256                        403 00102$:
                                    404 ;	main.c: 124: spi_txrx(SRES);
      008256 A6 30            [ 1]  405 	ld	a, #0x30
      008258 CD 81 6E         [ 4]  406 	call	_spi_txrx
                                    407 ;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      00825B CD 81 7F         [ 4]  408 	call	_spi_wait_idle
      00825E C6 50 0F         [ 1]  409 	ld	a, 0x500f
      008261 AA 04            [ 1]  410 	or	a, #0x04
      008263 C7 50 0F         [ 1]  411 	ld	0x500f, a
                                    412 ;	main.c: 126: delay_ms(5);
      008266 AE 00 05         [ 2]  413 	ldw	x, #0x0005
                                    414 ;	main.c: 127: }
      008269 CC 80 FC         [ 2]  415 	jp	_delay_ms
                                    416 ;	main.c: 130: static void cc_config_868(void){
                                    417 ;	-----------------------------------------
                                    418 ;	 function cc_config_868
                                    419 ;	-----------------------------------------
      00826C                        420 _cc_config_868:
                                    421 ;	main.c: 131: cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
      00826C 4B 29            [ 1]  422 	push	#0x29
      00826E 4F               [ 1]  423 	clr	a
      00826F CD 81 E3         [ 4]  424 	call	_cc_write_reg
      008272 4B 06            [ 1]  425 	push	#0x06
      008274 A6 02            [ 1]  426 	ld	a, #0x02
      008276 CD 81 E3         [ 4]  427 	call	_cc_write_reg
      008279 4B 47            [ 1]  428 	push	#0x47
      00827B A6 03            [ 1]  429 	ld	a, #0x03
      00827D CD 81 E3         [ 4]  430 	call	_cc_write_reg
                                    431 ;	main.c: 132: cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
      008280 4B 3D            [ 1]  432 	push	#0x3d
      008282 A6 06            [ 1]  433 	ld	a, #0x06
      008284 CD 81 E3         [ 4]  434 	call	_cc_write_reg
      008287 4B 04            [ 1]  435 	push	#0x04
      008289 A6 07            [ 1]  436 	ld	a, #0x07
      00828B CD 81 E3         [ 4]  437 	call	_cc_write_reg
      00828E 4B 05            [ 1]  438 	push	#0x05
      008290 A6 08            [ 1]  439 	ld	a, #0x08
      008292 CD 81 E3         [ 4]  440 	call	_cc_write_reg
                                    441 ;	main.c: 133: cc_write_reg(0x0B,0x06); cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
      008295 4B 06            [ 1]  442 	push	#0x06
      008297 A6 0B            [ 1]  443 	ld	a, #0x0b
      008299 CD 81 E3         [ 4]  444 	call	_cc_write_reg
      00829C 4B 21            [ 1]  445 	push	#0x21
      00829E A6 0D            [ 1]  446 	ld	a, #0x0d
      0082A0 CD 81 E3         [ 4]  447 	call	_cc_write_reg
      0082A3 4B 65            [ 1]  448 	push	#0x65
      0082A5 A6 0E            [ 1]  449 	ld	a, #0x0e
      0082A7 CD 81 E3         [ 4]  450 	call	_cc_write_reg
      0082AA 4B 6A            [ 1]  451 	push	#0x6a
      0082AC A6 0F            [ 1]  452 	ld	a, #0x0f
      0082AE CD 81 E3         [ 4]  453 	call	_cc_write_reg
                                    454 ;	main.c: 134: cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
      0082B1 4B F5            [ 1]  455 	push	#0xf5
      0082B3 A6 10            [ 1]  456 	ld	a, #0x10
      0082B5 CD 81 E3         [ 4]  457 	call	_cc_write_reg
      0082B8 4B 83            [ 1]  458 	push	#0x83
      0082BA A6 11            [ 1]  459 	ld	a, #0x11
      0082BC CD 81 E3         [ 4]  460 	call	_cc_write_reg
      0082BF 4B 13            [ 1]  461 	push	#0x13
      0082C1 A6 12            [ 1]  462 	ld	a, #0x12
      0082C3 CD 81 E3         [ 4]  463 	call	_cc_write_reg
                                    464 ;	main.c: 135: cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
      0082C6 4B 22            [ 1]  465 	push	#0x22
      0082C8 A6 13            [ 1]  466 	ld	a, #0x13
      0082CA CD 81 E3         [ 4]  467 	call	_cc_write_reg
      0082CD 4B F8            [ 1]  468 	push	#0xf8
      0082CF A6 14            [ 1]  469 	ld	a, #0x14
      0082D1 CD 81 E3         [ 4]  470 	call	_cc_write_reg
                                    471 ;	main.c: 136: cc_write_reg(0x15,0x15); cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
      0082D4 4B 15            [ 1]  472 	push	#0x15
      0082D6 A6 15            [ 1]  473 	ld	a, #0x15
      0082D8 CD 81 E3         [ 4]  474 	call	_cc_write_reg
      0082DB 4B 18            [ 1]  475 	push	#0x18
      0082DD A6 18            [ 1]  476 	ld	a, #0x18
      0082DF CD 81 E3         [ 4]  477 	call	_cc_write_reg
      0082E2 4B 16            [ 1]  478 	push	#0x16
      0082E4 A6 19            [ 1]  479 	ld	a, #0x19
      0082E6 CD 81 E3         [ 4]  480 	call	_cc_write_reg
                                    481 ;	main.c: 137: cc_write_reg(0x1B,0x43); cc_write_reg(0x22,0x11);
      0082E9 4B 43            [ 1]  482 	push	#0x43
      0082EB A6 1B            [ 1]  483 	ld	a, #0x1b
      0082ED CD 81 E3         [ 4]  484 	call	_cc_write_reg
      0082F0 4B 11            [ 1]  485 	push	#0x11
      0082F2 A6 22            [ 1]  486 	ld	a, #0x22
      0082F4 CD 81 E3         [ 4]  487 	call	_cc_write_reg
                                    488 ;	main.c: 138: cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
      0082F7 4B E9            [ 1]  489 	push	#0xe9
      0082F9 A6 23            [ 1]  490 	ld	a, #0x23
      0082FB CD 81 E3         [ 4]  491 	call	_cc_write_reg
      0082FE 4B 2A            [ 1]  492 	push	#0x2a
      008300 A6 24            [ 1]  493 	ld	a, #0x24
      008302 CD 81 E3         [ 4]  494 	call	_cc_write_reg
      008305 4B 00            [ 1]  495 	push	#0x00
      008307 A6 25            [ 1]  496 	ld	a, #0x25
      008309 CD 81 E3         [ 4]  497 	call	_cc_write_reg
      00830C 4B 1F            [ 1]  498 	push	#0x1f
      00830E A6 26            [ 1]  499 	ld	a, #0x26
      008310 CD 81 E3         [ 4]  500 	call	_cc_write_reg
                                    501 ;	main.c: 139: cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
      008313 4B 81            [ 1]  502 	push	#0x81
      008315 A6 2C            [ 1]  503 	ld	a, #0x2c
      008317 CD 81 E3         [ 4]  504 	call	_cc_write_reg
      00831A 4B 35            [ 1]  505 	push	#0x35
      00831C A6 2D            [ 1]  506 	ld	a, #0x2d
      00831E CD 81 E3         [ 4]  507 	call	_cc_write_reg
      008321 4B 09            [ 1]  508 	push	#0x09
      008323 A6 2E            [ 1]  509 	ld	a, #0x2e
      008325 CD 81 E3         [ 4]  510 	call	_cc_write_reg
                                    511 ;	main.c: 140: cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
      008328 A6 36            [ 1]  512 	ld	a, #0x36
      00832A CD 81 C2         [ 4]  513 	call	_cc_strobe
      00832D A6 3A            [ 1]  514 	ld	a, #0x3a
      00832F CD 81 C2         [ 4]  515 	call	_cc_strobe
      008332 A6 3B            [ 1]  516 	ld	a, #0x3b
      008334 CD 81 C2         [ 4]  517 	call	_cc_strobe
                                    518 ;	main.c: 141: delay_ms(2);
      008337 AE 00 02         [ 2]  519 	ldw	x, #0x0002
                                    520 ;	main.c: 142: }
      00833A CC 80 FC         [ 2]  521 	jp	_delay_ms
                                    522 ;	main.c: 145: static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
                                    523 ;	-----------------------------------------
                                    524 ;	 function cc_send_packet
                                    525 ;	-----------------------------------------
      00833D                        526 _cc_send_packet:
      00833D 52 07            [ 2]  527 	sub	sp, #7
      00833F 1F 02            [ 2]  528 	ldw	(0x02, sp), x
                                    529 ;	main.c: 146: if(len==0 || len>61) return 0;
      008341 6B 01            [ 1]  530 	ld	(0x01, sp), a
      008343 27 06            [ 1]  531 	jreq	00101$
      008345 7B 01            [ 1]  532 	ld	a, (0x01, sp)
      008347 A1 3D            [ 1]  533 	cp	a, #0x3d
      008349 23 04            [ 2]  534 	jrule	00102$
      00834B                        535 00101$:
      00834B 4F               [ 1]  536 	clr	a
      00834C CC 83 E0         [ 2]  537 	jp	00119$
      00834F                        538 00102$:
                                    539 ;	main.c: 147: cc_strobe(SIDLE); cc_strobe(SFTX);
      00834F A6 36            [ 1]  540 	ld	a, #0x36
      008351 CD 81 C2         [ 4]  541 	call	_cc_strobe
      008354 A6 3B            [ 1]  542 	ld	a, #0x3b
      008356 CD 81 C2         [ 4]  543 	call	_cc_strobe
                                    544 ;	main.c: 148: if(!cc_select()) return 0;
      008359 CD 81 85         [ 4]  545 	call	_cc_select
      00835C 4D               [ 1]  546 	tnz	a
      00835D 26 04            [ 1]  547 	jrne	00105$
      00835F 4F               [ 1]  548 	clr	a
      008360 CC 83 E0         [ 2]  549 	jp	00119$
      008363                        550 00105$:
                                    551 ;	main.c: 149: spi_txrx(TXFIFO | CC_BURST);
      008363 A6 7F            [ 1]  552 	ld	a, #0x7f
      008365 CD 81 6E         [ 4]  553 	call	_spi_txrx
                                    554 ;	main.c: 150: spi_txrx(len);
      008368 7B 01            [ 1]  555 	ld	a, (0x01, sp)
      00836A CD 81 6E         [ 4]  556 	call	_spi_txrx
                                    557 ;	main.c: 151: for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
      00836D 0F 07            [ 1]  558 	clr	(0x07, sp)
      00836F                        559 00117$:
      00836F 7B 07            [ 1]  560 	ld	a, (0x07, sp)
      008371 11 01            [ 1]  561 	cp	a, (0x01, sp)
      008373 24 0F            [ 1]  562 	jrnc	00106$
      008375 5F               [ 1]  563 	clrw	x
      008376 7B 07            [ 1]  564 	ld	a, (0x07, sp)
      008378 97               [ 1]  565 	ld	xl, a
      008379 72 FB 02         [ 2]  566 	addw	x, (0x02, sp)
      00837C F6               [ 1]  567 	ld	a, (x)
      00837D CD 81 6E         [ 4]  568 	call	_spi_txrx
      008380 0C 07            [ 1]  569 	inc	(0x07, sp)
      008382 20 EB            [ 2]  570 	jra	00117$
      008384                        571 00106$:
                                    572 ;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
      008384 CD 81 7F         [ 4]  573 	call	_spi_wait_idle
      008387 72 14 50 0F      [ 1]  574 	bset	0x500f, #2
                                    575 ;	main.c: 153: cc_strobe(STX);
      00838B A6 35            [ 1]  576 	ld	a, #0x35
      00838D CD 81 C2         [ 4]  577 	call	_cc_strobe
                                    578 ;	main.c: 155: while(!GDO0_READ() && ++guard<150000UL){}   // front haut
      008390 5F               [ 1]  579 	clrw	x
      008391 1F 06            [ 2]  580 	ldw	(0x06, sp), x
      008393 90 5F            [ 1]  581 	clrw	y
      008395                        582 00108$:
      008395 72 08 50 10 18   [ 2]  583 	btjt	0x5010, #4, 00128$
      00839A 1E 06            [ 2]  584 	ldw	x, (0x06, sp)
      00839C 5C               [ 1]  585 	incw	x
      00839D 1F 06            [ 2]  586 	ldw	(0x06, sp), x
      00839F 26 02            [ 1]  587 	jrne	00169$
      0083A1 90 5C            [ 1]  588 	incw	y
      0083A3                        589 00169$:
      0083A3 1E 06            [ 2]  590 	ldw	x, (0x06, sp)
      0083A5 A3 49 F0         [ 2]  591 	cpw	x, #0x49f0
      0083A8 90 9F            [ 1]  592 	ld	a, yl
      0083AA A2 02            [ 1]  593 	sbc	a, #0x02
      0083AC 90 9E            [ 1]  594 	ld	a, yh
      0083AE A2 00            [ 1]  595 	sbc	a, #0x00
      0083B0 25 E3            [ 1]  596 	jrc	00108$
                                    597 ;	main.c: 156: while( GDO0_READ() && ++guard<400000UL){}   // retour bas
      0083B2                        598 00128$:
      0083B2 17 04            [ 2]  599 	ldw	(0x04, sp), y
      0083B4 16 06            [ 2]  600 	ldw	y, (0x06, sp)
      0083B6                        601 00112$:
      0083B6 72 09 50 10 17   [ 2]  602 	btjf	0x5010, #4, 00114$
      0083BB 90 5C            [ 1]  603 	incw	y
      0083BD 26 05            [ 1]  604 	jrne	00172$
      0083BF 1E 04            [ 2]  605 	ldw	x, (0x04, sp)
      0083C1 5C               [ 1]  606 	incw	x
      0083C2 1F 04            [ 2]  607 	ldw	(0x04, sp), x
      0083C4                        608 00172$:
      0083C4 90 A3 1A 80      [ 2]  609 	cpw	y, #0x1a80
      0083C8 7B 05            [ 1]  610 	ld	a, (0x05, sp)
      0083CA A2 06            [ 1]  611 	sbc	a, #0x06
      0083CC 7B 04            [ 1]  612 	ld	a, (0x04, sp)
      0083CE A2 00            [ 1]  613 	sbc	a, #0x00
      0083D0 25 E4            [ 1]  614 	jrc	00112$
      0083D2                        615 00114$:
                                    616 ;	main.c: 157: return (guard<400000UL);
      0083D2 90 A3 1A 80      [ 2]  617 	cpw	y, #0x1a80
      0083D6 7B 05            [ 1]  618 	ld	a, (0x05, sp)
      0083D8 A2 06            [ 1]  619 	sbc	a, #0x06
      0083DA 7B 04            [ 1]  620 	ld	a, (0x04, sp)
      0083DC A2 00            [ 1]  621 	sbc	a, #0x00
      0083DE 4F               [ 1]  622 	clr	a
      0083DF 49               [ 1]  623 	rlc	a
      0083E0                        624 00119$:
                                    625 ;	main.c: 158: }
      0083E0 5B 07            [ 2]  626 	addw	sp, #7
      0083E2 81               [ 4]  627 	ret
                                    628 ;	main.c: 161: static void dump_once(const char* tag){
                                    629 ;	-----------------------------------------
                                    630 ;	 function dump_once
                                    631 ;	-----------------------------------------
      0083E3                        632 _dump_once:
      0083E3 52 08            [ 2]  633 	sub	sp, #8
      0083E5 1F 07            [ 2]  634 	ldw	(0x07, sp), x
                                    635 ;	main.c: 162: uint8_t pn = cc_read_status(PARTNUM);
      0083E7 A6 30            [ 1]  636 	ld	a, #0x30
      0083E9 CD 82 05         [ 4]  637 	call	_cc_read_status
      0083EC 6B 06            [ 1]  638 	ld	(0x06, sp), a
                                    639 ;	main.c: 163: uint8_t vr = cc_read_status(VERSION);
      0083EE A6 31            [ 1]  640 	ld	a, #0x31
      0083F0 CD 82 05         [ 4]  641 	call	_cc_read_status
      0083F3 6B 05            [ 1]  642 	ld	(0x05, sp), a
                                    643 ;	main.c: 164: uint8_t ms = cc_read_status(MARCSTATE);
      0083F5 A6 35            [ 1]  644 	ld	a, #0x35
      0083F7 CD 82 05         [ 4]  645 	call	_cc_read_status
      0083FA 90 97            [ 1]  646 	ld	yl, a
                                    647 ;	main.c: 166: tag, pn, vr, ms, MISO_IS_HIGH());
      0083FC C6 50 0B         [ 1]  648 	ld	a, 0x500b
      0083FF 2A 05            [ 1]  649 	jrpl	00103$
      008401 5F               [ 1]  650 	clrw	x
      008402 5C               [ 1]  651 	incw	x
      008403 1F 01            [ 2]  652 	ldw	(0x01, sp), x
      008405 BC                     653 	.byte 0xbc
      008406                        654 00103$:
      008406 5F               [ 1]  655 	clrw	x
      008407 1F 01            [ 2]  656 	ldw	(0x01, sp), x
      008409                        657 00104$:
      008409 4F               [ 1]  658 	clr	a
      00840A 90 95            [ 1]  659 	ld	yh, a
      00840C 7B 05            [ 1]  660 	ld	a, (0x05, sp)
      00840E 6B 04            [ 1]  661 	ld	(0x04, sp), a
      008410 0F 03            [ 1]  662 	clr	(0x03, sp)
      008412 7B 06            [ 1]  663 	ld	a, (0x06, sp)
      008414 0F 05            [ 1]  664 	clr	(0x05, sp)
                                    665 ;	main.c: 165: printf("[%s] PART=0x%02X VER=0x%02X MARC=0x%02X  (MISO=%d)\r\n",
      008416 1E 01            [ 2]  666 	ldw	x, (0x01, sp)
      008418 89               [ 2]  667 	pushw	x
      008419 90 89            [ 2]  668 	pushw	y
      00841B 1E 07            [ 2]  669 	ldw	x, (0x07, sp)
      00841D 89               [ 2]  670 	pushw	x
      00841E 88               [ 1]  671 	push	a
      00841F 7B 0C            [ 1]  672 	ld	a, (0x0c, sp)
      008421 88               [ 1]  673 	push	a
      008422 1E 0F            [ 2]  674 	ldw	x, (0x0f, sp)
      008424 89               [ 2]  675 	pushw	x
      008425 4B 24            [ 1]  676 	push	#<(___str_0+0)
      008427 4B 80            [ 1]  677 	push	#((___str_0+0) >> 8)
      008429 CD 84 FF         [ 4]  678 	call	_printf
                                    679 ;	main.c: 167: }
      00842C 5B 14            [ 2]  680 	addw	sp, #20
      00842E 81               [ 4]  681 	ret
                                    682 ;	main.c: 170: void main(void){
                                    683 ;	-----------------------------------------
                                    684 ;	 function main
                                    685 ;	-----------------------------------------
      00842F                        686 _main:
      00842F 52 04            [ 2]  687 	sub	sp, #4
                                    688 ;	main.c: 171: uart_init(); gpio_init(); spi_init();
      008431 CD 80 BA         [ 4]  689 	call	_uart_init
      008434 CD 81 34         [ 4]  690 	call	_gpio_init
      008437 CD 81 61         [ 4]  691 	call	_spi_init
                                    692 ;	main.c: 172: printf("\r\n[STM8S] CC1101 TX test @868 MHz  (SWAP=%d)\r\n", SWAP_MOSI_MISO);
      00843A 5F               [ 1]  693 	clrw	x
      00843B 89               [ 2]  694 	pushw	x
      00843C 4B 59            [ 1]  695 	push	#<(___str_1+0)
      00843E 4B 80            [ 1]  696 	push	#((___str_1+0) >> 8)
      008440 CD 84 FF         [ 4]  697 	call	_printf
      008443 5B 04            [ 2]  698 	addw	sp, #4
                                    699 ;	main.c: 175: delay_ms(20);
      008445 AE 00 14         [ 2]  700 	ldw	x, #0x0014
      008448 CD 80 FC         [ 4]  701 	call	_delay_ms
                                    702 ;	main.c: 178: dump_once("BEFORE");
      00844B AE 80 88         [ 2]  703 	ldw	x, #(___str_2+0)
      00844E CD 83 E3         [ 4]  704 	call	_dump_once
                                    705 ;	main.c: 180: cc_reset();
      008451 CD 82 2D         [ 4]  706 	call	_cc_reset
                                    707 ;	main.c: 181: dump_once("AFTER_RST");
      008454 AE 80 8F         [ 2]  708 	ldw	x, #(___str_3+0)
      008457 CD 83 E3         [ 4]  709 	call	_dump_once
                                    710 ;	main.c: 183: cc_config_868();
      00845A CD 82 6C         [ 4]  711 	call	_cc_config_868
                                    712 ;	main.c: 184: dump_once("AFTER_CFG");
      00845D AE 80 99         [ 2]  713 	ldw	x, #(___str_4+0)
      008460 CD 83 E3         [ 4]  714 	call	_dump_once
      008463                        715 00102$:
                                    716 ;	main.c: 187: uint8_t pkt[4] = {0x01,0x00,0xEA,0xEB};
      008463 A6 01            [ 1]  717 	ld	a, #0x01
      008465 6B 01            [ 1]  718 	ld	(0x01, sp), a
      008467 0F 02            [ 1]  719 	clr	(0x02, sp)
      008469 A6 EA            [ 1]  720 	ld	a, #0xea
      00846B 6B 03            [ 1]  721 	ld	(0x03, sp), a
      00846D A6 EB            [ 1]  722 	ld	a, #0xeb
      00846F 6B 04            [ 1]  723 	ld	(0x04, sp), a
                                    724 ;	main.c: 188: uint8_t ok = cc_send_packet(pkt, sizeof(pkt));
      008471 A6 04            [ 1]  725 	ld	a, #0x04
      008473 96               [ 1]  726 	ldw	x, sp
      008474 5C               [ 1]  727 	incw	x
      008475 CD 83 3D         [ 4]  728 	call	_cc_send_packet
                                    729 ;	main.c: 189: dump_once(ok?"TX_OK":"TX_TO");
      008478 4D               [ 1]  730 	tnz	a
      008479 27 04            [ 1]  731 	jreq	00106$
      00847B AE 80 A3         [ 2]  732 	ldw	x, #___str_5+0
      00847E BC                     733 	.byte 0xbc
      00847F                        734 00106$:
      00847F AE 80 A9         [ 2]  735 	ldw	x, #(___str_6+0)
      008482                        736 00107$:
      008482 CD 83 E3         [ 4]  737 	call	_dump_once
                                    738 ;	main.c: 190: delay_ms(1500);
      008485 AE 05 DC         [ 2]  739 	ldw	x, #0x05dc
      008488 CD 80 FC         [ 4]  740 	call	_delay_ms
      00848B 20 D6            [ 2]  741 	jra	00102$
                                    742 ;	main.c: 192: }
      00848D 5B 04            [ 2]  743 	addw	sp, #4
      00848F 81               [ 4]  744 	ret
                                    745 	.area CODE
                                    746 	.area CONST
                                    747 	.area CONST
      008024                        748 ___str_0:
      008024 5B 25 73 5D 20 50 41   749 	.ascii "[%s] PART=0x%02X VER=0x%02X MARC=0x%02X  (MISO=%d)"
             52 54 3D 30 78 25 30
             32 58 20 56 45 52 3D
             30 78 25 30 32 58 20
             4D 41 52 43 3D 30 78
             25 30 32 58 20 20 28
             4D 49 53 4F 3D 25 64
             29
      008056 0D                     750 	.db 0x0d
      008057 0A                     751 	.db 0x0a
      008058 00                     752 	.db 0x00
                                    753 	.area CODE
                                    754 	.area CONST
      008059                        755 ___str_1:
      008059 0D                     756 	.db 0x0d
      00805A 0A                     757 	.db 0x0a
      00805B 5B 53 54 4D 38 53 5D   758 	.ascii "[STM8S] CC1101 TX test @868 MHz  (SWAP=%d)"
             20 43 43 31 31 30 31
             20 54 58 20 74 65 73
             74 20 40 38 36 38 20
             4D 48 7A 20 20 28 53
             57 41 50 3D 25 64 29
      008085 0D                     759 	.db 0x0d
      008086 0A                     760 	.db 0x0a
      008087 00                     761 	.db 0x00
                                    762 	.area CODE
                                    763 	.area CONST
      008088                        764 ___str_2:
      008088 42 45 46 4F 52 45      765 	.ascii "BEFORE"
      00808E 00                     766 	.db 0x00
                                    767 	.area CODE
                                    768 	.area CONST
      00808F                        769 ___str_3:
      00808F 41 46 54 45 52 5F 52   770 	.ascii "AFTER_RST"
             53 54
      008098 00                     771 	.db 0x00
                                    772 	.area CODE
                                    773 	.area CONST
      008099                        774 ___str_4:
      008099 41 46 54 45 52 5F 43   775 	.ascii "AFTER_CFG"
             46 47
      0080A2 00                     776 	.db 0x00
                                    777 	.area CODE
                                    778 	.area CONST
      0080A3                        779 ___str_5:
      0080A3 54 58 5F 4F 4B         780 	.ascii "TX_OK"
      0080A8 00                     781 	.db 0x00
                                    782 	.area CODE
                                    783 	.area CONST
      0080A9                        784 ___str_6:
      0080A9 54 58 5F 54 4F         785 	.ascii "TX_TO"
      0080AE 00                     786 	.db 0x00
                                    787 	.area CODE
                                    788 	.area INITIALIZER
                                    789 	.area CABS (ABS)
