;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module nokia
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _big_char_deg
	.globl _big_char_dot
	.globl _big_char_C
	.globl _big_digit_9
	.globl _big_digit_8
	.globl _big_digit_7
	.globl _big_digit_6
	.globl _big_digit_5
	.globl _big_digit_4
	.globl _big_digit_3
	.globl _big_digit_2
	.globl _big_digit_1
	.globl _big_digit_0
	.globl _main
	.globl _lcd_print_temperature
	.globl _lcd_draw_char_small
	.globl _lcd_draw_8x8_char
	.globl _lcd_clear
	.globl _lcd_init
	.globl _lcd_write_data
	.globl _lcd_write_cmd
	.globl _lcd_send_byte
	.globl _ds18b20_read_raw
	.globl _ds18b20_start_conversion
	.globl _onewire_read_byte
	.globl _onewire_write_byte
	.globl _onewire_read_bit
	.globl _onewire_write_bit
	.globl _onewire_reset
	.globl _delay_ms
	.globl _delay_us
	.globl _sprintf
	.globl _big_digits
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_big_digits::
	.ds 20
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
;	nokia.c: 42: void delay_us(uint16_t us) {
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
;	nokia.c: 43: while(us--) {
00101$:
	ldw	y, x
	decw	x
	tnzw	y
	jrne	00117$
	ret
00117$:
;	nokia.c: 44: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
;	nokia.c: 45: __asm__("nop"); __asm__("nop"); __asm__("nop");
	nop
	nop
	nop
	jra	00101$
;	nokia.c: 47: }
	ret
;	nokia.c: 49: void delay_ms(uint16_t ms) {
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	sub	sp, #10
	ldw	(0x05, sp), x
;	nokia.c: 51: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
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
;	nokia.c: 52: __asm__("nop");
	nop
;	nokia.c: 51: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
	ldw	x, (0x09, sp)
	incw	x
	ldw	(0x09, sp), x
	jrne	00103$
	ldw	x, (0x07, sp)
	incw	x
	ldw	(0x07, sp), x
	jra	00103$
00105$:
;	nokia.c: 53: }
	addw	sp, #10
	ret
;	nokia.c: 56: uint8_t onewire_reset(void) {
;	-----------------------------------------
;	 function onewire_reset
;	-----------------------------------------
_onewire_reset:
;	nokia.c: 57: DS_OUTPUT(); DS_LOW();
	bset	0x5007, #5
	bres	0x5005, #5
;	nokia.c: 58: delay_us(480);
	ldw	x, #0x01e0
	call	_delay_us
;	nokia.c: 59: DS_INPUT();
	bres	0x5007, #5
;	nokia.c: 60: delay_us(70);
	ldw	x, #0x0046
	call	_delay_us
;	nokia.c: 61: uint8_t presence = !DS_READ();
	ld	a, 0x5006
	swap	a
	srl	a
	and	a, #0x01
	xor	a, #0x01
;	nokia.c: 62: delay_us(410);
	push	a
	ldw	x, #0x019a
	call	_delay_us
	pop	a
;	nokia.c: 63: return presence;
;	nokia.c: 64: }
	ret
;	nokia.c: 66: void onewire_write_bit(uint8_t bit) {
;	-----------------------------------------
;	 function onewire_write_bit
;	-----------------------------------------
_onewire_write_bit:
	push	a
	ld	(0x01, sp), a
;	nokia.c: 67: DS_OUTPUT(); DS_LOW();
	bset	0x5007, #5
	bres	0x5005, #5
;	nokia.c: 68: delay_us(bit ? 6 : 60);
	tnz	(0x01, sp)
	jreq	00103$
	ldw	x, #0x0006
	.byte 0xbc
00103$:
	ldw	x, #0x003c
00104$:
	call	_delay_us
;	nokia.c: 69: DS_INPUT();
	bres	0x5007, #5
;	nokia.c: 70: delay_us(bit ? 64 : 10);
	tnz	(0x01, sp)
	jreq	00105$
	ldw	x, #0x0040
	jra	00106$
00105$:
	ldw	x, #0x000a
00106$:
	pop	a
	jp	_delay_us
;	nokia.c: 71: }
	pop	a
	ret
;	nokia.c: 73: uint8_t onewire_read_bit(void) {
;	-----------------------------------------
;	 function onewire_read_bit
;	-----------------------------------------
_onewire_read_bit:
;	nokia.c: 75: DS_OUTPUT(); DS_LOW();
	bset	0x5007, #5
	bres	0x5005, #5
;	nokia.c: 76: delay_us(6);
	ldw	x, #0x0006
	call	_delay_us
;	nokia.c: 77: DS_INPUT();
	bres	0x5007, #5
;	nokia.c: 78: delay_us(9);
	ldw	x, #0x0009
	call	_delay_us
;	nokia.c: 79: bit = (DS_READ() ? 1 : 0);
	btjf	0x5006, #5, 00103$
	clrw	x
	incw	x
	.byte 0x21
00103$:
	clrw	x
00104$:
	ld	a, xl
;	nokia.c: 80: delay_us(55);
	push	a
	ldw	x, #0x0037
	call	_delay_us
	pop	a
;	nokia.c: 81: return bit;
;	nokia.c: 82: }
	ret
;	nokia.c: 84: void onewire_write_byte(uint8_t byte) {
;	-----------------------------------------
;	 function onewire_write_byte
;	-----------------------------------------
_onewire_write_byte:
	sub	sp, #2
	ld	(0x01, sp), a
;	nokia.c: 85: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00103$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00105$
;	nokia.c: 86: onewire_write_bit(byte & 0x01);
	ld	a, (0x01, sp)
	and	a, #0x01
	call	_onewire_write_bit
;	nokia.c: 87: byte >>= 1;
	srl	(0x01, sp)
;	nokia.c: 85: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00103$
00105$:
;	nokia.c: 89: }
	addw	sp, #2
	ret
;	nokia.c: 91: uint8_t onewire_read_byte(void) {
;	-----------------------------------------
;	 function onewire_read_byte
;	-----------------------------------------
_onewire_read_byte:
	sub	sp, #2
;	nokia.c: 92: uint8_t byte = 0;
	clr	(0x01, sp)
;	nokia.c: 93: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x02, sp)
00105$:
	ld	a, (0x02, sp)
	cp	a, #0x08
	jrnc	00103$
;	nokia.c: 94: byte >>= 1;
	srl	(0x01, sp)
;	nokia.c: 95: if (onewire_read_bit()) byte |= 0x80;
	call	_onewire_read_bit
	tnz	a
	jreq	00106$
	sll	(0x01, sp)
	scf
	rrc	(0x01, sp)
00106$:
;	nokia.c: 93: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x02, sp)
	jra	00105$
