;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _printf
	.globl _putchar
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
;--------------------------------------------------------
; Stack segment in internal ram
;--------------------------------------------------------
	.area	SSEG
__start__stack:
	.ds	1

;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area DABS (ABS)

; default segment ordering for linker
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area CONST
	.area INITIALIZER
	.area CODE

;--------------------------------------------------------
; interrupt vector
;--------------------------------------------------------
	.area HOME
__interrupt_vect:
	int s_GSINIT ; reset
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area GSINIT
__sdcc_init_data:
; stm8_genXINIT() start
	ldw x, #l_DATA
	jreq	00002$
00001$:
	clr (s_DATA - 1, x)
	decw x
	jrne	00001$
00002$:
	ldw	x, #l_INITIALIZER
	jreq	00004$
00003$:
	ld	a, (s_INITIALIZER - 1, x)
	ld	(s_INITIALIZED - 1, x), a
	decw	x
	jrne	00003$
00004$:
; stm8_genXINIT() end
	.area GSFINAL
	jp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME
	.area HOME
__sdcc_program_startup:
	jp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CODE
;	main.c: 19: static void uart_init(void){
;	-----------------------------------------
;	 function uart_init
;	-----------------------------------------
_uart_init:
;	main.c: 20: CLK_CKDIVR = 0x00;
	mov	0x50c6+0, #0x00
;	main.c: 22: UART1_BRR1 = (div >> 4) & 0xFF;
	ld	a, #0x68
	ld	0x5232, a
;	main.c: 23: UART1_BRR2 = ((div & 0x0F) | ((div >> 8) & 0xF0));
	ld	a, #0x83
	and	a, #0x0f
	ld	0x5233, a
;	main.c: 24: UART1_CR1 = 0x00; UART1_CR3 = 0x00;
	mov	0x5234+0, #0x00
	mov	0x5236+0, #0x00
;	main.c: 25: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
	mov	0x5235+0, #0x0c
;	main.c: 26: (void)UART1_SR; (void)UART1_DR;
	ld	a, 0x5230
	ld	a, 0x5231
;	main.c: 27: }
	ret
;	main.c: 28: int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; }
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
00101$:
	ld	a, 0x5230
	jrpl	00101$
	ld	a, xl
	ld	0x5231, a
	clrw	x
	ret
;	main.c: 29: static inline void delay_cycles(volatile uint16_t n){ while(n--) __asm__("nop"); }
;	-----------------------------------------
;	 function delay_cycles
;	-----------------------------------------
_delay_cycles:
	sub	sp, #2
	ldw	(0x01, sp), x
00101$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00104$
	nop
	jra	00101$
00104$:
	addw	sp, #2
	ret
