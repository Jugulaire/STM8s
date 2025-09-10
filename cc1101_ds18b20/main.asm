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
	.globl _cc_send_temp_x100
	.globl _ds18b20_read_raw
	.globl _ds18b20_start_conversion
	.globl _onewire_read_byte
	.globl _onewire_write_byte
	.globl _onewire_read_bit
	.globl _onewire_write_bit
	.globl _onewire_reset
	.globl _delay_us
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
;	main.c: 10: static void uart_init(void){
;	-----------------------------------------
;	 function uart_init
;	-----------------------------------------
_uart_init:
;	main.c: 11: CLK_CKDIVR = 0x00;
	mov	0x50c6+0, #0x00
;	main.c: 13: UART1_BRR1 = (div >> 4) & 0xFF;
	ld	a, #0x68
	ld	0x5232, a
;	main.c: 14: UART1_BRR2 = ((div & 0x0F) | ((div >> 8) & 0xF0));
	ld	a, #0x83
	and	a, #0x0f
	ld	0x5233, a
;	main.c: 15: UART1_CR1 = 0x00; UART1_CR3 = 0x00;
	mov	0x5234+0, #0x00
	mov	0x5236+0, #0x00
;	main.c: 16: UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
	mov	0x5235+0, #0x0c
;	main.c: 17: (void)UART1_SR; (void)UART1_DR;
	ld	a, 0x5230
	ld	a, 0x5231
;	main.c: 18: }
	ret
;	main.c: 19: int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; } // Gestion des printf 
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
;	main.c: 42: void delay_us(uint16_t us) {
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
;	main.c: 43: while(us--) {
00101$:
	ldw	y, x
	decw	x
	tnzw	y
	jrne	00117$
	ret
00117$:
;	main.c: 44: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
;	main.c: 45: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
	jra	00101$
;	main.c: 47: }
	ret
;	main.c: 50: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	main.c: 54: }
	addw	sp, #10
	ret
;	main.c: 59: uint8_t onewire_reset(void) {
;	-----------------------------------------
;	 function onewire_reset
;	-----------------------------------------
_onewire_reset:
;	main.c: 60: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
	bset	0x5011, #3
	bres	0x500f, #3
;	main.c: 61: delay_us(480);
	ldw	x, #0x01e0
	call	_delay_us
;	main.c: 62: DS_INPUT();                    // Relâche la ligne
	bres	0x5011, #3
;	main.c: 63: delay_us(70);                  // Attend la réponse du capteur
	ldw	x, #0x0046
	call	_delay_us
;	main.c: 64: uint8_t presence = !DS_READ(); // 0 = présence détectée
	ld	a, 0x5010
	swap	a
	sll	a
	clr	a
	rlc	a
	sub	a, #0x01
	clr	a
	rlc	a
;	main.c: 65: delay_us(410);                 // Fin du timing 1-Wire
	push	a
	ldw	x, #0x019a
	call	_delay_us
	pop	a
;	main.c: 66: return presence;
;	main.c: 67: }
	ret
;	main.c: 70: void onewire_write_bit(uint8_t bit) {
;	-----------------------------------------
;	 function onewire_write_bit
;	-----------------------------------------
_onewire_write_bit:
	push	a
	ld	(0x01, sp), a
;	main.c: 71: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	main.c: 72: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
	tnz	(0x01, sp)
	jreq	00103$
	ldw	x, #0x0006
	.byte 0xbc
00103$:
	ldw	x, #0x003c
00104$:
	call	_delay_us
;	main.c: 73: DS_INPUT();                    // Libère la ligne
	bres	0x5011, #3
;	main.c: 74: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
	tnz	(0x01, sp)
	jreq	00105$
	ldw	x, #0x0040
	jra	00106$
00105$:
	ldw	x, #0x000a
00106$:
	pop	a
	jp	_delay_us
;	main.c: 75: }
	pop	a
	ret
;	main.c: 78: uint8_t onewire_read_bit(void) {
;	-----------------------------------------
;	 function onewire_read_bit
;	-----------------------------------------
_onewire_read_bit:
;	main.c: 80: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	main.c: 81: delay_us(6);                   // Pulse d'initiation de lecture
	ldw	x, #0x0006
	call	_delay_us
;	main.c: 82: DS_INPUT();                    // Libère la ligne pour lire
	bres	0x5011, #3
;	main.c: 83: delay_us(9);                   // Délai standard
	ldw	x, #0x0009
	call	_delay_us
;	main.c: 84: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
	btjf	0x5010, #3, 00103$
	clrw	x
	incw	x
	.byte 0x21
00103$:
	clrw	x
00104$:
	ld	a, xl
;	main.c: 85: delay_us(55);                  // Fin du slot
	push	a
	ldw	x, #0x0037
	call	_delay_us
	pop	a
;	main.c: 86: return bit;
;	main.c: 87: }
	ret