00103$:
;	nokia.c: 97: return byte;
	ld	a, (0x01, sp)
;	nokia.c: 98: }
	addw	sp, #2
	ret
;	nokia.c: 100: void ds18b20_start_conversion(void) {
;	-----------------------------------------
;	 function ds18b20_start_conversion
;	-----------------------------------------
_ds18b20_start_conversion:
;	nokia.c: 101: onewire_reset();
	call	_onewire_reset
;	nokia.c: 102: onewire_write_byte(0xCC);
	ld	a, #0xcc
	call	_onewire_write_byte
;	nokia.c: 103: onewire_write_byte(0x44);
	ld	a, #0x44
;	nokia.c: 104: }
	jp	_onewire_write_byte
;	nokia.c: 106: int16_t ds18b20_read_raw(void) {
;	-----------------------------------------
;	 function ds18b20_read_raw
;	-----------------------------------------
_ds18b20_read_raw:
	sub	sp, #4
;	nokia.c: 107: onewire_reset();
	call	_onewire_reset
;	nokia.c: 108: onewire_write_byte(0xCC);
	ld	a, #0xcc
	call	_onewire_write_byte
;	nokia.c: 109: onewire_write_byte(0xBE);
	ld	a, #0xbe
	call	_onewire_write_byte
;	nokia.c: 110: uint8_t lsb = onewire_read_byte();
	call	_onewire_read_byte
;	nokia.c: 111: uint8_t msb = onewire_read_byte();
	push	a
	call	_onewire_read_byte
	ld	xh, a
	pop	a
;	nokia.c: 112: return ((int16_t)msb << 8) | lsb;
	clr	(0x02, sp)
	clr	(0x03, sp)
	or	a, (0x02, sp)
	rlwa	x
	or	a, (0x03, sp)
	ld	xh, a
;	nokia.c: 113: }
	addw	sp, #4
	ret
