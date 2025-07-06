                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module UART
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _uart_read
                                     13 	.globl _uart_write
                                     14 	.globl _uart_config
                                     15 	.globl _printf
                                     16 	.globl _putchar
                                     17 ;--------------------------------------------------------
                                     18 ; ram data
                                     19 ;--------------------------------------------------------
                                     20 	.area DATA
                                     21 ;--------------------------------------------------------
                                     22 ; ram data
                                     23 ;--------------------------------------------------------
                                     24 	.area INITIALIZED
                                     25 ;--------------------------------------------------------
                                     26 ; Stack segment in internal ram
                                     27 ;--------------------------------------------------------
                                     28 	.area	SSEG
      000001                         29 __start__stack:
      000001                         30 	.ds	1
                                     31 
                                     32 ;--------------------------------------------------------
                                     33 ; absolute external ram data
                                     34 ;--------------------------------------------------------
                                     35 	.area DABS (ABS)
                                     36 
                                     37 ; default segment ordering for linker
                                     38 	.area HOME
                                     39 	.area GSINIT
                                     40 	.area GSFINAL
                                     41 	.area CONST
                                     42 	.area INITIALIZER
                                     43 	.area CODE
                                     44 
                                     45 ;--------------------------------------------------------
                                     46 ; interrupt vector
                                     47 ;--------------------------------------------------------
                                     48 	.area HOME
      008000                         49 __interrupt_vect:
      008000 82 00 80 07             50 	int s_GSINIT ; reset
                                     51 ;--------------------------------------------------------
                                     52 ; global & static initialisations
                                     53 ;--------------------------------------------------------
                                     54 	.area HOME
                                     55 	.area GSINIT
                                     56 	.area GSFINAL
                                     57 	.area GSINIT
      008007                         58 __sdcc_init_data:
                                     59 ; stm8_genXINIT() start
      008007 AE 00 00         [ 2]   60 	ldw x, #l_DATA
      00800A 27 07            [ 1]   61 	jreq	00002$
      00800C                         62 00001$:
      00800C 72 4F 00 00      [ 1]   63 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   64 	decw x
      008011 26 F9            [ 1]   65 	jrne	00001$
      008013                         66 00002$:
      008013 AE 00 00         [ 2]   67 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   68 	jreq	00004$
      008018                         69 00003$:
      008018 D6 80 3B         [ 1]   70 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 00         [ 1]   71 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   72 	decw	x
      00801F 26 F7            [ 1]   73 	jrne	00003$
      008021                         74 00004$:
                                     75 ; stm8_genXINIT() end
                                     76 	.area GSFINAL
      008021 CC 80 04         [ 2]   77 	jp	__sdcc_program_startup
                                     78 ;--------------------------------------------------------
                                     79 ; Home
                                     80 ;--------------------------------------------------------
                                     81 	.area HOME
                                     82 	.area HOME
      008004                         83 __sdcc_program_startup:
      008004 CC 80 B4         [ 2]   84 	jp	_main
                                     85 ;	return from main will return to caller
                                     86 ;--------------------------------------------------------
                                     87 ; code
                                     88 ;--------------------------------------------------------
                                     89 	.area CODE
                                     90 ;	UART.c: 8: void uart_config() {
                                     91 ;	-----------------------------------------
                                     92 ;	 function uart_config
                                     93 ;	-----------------------------------------
      00803C                         94 _uart_config:
                                     95 ;	UART.c: 16: uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
      00803C A6 68            [ 1]   96 	ld	a, #0x68
      00803E 97               [ 1]   97 	ld	xl, a
                                     98 ;	UART.c: 17: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8
      00803F A6 83            [ 1]   99 	ld	a, #0x83
      008041 A4 0F            [ 1]  100 	and	a, #0x0f
                                    101 ;	UART.c: 19: UART1_BRR1 = brr1;
      008043 90 AE 52 32      [ 2]  102 	ldw	y, #0x5232
      008047 88               [ 1]  103 	push	a
      008048 9F               [ 1]  104 	ld	a, xl
      008049 90 F7            [ 1]  105 	ld	(y), a
      00804B 84               [ 1]  106 	pop	a
                                    107 ;	UART.c: 20: UART1_BRR2 = brr2;
      00804C C7 52 33         [ 1]  108 	ld	0x5233, a
                                    109 ;	UART.c: 21: UART1_CR1 = 0x00;    // 8 data bits, no parity
      00804F 35 00 52 34      [ 1]  110 	mov	0x5234+0, #0x00
                                    111 ;	UART.c: 22: UART1_CR3 = 0x00;    // 1 stop bit
      008053 35 00 52 36      [ 1]  112 	mov	0x5236+0, #0x00
                                    113 ;	UART.c: 23: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
      008057 35 0C 52 35      [ 1]  114 	mov	0x5235+0, #0x0c
                                    115 ;	UART.c: 24: }
      00805B 81               [ 4]  116 	ret
                                    117 ;	UART.c: 26: void uart_write(uint8_t data) {
                                    118 ;	-----------------------------------------
                                    119 ;	 function uart_write
                                    120 ;	-----------------------------------------
      00805C                        121 _uart_write:
                                    122 ;	UART.c: 27: UART1_DR = data;
      00805C C7 52 31         [ 1]  123 	ld	0x5231, a
                                    124 ;	UART.c: 28: PB_ODR &= ~(1 << 5);  // LED OFF
      00805F 72 1B 50 05      [ 1]  125 	bres	0x5005, #5
                                    126 ;	UART.c: 29: while (!(UART1_SR & (1 << UART1_SR_TC)));
      008063                        127 00101$:
      008063 72 0D 52 30 FB   [ 2]  128 	btjf	0x5230, #6, 00101$
                                    129 ;	UART.c: 30: PB_ODR |= (1 << 5);   // LED ON
      008068 72 1A 50 05      [ 1]  130 	bset	0x5005, #5
                                    131 ;	UART.c: 31: }
      00806C 81               [ 4]  132 	ret
                                    133 ;	UART.c: 33: uint8_t uart_read() {
                                    134 ;	-----------------------------------------
                                    135 ;	 function uart_read
                                    136 ;	-----------------------------------------
      00806D                        137 _uart_read:
                                    138 ;	UART.c: 34: while (!(UART1_SR & (1 << UART1_SR_RXNE)));
      00806D                        139 00101$:
      00806D 72 0B 52 30 FB   [ 2]  140 	btjf	0x5230, #5, 00101$
                                    141 ;	UART.c: 35: return UART1_DR;
      008072 C6 52 31         [ 1]  142 	ld	a, 0x5231
                                    143 ;	UART.c: 36: }
      008075 81               [ 4]  144 	ret
                                    145 ;	UART.c: 38: int putchar(int c) {
                                    146 ;	-----------------------------------------
                                    147 ;	 function putchar
                                    148 ;	-----------------------------------------
      008076                        149 _putchar:
      008076 9F               [ 1]  150 	ld	a, xl
                                    151 ;	UART.c: 39: uart_write(c);
      008077 CD 80 5C         [ 4]  152 	call	_uart_write
                                    153 ;	UART.c: 40: return 0;
      00807A 5F               [ 1]  154 	clrw	x
                                    155 ;	UART.c: 41: }
      00807B 81               [ 4]  156 	ret
                                    157 ;	UART.c: 43: static inline void delay_ms(uint16_t ms) {
                                    158 ;	-----------------------------------------
                                    159 ;	 function delay_ms
                                    160 ;	-----------------------------------------
      00807C                        161 _delay_ms:
      00807C 52 0A            [ 2]  162 	sub	sp, #10
      00807E 1F 05            [ 2]  163 	ldw	(0x05, sp), x
                                    164 ;	UART.c: 45: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008080 5F               [ 1]  165 	clrw	x
      008081 1F 09            [ 2]  166 	ldw	(0x09, sp), x
      008083 1F 07            [ 2]  167 	ldw	(0x07, sp), x
      008085                        168 00103$:
      008085 1E 05            [ 2]  169 	ldw	x, (0x05, sp)
      008087 89               [ 2]  170 	pushw	x
      008088 AE 03 78         [ 2]  171 	ldw	x, #0x0378
      00808B CD 80 D5         [ 4]  172 	call	___muluint2ulong
      00808E 5B 02            [ 2]  173 	addw	sp, #2
      008090 1F 03            [ 2]  174 	ldw	(0x03, sp), x
      008092 17 01            [ 2]  175 	ldw	(0x01, sp), y
      008094 1E 09            [ 2]  176 	ldw	x, (0x09, sp)
      008096 13 03            [ 2]  177 	cpw	x, (0x03, sp)
      008098 7B 08            [ 1]  178 	ld	a, (0x08, sp)
      00809A 12 02            [ 1]  179 	sbc	a, (0x02, sp)
      00809C 7B 07            [ 1]  180 	ld	a, (0x07, sp)
      00809E 12 01            [ 1]  181 	sbc	a, (0x01, sp)
      0080A0 24 0F            [ 1]  182 	jrnc	00105$
                                    183 ;	UART.c: 46: __asm__("nop");
      0080A2 9D               [ 1]  184 	nop
                                    185 ;	UART.c: 45: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080A3 1E 09            [ 2]  186 	ldw	x, (0x09, sp)
      0080A5 5C               [ 1]  187 	incw	x
      0080A6 1F 09            [ 2]  188 	ldw	(0x09, sp), x
      0080A8 26 DB            [ 1]  189 	jrne	00103$
      0080AA 1E 07            [ 2]  190 	ldw	x, (0x07, sp)
      0080AC 5C               [ 1]  191 	incw	x
      0080AD 1F 07            [ 2]  192 	ldw	(0x07, sp), x
      0080AF 20 D4            [ 2]  193 	jra	00103$
      0080B1                        194 00105$:
                                    195 ;	UART.c: 47: }
      0080B1 5B 0A            [ 2]  196 	addw	sp, #10
      0080B3 81               [ 4]  197 	ret
                                    198 ;	UART.c: 49: void main() {
                                    199 ;	-----------------------------------------
                                    200 ;	 function main
                                    201 ;	-----------------------------------------
      0080B4                        202 _main:
                                    203 ;	UART.c: 50: CLK_CKDIVR = 0x00;  // Set system clock to full 16 MHz
      0080B4 35 00 50 C6      [ 1]  204 	mov	0x50c6+0, #0x00
                                    205 ;	UART.c: 52: uart_config();
      0080B8 CD 80 3C         [ 4]  206 	call	_uart_config
                                    207 ;	UART.c: 55: PB_CR1= (1 << 5);
      0080BB 35 20 50 08      [ 1]  208 	mov	0x5008+0, #0x20
                                    209 ;	UART.c: 56: PB_DDR = (1 << 5);
      0080BF 35 20 50 07      [ 1]  210 	mov	0x5007+0, #0x20
                                    211 ;	UART.c: 58: while (1) {
      0080C3                        212 00102$:
                                    213 ;	UART.c: 59: uint8_t c = uart_read();   // Attendre un caractère du terminal
      0080C3 CD 80 6D         [ 4]  214 	call	_uart_read
                                    215 ;	UART.c: 60: printf("Echo : %c \r\n", c);
      0080C6 5F               [ 1]  216 	clrw	x
      0080C7 97               [ 1]  217 	ld	xl, a
      0080C8 89               [ 2]  218 	pushw	x
      0080C9 4B 24            [ 1]  219 	push	#<(___str_0+0)
      0080CB 4B 80            [ 1]  220 	push	#((___str_0+0) >> 8)
      0080CD CD 81 44         [ 4]  221 	call	_printf
      0080D0 5B 04            [ 2]  222 	addw	sp, #4
      0080D2 20 EF            [ 2]  223 	jra	00102$
                                    224 ;	UART.c: 62: }
      0080D4 81               [ 4]  225 	ret
                                    226 	.area CODE
                                    227 	.area CONST
                                    228 	.area CONST
      008024                        229 ___str_0:
      008024 45 63 68 6F 20 3A 20   230 	.ascii "Echo : %c "
             25 63 20
      00802E 0D                     231 	.db 0x0d
      00802F 0A                     232 	.db 0x0a
      008030 00                     233 	.db 0x00
                                    234 	.area CODE
                                    235 	.area INITIALIZER
                                    236 	.area CABS (ABS)