;	main.c: 90: void onewire_write_byte(uint8_t byte) {
;	-----------------------------------------
;	 function onewire_write_byte
;	-----------------------------------------
_onewire_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	main.c: 91: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00103$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00105$
;	main.c: 92: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
	ld	a, (0x01, sp)
	and	a, #0x01
	call	_onewire_write_bit
;	main.c: 93: byte >>= 1;
	srl	(0x01, sp)
;	main.c: 91: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00103$
00105$:
;	main.c: 95: }
	addw	sp, #2
	ret
;	main.c: 98: uint8_t onewire_read_byte(void) {
;	-----------------------------------------
;	 function onewire_read_byte
;	-----------------------------------------
_onewire_read_byte:
	sub	sp, #2
;	main.c: 99: uint8_t byte = 0;
	clr	(0x01, sp)
;	main.c: 100: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00105$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00103$
;	main.c: 101: byte >>= 1;
	srl	(0x01, sp)
;	main.c: 102: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
	call	_onewire_read_bit
	tnz	a
	jreq	00106$
	sll	(0x01, sp)
	scf
	rrc	(0x01, sp)
00106$:
;	main.c: 100: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00105$
00103$:
;	main.c: 104: return byte;
	ld	a, (0x01, sp)
;	main.c: 105: }
	addw	sp, #2
	ret
;	main.c: 108: void ds18b20_start_conversion(void) {
;	-----------------------------------------
;	 function ds18b20_start_conversion
;	-----------------------------------------
_ds18b20_start_conversion:
;	main.c: 109: onewire_reset();
	call	_onewire_reset
;	main.c: 110: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
	ld	a, #0xcc
	call	_onewire_write_byte
;	main.c: 111: onewire_write_byte(0x44); // Convert T (lance mesure)
	ld	a, #0x44
;	main.c: 112: }
	jp	_onewire_write_byte
;	main.c: 115: int16_t ds18b20_read_raw(void) {
;	-----------------------------------------
;	 function ds18b20_read_raw
;	-----------------------------------------
_ds18b20_read_raw:
	sub	sp, #4
;	main.c: 116: onewire_reset();
	call	_onewire_reset
;	main.c: 117: onewire_write_byte(0xCC); // Skip ROM
	ld	a, #0xcc
	call	_onewire_write_byte
;	main.c: 118: onewire_write_byte(0xBE); // Read Scratchpad
	ld	a, #0xbe
	call	_onewire_write_byte
;	main.c: 120: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
	call	_onewire_read_byte
;	main.c: 121: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
	push	a
	call	_onewire_read_byte
	ld	xh, a
	pop	a
;	main.c: 123: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
	clr	(0x02, sp)
	clr	(0x03, sp)
	or	a, (0x02, sp)
	rlwa	x
	or	a, (0x03, sp)
	ld	xh, a
;	main.c: 124: }
	addw	sp, #4
	ret
;	main.c: 140: static void gpio_init(void){
;	-----------------------------------------
;	 function gpio_init
;	-----------------------------------------
_gpio_init:
;	main.c: 142: PC_DDR |= (1<<5) | (1<<MOSI_BIT);
	ld	a, 0x500c
	or	a, #0x60
	ld	0x500c, a
;	main.c: 143: PC_CR1 |= (1<<5) | (1<<MOSI_BIT);
	ld	a, 0x500d
	or	a, #0x60
	ld	0x500d, a
;	main.c: 145: PC_DDR &= (uint8_t)~(1<<MISO_BIT);
	bres	0x500c, #7
;	main.c: 146: PC_CR1 &= (uint8_t)~(1<<MISO_BIT);
	bres	0x500d, #7
;	main.c: 148: PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
	bset	0x5011, #2
	bset	0x5012, #2
	bset	0x500f, #2
;	main.c: 150: PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
	bres	0x5011, #4
	bres	0x5012, #4
;	main.c: 152: PD_DDR &= (uint8_t)~(1<<3);
	bres	0x5011, #3
;	main.c: 153: PD_CR1 |= (1<<3);
	bset	0x5012, #3
;	main.c: 154: }
	ret
