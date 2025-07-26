;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _digit_to_segment
	.globl _main
	.globl _tm_display_temp_x100
	.globl _tm_set_segments
	.globl _tm_write_byte
	.globl _tm_stop
	.globl _tm_start
	.globl _tm_delay
	.globl _ds18b20_read_raw
	.globl _ds18b20_start_conversion
	.globl _onewire_read_byte
	.globl _onewire_write_byte
	.globl _onewire_read_bit
	.globl _onewire_write_bit
	.globl _onewire_reset
	.globl _delay_us
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
;	main.c: 31: void delay_us(uint16_t us) {
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
;	main.c: 32: while(us--) {
00101$:
	ldw	y, x
	decw	x
	tnzw	y
	jrne	00117$
	ret
00117$:
;	main.c: 33: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
;	main.c: 34: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
	jra	00101$
;	main.c: 36: }
	ret
;	main.c: 39: static inline void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	main.c: 42: __asm__("nop");
	nop
;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	main.c: 43: }
	addw	sp, #10
	ret
;	main.c: 48: uint8_t onewire_reset(void) {
;	-----------------------------------------
;	 function onewire_reset
;	-----------------------------------------
_onewire_reset:
;	main.c: 49: DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
	bset	0x5011, #3
	bres	0x500f, #3
;	main.c: 50: delay_us(480);
	ldw	x, #0x01e0
	call	_delay_us
;	main.c: 51: DS_INPUT();                    // Relâche la ligne
	bres	0x5011, #3
;	main.c: 52: delay_us(70);                  // Attend la réponse du capteur
	ldw	x, #0x0046
	call	_delay_us
;	main.c: 53: uint8_t presence = !DS_READ(); // 0 = présence détectée
	ld	a, 0x5010
	swap	a
	sll	a
	clr	a
	rlc	a
	sub	a, #0x01
	clr	a
	rlc	a
;	main.c: 54: delay_us(410);                 // Fin du timing 1-Wire
	push	a
	ldw	x, #0x019a
	call	_delay_us
	pop	a
;	main.c: 55: return presence;
;	main.c: 56: }
	ret
;	main.c: 59: void onewire_write_bit(uint8_t bit) {
;	-----------------------------------------
;	 function onewire_write_bit
;	-----------------------------------------
_onewire_write_bit:
	push	a
	ld	(0x01, sp), a
;	main.c: 60: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	main.c: 61: delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
	tnz	(0x01, sp)
	jreq	00103$
	ldw	x, #0x0006
	.byte 0xbc
00103$:
	ldw	x, #0x003c
00104$:
	call	_delay_us
;	main.c: 62: DS_INPUT();                    // Libère la ligne
	bres	0x5011, #3
;	main.c: 63: delay_us(bit ? 64 : 10);       // Attente avant prochain bit
	tnz	(0x01, sp)
	jreq	00105$
	ldw	x, #0x0040
	jra	00106$
00105$:
	ldw	x, #0x000a
00106$:
	pop	a
	jp	_delay_us
;	main.c: 64: }
	pop	a
	ret
;	main.c: 67: uint8_t onewire_read_bit(void) {
;	-----------------------------------------
;	 function onewire_read_bit
;	-----------------------------------------
_onewire_read_bit:
;	main.c: 69: DS_OUTPUT(); DS_LOW();
	bset	0x5011, #3
	bres	0x500f, #3
;	main.c: 70: delay_us(6);                   // Pulse d'initiation de lecture
	ldw	x, #0x0006
	call	_delay_us
;	main.c: 71: DS_INPUT();                    // Libère la ligne pour lire
	bres	0x5011, #3
;	main.c: 72: delay_us(9);                   // Délai standard
	ldw	x, #0x0009
	call	_delay_us
;	main.c: 73: bit = (DS_READ() ? 1 : 0);     // Lecture du bit
	btjf	0x5010, #3, 00103$
	clrw	x
	incw	x
	.byte 0x21
00103$:
	clrw	x
00104$:
	ld	a, xl
;	main.c: 74: delay_us(55);                  // Fin du slot
	push	a
	ldw	x, #0x0037
	call	_delay_us
	pop	a
;	main.c: 75: return bit;
;	main.c: 76: }
	ret
