                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module spi
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _SPI_init
                                     12 	.globl _SPI_read
                                     13 	.globl _SPI_write
                                     14 ;--------------------------------------------------------
                                     15 ; ram data
                                     16 ;--------------------------------------------------------
                                     17 	.area DATA
                                     18 ;--------------------------------------------------------
                                     19 ; ram data
                                     20 ;--------------------------------------------------------
                                     21 	.area INITIALIZED
                                     22 ;--------------------------------------------------------
                                     23 ; absolute external ram data
                                     24 ;--------------------------------------------------------
                                     25 	.area DABS (ABS)
                                     26 
                                     27 ; default segment ordering for linker
                                     28 	.area HOME
                                     29 	.area GSINIT
                                     30 	.area GSFINAL
                                     31 	.area CONST
                                     32 	.area INITIALIZER
                                     33 	.area CODE
                                     34 
                                     35 ;--------------------------------------------------------
                                     36 ; global & static initialisations
                                     37 ;--------------------------------------------------------
                                     38 	.area HOME
                                     39 	.area GSINIT
                                     40 	.area GSFINAL
                                     41 	.area GSINIT
                                     42 ;--------------------------------------------------------
                                     43 ; Home
                                     44 ;--------------------------------------------------------
                                     45 	.area HOME
                                     46 	.area HOME
                                     47 ;--------------------------------------------------------
                                     48 ; code
                                     49 ;--------------------------------------------------------
                                     50 	.area CODE
                                     51 ;	../../lib/spi.c: 4: void SPI_init() {
                                     52 ;	-----------------------------------------
                                     53 ;	 function SPI_init
                                     54 ;	-----------------------------------------
      00814E                         55 _SPI_init:
                                     56 ;	../../lib/spi.c: 5: SPI_CR1 = (1 << SPI_CR1_MSTR) | (1 << SPI_CR1_SPE) | (1 << SPI_CR1_BR1);
      00814E 35 54 52 00      [ 1]   57 	mov	0x5200+0, #0x54
                                     58 ;	../../lib/spi.c: 6: SPI_CR2 = (1 << SPI_CR2_SSM) | (1 << SPI_CR2_SSI) | (1 << SPI_CR2_BDM) | (1 << SPI_CR2_BDOE);
      008152 35 C3 52 01      [ 1]   59 	mov	0x5201+0, #0xc3
                                     60 ;	../../lib/spi.c: 7: }
      008156 81               [ 4]   61 	ret
                                     62 ;	../../lib/spi.c: 9: uint8_t SPI_read() {
                                     63 ;	-----------------------------------------
                                     64 ;	 function SPI_read
                                     65 ;	-----------------------------------------
      008157                         66 _SPI_read:
                                     67 ;	../../lib/spi.c: 10: SPI_write(0xFF);
      008157 A6 FF            [ 1]   68 	ld	a, #0xff
      008159 CD 81 65         [ 4]   69 	call	_SPI_write
                                     70 ;	../../lib/spi.c: 11: while (!(SPI_SR & (1 << SPI_SR_RXNE)));
      00815C                         71 00101$:
      00815C 72 01 52 03 FB   [ 2]   72 	btjf	0x5203, #0, 00101$
                                     73 ;	../../lib/spi.c: 12: return SPI_DR;
      008161 C6 52 04         [ 1]   74 	ld	a, 0x5204
                                     75 ;	../../lib/spi.c: 13: }
      008164 81               [ 4]   76 	ret
                                     77 ;	../../lib/spi.c: 15: void SPI_write(uint8_t data) {
                                     78 ;	-----------------------------------------
                                     79 ;	 function SPI_write
                                     80 ;	-----------------------------------------
      008165                         81 _SPI_write:
                                     82 ;	../../lib/spi.c: 16: SPI_DR = data;
      008165 C7 52 04         [ 1]   83 	ld	0x5204, a
                                     84 ;	../../lib/spi.c: 17: while (!(SPI_SR & (1 << SPI_SR_TXE)));
      008168                         85 00101$:
      008168 72 03 52 03 FB   [ 2]   86 	btjf	0x5203, #1, 00101$
                                     87 ;	../../lib/spi.c: 18: }
      00816D 81               [ 4]   88 	ret
                                     89 	.area CODE
                                     90 	.area CONST
                                     91 	.area INITIALIZER
                                     92 	.area CABS (ABS)