;	main.c: 30: static void delay_ms(uint16_t ms){ for(uint32_t i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop"); }
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
	clrw	x
	ldw	(0x09, sp), x
	ldw	(0x07, sp), x
00103$:
	ldw	x, (0x05, sp)
	pushw	x
	ldw	x, #0x0378
	call	___muluint2ulong
	addw	sp, #2
	ldw	(0x03, sp), x
	ldw	(0x01, sp), y
	ldw	x, (0x09, sp)
	cpw	x, (0x03, sp)
	ld	a, (0x08, sp)
	sbc	a, (0x02, sp)
	ld	a, (0x07, sp)
	sbc	a, (0x01, sp)
	jrnc	00105$
	nop
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
	addw	sp, #10
	ret
;	main.c: 46: static void gpio_init(void){
;	-----------------------------------------
;	 function gpio_init
;	-----------------------------------------
_gpio_init:
;	main.c: 48: PC_DDR |= (1<<5) | (1<<MOSI_BIT);
	ld	a, 0x500c
	or	a, #0x60
	ld	0x500c, a
;	main.c: 49: PC_CR1 |= (1<<5) | (1<<MOSI_BIT);
	ld	a, 0x500d
	or	a, #0x60
	ld	0x500d, a
;	main.c: 51: PC_DDR &= (uint8_t)~(1<<MISO_BIT);
	bres	0x500c, #7
;	main.c: 52: PC_CR1 &= (uint8_t)~(1<<MISO_BIT);
	bres	0x500d, #7
;	main.c: 54: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
	bset	0x5011, #2
	bset	0x5012, #2
	bset	0x500f, #2
;	main.c: 56: PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
	bres	0x5011, #4
	bres	0x5012, #4
;	main.c: 57: }
	ret
;	main.c: 59: static void spi_init(void){
;	-----------------------------------------
;	 function spi_init
;	-----------------------------------------
_spi_init:
;	main.c: 61: SPI_CR1 = (1<<SPI_CR1_MSTR) | (1<<SPI_CR1_BR2) | (1<<SPI_CR1_BR1) | (1<<SPI_CR1_BR0);
	mov	0x5200+0, #0x3c
;	main.c: 62: SPI_CR2 = (1<<SPI_CR2_SSM) | (1<<SPI_CR2_SSI);
	mov	0x5201+0, #0x03
;	main.c: 63: SPI_CR1 |= (1<<SPI_CR1_SPE);
	bset	0x5200, #6
;	main.c: 64: }
	ret
;	main.c: 65: static uint8_t spi_txrx(uint8_t v){
;	-----------------------------------------
;	 function spi_txrx
;	-----------------------------------------
_spi_txrx:
;	main.c: 66: SPI_DR = v;
	ld	0x5204, a
;	main.c: 67: while(!(SPI_SR & (1<<SPI_SR_TXE)));
00101$:
	btjf	0x5203, #1, 00101$
;	main.c: 68: while(!(SPI_SR & (1<<SPI_SR_RXNE)));
00104$:
	btjf	0x5203, #0, 00104$
;	main.c: 69: return SPI_DR;
	ld	a, 0x5204
;	main.c: 70: }
	ret
;	main.c: 71: static void spi_wait_idle(void){ while(SPI_SR & (1<<SPI_SR_BSY)); }
;	-----------------------------------------
;	 function spi_wait_idle
;	-----------------------------------------
_spi_wait_idle:
00101$:
	ld	a, 0x5203
	jrmi	00101$
	ret
;	main.c: 86: static uint8_t cc_select(void){
;	-----------------------------------------
;	 function cc_select
;	-----------------------------------------
_cc_select:
	sub	sp, #4
;	main.c: 87: CSN_LOW();
	bres	0x500f, #2
;	main.c: 90: while(MISO_IS_HIGH()){
	clrw	x
	ldw	(0x03, sp), x
	ldw	(0x01, sp), x
00103$:
	ld	a, 0x500b
	jrpl	00105$
;	main.c: 91: if(++guard>100000UL){ CSN_HIGH(); return 0; }
	ldw	x, (0x03, sp)
	incw	x
	ldw	(0x03, sp), x
	jrne	00124$
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
00124$:
	ldw	x, #0x86a0
	cpw	x, (0x03, sp)
	ld	a, #0x01
	sbc	a, (0x02, sp)
	clr	a
	sbc	a, (0x01, sp)
	jrnc	00103$
	bset	0x500f, #2
	clr	a
;	main.c: 93: return 1;
	.byte 0xc5
00105$:
	ld	a, #0x01
00106$:
;	main.c: 94: }
	addw	sp, #4
	ret
;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
;	-----------------------------------------
;	 function cc_deselect
;	-----------------------------------------
_cc_deselect:
	call	_spi_wait_idle
	bset	0x500f, #2
	ret
;	main.c: 97: static uint8_t cc_strobe(uint8_t st){
;	-----------------------------------------
;	 function cc_strobe
;	-----------------------------------------
_cc_strobe:
	sub	sp, #2
	ld	(0x02, sp), a
;	main.c: 98: if(!cc_select()) return 0xFF;
	call	_cc_select
	tnz	a
	jrne	00102$
	ld	a, #0xff
	jra	00104$
00102$:
;	main.c: 99: uint8_t s = spi_txrx(st);
	ld	a, (0x02, sp)
	call	_spi_txrx
	ld	(0x01, sp), a
;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 101: return s;
	ld	a, (0x01, sp)
00104$:
;	main.c: 102: }
	addw	sp, #2
	ret
;	main.c: 103: static void cc_write_reg(uint8_t a, uint8_t v){
;	-----------------------------------------
;	 function cc_write_reg
;	-----------------------------------------
_cc_write_reg:
	push	a
	ld	(0x01, sp), a
;	main.c: 104: if(!cc_select()) return;
	call	_cc_select
	tnz	a
	jreq	00104$
;	main.c: 105: spi_txrx(a); spi_txrx(v);
	ld	a, (0x01, sp)
	call	_spi_txrx
	ld	a, (0x04, sp)
	call	_spi_txrx
;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	ld	a, 0x500f
	or	a, #0x04
	ld	0x500f, a
;	main.c: 106: cc_deselect();
00104$:
;	main.c: 107: }
	pop	a
	popw	x
	pop	a
	jp	(x)
;	main.c: 108: static uint8_t cc_read_status(uint8_t addr){
;	-----------------------------------------
;	 function cc_read_status
;	-----------------------------------------
_cc_read_status:
	sub	sp, #2
	ld	(0x02, sp), a
;	main.c: 110: if(!cc_select()) return 0xFF;
	call	_cc_select
	tnz	a
	jrne	00102$
	ld	a, #0xff
	jra	00104$
00102$:
;	main.c: 111: (void)spi_txrx(addr | 0xC0);   // 0x80 -> 0xC0
	ld	a, (0x02, sp)
	or	a, #0xc0
	call	_spi_txrx
;	main.c: 112: v = spi_txrx(0xFF);
	ld	a, #0xff
	call	_spi_txrx
	ld	(0x01, sp), a
;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 114: return v;
	ld	a, (0x01, sp)
00104$:
;	main.c: 115: }
	addw	sp, #2
	ret
;	main.c: 119: static void cc_reset(void){
;	-----------------------------------------
;	 function cc_reset
;	-----------------------------------------
_cc_reset:
;	main.c: 120: CSN_HIGH(); delay_ms(5);
	bset	0x500f, #2
	ldw	x, #0x0005
	call	_delay_ms
;	main.c: 121: CSN_LOW();  delay_ms(5);
	bres	0x500f, #2
	ldw	x, #0x0005
	call	_delay_ms
;	main.c: 122: CSN_HIGH(); delay_ms(5);
	ld	a, 0x500f
	or	a, #0x04
	ld	0x500f, a
	ldw	x, #0x0005
	call	_delay_ms
;	main.c: 123: if(!cc_select()) return;
	call	_cc_select
	tnz	a
	jrne	00102$
	ret
00102$:
;	main.c: 124: spi_txrx(SRES);
	ld	a, #0x30
	call	_spi_txrx
;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	ld	a, 0x500f
	or	a, #0x04
	ld	0x500f, a
;	main.c: 126: delay_ms(5);
	ldw	x, #0x0005
;	main.c: 127: }
	jp	_delay_ms
;	main.c: 130: static void cc_config_868(void){
;	-----------------------------------------
;	 function cc_config_868
;	-----------------------------------------
_cc_config_868:
;	main.c: 131: cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
	push	#0x29
	clr	a
	call	_cc_write_reg
	push	#0x06
	ld	a, #0x02
	call	_cc_write_reg
	push	#0x47
	ld	a, #0x03
	call	_cc_write_reg
;	main.c: 132: cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
	push	#0x3d
	ld	a, #0x06
	call	_cc_write_reg
	push	#0x04
	ld	a, #0x07
	call	_cc_write_reg
	push	#0x05
	ld	a, #0x08
	call	_cc_write_reg
;	main.c: 133: cc_write_reg(0x0B,0x06); cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
	push	#0x06
	ld	a, #0x0b
	call	_cc_write_reg
	push	#0x21
	ld	a, #0x0d
	call	_cc_write_reg
	push	#0x65
	ld	a, #0x0e
	call	_cc_write_reg
	push	#0x6a
	ld	a, #0x0f
	call	_cc_write_reg
;	main.c: 134: cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
	push	#0xf5
	ld	a, #0x10
	call	_cc_write_reg
	push	#0x83
	ld	a, #0x11
	call	_cc_write_reg
	push	#0x13
	ld	a, #0x12
	call	_cc_write_reg
;	main.c: 135: cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
	push	#0x22
	ld	a, #0x13
	call	_cc_write_reg
	push	#0xf8
	ld	a, #0x14
	call	_cc_write_reg
;	main.c: 136: cc_write_reg(0x15,0x15); cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
	push	#0x15
	ld	a, #0x15
	call	_cc_write_reg
	push	#0x18
	ld	a, #0x18
	call	_cc_write_reg
	push	#0x16
	ld	a, #0x19
	call	_cc_write_reg
;	main.c: 137: cc_write_reg(0x1B,0x43); cc_write_reg(0x22,0x11);
	push	#0x43
	ld	a, #0x1b
	call	_cc_write_reg
	push	#0x11
	ld	a, #0x22
	call	_cc_write_reg
;	main.c: 138: cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
	push	#0xe9
	ld	a, #0x23
	call	_cc_write_reg
	push	#0x2a
	ld	a, #0x24
	call	_cc_write_reg
	push	#0x00
	ld	a, #0x25
	call	_cc_write_reg
	push	#0x1f
	ld	a, #0x26
	call	_cc_write_reg
;	main.c: 139: cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
	push	#0x81
	ld	a, #0x2c
	call	_cc_write_reg
	push	#0x35
	ld	a, #0x2d
	call	_cc_write_reg
	push	#0x09
	ld	a, #0x2e
	call	_cc_write_reg
;	main.c: 140: cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
	ld	a, #0x36
	call	_cc_strobe
	ld	a, #0x3a
	call	_cc_strobe
	ld	a, #0x3b
	call	_cc_strobe
;	main.c: 141: delay_ms(2);
	ldw	x, #0x0002
;	main.c: 142: }
	jp	_delay_ms
;	main.c: 145: static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
;	-----------------------------------------
;	 function cc_send_packet
;	-----------------------------------------
_cc_send_packet:
	sub	sp, #7
	ldw	(0x02, sp), x
;	main.c: 146: if(len==0 || len>61) return 0;
	ld	(0x01, sp), a
	jreq	00101$
	ld	a, (0x01, sp)
	cp	a, #0x3d
	jrule	00102$
00101$:
	clr	a
	jp	00119$
00102$:
;	main.c: 147: cc_strobe(SIDLE); cc_strobe(SFTX);
	ld	a, #0x36
	call	_cc_strobe
	ld	a, #0x3b
	call	_cc_strobe
;	main.c: 148: if(!cc_select()) return 0;
	call	_cc_select
	tnz	a
	jrne	00105$
	clr	a
	jp	00119$
00105$:
;	main.c: 149: spi_txrx(TXFIFO | CC_BURST);
	ld	a, #0x7f
	call	_spi_txrx
;	main.c: 150: spi_txrx(len);
	ld	a, (0x01, sp)
	call	_spi_txrx
;	main.c: 151: for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
	clr	(0x07, sp)
00117$:
	ld	a, (0x07, sp)
	cp	a, (0x01, sp)
	jrnc	00106$
	clrw	x
	ld	a, (0x07, sp)
	ld	xl, a
	addw	x, (0x02, sp)
	ld	a, (x)
	call	_spi_txrx
	inc	(0x07, sp)
	jra	00117$
00106$:
;	main.c: 95: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 153: cc_strobe(STX);
	ld	a, #0x35
	call	_cc_strobe
;	main.c: 155: while(!GDO0_READ() && ++guard<150000UL){}   // front haut
	clrw	x
	ldw	(0x06, sp), x
	clrw	y
00108$:
	btjt	0x5010, #4, 00128$
	ldw	x, (0x06, sp)
	incw	x
	ldw	(0x06, sp), x
	jrne	00169$
	incw	y
00169$:
	ldw	x, (0x06, sp)
	cpw	x, #0x49f0
	ld	a, yl
	sbc	a, #0x02
	ld	a, yh
	sbc	a, #0x00
	jrc	00108$
;	main.c: 156: while( GDO0_READ() && ++guard<400000UL){}   // retour bas
00128$:
	ldw	(0x04, sp), y
	ldw	y, (0x06, sp)
00112$:
	btjf	0x5010, #4, 00114$
	incw	y
	jrne	00172$
	ldw	x, (0x04, sp)
	incw	x
	ldw	(0x04, sp), x
00172$:
	cpw	y, #0x1a80
	ld	a, (0x05, sp)
	sbc	a, #0x06
	ld	a, (0x04, sp)
	sbc	a, #0x00
	jrc	00112$
00114$:
;	main.c: 157: return (guard<400000UL);
	cpw	y, #0x1a80
	ld	a, (0x05, sp)
	sbc	a, #0x06
	ld	a, (0x04, sp)
	sbc	a, #0x00
	clr	a
	rlc	a
00119$:
;	main.c: 158: }
	addw	sp, #7
	ret
;	main.c: 161: static void dump_once(const char* tag){
;	-----------------------------------------
;	 function dump_once
;	-----------------------------------------
_dump_once:
	sub	sp, #8
	ldw	(0x07, sp), x
;	main.c: 162: uint8_t pn = cc_read_status(PARTNUM);
	ld	a, #0x30
	call	_cc_read_status
	ld	(0x06, sp), a
;	main.c: 163: uint8_t vr = cc_read_status(VERSION);
	ld	a, #0x31
	call	_cc_read_status
	ld	(0x05, sp), a
;	main.c: 164: uint8_t ms = cc_read_status(MARCSTATE);
	ld	a, #0x35
	call	_cc_read_status
	ld	yl, a
;	main.c: 166: tag, pn, vr, ms, MISO_IS_HIGH());
	ld	a, 0x500b
	jrpl	00103$
	clrw	x
	incw	x
	ldw	(0x01, sp), x
	.byte 0xbc
00103$:
	clrw	x
	ldw	(0x01, sp), x
00104$:
	clr	a
	ld	yh, a
	ld	a, (0x05, sp)
	ld	(0x04, sp), a
	clr	(0x03, sp)
	ld	a, (0x06, sp)
	clr	(0x05, sp)
;	main.c: 165: printf("[%s] PART=0x%02X VER=0x%02X MARC=0x%02X  (MISO=%d)\r\n",
	ldw	x, (0x01, sp)
	pushw	x
	pushw	y
	ldw	x, (0x07, sp)
	pushw	x
	push	a
	ld	a, (0x0c, sp)
	push	a
	ldw	x, (0x0f, sp)
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
;	main.c: 167: }
	addw	sp, #20
	ret
;	main.c: 170: void main(void){
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	sub	sp, #4
;	main.c: 171: uart_init(); gpio_init(); spi_init();
	call	_uart_init
	call	_gpio_init
	call	_spi_init
;	main.c: 172: printf("\r\n[STM8S] CC1101 TX test @868 MHz  (SWAP=%d)\r\n", SWAP_MOSI_MISO);
	clrw	x
	pushw	x
	push	#<(___str_1+0)
	push	#((___str_1+0) >> 8)
	call	_printf
	addw	sp, #4
;	main.c: 175: delay_ms(20);
	ldw	x, #0x0014
	call	_delay_ms
;	main.c: 178: dump_once("BEFORE");
	ldw	x, #(___str_2+0)
	call	_dump_once
;	main.c: 180: cc_reset();
	call	_cc_reset
;	main.c: 181: dump_once("AFTER_RST");
	ldw	x, #(___str_3+0)
	call	_dump_once
;	main.c: 183: cc_config_868();
	call	_cc_config_868
;	main.c: 184: dump_once("AFTER_CFG");
	ldw	x, #(___str_4+0)
	call	_dump_once
00102$:
;	main.c: 187: uint8_t pkt[4] = {0x01,0x00,0xEA,0xEB};
	ld	a, #0x01
	ld	(0x01, sp), a
	clr	(0x02, sp)
	ld	a, #0xea
	ld	(0x03, sp), a
	ld	a, #0xeb
	ld	(0x04, sp), a
;	main.c: 188: uint8_t ok = cc_send_packet(pkt, sizeof(pkt));
	ld	a, #0x04
	ldw	x, sp
	incw	x
	call	_cc_send_packet
;	main.c: 189: dump_once(ok?"TX_OK":"TX_TO");
	tnz	a
	jreq	00106$
	ldw	x, #___str_5+0
	.byte 0xbc
00106$:
	ldw	x, #(___str_6+0)
00107$:
	call	_dump_once
;	main.c: 190: delay_ms(1500);
	ldw	x, #0x05dc
	call	_delay_ms
	jra	00102$
;	main.c: 192: }
	addw	sp, #4
	ret
	.area CODE
	.area CONST
	.area CONST
___str_0:
	.ascii "[%s] PART=0x%02X VER=0x%02X MARC=0x%02X  (MISO=%d)"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_1:
	.db 0x0d
	.db 0x0a
	.ascii "[STM8S] CC1101 TX test @868 MHz  (SWAP=%d)"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_2:
	.ascii "BEFORE"
	.db 0x00
	.area CODE
	.area CONST
___str_3:
	.ascii "AFTER_RST"
	.db 0x00
	.area CODE
	.area CONST
___str_4:
	.ascii "AFTER_CFG"
	.db 0x00
	.area CODE
	.area CONST
___str_5:
	.ascii "TX_OK"
	.db 0x00
	.area CODE
	.area CONST
___str_6:
	.ascii "TX_TO"
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
