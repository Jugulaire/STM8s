;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module 1_wire
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _ds18b20_read_raw
	.globl _ds18b20_start_conversion
	.globl _onewire_read_byte
	.globl _onewire_write_byte
	.globl _onewire_read_bit
	.globl _onewire_write_bit
	.globl _onewire_reset
	.globl _delay_us
	.globl _uart_read
	.globl _uart_write
	.globl _uart_config
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
;	1_wire.c: 17: void uart_config() {
;	-----------------------------------------
;	 function uart_config
;	-----------------------------------------
_uart_config:
;	1_wire.c: 18: CLK_CKDIVR = 0x00; // Horloge non divisée (reste à 16 MHz)
	mov	0x50c6+0, #0x00
;	1_wire.c: 23: uint8_t brr1 = (usartdiv >> 4) & 0xFF;
	ld	a, #0x68
	ld	xl, a
;	1_wire.c: 24: uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);
	ld	a, #0x83
	and	a, #0x0f
;	1_wire.c: 26: UART1_BRR1 = brr1;
	ldw	y, #0x5232
	push	a
	ld	a, xl
	ld	(y), a
	pop	a
;	1_wire.c: 27: UART1_BRR2 = brr2;
	ld	0x5233, a
;	1_wire.c: 29: UART1_CR1 = 0x00; // Pas de parité, 8 bits de données
	mov	0x5234+0, #0x00
;	1_wire.c: 30: UART1_CR3 = 0x00; // 1 bit de stop
	mov	0x5236+0, #0x00
;	1_wire.c: 31: UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // Active TX et RX
	mov	0x5235+0, #0x0c
;	1_wire.c: 34: (void)UART1_SR;
	ld	a, 0x5230
;	1_wire.c: 35: (void)UART1_DR;
	ld	a, 0x5231
;	1_wire.c: 36: }
	ret
;	1_wire.c: 39: void uart_write(uint8_t data) {
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
;	1_wire.c: 40: UART1_DR = data;                    // Envoie l'octet
	ld	0x5231, a
;	1_wire.c: 41: PB_ODR &= ~(1 << 5);                // Éteint une LED (facultatif pour debug)
	bres	0x5005, #5
;	1_wire.c: 42: while (!(UART1_SR & (1 << UART1_SR_TC))); // Attente que la transmission soit terminée
00101$:
	btjf	0x5230, #6, 00101$
;	1_wire.c: 43: PB_ODR |= (1 << 5);                 // Allume la LED (facultatif)
	bset	0x5005, #5
;	1_wire.c: 44: }
	ret
;	1_wire.c: 47: uint8_t uart_read() {
;	-----------------------------------------
;	 function uart_read
;	-----------------------------------------
_uart_read:
;	1_wire.c: 48: while (!(UART1_SR & (1 << UART1_SR_RXNE))); // Attente réception
00101$:
	btjf	0x5230, #5, 00101$
;	1_wire.c: 49: return UART1_DR;
	ld	a, 0x5231
;	1_wire.c: 50: }
	ret
;	1_wire.c: 53: int putchar(int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	ld	a, xl
;	1_wire.c: 54: uart_write(c);
	call	_uart_write
;	1_wire.c: 55: return 0;
	clrw	x
;	1_wire.c: 56: }
	ret
;	1_wire.c: 60: void delay_us(uint16_t us) {
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
;	1_wire.c: 61: while(us--) {
00101$:
	ldw	y, x
	decw	x
	tnzw	y
	jrne	00117$
	ret
00117$:
;	1_wire.c: 62: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
;	1_wire.c: 63: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
	jra	00101$
;	1_wire.c: 65: }
	ret
;	1_wire.c: 68: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	1_wire.c: 71: __asm__("nop");
	nop
;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	1_wire.c: 72: }
	addw	sp, #10
	ret