;	nokia.c: 117: void lcd_send_byte(uint8_t data) {
;	-----------------------------------------
;	 function lcd_send_byte
;	-----------------------------------------
_lcd_send_byte:
	push	a
	ld	xh, a
;	nokia.c: 118: for (uint8_t i = 0; i < 8; i++) {
	clr	(0x01, sp)
00106$:
	ld	a, (0x01, sp)
	cp	a, #0x08
	jrnc	00108$
;	nokia.c: 119: if (data & 0x80) LCD_DIN_HIGH();  // Si bit courant = 1, ligne DIN à 1
	ld	a, 0x500a
	tnzw	x
	jrpl	00102$
	or	a, #0x40
	ld	0x500a, a
	jra	00103$
00102$:
;	nokia.c: 120: else LCD_DIN_LOW();               // Sinon ligne DIN à 0
	and	a, #0xbf
	ld	0x500a, a
00103$:
;	nokia.c: 122: LCD_CLK_HIGH();  // Front montant : le LCD lit le bit ici
	bset	0x500a, #5
;	nokia.c: 123: LCD_CLK_LOW();   // Front descendant : prêt pour le bit suivant
	bres	0x500a, #5
;	nokia.c: 125: data <<= 1;  // Décale vers la gauche pour le prochain bit
	ld	a, xh
	sll	a
	ld	xh, a
;	nokia.c: 118: for (uint8_t i = 0; i < 8; i++) {
	inc	(0x01, sp)
	jra	00106$
00108$:
;	nokia.c: 127: }
	pop	a
	ret
;	nokia.c: 131: void lcd_write_cmd(uint8_t cmd) {
;	-----------------------------------------
;	 function lcd_write_cmd
;	-----------------------------------------
_lcd_write_cmd:
	ld	xl, a
;	nokia.c: 132: LCD_DC_LOW();     // On sélectionne le mode "commande"
	bres	0x500a, #4
;	nokia.c: 133: LCD_CE_LOW();     // Active la communication avec l'écran
	bres	0x500f, #1
;	nokia.c: 134: lcd_send_byte(cmd); // Envoie la commande
	ld	a, xl
	call	_lcd_send_byte
;	nokia.c: 135: LCD_CE_HIGH();    // Termine la communication
	bset	0x500f, #1
;	nokia.c: 136: }
	ret
;	nokia.c: 140: void lcd_write_data(uint8_t data) {
;	-----------------------------------------
;	 function lcd_write_data
;	-----------------------------------------
_lcd_write_data:
	ld	xl, a
;	nokia.c: 141: LCD_DC_HIGH();     // Mode "donnée"
	bset	0x500a, #4
;	nokia.c: 142: LCD_CE_LOW();      // Active la communication avec l'écran
	bres	0x500f, #1
;	nokia.c: 143: lcd_send_byte(data);  // Envoie la donnée (1 octet = 8 pixels verticaux)
	ld	a, xl
	call	_lcd_send_byte
;	nokia.c: 144: LCD_CE_HIGH();     // Termine la communication
	bset	0x500f, #1
;	nokia.c: 145: }
	ret
;	nokia.c: 149: void lcd_init(void) {
;	-----------------------------------------
;	 function lcd_init
;	-----------------------------------------
_lcd_init:
;	nokia.c: 151: PC_DDR |= (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7);
	ld	a, 0x500c
	or	a, #0xf0
	ld	0x500c, a
;	nokia.c: 152: PC_CR1 |= (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7);
	ld	a, 0x500d
	or	a, #0xf0
	ld	0x500d, a
;	nokia.c: 155: PD_DDR |= (1 << 1);
	bset	0x5011, #1
;	nokia.c: 156: PD_CR1 |= (1 << 1);
	bset	0x5012, #1
;	nokia.c: 159: LCD_RST_LOW();     // Maintient RST à 0
	bres	0x500a, #7
;	nokia.c: 160: delay_ms(100);     // Attend 100 ms
	ldw	x, #0x0064
	call	_delay_ms
;	nokia.c: 161: LCD_RST_HIGH();    // Libère RST → redémarrage du LCD
	bset	0x500a, #7
;	nokia.c: 164: lcd_write_cmd(0x21); // Mode étendu (permet config contraste, température...)
	ld	a, #0x21
	call	_lcd_write_cmd
;	nokia.c: 165: lcd_write_cmd(0xB0); // Contraste (valeur entre 0x80 et 0xBF, à adapter si besoin)
	ld	a, #0xb0
	call	_lcd_write_cmd
;	nokia.c: 166: lcd_write_cmd(0x04); // Coefficient de température (valeur recommandée)
	ld	a, #0x04
	call	_lcd_write_cmd
;	nokia.c: 167: lcd_write_cmd(0x14); // Biais LCD (rapport tension segments)
	ld	a, #0x14
	call	_lcd_write_cmd
;	nokia.c: 168: lcd_write_cmd(0x20); // Retour en mode basique
	ld	a, #0x20
	call	_lcd_write_cmd
;	nokia.c: 169: lcd_write_cmd(0x0C); // Affichage normal (pas d’inversion, pas de tout-éteint)
	ld	a, #0x0c
;	nokia.c: 170: }
	jp	_lcd_write_cmd
;	nokia.c: 174: void lcd_clear(void) {
;	-----------------------------------------
;	 function lcd_clear
;	-----------------------------------------
_lcd_clear:
;	nokia.c: 175: for (uint16_t i = 0; i < 504; i++) {
	clrw	x
00103$:
	ldw	y, x
	cpw	y, #0x01f8
	jrc	00118$
	ret
00118$:
;	nokia.c: 176: lcd_write_data(0x00); // Chaque octet = 8 pixels verticaux noirs
	pushw	x
	clr	a
	call	_lcd_write_data
	popw	x
;	nokia.c: 175: for (uint16_t i = 0; i < 504; i++) {
	incw	x
	jra	00103$
;	nokia.c: 178: }
	ret
;	nokia.c: 183: void lcd_draw_8x8_char(const uint8_t* glyph, uint8_t x, uint8_t y) {
;	-----------------------------------------
;	 function lcd_draw_8x8_char
;	-----------------------------------------
_lcd_draw_8x8_char:
	sub	sp, #8
	ldw	(0x04, sp), x
	ld	(0x03, sp), a
;	nokia.c: 184: for (uint8_t col = 0; col < 8; col++) {
	clr	(0x06, sp)
00109$:
	ld	a, (0x06, sp)
	cp	a, #0x08
	jrnc	00111$
;	nokia.c: 185: uint8_t out = 0;
	clr	(0x07, sp)
;	nokia.c: 186: for (uint8_t row = 0; row < 8; row++) {
	ld	a, #0x07
	sub	a, (0x06, sp)
	clrw	x
	incw	x
	ldw	(0x01, sp), x
	tnz	a
	jreq	00142$
00141$:
	sll	(0x02, sp)
	rlc	(0x01, sp)
	dec	a
	jrne	00141$
00142$:
	clr	(0x08, sp)
00106$:
	ld	a, (0x08, sp)
	cp	a, #0x08
	jrnc	00103$
;	nokia.c: 187: if (glyph[row] & (1 << (7 - col))) {
	clrw	x
	ld	a, (0x08, sp)
	ld	xl, a
	addw	x, (0x04, sp)
	ld	a, (x)
	clrw	x
	and	a, (0x02, sp)
	rrwa	x
	and	a, (0x01, sp)
	ld	xl, a
	tnzw	x
	jreq	00107$
;	nokia.c: 188: out |= (1 << row);  // Transpose bit : ligne → colonne
	ld	a, (0x08, sp)
	ld	xl, a
	ld	a, #0x01
	push	a
	ld	a, xl
	tnz	a
	jreq	00146$
00145$:
	sll	(1, sp)
	dec	a
	jrne	00145$
00146$:
	pop	a
	or	a, (0x07, sp)
	ld	(0x07, sp), a
00107$:
;	nokia.c: 186: for (uint8_t row = 0; row < 8; row++) {
	inc	(0x08, sp)
	jra	00106$
00103$:
;	nokia.c: 193: lcd_write_cmd(0x40 | (y / 8));   // Page Y (chaque page = 8 lignes)
	ld	a, (0x0b, sp)
	clrw	x
	ld	xl, a
	tnzw	x
	jrpl	00147$
	addw	x, #0x0007
00147$:
	sraw	x
	sraw	x
	sraw	x
	ld	a, xl
	or	a, #0x40
	call	_lcd_write_cmd
;	nokia.c: 194: lcd_write_cmd(0x80 | (x + col)); // Colonne X + décalage actuel
	ld	a, (0x03, sp)
	add	a, (0x06, sp)
	or	a, #0x80
	call	_lcd_write_cmd
;	nokia.c: 196: lcd_write_data(out); // Envoie 1 colonne verticale de 8 pixels
	ld	a, (0x07, sp)
	call	_lcd_write_data
;	nokia.c: 184: for (uint8_t col = 0; col < 8; col++) {
	inc	(0x06, sp)
	jra	00109$
00111$:
;	nokia.c: 198: }
	addw	sp, #8
	popw	x
	pop	a
	jp	(x)
;	nokia.c: 203: void lcd_draw_char_small(const uint8_t *data, uint8_t x, uint8_t page) {
;	-----------------------------------------
;	 function lcd_draw_char_small
;	-----------------------------------------
_lcd_draw_char_small:
	sub	sp, #3
	ldw	(0x01, sp), x
;	nokia.c: 204: lcd_write_cmd(0x80 | x);           // Position horizontale (X)
	or	a, #0x80
	call	_lcd_write_cmd
;	nokia.c: 205: lcd_write_cmd(0x40 | page);        // Position verticale (page Y de 8 lignes)
	ld	a, (0x06, sp)
	or	a, #0x40
	call	_lcd_write_cmd
;	nokia.c: 207: for (uint8_t i = 0; i < 5; i++) {
	clr	(0x03, sp)
00103$:
	ld	a, (0x03, sp)
	cp	a, #0x05
	jrnc	00101$
;	nokia.c: 208: lcd_write_data(data[i]);       // Envoie les 5 colonnes du caractère
	clrw	x
	ld	a, (0x03, sp)
	ld	xl, a
	addw	x, (0x01, sp)
	ld	a, (x)
	call	_lcd_write_data
;	nokia.c: 207: for (uint8_t i = 0; i < 5; i++) {
	inc	(0x03, sp)
	jra	00103$
00101$:
;	nokia.c: 210: lcd_write_data(0x00); // Ajoute un espace de 1 colonne après
	clr	a
	ldw	x, (4, sp)
	ldw	(5, sp), x
	addw	sp, #4
;	nokia.c: 211: }
	jp	_lcd_write_data
	pop	a
	jp	(x)
;	nokia.c: 215: void lcd_print_temperature(int16_t temp_x100, uint8_t x, uint8_t y) {
;	-----------------------------------------
;	 function lcd_print_temperature
;	-----------------------------------------
_lcd_print_temperature:
	sub	sp, #15
	ld	(0x0e, sp), a
;	nokia.c: 219: int int_part = temp_x100 / 100;
	pushw	x
	push	#0x64
	push	#0x00
	call	__divsint
	exgw	x, y
	popw	x
	ldw	(0x01, sp), y
;	nokia.c: 220: int frac_part = temp_x100 % 100;
	pushw	x
	push	#0x64
	push	#0x00
	call	__modsint
	exgw	x, y
	popw	x
	ldw	(0x0c, sp), y
;	nokia.c: 222: if (temp_x100 < 0) {
	tnzw	x
	jrpl	00102$
;	nokia.c: 223: int_part = -int_part;
	ldw	x, (0x01, sp)
	negw	x
;	nokia.c: 224: frac_part = -frac_part;
	ldw	y, (0x0c, sp)
	negw	y
;	nokia.c: 225: buf[0] = '-';
	ld	a, #0x2d
	ld	(0x03, sp), a
;	nokia.c: 226: sprintf(buf + 1, "%d.%02d", int_part, frac_part);
	pushw	y
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	ldw	x, sp
	addw	x, #10
	pushw	x
	call	_sprintf
	addw	sp, #8
	jra	00103$
00102$:
;	nokia.c: 228: sprintf(buf, "%d.%02d", int_part, frac_part);
	ldw	x, (0x0c, sp)
	pushw	x
	ldw	x, (0x03, sp)
	pushw	x
	push	#<(___str_0+0)
	push	#((___str_0+0) >> 8)
	ldw	x, sp
	addw	x, #9
	pushw	x
	call	_sprintf
	addw	sp, #8
00103$:
;	nokia.c: 231: uint8_t cursor = x; // Position de départ
	ld	a, (0x0e, sp)
	ld	(0x0b, sp), a
;	nokia.c: 234: for (uint8_t i = 0; buf[i] != '\0'; i++) {
	clr	(0x0f, sp)
00115$:
	clrw	x
	ld	a, (0x0f, sp)
	ld	xl, a
	pushw	x
	ldw	x, sp
	addw	x, #5
	addw	x, (1, sp)
	addw	sp, #2
	ld	a, (x)
	ld	xl, a
;	nokia.c: 255: cursor += 8; // Avance de 8 pixels pour le prochain caractère
	ld	a, (0x0b, sp)
	add	a, #0x08
	ld	(0x0c, sp), a
;	nokia.c: 234: for (uint8_t i = 0; buf[i] != '\0'; i++) {
	ld	a, xl
	tnz	a
	jreq	00113$
;	nokia.c: 235: char c = buf[i];
	ld	a, xl
;	nokia.c: 237: if (c >= '0' && c <= '9') {
	ld	(0x0d, sp), a
	cp	a, #0x30
	jrc	00110$
	ld	a, (0x0d, sp)
	cp	a, #0x39
	jrugt	00110$
;	nokia.c: 238: lcd_draw_8x8_char(big_digits[c - '0'], cursor, y);
	ld	a, (0x0d, sp)
	sub	a, #0x30
	ld	xl, a
	rlc	a
	clr	a
	sbc	a, #0x00
	ld	xh, a
	sllw	x
	ldw	x, (_big_digits+0, x)
	ld	a, (0x12, sp)
	push	a
	ld	a, (0x0c, sp)
	call	_lcd_draw_8x8_char
	jra	00111$
00110$:
;	nokia.c: 239: } else if (c == '.') {
	ld	a, (0x0d, sp)
	cp	a, #0x2e
	jrne	00107$
;	nokia.c: 240: lcd_draw_8x8_char(big_char_dot, cursor, y);
	ld	a, (0x12, sp)
	push	a
	ld	a, (0x0c, sp)
	ldw	x, #(_big_char_dot+0)
	call	_lcd_draw_8x8_char
	jra	00111$
00107$:
;	nokia.c: 241: } else if (c == '-') {
	ld	a, (0x0d, sp)
	cp	a, #0x2d
	jrne	00111$
;	nokia.c: 252: lcd_draw_8x8_char(minus, cursor, y);
	ld	a, (0x12, sp)
	push	a
	ld	a, (0x0c, sp)
	ldw	x, #(_lcd_print_temperature_minus_262145_71+0)
	call	_lcd_draw_8x8_char
00111$:
;	nokia.c: 255: cursor += 8; // Avance de 8 pixels pour le prochain caractère
	ld	a, (0x0c, sp)
	ld	(0x0b, sp), a
;	nokia.c: 234: for (uint8_t i = 0; buf[i] != '\0'; i++) {
	inc	(0x0f, sp)
	jra	00115$
00113$:
;	nokia.c: 259: lcd_draw_8x8_char(big_char_deg, cursor, y);
	ld	a, (0x12, sp)
	push	a
	ld	a, (0x0c, sp)
	ldw	x, #(_big_char_deg+0)
	call	_lcd_draw_8x8_char
;	nokia.c: 260: cursor += 8;
	ld	a, (0x0c, sp)
	ld	xl, a
;	nokia.c: 261: lcd_draw_8x8_char(big_char_C, cursor, y);
	ld	a, (0x12, sp)
	push	a
	ld	a, xl
	ldw	x, #(_big_char_C+0)
	call	_lcd_draw_8x8_char
;	nokia.c: 262: }
	addw	sp, #15
	popw	x
	pop	a
	jp	(x)
;	nokia.c: 267: void main() {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	nokia.c: 269: CLK_CKDIVR = 0x00; // forcer la frequence CPU
	mov	0x50c6+0, #0x00
;	nokia.c: 273: PB_DDR &= ~(1 << DS_PIN);    // Direction = entrée
	bres	0x5007, #5
;	nokia.c: 274: PB_CR1 |= (1 << DS_PIN);     // Active le pull-up (résistance interne à Vcc)
	bset	0x5008, #5
;	nokia.c: 278: lcd_init();   // Envoie la séquence d’initialisation au LCD PCD8544
	call	_lcd_init
;	nokia.c: 279: lcd_clear();  // Efface tout l’écran
	call	_lcd_clear
;	nokia.c: 282: while (1) {
00102$:
;	nokia.c: 284: ds18b20_start_conversion(); // Envoie la commande "Convert T"
	call	_ds18b20_start_conversion
;	nokia.c: 285: delay_ms(750);              // Attente du temps de conversion (max 750 ms)
	ldw	x, #0x02ee
	call	_delay_ms
;	nokia.c: 288: int16_t raw = ds18b20_read_raw(); // Lit les 16 bits bruts (valeur signée)
	call	_ds18b20_read_raw
;	nokia.c: 292: int16_t temp_x100 = (raw * 625UL) / 100;
	clrw	y
	tnzw	x
	jrpl	00111$
	decw	y
00111$:
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
;	nokia.c: 295: lcd_print_temperature(temp_x100, 16, 16);
	push	#0x10
	ld	a, #0x10
	call	_lcd_print_temperature
;	nokia.c: 299: delay_ms(1000); // Rafraîchissement toutes les secondes
	ldw	x, #0x03e8
	call	_delay_ms
	jra	00102$
;	nokia.c: 301: }
	ret
	.area CODE
	.area CONST
_big_digit_0:
	.db #0x3c	; 60
	.db #0x66	; 102	'f'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x66	; 102	'f'
	.db #0x3c	; 60
_big_digit_1:
	.db #0x18	; 24
	.db #0x38	; 56	'8'
	.db #0x78	; 120	'x'
	.db #0x18	; 24
	.db #0x18	; 24
	.db #0x18	; 24
	.db #0x18	; 24
	.db #0x7e	; 126
_big_digit_2:
	.db #0x7c	; 124
	.db #0xc6	; 198
	.db #0x06	; 6
	.db #0x0c	; 12
	.db #0x30	; 48	'0'
	.db #0x60	; 96
	.db #0xfe	; 254
	.db #0xfe	; 254
_big_digit_3:
	.db #0x7c	; 124
	.db #0xc6	; 198
	.db #0x06	; 6
	.db #0x3c	; 60
	.db #0x06	; 6
	.db #0x06	; 6
	.db #0xc6	; 198
	.db #0x7c	; 124
_big_digit_4:
	.db #0x0c	; 12
	.db #0x1c	; 28
	.db #0x3c	; 60
	.db #0x6c	; 108	'l'
	.db #0xcc	; 204
	.db #0xfe	; 254
	.db #0x0c	; 12
	.db #0x0c	; 12
_big_digit_5:
	.db #0xfe	; 254
	.db #0xc0	; 192
	.db #0xfc	; 252
	.db #0x06	; 6
	.db #0x06	; 6
	.db #0x06	; 6
	.db #0xc6	; 198
	.db #0x7c	; 124
_big_digit_6:
	.db #0x3c	; 60
	.db #0x60	; 96
	.db #0xc0	; 192
	.db #0xfc	; 252
	.db #0xc6	; 198
	.db #0xc6	; 198
	.db #0x66	; 102	'f'
	.db #0x3c	; 60
_big_digit_7:
	.db #0xfe	; 254
	.db #0x06	; 6
	.db #0x0c	; 12
	.db #0x18	; 24
	.db #0x30	; 48	'0'
	.db #0x60	; 96
	.db #0xc0	; 192
	.db #0xc0	; 192
_big_digit_8:
	.db #0x7c	; 124
	.db #0xc6	; 198
	.db #0xc6	; 198
	.db #0x7c	; 124
	.db #0xc6	; 198
	.db #0xc6	; 198
	.db #0xc6	; 198
	.db #0x7c	; 124
_big_digit_9:
	.db #0x3c	; 60
	.db #0x66	; 102	'f'
	.db #0xc6	; 198
	.db #0x7e	; 126
	.db #0x06	; 6
	.db #0x0c	; 12
	.db #0x18	; 24
	.db #0x70	; 112	'p'
_big_char_C:
	.db #0x3e	; 62
	.db #0x60	; 96
	.db #0xc0	; 192
	.db #0xc0	; 192
	.db #0xc0	; 192
	.db #0xc0	; 192
	.db #0x60	; 96
	.db #0x3e	; 62
_big_char_dot:
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x18	; 24
	.db #0x18	; 24
_big_char_deg:
	.db #0x1c	; 28
	.db #0x22	; 34
	.db #0x22	; 34
	.db #0x1c	; 28
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
_lcd_print_temperature_minus_262145_71:
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xfe	; 254
	.db #0xfe	; 254
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.area CONST
___str_0:
	.ascii "%d.%02d"
	.db 0x00
	.area CODE
	.area INITIALIZER
__xinit__big_digits:
	.dw _big_digit_0
	.dw _big_digit_1
	.dw _big_digit_2
	.dw _big_digit_3
	.dw _big_digit_4
	.dw _big_digit_5
	.dw _big_digit_6
	.dw _big_digit_7
	.dw _big_digit_8
	.dw _big_digit_9
	.area CABS (ABS)
