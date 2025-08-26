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
	.globl _puts
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
;	main.c: 19: static inline void uart_config(void) {
;	-----------------------------------------
;	 function uart_config
;	-----------------------------------------
_uart_config:
;	main.c: 20: CLK_CKDIVR = 0x00; // 16 MHz
	mov	0x50c6+0, #0x00
;	main.c: 22: UART1_BRR1 = (usartdiv >> 4) & 0xFF;
	ld	a, #0x68
	ld	0x5232, a
;	main.c: 23: UART1_BRR2 = ((usartdiv & 0x0F) | ((usartdiv >> 8) & 0xF0));
	ld	a, #0x83
	and	a, #0x0f
	ld	0x5233, a
;	main.c: 24: UART1_CR1 = 0x00;
	mov	0x5234+0, #0x00
;	main.c: 25: UART1_CR3 = 0x00;
	mov	0x5236+0, #0x00
;	main.c: 26: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
	mov	0x5235+0, #0x0c
;	main.c: 27: (void)UART1_SR; (void)UART1_DR;
	ld	a, 0x5230
	ld	a, 0x5231
;	main.c: 28: }
	ret
;	main.c: 29: static inline void uart_write(uint8_t b){ UART1_DR=b; while(!(UART1_SR&(1<<UART1_SR_TC))); }
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
	ld	0x5231, a
00101$:
	btjf	0x5230, #6, 00101$
	ret
;	main.c: 30: int putchar(int c){ uart_write((uint8_t)c); return 0; }
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	main.c: 29: static inline void uart_write(uint8_t b){ UART1_DR=b; while(!(UART1_SR&(1<<UART1_SR_TC))); }
	ld	0x5231, a
00101$:
	btjf	0x5230, #6, 00101$
;	main.c: 30: int putchar(int c){ uart_write((uint8_t)c); return 0; }
	clrw	x
	ret
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
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
;	main.c: 33: static inline void delay_ms(uint16_t ms){
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
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
;	main.c: 35: }
	addw	sp, #10
	ret
;	main.c: 85: static void gpio_init_spi(void){
;	-----------------------------------------
;	 function gpio_init_spi
;	-----------------------------------------
_gpio_init_spi:
;	main.c: 87: PC_DDR |= (1<<5)|(1<<6); PC_CR1 |= (1<<5)|(1<<6);
	ld	a, 0x500c
	or	a, #0x60
	ld	0x500c, a
	ld	a, 0x500d
	or	a, #0x60
	ld	0x500d, a
;	main.c: 89: PC_DDR &= (uint8_t)~(1<<7); PC_CR1 &= (uint8_t)~(1<<7);
	bres	0x500c, #7
	bres	0x500d, #7
;	main.c: 91: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
	bset	0x5011, #2
	bset	0x5012, #2
	bset	0x500f, #2
;	main.c: 93: PD_DDR |= (1<<4); PD_CR1 |= (1<<4); CE_LOW();
	bset	0x5011, #4
	bset	0x5012, #4
	bres	0x500f, #4
;	main.c: 94: }
	ret
;	main.c: 97: static void spi_init(void){
;	-----------------------------------------
;	 function spi_init
;	-----------------------------------------
_spi_init:
;	main.c: 98: SPI_CR1 = BIT(SPI_CR1_MSTR) | BIT(SPI_CR1_BR2);   /* /64 */
	mov	0x5200+0, #0x24
;	main.c: 99: SPI_CR2 = BIT(SPI_CR2_SSM)  | BIT(SPI_CR2_SSI);
	mov	0x5201+0, #0x03
;	main.c: 100: SPI_CR1 |= BIT(SPI_CR1_SPE);
	bset	0x5200, #6
;	main.c: 101: }
	ret
;	main.c: 102: static uint8_t spi_txrx(uint8_t v){
;	-----------------------------------------
;	 function spi_txrx
;	-----------------------------------------
_spi_txrx:
;	main.c: 103: SPI_DR = v;
	ld	0x5204, a
;	main.c: 104: while(!(SPI_SR & BIT(SPI_SR_TXE)));
00101$:
	btjf	0x5203, #1, 00101$
;	main.c: 105: while(!(SPI_SR & BIT(SPI_SR_RXNE)));
00104$:
	btjf	0x5203, #0, 00104$
;	main.c: 106: return SPI_DR;
	ld	a, 0x5204
;	main.c: 107: }
	ret
;	main.c: 108: static void spi_wait_idle(void){ while(SPI_SR & BIT(SPI_SR_BSY)); }
;	-----------------------------------------
;	 function spi_wait_idle
;	-----------------------------------------
_spi_wait_idle:
00101$:
	ld	a, 0x5203
	jrmi	00101$
	ret