;	main.c: 79: void onewire_write_byte(uint8_t byte) {
;	-----------------------------------------
;	 function onewire_write_byte
;	-----------------------------------------
_onewire_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	main.c: 80: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00103$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00105$
;	main.c: 81: onewire_write_bit(byte & 0x01); // Envoie le bit LSB
	ld	a, (0x01, sp)
	and	a, #0x01
	call	_onewire_write_bit
;	main.c: 82: byte >>= 1;
	srl	(0x01, sp)
;	main.c: 80: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00103$
00105$:
;	main.c: 84: }
	addw	sp, #2
	ret
;	main.c: 87: uint8_t onewire_read_byte(void) {
;	-----------------------------------------
;	 function onewire_read_byte
;	-----------------------------------------
_onewire_read_byte:
	sub	sp, #2
;	main.c: 88: uint8_t byte = 0;
	clr	(0x01, sp)
;	main.c: 89: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00105$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00103$
;	main.c: 90: byte >>= 1;
	srl	(0x01, sp)
;	main.c: 91: if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
	call	_onewire_read_bit
	tnz	a
	jreq	00106$
	sll	(0x01, sp)
	scf
	rrc	(0x01, sp)
00106$:
;	main.c: 89: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00105$
00103$:
;	main.c: 93: return byte;
	ld	a, (0x01, sp)
;	main.c: 94: }
	addw	sp, #2
	ret
;	main.c: 97: void ds18b20_start_conversion(void) {
;	-----------------------------------------
;	 function ds18b20_start_conversion
;	-----------------------------------------
_ds18b20_start_conversion:
;	main.c: 98: onewire_reset();
	call	_onewire_reset
;	main.c: 99: onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
	ld	a, #0xcc
	call	_onewire_write_byte
;	main.c: 100: onewire_write_byte(0x44); // Convert T (lance mesure)
	ld	a, #0x44
;	main.c: 101: }
	jp	_onewire_write_byte
;	main.c: 104: int16_t ds18b20_read_raw(void) {
;	-----------------------------------------
;	 function ds18b20_read_raw
;	-----------------------------------------
_ds18b20_read_raw:
	sub	sp, #4
;	main.c: 105: onewire_reset();
	call	_onewire_reset
;	main.c: 106: onewire_write_byte(0xCC); // Skip ROM
	ld	a, #0xcc
	call	_onewire_write_byte
;	main.c: 107: onewire_write_byte(0xBE); // Read Scratchpad
	ld	a, #0xbe
	call	_onewire_write_byte
;	main.c: 109: uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
	call	_onewire_read_byte
;	main.c: 110: uint8_t msb = onewire_read_byte(); // MSB = partie entière signée
	push	a
	call	_onewire_read_byte
	ld	xh, a
	pop	a
;	main.c: 112: return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
	clr	(0x02, sp)
	clr	(0x03, sp)
	or	a, (0x02, sp)
	rlwa	x
	or	a, (0x03, sp)
	ld	xh, a
;	main.c: 113: }
	addw	sp, #4
	ret
;	main.c: 131: void tm_delay() {
;	-----------------------------------------
;	 function tm_delay
;	-----------------------------------------
_tm_delay:
	sub	sp, #2
;	main.c: 132: for (volatile int i = 0; i < 50; i++) __asm__("nop");
	clrw	x
	ldw	(0x01, sp), x
00103$:
	ldw	x, (0x01, sp)
	cpw	x, #0x0032
	jrsge	00105$
	nop
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
	jra	00103$
00105$:
;	main.c: 133: }
	addw	sp, #2
	ret
;	main.c: 135: void tm_start() {
;	-----------------------------------------
;	 function tm_start
;	-----------------------------------------
_tm_start:
;	main.c: 136: TM_DIO_DDR |= (1 << TM_DIO_PIN);
	bset	0x5002, #1
;	main.c: 137: TM_CLK_DDR |= (1 << TM_CLK_PIN);
	bset	0x5002, #2
;	main.c: 138: TM_DIO_PORT |= (1 << TM_DIO_PIN);
	bset	0x5000, #1
;	main.c: 139: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 140: tm_delay();
	call	_tm_delay
;	main.c: 141: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
	bres	0x5000, #1
;	main.c: 142: tm_delay();
	call	_tm_delay
;	main.c: 143: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	bres	0x5000, #2
;	main.c: 144: }
	ret