;	main.c: 157: static void spi_init(void){
;	-----------------------------------------
;	 function spi_init
;	-----------------------------------------
_spi_init:
;	main.c: 159: SPI_CR1 = (1<<SPI_CR1_MSTR) | (1<<SPI_CR1_BR2) | (1<<SPI_CR1_BR1) | (1<<SPI_CR1_BR0);
	mov	0x5200+0, #0x3c
;	main.c: 160: SPI_CR2 = (1<<SPI_CR2_SSM) | (1<<SPI_CR2_SSI);
	mov	0x5201+0, #0x03
;	main.c: 161: SPI_CR1 |= (1<<SPI_CR1_SPE);
	bset	0x5200, #6
;	main.c: 162: }
	ret
;	main.c: 163: static uint8_t spi_txrx(uint8_t v){
;	-----------------------------------------
;	 function spi_txrx
;	-----------------------------------------
_spi_txrx:
;	main.c: 164: SPI_DR = v;
	ld	0x5204, a
;	main.c: 165: while(!(SPI_SR & (1<<SPI_SR_TXE)));
00101$:
	btjf	0x5203, #1, 00101$
;	main.c: 166: while(!(SPI_SR & (1<<SPI_SR_RXNE)));
00104$:
	btjf	0x5203, #0, 00104$
;	main.c: 167: return SPI_DR;
	ld	a, 0x5204
;	main.c: 168: }
	ret
;	main.c: 169: static void spi_wait_idle(void){ while(SPI_SR & (1<<SPI_SR_BSY)); }
;	-----------------------------------------
;	 function spi_wait_idle
;	-----------------------------------------
_spi_wait_idle:
00101$:
	ld	a, 0x5203
	jrmi	00101$
	ret