;	1_wire.c: 77: uint8_t onewire_reset(void) {
;	-----------------------------------------
;	 function onewire_reset
;	-----------------------------------------
_onewire_reset:
;	1_wire.c: 78: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
	bset	0x5011, #3
	bres	0x500f, #3
;	1_wire.c: 79: delay_us(480);
	ldw	x, #0x01e0
	call	_delay_us
;	1_wire.c: 80: DS_INPUT();                    // Relâche la ligne
	bres	0x5011, #3
;	1_wire.c: 81: delay_us(70);                  // Attend la réponse du capteur
	ldw	x, #0x0046
	call	_delay_us
;	1_wire.c: 82: uint8_t presence = !DS_READ(); // 0 = présence détectée
	ld	a, 0x5010
	swap	a
	sll	a
	clr	a
	rlc	a
	sub	a, #0x01
	clr	a
	rlc	a
;	1_wire.c: 83: delay_us(410);                 // Fin du timing 1-Wire
	push	a
	ldw	x, #0x019a
	call	_delay_us
	pop	a
;	1_wire.c: 84: return presence;
;	1_wire.c: 85: }
	ret
;	1_wire.c: 88: void onewire_write_bit(uint8_t bit) {
;	-----------------------------------------
;	 function onewire_write_bit
;	-----------------------------------------
_onewire_write_bit:
	push	a
	ld	(0x01, sp), a
;	1_wire.c: 89: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	1_wire.c: 90: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
	tnz	(0x01, sp)
	jreq	00103$
	ldw	x, #0x0006
	.byte 0xbc
00103$:
	ldw	x, #0x003c
00104$:
	call	_delay_us
;	1_wire.c: 91: DS_INPUT();                    // Libère la ligne
	bres	0x5011, #3
;	1_wire.c: 92: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
	tnz	(0x01, sp)
	jreq	00105$
	ldw	x, #0x0040
	jra	00106$
00105$:
	ldw	x, #0x000a
00106$:
	pop	a
	jp	_delay_us
;	1_wire.c: 93: }
	pop	a
	ret
;	1_wire.c: 96: uint8_t onewire_read_bit(void) {
;	-----------------------------------------
;	 function onewire_read_bit
;	-----------------------------------------
_onewire_read_bit:
;	1_wire.c: 98: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	1_wire.c: 99: delay_us(6);                   // Pulse d'initiation de lecture
	ldw	x, #0x0006
	call	_delay_us
;	1_wire.c: 100: DS_INPUT();                    // Libère la ligne pour lire
	bres	0x5011, #3
;	1_wire.c: 101: delay_us(9);                   // Délai standard
	ldw	x, #0x0009
	call	_delay_us
;	1_wire.c: 102: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
	btjf	0x5010, #3, 00103$
	clrw	x
	incw	x
	.byte 0x21
00103$:
	clrw	x
00104$:
	ld	a, xl
;	1_wire.c: 103: delay_us(55);                  // Fin du slot
	push	a
	ldw	x, #0x0037
	call	_delay_us
	pop	a
;	1_wire.c: 104: return bit;
;	1_wire.c: 105: }
	ret
;	1_wire.c: 108: void onewire_write_byte(uint8_t byte) {
;	-----------------------------------------
;	 function onewire_write_byte
;	-----------------------------------------
_onewire_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	1_wire.c: 109: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00103$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00105$
;	1_wire.c: 110: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
	ld	a, (0x01, sp)
	and	a, #0x01
	call	_onewire_write_bit
;	1_wire.c: 111: byte >>= 1;
	srl	(0x01, sp)
;	1_wire.c: 109: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00103$
00105$:
;	1_wire.c: 113: }
	addw	sp, #2
	ret
;	1_wire.c: 116: uint8_t onewire_read_byte(void) {
;	-----------------------------------------
;	 function onewire_read_byte
;	-----------------------------------------
_onewire_read_byte:
	sub	sp, #2
;	1_wire.c: 117: uint8_t byte = 0;
	clr	(0x01, sp)
;	1_wire.c: 118: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00105$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00103$
;	1_wire.c: 119: byte >>= 1;
	srl	(0x01, sp)
;	1_wire.c: 120: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
	call	_onewire_read_bit
	tnz	a
	jreq	00106$
	sll	(0x01, sp)
	scf
	rrc	(0x01, sp)
00106$:
;	1_wire.c: 118: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00105$
00103$:
;	1_wire.c: 122: return byte;
	ld	a, (0x01, sp)
;	1_wire.c: 123: }
	addw	sp, #2
	ret