;	main.c: 146: void tm_stop() {
;	-----------------------------------------
;	 function tm_stop
;	-----------------------------------------
_tm_stop:
;	main.c: 147: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	bres	0x5000, #2
;	main.c: 148: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
	bres	0x5000, #1
;	main.c: 149: tm_delay();
	call	_tm_delay
;	main.c: 150: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 151: tm_delay();
	call	_tm_delay
;	main.c: 152: TM_DIO_PORT |= (1 << TM_DIO_PIN);
	bset	0x5000, #1
;	main.c: 153: }
	ret
;	main.c: 155: void tm_write_byte(uint8_t b) {
;	-----------------------------------------
;	 function tm_write_byte
;	-----------------------------------------
_tm_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	main.c: 156: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00106$:
;	main.c: 157: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	ld	a, 0x5000
	and	a, #0xfb
;	main.c: 156: for (uint8_t i = 0; i < 8; i++) {
	push	a
	ld	a, (0x03, sp)
	cp	a, #0x08
	pop	a
	jrnc	00104$
;	main.c: 157: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	ld	0x5000, a
	ld	a, 0x5000
;	main.c: 158: if (b & 0x01)
	push	a
	ld	a, (0x02, sp)
	srl	a
	pop	a
	jrnc	00102$
;	main.c: 159: TM_DIO_PORT |= (1 << TM_DIO_PIN);
	or	a, #0x02
	ld	0x5000, a
	jra	00103$
00102$:
;	main.c: 161: TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
	and	a, #0xfd
	ld	0x5000, a
00103$:
;	main.c: 162: tm_delay();
	call	_tm_delay
;	main.c: 163: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 164: tm_delay();
	call	_tm_delay
;	main.c: 165: b >>= 1;
	srl	(0x01, sp)
;	main.c: 156: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00106$
00104$:
;	main.c: 169: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	ld	0x5000, a
;	main.c: 170: TM_DIO_DDR &= ~(1 << TM_DIO_PIN); // entrée
	bres	0x5002, #1
;	main.c: 171: tm_delay();
	call	_tm_delay
;	main.c: 172: TM_CLK_PORT |= (1 << TM_CLK_PIN);
	bset	0x5000, #2
;	main.c: 173: tm_delay();
	call	_tm_delay
;	main.c: 174: TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
	bres	0x5000, #2
;	main.c: 175: TM_DIO_DDR |= (1 << TM_DIO_PIN); // repasse en sortie
	bset	0x5002, #1
;	main.c: 176: }
	addw	sp, #2
	ret
;	main.c: 179: void tm_set_segments(uint8_t *segments, uint8_t length) {
;	-----------------------------------------
;	 function tm_set_segments
;	-----------------------------------------
_tm_set_segments:
	sub	sp, #4
	ldw	(0x02, sp), x
	ld	(0x01, sp), a
;	main.c: 180: tm_start();
	call	_tm_start
;	main.c: 181: tm_write_byte(0x40); // Commande : auto-increment mode
	ld	a, #0x40
	call	_tm_write_byte
;	main.c: 182: tm_stop();
	call	_tm_stop
;	main.c: 184: tm_start();
	call	_tm_start
;	main.c: 185: tm_write_byte(0xC0); // Adresse de départ = 0
	ld	a, #0xc0
	call	_tm_write_byte
;	main.c: 186: for (uint8_t i = 0; i < length; i++) {
	clr	(0x04, sp)
00103$:
	ld	a, (0x04, sp)
	cp	a, (0x01, sp)
	jrnc	00101$
;	main.c: 187: tm_write_byte(segments[i]);
	clrw	x
	ld	a, (0x04, sp)
	ld	xl, a
	addw	x, (0x02, sp)
	ld	a, (x)
	call	_tm_write_byte
;	main.c: 186: for (uint8_t i = 0; i < length; i++) {
	inc	(0x04, sp)
	jra	00103$
00101$:
;	main.c: 189: tm_stop();
	call	_tm_stop
;	main.c: 191: tm_start();
	call	_tm_start
;	main.c: 192: tm_write_byte(0x88 | 0x07); // Affichage ON, luminosité max (0x00 à 0x07)
	ld	a, #0x8f
	call	_tm_write_byte
;	main.c: 193: tm_stop();
	addw	sp, #4
;	main.c: 194: }
	jp	_tm_stop
;	main.c: 197: void tm_display_temp_x100(int temp_x100) {
;	-----------------------------------------
;	 function tm_display_temp_x100
;	-----------------------------------------
_tm_display_temp_x100:
	sub	sp, #10
;	main.c: 198: int val = temp_x100;
	ldw	(0x05, sp), x
;	main.c: 199: if (val < 0) val = -val;  // Ignore le signe ici (optionnel à améliorer)
	tnzw	x
	jrpl	00111$
	negw	x
	ldw	(0x05, sp), x
;	main.c: 203: for (int i = 3; i >= 0; i--) {
00111$:
	ldw	x, #0x0003
	ldw	(0x09, sp), x
00105$:
	tnz	(0x09, sp)
	jrmi	00103$
;	main.c: 204: digits[i] = digit_to_segment[val % 10];
	ldw	x, sp
	incw	x
	addw	x, (0x09, sp)
	ldw	(0x07, sp), x
	push	#0x0a
	push	#0x00
	ldw	x, (0x07, sp)
	call	__modsint
	ld	a, (_digit_to_segment+0, x)
	ldw	x, (0x07, sp)
	ld	(x), a
;	main.c: 205: val /= 10;
	push	#0x0a
	push	#0x00
	ldw	x, (0x07, sp)
	call	__divsint
	ldw	(0x05, sp), x
;	main.c: 203: for (int i = 3; i >= 0; i--) {
	ldw	x, (0x09, sp)
	decw	x
	ldw	(0x09, sp), x
	jra	00105$
00103$:
;	main.c: 209: digits[1] |= 0x80;
	rlc	(0x02, sp)
	scf
	rrc	(0x02, sp)
;	main.c: 211: tm_set_segments(digits, 4);
	ld	a, #0x04
	ldw	x, sp
	incw	x
	call	_tm_set_segments
;	main.c: 212: }
	addw	sp, #10
	ret
;	main.c: 215: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	main.c: 217: CLK_CKDIVR = 0x00; // forcer la frequence CPU
	mov	0x50c6+0, #0x00
;	main.c: 220: PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
	ld	a, 0x5002
	or	a, #0x06
	ld	0x5002, a
;	main.c: 221: PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull
	ld	a, 0x5003
	or	a, #0x06
	ld	0x5003, a
;	main.c: 223: PD_DDR &= ~(1 << 3);    // PD3 en entrée
	bres	0x5011, #3
;	main.c: 224: PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)
	bset	0x5012, #3
;	main.c: 227: while (1) {
00102$:
;	main.c: 228: ds18b20_start_conversion(); // Démarre une conversion de température
	call	_ds18b20_start_conversion
;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00109$:
	cpw	y, #0x2990
	ld	a, xl
	sbc	a, #0x0a
	ld	a, xh
	sbc	a, #0x00
	jrnc	00105$
;	main.c: 42: __asm__("nop");
	nop
;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00109$
	incw	x
	jra	00109$
;	main.c: 229: delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)
00105$:
;	main.c: 231: int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
	call	_ds18b20_read_raw
;	main.c: 234: int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100
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
;	main.c: 237: tm_display_temp_x100(temp_x100);
	call	_tm_display_temp_x100
;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	clrw	y
	clrw	x
00112$:
	cpw	y, #0x8cc0
	ld	a, xl
	sbc	a, #0x0d
	ld	a, xh
	sbc	a, #0x00
	jrnc	00102$
;	main.c: 42: __asm__("nop");
	nop
;	main.c: 41: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	incw	y
	jrne	00112$
	incw	x
	jra	00112$
;	main.c: 239: delay_ms(1000); // Pause entre chaque mesure
;	main.c: 241: }
	ret
	.area CODE
	.area CONST
_digit_to_segment:
	.db #0x3f	; 63
	.db #0x06	; 6
	.db #0x5b	; 91
	.db #0x4f	; 79	'O'
	.db #0x66	; 102	'f'
	.db #0x6d	; 109	'm'
	.db #0x7d	; 125
	.db #0x07	; 7
	.db #0x7f	; 127
	.db #0x6f	; 111	'o'
	.area INITIALIZER
	.area CABS (ABS)