;	main.c: 189: static uint8_t cc_select(void){
;	-----------------------------------------
;	 function cc_select
;	-----------------------------------------
_cc_select:
	sub	sp, #4
;	main.c: 190: CSN_LOW();
	bres	0x500f, #2
;	main.c: 193: while(MISO_IS_HIGH()){
	clrw	x
	ldw	(0x03, sp), x
	ldw	(0x01, sp), x
00103$:
	ld	a, 0x500b
	jrpl	00105$
;	main.c: 194: if(++guard>100000UL){ CSN_HIGH(); return 0; }
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
;	main.c: 196: return 1;
	.byte 0xc5
00105$:
	ld	a, #0x01
00106$:
;	main.c: 197: }
	addw	sp, #4
	ret
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
;	-----------------------------------------
;	 function cc_deselect
;	-----------------------------------------
_cc_deselect:
	call	_spi_wait_idle
	bset	0x500f, #2
	ret
;	main.c: 200: static uint8_t cc_strobe(uint8_t st){
;	-----------------------------------------
;	 function cc_strobe
;	-----------------------------------------
_cc_strobe:
	sub	sp, #2
	ld	(0x02, sp), a
;	main.c: 201: if(!cc_select()) return 0xFF;
	call	_cc_select
	tnz	a
	jrne	00102$
	ld	a, #0xff
	jra	00104$
00102$:
;	main.c: 202: uint8_t s = spi_txrx(st);
	ld	a, (0x02, sp)
	call	_spi_txrx
	ld	(0x01, sp), a
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 204: return s;
	ld	a, (0x01, sp)
00104$:
;	main.c: 205: }
	addw	sp, #2
	ret
;	main.c: 206: static void cc_write_reg(uint8_t a, uint8_t v){
;	-----------------------------------------
;	 function cc_write_reg
;	-----------------------------------------
_cc_write_reg:
	push	a
	ld	(0x01, sp), a
;	main.c: 207: if(!cc_select()) return;
	call	_cc_select
	tnz	a
	jreq	00104$
;	main.c: 208: spi_txrx(a); spi_txrx(v);
	ld	a, (0x01, sp)
	call	_spi_txrx
	ld	a, (0x04, sp)
	call	_spi_txrx
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	ld	a, 0x500f
	or	a, #0x04
	ld	0x500f, a
;	main.c: 209: cc_deselect();
00104$:
;	main.c: 210: }
	pop	a
	popw	x
	pop	a
	jp	(x)
;	main.c: 211: static uint8_t cc_read_status(uint8_t addr){
;	-----------------------------------------
;	 function cc_read_status
;	-----------------------------------------
_cc_read_status:
	sub	sp, #2
	ld	(0x02, sp), a
;	main.c: 212: if(!cc_select()) return 0xFF;
	call	_cc_select
	tnz	a
	jrne	00102$
	ld	a, #0xff
	jra	00104$
00102$:
;	main.c: 213: (void)spi_txrx(addr | 0xC0);   // READ | BURST pour status regs
	ld	a, (0x02, sp)
	or	a, #0xc0
	call	_spi_txrx
;	main.c: 214: uint8_t v = spi_txrx(0xFF);
	ld	a, #0xff
	call	_spi_txrx
	ld	(0x01, sp), a
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 216: return v;
	ld	a, (0x01, sp)
00104$:
;	main.c: 217: }
	addw	sp, #2
	ret
;	main.c: 220: static void cc_reset(void){
;	-----------------------------------------
;	 function cc_reset
;	-----------------------------------------
_cc_reset:
;	main.c: 221: CSN_HIGH(); delay_ms(5);
	bset	0x500f, #2
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00113$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00104$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00113$
	incw	x
	jra	00113$
;	main.c: 221: CSN_HIGH(); delay_ms(5);
00104$:
;	main.c: 222: CSN_LOW();  delay_ms(5);
	bres	0x500f, #2
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00116$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00106$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00116$
	incw	x
	jra	00116$
;	main.c: 222: CSN_LOW();  delay_ms(5);
00106$:
;	main.c: 223: CSN_HIGH(); delay_ms(5);
	bset	0x500f, #2
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00119$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00108$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00119$
	incw	x
	jra	00119$
;	main.c: 223: CSN_HIGH(); delay_ms(5);
00108$:
;	main.c: 224: if(cc_select()){ spi_txrx(SRES); cc_deselect(); }
	call	_cc_select
	tnz	a
	jreq	00134$
	ld	a, #0x30
	call	_spi_txrx
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
00134$:
	clrw	y
	clrw	x
00122$:
	cpw	y, #0x1158
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrc	00182$
	ret
00182$:
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00122$
	incw	x
	jra	00122$
;	main.c: 225: delay_ms(5);
;	main.c: 226: }
	ret
;	main.c: 228: static void cc_write_patble(uint8_t pa){
;	-----------------------------------------
;	 function cc_write_patble
;	-----------------------------------------
_cc_write_patble:
	push	a
	ld	(0x01, sp), a
;	main.c: 229: if(!cc_select()) return;
	call	_cc_select
	tnz	a
	jreq	00108$
;	main.c: 230: spi_txrx(PATABLE | CC_BURST);
	ld	a, #0x7e
	call	_spi_txrx
;	main.c: 231: for(uint8_t i=0;i<8;i++) spi_txrx(pa);
	clr	a
00106$:
	cp	a, #0x08
	jrnc	00103$
	push	a
	ld	a, (0x02, sp)
	call	_spi_txrx
	pop	a
	inc	a
	jra	00106$
00103$:
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 232: cc_deselect();
00108$:
;	main.c: 233: }
	pop	a
	ret
;	main.c: 235: static void cc_config_868(void){
;	-----------------------------------------
;	 function cc_config_868
;	-----------------------------------------
_cc_config_868:
;	main.c: 237: cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
	push	#0x29
	clr	a
	call	_cc_write_reg
	push	#0x06
	ld	a, #0x02
	call	_cc_write_reg
	push	#0x47
	ld	a, #0x03
	call	_cc_write_reg
;	main.c: 238: cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
	push	#0x3d
	ld	a, #0x06
	call	_cc_write_reg
	push	#0x04
	ld	a, #0x07
	call	_cc_write_reg
	push	#0x05
	ld	a, #0x08
	call	_cc_write_reg
;	main.c: 239: cc_write_reg(0x0B,0x06);
	push	#0x06
	ld	a, #0x0b
	call	_cc_write_reg
;	main.c: 240: cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
	push	#0x21
	ld	a, #0x0d
	call	_cc_write_reg
	push	#0x65
	ld	a, #0x0e
	call	_cc_write_reg
	push	#0x6a
	ld	a, #0x0f
	call	_cc_write_reg
;	main.c: 241: cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
	push	#0xf5
	ld	a, #0x10
	call	_cc_write_reg
	push	#0x83
	ld	a, #0x11
	call	_cc_write_reg
	push	#0x13
	ld	a, #0x12
	call	_cc_write_reg
;	main.c: 242: cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
	push	#0x22
	ld	a, #0x13
	call	_cc_write_reg
	push	#0xf8
	ld	a, #0x14
	call	_cc_write_reg
;	main.c: 243: cc_write_reg(0x15,0x15);
	push	#0x15
	ld	a, #0x15
	call	_cc_write_reg
;	main.c: 244: cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
	push	#0x18
	ld	a, #0x18
	call	_cc_write_reg
	push	#0x16
	ld	a, #0x19
	call	_cc_write_reg
;	main.c: 245: cc_write_reg(0x1B,0x43);
	push	#0x43
	ld	a, #0x1b
	call	_cc_write_reg
;	main.c: 246: cc_write_reg(0x22,0x11);
	push	#0x11
	ld	a, #0x22
	call	_cc_write_reg
;	main.c: 247: cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
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
;	main.c: 248: cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
	push	#0x81
	ld	a, #0x2c
	call	_cc_write_reg
	push	#0x35
	ld	a, #0x2d
	call	_cc_write_reg
	push	#0x09
	ld	a, #0x2e
	call	_cc_write_reg
;	main.c: 249: cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
	ld	a, #0x36
	call	_cc_strobe
	ld	a, #0x3a
	call	_cc_strobe
	ld	a, #0x3b
	call	_cc_strobe
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00104$:
	cpw	y, #0x06f0
	ld	a, xl
	sbc	a, #0x00
	ld	a, xh
	sbc	a, #0x00
	jrnc	00102$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00104$
	incw	x
	jra	00104$
;	main.c: 250: delay_ms(2);
00102$:
;	main.c: 252: cc_write_patble(0xC0);      // mets 0x84 pour tester “0 dBm”, 0xC8 si tu veux un cran de plus
	ld	a, #0xc0
;	main.c: 253: }
	jp	_cc_write_patble
;	main.c: 256: static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
;	-----------------------------------------
;	 function cc_send_packet
;	-----------------------------------------
_cc_send_packet:
	sub	sp, #7
	ldw	(0x02, sp), x
;	main.c: 257: if(len==0 || len>61) return 0;
	ld	(0x01, sp), a
	jreq	00101$
	ld	a, (0x01, sp)
	cp	a, #0x3d
	jrule	00102$
00101$:
	clr	a
	jra	00116$
00102$:
;	main.c: 258: cc_strobe(SIDLE); 
	ld	a, #0x36
	call	_cc_strobe
;	main.c: 259: cc_strobe(SFTX);
	ld	a, #0x3b
	call	_cc_strobe
;	main.c: 261: if(!cc_select()) return 0;
	call	_cc_select
	tnz	a
	jrne	00105$
	clr	a
	jra	00116$
00105$:
;	main.c: 262: spi_txrx(TXFIFO | CC_BURST);
	ld	a, #0x7f
	call	_spi_txrx
;	main.c: 263: spi_txrx(len);
	ld	a, (0x01, sp)
	call	_spi_txrx
;	main.c: 264: for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
	clr	(0x07, sp)
00111$:
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
	jra	00111$
00106$:
;	main.c: 198: static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }
	call	_spi_wait_idle
	bset	0x500f, #2