;	main.c: 111: static uint8_t nrf_read_reg(uint8_t reg){
;	-----------------------------------------
;	 function nrf_read_reg
;	-----------------------------------------
_nrf_read_reg:
	sub	sp, #4
	ld	(0x04, sp), a
;	main.c: 113: CSN_LOW(); delay_cycles(50);
	ld	a, 0x500f
	and	a, #0xfb
	ld	0x500f, a
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00101$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00104$
	nop
	jra	00101$
;	main.c: 113: CSN_LOW(); delay_cycles(50);
00104$:
;	main.c: 114: (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
	ld	a, (0x04, sp)
	and	a, #0x1f
	call	_spi_txrx
;	main.c: 115: v = spi_txrx(0xFF);
	ld	a, #0xff
	call	_spi_txrx
	ld	(0x03, sp), a
;	main.c: 116: spi_wait_idle(); delay_cycles(50);
	call	_spi_wait_idle
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00105$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00108$
	nop
	jra	00105$
;	main.c: 116: spi_wait_idle(); delay_cycles(50);
00108$:
;	main.c: 117: CSN_HIGH();
	bset	0x500f, #2
;	main.c: 118: return v;
	ld	a, (0x03, sp)
;	main.c: 119: }
	addw	sp, #4
	ret
;	main.c: 120: static void nrf_write_reg(uint8_t reg, uint8_t val){
;	-----------------------------------------
;	 function nrf_write_reg
;	-----------------------------------------
_nrf_write_reg:
	sub	sp, #3
	ld	(0x03, sp), a
;	main.c: 121: CSN_LOW(); delay_cycles(50);
	ld	a, 0x500f
	and	a, #0xfb
	ld	0x500f, a
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00101$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00104$
	nop
	jra	00101$
;	main.c: 121: CSN_LOW(); delay_cycles(50);
00104$:
;	main.c: 122: (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
	ld	a, (0x03, sp)
	and	a, #0x1f
	or	a, #0x20
	call	_spi_txrx
;	main.c: 123: (void)spi_txrx(val);
	ld	a, (0x06, sp)
	call	_spi_txrx
;	main.c: 124: spi_wait_idle(); delay_cycles(50);
	call	_spi_wait_idle
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00105$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00108$
	nop
	jra	00105$
;	main.c: 124: spi_wait_idle(); delay_cycles(50);
00108$:
;	main.c: 125: CSN_HIGH();
	bset	0x500f, #2
;	main.c: 126: }
	addw	sp, #3
	popw	x
	pop	a
	jp	(x)
;	main.c: 127: static void nrf_read_reg_n(uint8_t reg, uint8_t *buf, uint8_t len){
;	-----------------------------------------
;	 function nrf_read_reg_n
;	-----------------------------------------
_nrf_read_reg_n:
	sub	sp, #6
	ld	(0x05, sp), a
	ldw	(0x03, sp), x
;	main.c: 128: CSN_LOW(); delay_cycles(50);
	ld	a, 0x500f
	and	a, #0xfb
	ld	0x500f, a
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00102$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00105$
	nop
	jra	00102$
;	main.c: 128: CSN_LOW(); delay_cycles(50);
00105$:
;	main.c: 129: (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
	ld	a, (0x05, sp)
	and	a, #0x1f
	call	_spi_txrx
;	main.c: 130: for(uint8_t i=0;i<len;i++) buf[i] = spi_txrx(0xFF);
	clr	(0x06, sp)
00111$:
	ld	a, (0x06, sp)
	cp	a, (0x09, sp)
	jrnc	00101$
	clrw	x
	ld	a, (0x06, sp)
	ld	xl, a
	addw	x, (0x03, sp)
	pushw	x
	ld	a, #0xff
	call	_spi_txrx
	popw	x
	ld	(x), a
	inc	(0x06, sp)
	jra	00111$
00101$:
;	main.c: 131: spi_wait_idle(); delay_cycles(50);
	call	_spi_wait_idle
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00106$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00109$
	nop
	jra	00106$
;	main.c: 131: spi_wait_idle(); delay_cycles(50);
00109$:
;	main.c: 132: CSN_HIGH();
	bset	0x500f, #2
;	main.c: 133: }
	addw	sp, #6
	popw	x
	pop	a
	jp	(x)
;	main.c: 134: static void nrf_write_reg_n(uint8_t reg, const uint8_t *buf, uint8_t len){
;	-----------------------------------------
;	 function nrf_write_reg_n
;	-----------------------------------------
_nrf_write_reg_n:
	sub	sp, #6
	ld	(0x05, sp), a
	ldw	(0x03, sp), x
;	main.c: 135: CSN_LOW(); delay_cycles(50);
	ld	a, 0x500f
	and	a, #0xfb
	ld	0x500f, a
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00102$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00105$
	nop
	jra	00102$
;	main.c: 135: CSN_LOW(); delay_cycles(50);
00105$:
;	main.c: 136: (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
	ld	a, (0x05, sp)
	and	a, #0x1f
	or	a, #0x20
	call	_spi_txrx
;	main.c: 137: for(uint8_t i=0;i<len;i++) (void)spi_txrx(buf[i]);
	clr	(0x06, sp)
00111$:
	ld	a, (0x06, sp)
	cp	a, (0x09, sp)
	jrnc	00101$
	clrw	x
	ld	a, (0x06, sp)
	ld	xl, a
	addw	x, (0x03, sp)
	ld	a, (x)
	call	_spi_txrx
	inc	(0x06, sp)
	jra	00111$
00101$:
;	main.c: 138: spi_wait_idle(); delay_cycles(50);
	call	_spi_wait_idle
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00106$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00109$
	nop
	jra	00106$
;	main.c: 138: spi_wait_idle(); delay_cycles(50);
00109$:
;	main.c: 139: CSN_HIGH();
	bset	0x500f, #2
;	main.c: 140: }
	addw	sp, #6
	popw	x
	pop	a
	jp	(x)
;	main.c: 141: static uint8_t nrf_cmd(uint8_t cmd){
;	-----------------------------------------
;	 function nrf_cmd
;	-----------------------------------------
_nrf_cmd:
	sub	sp, #4
	ld	(0x04, sp), a
;	main.c: 143: CSN_LOW(); delay_cycles(50);
	ld	a, 0x500f
	and	a, #0xfb
	ld	0x500f, a
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00101$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00104$
	nop
	jra	00101$
;	main.c: 143: CSN_LOW(); delay_cycles(50);
00104$:
;	main.c: 144: s = spi_txrx(cmd);
	ld	a, (0x04, sp)
	call	_spi_txrx
	ld	(0x03, sp), a
;	main.c: 145: spi_wait_idle(); delay_cycles(50);
	call	_spi_wait_idle
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00105$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00108$
	nop
	jra	00105$
;	main.c: 145: spi_wait_idle(); delay_cycles(50);
00108$:
;	main.c: 146: CSN_HIGH();
	bset	0x500f, #2
;	main.c: 147: return s;
	ld	a, (0x03, sp)
;	main.c: 148: }
	addw	sp, #4
	ret
;	main.c: 151: static uint8_t nrf_status_raw(void){
;	-----------------------------------------
;	 function nrf_status_raw
;	-----------------------------------------
_nrf_status_raw:
	sub	sp, #3
;	main.c: 153: CSN_LOW(); delay_cycles(50);
	ld	a, 0x500f
	and	a, #0xfb
	ld	0x500f, a
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00101$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00104$
	nop
	jra	00101$
;	main.c: 153: CSN_LOW(); delay_cycles(50);
00104$:
;	main.c: 154: s = spi_txrx(NRF_NOP);
	ld	a, #0xff
	call	_spi_txrx
	ld	(0x03, sp), a
;	main.c: 155: spi_wait_idle(); delay_cycles(50);
	call	_spi_wait_idle
	ldw	x, #0x0032
	ldw	(0x01, sp), x
;	main.c: 32: static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
00105$:
	ldw	y, (0x01, sp)
	ldw	x, y
	decw	x
	ldw	(0x01, sp), x
	tnzw	y
	jreq	00108$
	nop
	jra	00105$
;	main.c: 155: spi_wait_idle(); delay_cycles(50);
00108$:
;	main.c: 156: CSN_HIGH(); return s;
	bset	0x500f, #2
	ld	a, (0x03, sp)
;	main.c: 157: }
	addw	sp, #3
	ret
;	main.c: 158: static uint8_t nrf_bus_ok(void){
;	-----------------------------------------
;	 function nrf_bus_ok
;	-----------------------------------------
_nrf_bus_ok:
;	main.c: 159: uint8_t s = nrf_status_raw();
	call	_nrf_status_raw
;	main.c: 160: return (s != 0xFF && s != 0x00);
	cp	a, #0xff
	jreq	00103$
	tnz	a
	jrne	00104$
00103$:
	clr	a
	ret
00104$:
	ld	a, #0x01
;	main.c: 161: }
	ret
;	main.c: 163: static void nrf_dump_status(void){
;	-----------------------------------------
;	 function nrf_dump_status
;	-----------------------------------------
_nrf_dump_status:
	sub	sp, #10
;	main.c: 164: uint8_t s = nrf_status_raw();
	call	_nrf_status_raw
;	main.c: 167: (s>>1)&0x07, !!(s&0x01));
	ld	xl, a
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	ld	(0x02, sp), a
	clr	(0x01, sp)
	ld	a, xl
	srl	a
	clr	(0x09, sp)
	and	a, #0x07
	ld	(0x04, sp), a
	clr	(0x03, sp)
;	main.c: 166: s, !!(s&(1<<RX_DR)), !!(s&(1<<TX_DS)), !!(s&(1<<MAX_RT)),
	ld	a, xl
	srl	a
	srl	a
	srl	a
	srl	a
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	ld	(0x06, sp), a
	clr	(0x05, sp)
	ld	a, xl
	swap	a
	srl	a
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	ld	(0x08, sp), a
	clr	(0x07, sp)
	ld	a, xl
	sll	a
	sll	a
	clr	a
	rlc	a
	sub	a, #0x01
	clr	a
	ccf
	rlc	a
	clr	(0x09, sp)
	rlwa	x
	clr	a
	rrwa	x
;	main.c: 165: printf("\r\n[STATUS] 0x%02X  (RX_DR=%d TX_DS=%d MAX_RT=%d RX_PIPE=%u TX_FULL=%d)\r\n",
	ldw	y, (0x01, sp)
	pushw	y
	ldw	y, (0x05, sp)
	pushw	y
	ldw	y, (0x09, sp)
	pushw	y
	ldw	y, (0x0d, sp)
	pushw	y
	push	a
	ld	a, (0x12, sp)
	push	a
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
;	main.c: 168: }
	addw	sp, #24
	ret
;	main.c: 169: static void nrf_dump_core_regs(void){
;	-----------------------------------------
;	 function nrf_dump_core_regs
;	-----------------------------------------
_nrf_dump_core_regs:
	sub	sp, #28
;	main.c: 170: uint8_t cfg = nrf_read_reg(NRF_REG_CONFIG);
	clr	a
	call	_nrf_read_reg
	ld	(0x1a, sp), a
;	main.c: 171: uint8_t rfch = nrf_read_reg(NRF_REG_RF_CH);
	ld	a, #0x05
	call	_nrf_read_reg
	ld	(0x1b, sp), a
;	main.c: 172: uint8_t rfs  = nrf_read_reg(NRF_REG_RF_SETUP);
	ld	a, #0x06
	call	_nrf_read_reg
	ld	(0x1c, sp), a
;	main.c: 174: nrf_read_reg_n(NRF_REG_TX_ADDR, tx, 5);
	push	#0x05
	ldw	x, sp
	incw	x
	incw	x
	ld	a, #0x10
	call	_nrf_read_reg_n
;	main.c: 175: nrf_read_reg_n(NRF_REG_RX_ADDR_P0, rx0, 5);
	push	#0x05
	ldw	x, sp
	addw	x, #7
	ld	a, #0x0a
	call	_nrf_read_reg_n
;	main.c: 177: printf("[CORE]   CONFIG=0x%02X  RF_CH=0x%02X  RF_SETUP=0x%02X\r\n", cfg, rfch, rfs);
	clrw	y
	ld	a, (0x1c, sp)
	ld	yl, a
	clrw	x
	ld	a, (0x1b, sp)
	ld	xl, a
	ld	a, (0x1a, sp)
	ld	(0x1c, sp), a
	clr	(0x1b, sp)
	pushw	y
	pushw	x
	ldw	x, (0x1f, sp)
	pushw	x
	push	#<(___str_1+0)
	push	#((___str_1+0) >> 8)
	call	_printf
	addw	sp, #8
;	main.c: 179: tx[0],tx[1],tx[2],tx[3],tx[4], rx0[0],rx0[1],rx0[2],rx0[3],rx0[4]);
	ld	a, (0x0a, sp)
	clrw	x
	ld	xl, a
	ld	a, (0x09, sp)
	ld	(0x0c, sp), a
	clr	(0x0b, sp)
	ld	a, (0x08, sp)
	ld	(0x0e, sp), a
	clr	(0x0d, sp)
	ld	a, (0x07, sp)
	ld	(0x10, sp), a
	clr	(0x0f, sp)
	ld	a, (0x06, sp)
	ld	(0x12, sp), a
	clr	(0x11, sp)
	ld	a, (0x05, sp)
	ld	(0x14, sp), a
	clr	(0x13, sp)
	ld	a, (0x04, sp)
	ld	(0x16, sp), a
	clr	(0x15, sp)
	ld	a, (0x03, sp)
	ld	(0x18, sp), a
	clr	(0x17, sp)
	ld	a, (0x02, sp)
	ld	(0x1a, sp), a
	clr	(0x19, sp)
	ld	a, (0x01, sp)
	clr	(0x1b, sp)
;	main.c: 178: printf("[ADDR]   TX_ADDR=%02X %02X %02X %02X %02X  |  RX0=%02X %02X %02X %02X %02X\r\n",
	pushw	x
	ldw	x, (0x0d, sp)
	pushw	x
	ldw	x, (0x11, sp)
	pushw	x
	ldw	x, (0x15, sp)
	pushw	x
	ldw	x, (0x19, sp)
	pushw	x
	ldw	x, (0x1d, sp)
	pushw	x
	ldw	x, (0x21, sp)
	pushw	x
	ldw	x, (0x25, sp)
	pushw	x
	ldw	x, (0x29, sp)
	pushw	x
	push	a
	ld	a, (0x2e, sp)
	push	a
	push	#<(___str_2+0)
	push	#((___str_2+0) >> 8)
	call	_printf
;	main.c: 180: }
	addw	sp, #50
	ret
;	main.c: 181: static void nrf_dump_tx_regs(void){
;	-----------------------------------------
;	 function nrf_dump_tx_regs
;	-----------------------------------------
_nrf_dump_tx_regs:
	sub	sp, #6
;	main.c: 182: uint8_t enaa = nrf_read_reg(NRF_REG_EN_AA);
	ld	a, #0x01
	call	_nrf_read_reg
	ld	(0x06, sp), a
;	main.c: 183: uint8_t enrx = nrf_read_reg(NRF_REG_EN_RXADDR);
	ld	a, #0x02
	call	_nrf_read_reg
	ld	(0x05, sp), a
;	main.c: 184: uint8_t retr = nrf_read_reg(NRF_REG_SETUP_RETR);
	ld	a, #0x04
	call	_nrf_read_reg
;	main.c: 185: uint8_t pw0  = nrf_read_reg(NRF_REG_RX_PW_P0);
	push	a
	ld	a, #0x11
	call	_nrf_read_reg
	ld	yl, a
	pop	a
;	main.c: 187: enaa, enrx, retr, pw0);
	clr	(0x01, sp)
	clrw	x
	ld	xl, a
	ld	a, (0x05, sp)
	ld	(0x04, sp), a
	clr	(0x03, sp)
	clr	(0x05, sp)
;	main.c: 186: printf("[TXCFG]  EN_AA=0x%02X  EN_RXADDR=0x%02X  SETUP_RETR=0x%02X  RX_PW_P0=%u\r\n",
	ld	a, yl
	push	a
	ld	a, (0x02, sp)
	push	a
	pushw	x
	ldw	x, (0x07, sp)
	pushw	x
	ldw	x, (0x0b, sp)
	pushw	x
	push	#<(___str_3+0)
	push	#((___str_3+0) >> 8)
	call	_printf
;	main.c: 188: }
	addw	sp, #16
	ret
;	main.c: 189: static void nrf_dump_fifo(void){
;	-----------------------------------------
;	 function nrf_dump_fifo
;	-----------------------------------------
_nrf_dump_fifo:
	sub	sp, #10
;	main.c: 190: uint8_t f = nrf_read_reg(NRF_REG_FIFO_STATUS);
	ld	a, #0x17
	call	_nrf_read_reg
;	main.c: 192: f, !!(f&0x10), !!(f&0x20), !!(f&0x01), !!(f&0x02));
	ld	xh, a
	srl	a
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	ld	(0x02, sp), a
	clr	(0x01, sp)
	ld	a, xh
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	ld	(0x04, sp), a
	clr	(0x03, sp)
	ld	a, xh
	swap	a
	srl	a
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	ld	xl, a
	clr	(0x05, sp)
	ld	a, xh
	srl	a
	srl	a
	srl	a
	srl	a
	and	a, #0x01
	xor	a, #0x01
	xor	a, #0x01
	clr	(0x07, sp)
	clr	(0x09, sp)
;	main.c: 191: printf("[FIFO]   0x%02X  TX_EMPTY=%d TX_FULL=%d  RX_EMPTY=%d RX_FULL=%d\r\n",
	ldw	y, (0x01, sp)
	pushw	y
	ldw	y, (0x05, sp)
	pushw	y
	pushw	x
	addw	sp, #1
	exg	a, xl
	ld	a, (0x0a, sp)
	exg	a, xl
	pushw	x
	addw	sp, #1
	push	a
	ld	a, (0x0e, sp)
	push	a
	ld	a, xh
	push	a
	ld	a, (0x12, sp)
	push	a
	push	#<(___str_4+0)
	push	#((___str_4+0) >> 8)
	call	_printf
;	main.c: 193: }
	addw	sp, #22
	ret
;	main.c: 196: static void nrf_set_common(uint8_t rf_ch){
;	-----------------------------------------
;	 function nrf_set_common
;	-----------------------------------------
_nrf_set_common:
;	main.c: 197: nrf_write_reg(NRF_REG_SETUP_AW, 0x03);     // adresse 5B
	push	a
	push	#0x03
	ld	a, #0x03
	call	_nrf_write_reg
	ld	a, #0x05
	call	_nrf_write_reg
;	main.c: 199: nrf_write_reg(NRF_REG_RF_SETUP, 0x06);     // 1Mbps, 0dBm
	push	#0x06
	ld	a, #0x06
	call	_nrf_write_reg
;	main.c: 200: nrf_write_reg_n(NRF_REG_TX_ADDR,    ADDR_NODE1, 5);
	push	#0x05
	ldw	x, #(_ADDR_NODE1+0)
	ld	a, #0x10
	call	_nrf_write_reg_n
;	main.c: 201: nrf_write_reg_n(NRF_REG_RX_ADDR_P0, ADDR_NODE1, 5);
	push	#0x05
	ldw	x, #(_ADDR_NODE1+0)
	ld	a, #0x0a
	call	_nrf_write_reg_n
;	main.c: 202: nrf_write_reg(NRF_REG_STATUS, 0x70);       // clear IRQ
	push	#0x70
	ld	a, #0x07
	call	_nrf_write_reg
;	main.c: 203: (void)nrf_cmd(NRF_CMD_FLUSH_RX);
	ld	a, #0xe2
	call	_nrf_cmd
;	main.c: 204: (void)nrf_cmd(NRF_CMD_FLUSH_TX);
	ld	a, #0xe1
	call	_nrf_cmd
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
	clrw	y
	clrw	x
00104$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrc	00119$
	ret
00119$:
	nop
	incw	y
	jrne	00104$
	incw	x
	jra	00104$
;	main.c: 205: delay_ms(5);                                // tpd2stby
;	main.c: 206: }
	ret
;	main.c: 209: static void nrf_ptx_start_ack(void){
;	-----------------------------------------
;	 function nrf_ptx_start_ack
;	-----------------------------------------
_nrf_ptx_start_ack:
;	main.c: 210: nrf_set_common(RF_CHAN);
	ld	a, #0x4c
	call	_nrf_set_common
;	main.c: 211: nrf_write_reg(NRF_REG_EN_AA,      0x01);
	push	#0x01
	ld	a, #0x01
	call	_nrf_write_reg
;	main.c: 212: nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
	push	#0x01
	ld	a, #0x02
	call	_nrf_write_reg
;	main.c: 213: nrf_write_reg(NRF_REG_RX_PW_P0,   PAYLOAD_LEN);
	push	#0x20
	ld	a, #0x11
	call	_nrf_write_reg
;	main.c: 214: nrf_write_reg(NRF_REG_SETUP_RETR, 0x5F);
	push	#0x5f
	ld	a, #0x04
	call	_nrf_write_reg
;	main.c: 215: nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP); // 0x0E
	push	#0x0e
	clr	a
	call	_nrf_write_reg
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
	clrw	y
	clrw	x
00104$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrc	00119$
	ret
00119$:
	nop
	incw	y
	jrne	00104$
	incw	x
	jra	00104$
;	main.c: 216: delay_ms(5);
;	main.c: 217: }
	ret
;	main.c: 219: static void nrf_ptx_start_noack(void){
;	-----------------------------------------
;	 function nrf_ptx_start_noack
;	-----------------------------------------
_nrf_ptx_start_noack:
;	main.c: 220: nrf_set_common(RF_CHAN);
	ld	a, #0x4c
	call	_nrf_set_common
;	main.c: 221: nrf_write_reg(NRF_REG_EN_AA,      0x00);
	push	#0x00
	ld	a, #0x01
	call	_nrf_write_reg
;	main.c: 222: nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
	push	#0x01
	ld	a, #0x02
	call	_nrf_write_reg
;	main.c: 223: nrf_write_reg(NRF_REG_SETUP_RETR, 0x00);
	push	#0x00
	ld	a, #0x04
	call	_nrf_write_reg
;	main.c: 224: nrf_write_reg(NRF_REG_RX_PW_P0,   PAYLOAD_LEN);
	push	#0x20
	ld	a, #0x11
	call	_nrf_write_reg
;	main.c: 225: nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP); // 0x0E
	push	#0x0e
	clr	a
	call	_nrf_write_reg
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
	clrw	y
	clrw	x
00104$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrc	00119$
	ret
00119$:
	nop
	incw	y
	jrne	00104$
	incw	x
	jra	00104$
;	main.c: 226: delay_ms(5);
;	main.c: 227: }
	ret
;	main.c: 229: static void nrf_prx_start(uint8_t payload_len){
;	-----------------------------------------
;	 function nrf_prx_start
;	-----------------------------------------
_nrf_prx_start:
	push	a
	ld	(0x01, sp), a
;	main.c: 230: nrf_set_common(RF_CHAN);
	ld	a, #0x4c
	call	_nrf_set_common
;	main.c: 231: nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
	push	#0x01
	ld	a, #0x02
	call	_nrf_write_reg
;	main.c: 232: nrf_write_reg(NRF_REG_EN_AA,      0x01);
	push	#0x01
	ld	a, #0x01
	call	_nrf_write_reg
;	main.c: 233: nrf_write_reg(NRF_REG_RX_PW_P0,   payload_len);
	ld	a, (0x01, sp)
	push	a
	ld	a, #0x11
	call	_nrf_write_reg
;	main.c: 234: nrf_write_reg(NRF_REG_SETUP_RETR, 0x5F);
	push	#0x5f
	ld	a, #0x04
	call	_nrf_write_reg
;	main.c: 235: nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP | CFG_PRIM_RX); // 0x0F
	push	#0x0f
	clr	a
	call	_nrf_write_reg
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
	clrw	y
	clrw	x
00104$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00102$
	nop
	incw	y
	jrne	00104$
	incw	x
	jra	00104$
;	main.c: 236: delay_ms(5);
00102$:
;	main.c: 237: CE_HIGH();
	bset	0x500f, #4
;	main.c: 238: }
	pop	a
	ret
;	main.c: 241: static uint8_t nrf_tx32_and_pulse_ce(const uint8_t *data, uint8_t len){
;	-----------------------------------------
;	 function nrf_tx32_and_pulse_ce
;	-----------------------------------------
_nrf_tx32_and_pulse_ce:
	sub	sp, #7
	ldw	(0x02, sp), x
	ld	(0x01, sp), a
;	main.c: 243: nrf_write_reg(NRF_REG_STATUS, 0x70);
	push	#0x70
	ld	a, #0x07
	call	_nrf_write_reg
;	main.c: 244: (void)nrf_cmd(NRF_CMD_FLUSH_TX);
	ld	a, #0xe1
	call	_nrf_cmd
;	main.c: 247: CSN_LOW(); (void)spi_txrx(NRF_W_TX_PAYLOAD);
	bres	0x500f, #2
	ld	a, #0xa0
	call	_spi_txrx
;	main.c: 248: for(uint8_t i=0;i<32;i++) (void)spi_txrx((i<len)?data[i]:0x00);
	clr	a
00112$:
	cp	a, #0x20
	jrnc	00101$
	cp	a, (0x01, sp)
	jrnc	00119$
	clrw	x
	ld	xl, a
	addw	x, (0x02, sp)
	push	a
	ld	a, (x)
	ld	xl, a
	pop	a
	rlwa	x
	clr	a
	rrwa	x
	.byte 0x21
00119$:
	clrw	x
00120$:
	push	a
	ld	a, xl
	call	_spi_txrx
	pop	a
	inc	a
	jra	00112$
00101$:
;	main.c: 249: spi_wait_idle(); CSN_HIGH();
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 252: nrf_dump_fifo();
	call	_nrf_dump_fifo
;	main.c: 255: CE_HIGH(); delay_ms(2); CE_LOW();
	bset	0x500f, #4
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
	clrw	y
	clrw	x
00115$:
	cpw	y, #0x06f0
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00110$
	nop
	incw	y
	jrne	00115$
	incw	x
	jra	00115$
;	main.c: 255: CE_HIGH(); delay_ms(2); CE_LOW();
00110$:
	bres	0x500f, #4
;	main.c: 259: while(guard++ < 60000UL){
	clrw	y
	clrw	x
	ldw	(0x04, sp), x
00106$:
	cpw	y, #0xea60
	ld	a, (0x05, sp)
	sbc	a, #0x00
	ld	a, (0x04, sp)
	sbc	a, #0x00
	jrnc	00108$
	incw	y
	jrne	00173$
	ldw	x, (0x04, sp)
	incw	x
	ldw	(0x04, sp), x
00173$:
;	main.c: 260: uint8_t s = nrf_status_raw();
	pushw	y
	call	_nrf_status_raw
	popw	y
;	main.c: 261: if (s & (1<<TX_DS)) { nrf_write_reg(NRF_REG_STATUS,(1<<TX_DS)); return 1; }
	bcp	a, #0x20
	jreq	00103$
	push	#0x20
	ld	a, #0x07
	call	_nrf_write_reg
	ld	a, #0x01
	jra	00117$
00103$:
;	main.c: 262: if (s & (1<<MAX_RT)) { nrf_write_reg(NRF_REG_STATUS,(1<<MAX_RT)); (void)nrf_cmd(NRF_CMD_FLUSH_TX); return 0; }
	bcp	a, #0x10
	jreq	00106$
	push	#0x10
	ld	a, #0x07
	call	_nrf_write_reg
	ld	a, #0xe1
	call	_nrf_cmd
	clr	a
	jra	00117$
00108$:
;	main.c: 265: (void)nrf_cmd(NRF_CMD_FLUSH_TX);
	ld	a, #0xe1
	call	_nrf_cmd
;	main.c: 266: return 0;
	clr	a
00117$:
;	main.c: 267: }
	addw	sp, #7
	ret
;	main.c: 269: static uint8_t nrf_ptx_send_noack(const uint8_t *data, uint8_t len){
;	-----------------------------------------
;	 function nrf_ptx_send_noack
;	-----------------------------------------
_nrf_ptx_send_noack:
;	main.c: 270: return nrf_tx32_and_pulse_ce(data, len); /* TX_DS quand la trame est émise */
;	main.c: 271: }
	jp	_nrf_tx32_and_pulse_ce
;	main.c: 272: static uint8_t nrf_ptx_send_ack(const uint8_t *data, uint8_t len){
;	-----------------------------------------
;	 function nrf_ptx_send_ack
;	-----------------------------------------
_nrf_ptx_send_ack:
;	main.c: 273: return nrf_tx32_and_pulse_ce(data, len); /* TX_DS si ACK reçu, MAX_RT sinon */
;	main.c: 274: }
	jp	_nrf_tx32_and_pulse_ce
;	main.c: 277: static void demo_tx_loop(void){
;	-----------------------------------------
;	 function demo_tx_loop
;	-----------------------------------------
_demo_tx_loop:
;	main.c: 280: printf("\r\n===== nRF24 TX NO-ACK @ch=%u, 1Mbps, CRC16 =====\r\n", RF_CHAN);
	push	#0x4c
	push	#0x00
	push	#<(___str_5+0)
	push	#((___str_5+0) >> 8)
	call	_printf
	addw	sp, #4
;	main.c: 281: nrf_ptx_start_noack();
	call	_nrf_ptx_start_noack
;	main.c: 282: nrf_dump_core_regs();
	call	_nrf_dump_core_regs
;	main.c: 283: nrf_dump_tx_regs();
	call	_nrf_dump_tx_regs
;	main.c: 284: nrf_dump_status();
	call	_nrf_dump_status
00107$:
;	main.c: 287: uint8_t ok = nrf_ptx_send_noack(msg, sizeof(msg));
	ld	a, #0x05
	ldw	x, #(_demo_tx_loop_msg_65536_142+0)
	call	_nrf_ptx_send_noack
;	main.c: 288: printf("[NOACK] %s\r\n", ok ? "TX_DS" : "timeout");
	tnz	a
	jreq	00111$
	ldw	x, #___str_7+0
	.byte 0xbc
00111$:
	ldw	x, #(___str_8+0)
00112$:
	pushw	x
	push	#<(___str_6+0)
	push	#((___str_6+0) >> 8)
	call	_printf
	addw	sp, #4
;	main.c: 289: nrf_dump_status();
	call	_nrf_dump_status
;	main.c: 290: nrf_dump_fifo();
	call	_nrf_dump_fifo
;	main.c: 34: uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
	clrw	y
	clrw	x
00105$:
	cpw	y, #0xc660
	ld	a, xl
	sbc	a, #0x06
	ld	a, xh
	sbc	a, #0x00
	jrnc	00107$
	nop
	incw	y
	jrne	00105$
	incw	x
	jra	00105$
;	main.c: 291: delay_ms(500);
;	main.c: 293: }
	ret
;	main.c: 319: void main(void){
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	main.c: 20: CLK_CKDIVR = 0x00; // 16 MHz
	mov	0x50c6+0, #0x00
;	main.c: 22: UART1_BRR1 = (usartdiv >> 4) & 0xFF;
	ld	a, #0x68
	ld	0x5232, a
;	main.c: 23: UART1_BRR2 = ((usartdiv & 0x0F) | ((usartdiv >> 8) & 0xF0));
	ld	a, #0x83
	and	a, #0x0f
	ld	0x5233, a
;	main.c: 24: UART1_CR1 = 0x00;
	mov	0x5234+0, #0x00
;	main.c: 25: UART1_CR3 = 0x00;
	mov	0x5236+0, #0x00
;	main.c: 26: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
	mov	0x5235+0, #0x0c
;	main.c: 27: (void)UART1_SR; (void)UART1_DR;
	ld	a, 0x5230
	ld	a, 0x5231
;	main.c: 321: printf("\r\n[STM8S] nRF24L01+ TX\r\n");
	ldw	x, #(___str_10+0)
	call	_puts
;	main.c: 322: gpio_init_spi();
	call	_gpio_init_spi
;	main.c: 323: spi_init();
	call	_spi_init
;	main.c: 325: if(!nrf_bus_ok()){
	call	_nrf_bus_ok
	tnz	a
	jreq	00119$
	jp	_demo_tx_loop
00119$:
;	main.c: 326: printf("SPI KO: STATUS=0x%02X (verifie CSN/SCK/MOSI/MISO/VCC)\r\n", nrf_status_raw());
	call	_nrf_status_raw
	clrw	x
	ld	xl, a
	pushw	x
	push	#<(___str_11+0)
	push	#((___str_11+0) >> 8)
	call	_printf
	addw	sp, #4
;	main.c: 327: while(1);
00102$:
;	main.c: 330: demo_tx_loop(); /* NO-ACK par défaut (simple à valider) */
;	main.c: 331: }
	jra	00102$
	.area CODE
	.area CONST
_ADDR_NODE1:
	.db #0x4e	; 78	'N'
	.db #0x4f	; 79	'O'
	.db #0x44	; 68	'D'
	.db #0x45	; 69	'E'
	.db #0x31	; 49	'1'
	.area CONST
___str_0:
	.db 0x0d
	.db 0x0a
	.ascii "[STATUS] 0x%02X  (RX_DR=%d TX_DS=%d MAX_RT=%d RX_PIPE=%u TX_"
	.ascii "FULL=%d)"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_1:
	.ascii "[CORE]   CONFIG=0x%02X  RF_CH=0x%02X  RF_SETUP=0x%02X"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_2:
	.ascii "[ADDR]   TX_ADDR=%02X %02X %02X %02X %02X  |  RX0=%02X %02X "
	.ascii "%02X %02X %02X"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_3:
	.ascii "[TXCFG]  EN_AA=0x%02X  EN_RXADDR=0x%02X  SETUP_RETR=0x%02X  "
	.ascii "RX_PW_P0=%u"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_4:
	.ascii "[FIFO]   0x%02X  TX_EMPTY=%d TX_FULL=%d  RX_EMPTY=%d RX_FULL"
	.ascii "=%d"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
_demo_tx_loop_msg_65536_142:
	.db #0x48	; 72	'H'
	.db #0x45	; 69	'E'
	.db #0x4c	; 76	'L'
	.db #0x4c	; 76	'L'
	.db #0x4f	; 79	'O'
	.area CONST
___str_5:
	.db 0x0d
	.db 0x0a
	.ascii "===== nRF24 TX NO-ACK @ch=%u, 1Mbps, CRC16 ====="
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_6:
	.ascii "[NOACK] %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_7:
	.ascii "TX_DS"
	.db 0x00
	.area CODE
	.area CONST
___str_8:
	.ascii "timeout"
	.db 0x00
	.area CODE
	.area CONST
___str_10:
	.db 0x0d
	.db 0x0a
	.ascii "[STM8S] nRF24L01+ TX"
	.db 0x0d
	.db 0x00
	.area CODE
	.area CONST
___str_11:
	.ascii "SPI KO: STATUS=0x%02X (verifie CSN/SCK/MOSI/MISO/VCC)"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