;	1_wire.c: 126: void ds18b20_start_conversion(void) {
;	-----------------------------------------
;	 function ds18b20_start_conversion
;	-----------------------------------------
_ds18b20_start_conversion:
;	1_wire.c: 127: onewire_reset();
	call	_onewire_reset
;	1_wire.c: 128: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
	ld	a, #0xcc
	call	_onewire_write_byte
;	1_wire.c: 129: onewire_write_byte(0x44); // Convert T (lance mesure)
	ld	a, #0x44
;	1_wire.c: 130: }
	jp	_onewire_write_byte
;	1_wire.c: 133: int16_t ds18b20_read_raw(void) {
;	-----------------------------------------
;	 function ds18b20_read_raw
;	-----------------------------------------
_ds18b20_read_raw:
	sub	sp, #4
;	1_wire.c: 134: onewire_reset();
	call	_onewire_reset
;	1_wire.c: 135: onewire_write_byte(0xCC); // Skip ROM
	ld	a, #0xcc
	call	_onewire_write_byte
;	1_wire.c: 136: onewire_write_byte(0xBE); // Read Scratchpad
	ld	a, #0xbe
	call	_onewire_write_byte
;	1_wire.c: 138: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
	call	_onewire_read_byte
;	1_wire.c: 139: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
	push	a
	call	_onewire_read_byte
	ld	xh, a
	pop	a
;	1_wire.c: 141: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
	clr	(0x02, sp)
	clr	(0x03, sp)
	or	a, (0x02, sp)
	rlwa	x
	or	a, (0x03, sp)
	ld	xh, a
;	1_wire.c: 142: }
	addw	sp, #4
	ret
;	1_wire.c: 145: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	sub	sp, #2
;	1_wire.c: 147: uart_config();   // Initialise l'UART (9600 bauds sur UART1)
	call	_uart_config
;	1_wire.c: 150: PD_DDR &= ~(1 << 3);    // PD3 en entrée
	bres	0x5011, #3
;	1_wire.c: 151: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
	bset	0x5012, #3
;	1_wire.c: 153: while (1) {
00102$:
;	1_wire.c: 154: ds18b20_start_conversion(); // Démarre une conversion de température
	call	_ds18b20_start_conversion
;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00109$:
	cpw	y, #0x2990
	ld	a, xl
	sbc	a, #0x0a
	ld	a, xh
	sbc	a, #0x00
	jrnc	00105$
;	1_wire.c: 71: __asm__("nop");
	nop
;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00109$
	incw	x
	jra	00109$
;	1_wire.c: 155: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
00105$:
;	1_wire.c: 157: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
	call	_ds18b20_read_raw
;	1_wire.c: 160: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
	clrw	y
	tnzw	x
	jrpl	00144$
	decw	y
00144$:
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
;	1_wire.c: 163: printf("Température : %d.%02d °C\r\n", temp_x100 / 100, temp_x100 % 100);
	pushw	x
	push	#0x64
	push	#0x00
	call	__modsint
	ldw	(0x03, sp), x
	popw	x
	push	#0x64
	push	#0x00
	call	__divsint
	ldw	y, (0x01, sp)
	pushw	y
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	call	_printf
	addw	sp, #6
;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00112$:
	cpw	y, #0x8cc0
	ld	a, xl
	sbc	a, #0x0d
	ld	a, xh
	sbc	a, #0x00
	jrnc	00102$
;	1_wire.c: 71: __asm__("nop");
	nop
;	1_wire.c: 70: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00112$
	incw	x
	jra	00112$
;	1_wire.c: 165: delay_ms(1000); // Pause entre chaque mesure
;	1_wire.c: 167: }
	addw	sp, #2
	ret
	.area CODE
	.area CONST
	.area CONST
___str_0:
	.ascii "Temp"
	.db 0xc3
	.db 0xa9
	.ascii "rature : %d.%02d "
	.db 0xc2
	.db 0xb0
	.ascii "C"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area CODE
	.area INITIALIZER
	.area CABS (ABS)