;	main.c: 267: cc_strobe(STX);
	ld	a, #0x35
	call	_cc_strobe
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
	ldw	(0x04, sp), x
00114$:
	cpw	y, #0x1158
	ld	a, (0x05, sp)
	sbc	a, #0x00
	ld	a, (0x04, sp)
	sbc	a, #0x00
	jrnc	00109$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00114$
	ldw	x, (0x04, sp)
	incw	x
	ldw	(0x04, sp), x
	jra	00114$
;	main.c: 270: delay_ms(5);
00109$:
;	main.c: 271: return 1;
	ld	a, #0x01
00116$:
;	main.c: 272: }
	addw	sp, #7
	ret
;	main.c: 275: void cc_send_temp_x100(int16_t temp_x100) {
;	-----------------------------------------
;	 function cc_send_temp_x100
;	-----------------------------------------
_cc_send_temp_x100:
	sub	sp, #8
;	main.c: 277: int16_t temp_x10 = temp_x100 / 10;
	push	#0x0a
	push	#0x00
	call	__divsint
	ldw	(0x05, sp), x
;	main.c: 280: pkt[0] = NODE_ID;                        // Identifiant du capteur
	ld	a, #0x01
	ld	(0x01, sp), a
;	main.c: 281: pkt[1] = (uint8_t)(temp_x10 >> 8);       // MSB
	ld	a, (0x05, sp)
	ld	(0x07, sp), a
	ld	(0x02, sp), a
;	main.c: 282: pkt[2] = (uint8_t)(temp_x10 & 0xFF);     // LSB
	ld	a, (0x06, sp)
	ld	(0x08, sp), a
	ld	(0x03, sp), a
;	main.c: 283: pkt[3] = pkt[0] ^ pkt[1] ^ pkt[2];       // Checksum XOR
	ld	a, (0x01, sp)
	xor	a, (0x07, sp)
	xor	a, (0x08, sp)
	ld	(0x04, sp), a
;	main.c: 285: uint8_t ok = cc_send_packet(pkt, sizeof(pkt));
	ld	a, #0x04
	ldw	x, sp
	incw	x
	call	_cc_send_packet
;	main.c: 289: ok ? "OK" : "FAIL");
	tnz	a
	jreq	00103$
	ldw	x, #___str_1+0
	.byte 0xbc
00103$:
	ldw	x, #(___str_2+0)
00104$:
	ldw	(0x07, sp), x
;	main.c: 288: temp_x10/10, temp_x10%10,
	ldw	x, (0x05, sp)
	pushw	x
	push	#0x0a
	push	#0x00
	call	__modsint
	ldw	(0x07, sp), x
	popw	x
	push	#0x0a
	push	#0x00
;	main.c: 287: printf("[RADIO] send %d.%01d°C -> %s\r\n",
	call	__divsint
	ldw	y, (0x07, sp)
	pushw	y
	ldw	y, (0x07, sp)
	pushw	y
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
;	main.c: 290: }
	addw	sp, #16
	ret
;	main.c: 292: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	sub	sp, #6
;	main.c: 294: CLK_CKDIVR = 0x00; // forcer la frequence CPU
	mov	0x50c6+0, #0x00
;	main.c: 297: PD_DDR &= ~(1 << 3);    // PD3 en entrée
	bres	0x5011, #3
;	main.c: 298: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
	bset	0x5012, #3
;	main.c: 300: uart_init();
	call	_uart_init
;	main.c: 301: gpio_init();
	call	_gpio_init
;	main.c: 302: spi_init();
	call	_spi_init
;	main.c: 303: cc_reset();
	call	_cc_reset
;	main.c: 304: cc_config_868();
	call	_cc_config_868
;	main.c: 309: while (1) {
	clrw	x
	ldw	(0x01, sp), x
00104$:
;	main.c: 310: ds18b20_start_conversion(); // Démarre une conversion de température
	call	_ds18b20_start_conversion
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
	ldw	(0x03, sp), x
00111$:
	cpw	y, #0x2990
	ld	a, (0x04, sp)
	sbc	a, #0x0a
	ld	a, (0x03, sp)
	sbc	a, #0x00
	jrnc	00107$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00111$
	ldw	x, (0x03, sp)
	incw	x
	ldw	(0x03, sp), x
	jra	00111$
;	main.c: 311: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
00107$:
;	main.c: 313: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
	call	_ds18b20_read_raw
;	main.c: 316: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
	clrw	y
	tnzw	x
	jrpl	00151$
	decw	y
00151$:
	pushw	x
	pushw	y
	push	#0x71
	push	#0x02
	clrw	x
	pushw	x
	call	__mullong
	addw	sp, #8
	push	#0x64
	push	#0x00
	push	#0x00
	push	#0x00
	pushw	x
	pushw	y
	call	__divulong
	addw	sp, #8
	ldw	(0x05, sp), x
;	main.c: 320: if (counter % 120 == 0) {
	ldw	x, (0x01, sp)
	ldw	y, #0x0078
	divw	x, y
	tnzw	y
	jrne	00102$
;	main.c: 321: cc_send_temp_x100(temp_x100);
	ldw	x, (0x05, sp)
	call	_cc_send_temp_x100
00102$:
;	main.c: 324: counter++;
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00114$:
	cpw	y, #0x8cc0
	ld	a, xl
	sbc	a, #0x0d
	ld	a, xh
	sbc	a, #0x00
	jrnc	00104$
;	main.c: 53: __asm__("nop");
	nop
;	main.c: 52: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00114$
	incw	x
	jra	00114$
;	main.c: 328: delay_ms(NODE_ID * 1000UL);
;	main.c: 330: }
	addw	sp, #6
	ret
	.area CODE
	.area CONST
	.area CONST
___str_0:
	.ascii "[RADIO] send %d.%01d"
	.db 0xc2
	.db 0xb0
	.ascii "C -> %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area CONST
___str_1:
	.ascii "OK"
	.db 0x00
	.area CODE
	.area CONST
___str_2:
	.ascii "FAIL"
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
