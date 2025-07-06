                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module input
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _button_pressed
                                     13 ;--------------------------------------------------------
                                     14 ; ram data
                                     15 ;--------------------------------------------------------
                                     16 	.area DATA
      000001                         17 _button_pressed_last_state_65536_5:
      000001                         18 	.ds 8
                                     19 ;--------------------------------------------------------
                                     20 ; ram data
                                     21 ;--------------------------------------------------------
                                     22 	.area INITIALIZED
                                     23 ;--------------------------------------------------------
                                     24 ; Stack segment in internal ram
                                     25 ;--------------------------------------------------------
                                     26 	.area	SSEG
      000009                         27 __start__stack:
      000009                         28 	.ds	1
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
      008007 AE 00 08         [ 2]   58 	ldw x, #l_DATA
      00800A 27 07            [ 1]   59 	jreq	00002$
      00800C                         60 00001$:
      00800C 72 4F 00 00      [ 1]   61 	clr (s_DATA - 1, x)
      008010 5A               [ 2]   62 	decw x
      008011 26 F9            [ 1]   63 	jrne	00001$
      008013                         64 00002$:
      008013 AE 00 00         [ 2]   65 	ldw	x, #l_INITIALIZER
      008016 27 09            [ 1]   66 	jreq	00004$
      008018                         67 00003$:
      008018 D6 80 43         [ 1]   68 	ld	a, (s_INITIALIZER - 1, x)
      00801B D7 00 08         [ 1]   69 	ld	(s_INITIALIZED - 1, x), a
      00801E 5A               [ 2]   70 	decw	x
      00801F 26 F7            [ 1]   71 	jrne	00003$
      008021                         72 00004$:
                                     73 ; stm8_genXINIT() end
                                     74 ;	input.c: 13: static uint8_t last_state[8] = {0x00};  // Mémorise les derniers états (1 = repos, car pull-up active)
      008021 35 00 00 01      [ 1]   75 	mov	_button_pressed_last_state_65536_5+0, #0x00
      008025 35 00 00 02      [ 1]   76 	mov	_button_pressed_last_state_65536_5+1, #0x00
      008029 35 00 00 03      [ 1]   77 	mov	_button_pressed_last_state_65536_5+2, #0x00
      00802D 35 00 00 04      [ 1]   78 	mov	_button_pressed_last_state_65536_5+3, #0x00
      008031 35 00 00 05      [ 1]   79 	mov	_button_pressed_last_state_65536_5+4, #0x00
      008035 35 00 00 06      [ 1]   80 	mov	_button_pressed_last_state_65536_5+5, #0x00
      008039 35 00 00 07      [ 1]   81 	mov	_button_pressed_last_state_65536_5+6, #0x00
      00803D 35 00 00 08      [ 1]   82 	mov	_button_pressed_last_state_65536_5+7, #0x00
                                     83 	.area GSFINAL
      008041 CC 80 04         [ 2]   84 	jp	__sdcc_program_startup
                                     85 ;--------------------------------------------------------
                                     86 ; Home
                                     87 ;--------------------------------------------------------
                                     88 	.area HOME
                                     89 	.area HOME
      008004                         90 __sdcc_program_startup:
      008004 CC 81 13         [ 2]   91 	jp	_main
                                     92 ;	return from main will return to caller
                                     93 ;--------------------------------------------------------
                                     94 ; code
                                     95 ;--------------------------------------------------------
                                     96 	.area CODE
                                     97 ;	input.c: 5: static inline void delay_ms(uint16_t ms) {
                                     98 ;	-----------------------------------------
                                     99 ;	 function delay_ms
                                    100 ;	-----------------------------------------
      008044                        101 _delay_ms:
      008044 52 0A            [ 2]  102 	sub	sp, #10
      008046 1F 05            [ 2]  103 	ldw	(0x05, sp), x
                                    104 ;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      008048 5F               [ 1]  105 	clrw	x
      008049 1F 09            [ 2]  106 	ldw	(0x09, sp), x
      00804B 1F 07            [ 2]  107 	ldw	(0x07, sp), x
      00804D                        108 00103$:
      00804D 1E 05            [ 2]  109 	ldw	x, (0x05, sp)
      00804F 89               [ 2]  110 	pushw	x
      008050 AE 03 78         [ 2]  111 	ldw	x, #0x0378
      008053 CD 81 35         [ 4]  112 	call	___muluint2ulong
      008056 5B 02            [ 2]  113 	addw	sp, #2
      008058 1F 03            [ 2]  114 	ldw	(0x03, sp), x
      00805A 17 01            [ 2]  115 	ldw	(0x01, sp), y
      00805C 1E 09            [ 2]  116 	ldw	x, (0x09, sp)
      00805E 13 03            [ 2]  117 	cpw	x, (0x03, sp)
      008060 7B 08            [ 1]  118 	ld	a, (0x08, sp)
      008062 12 02            [ 1]  119 	sbc	a, (0x02, sp)
      008064 7B 07            [ 1]  120 	ld	a, (0x07, sp)
      008066 12 01            [ 1]  121 	sbc	a, (0x01, sp)
      008068 24 0F            [ 1]  122 	jrnc	00105$
                                    123 ;	input.c: 8: __asm__("nop");         // Instruction vide pour consommer du temps
      00806A 9D               [ 1]  124 	nop
                                    125 ;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      00806B 1E 09            [ 2]  126 	ldw	x, (0x09, sp)
      00806D 5C               [ 1]  127 	incw	x
      00806E 1F 09            [ 2]  128 	ldw	(0x09, sp), x
      008070 26 DB            [ 1]  129 	jrne	00103$
      008072 1E 07            [ 2]  130 	ldw	x, (0x07, sp)
      008074 5C               [ 1]  131 	incw	x
      008075 1F 07            [ 2]  132 	ldw	(0x07, sp), x
      008077 20 D4            [ 2]  133 	jra	00103$
      008079                        134 00105$:
                                    135 ;	input.c: 9: }
      008079 5B 0A            [ 2]  136 	addw	sp, #10
      00807B 81               [ 4]  137 	ret
                                    138 ;	input.c: 12: int8_t button_pressed(volatile uint8_t* idr, uint8_t pin) {
                                    139 ;	-----------------------------------------
                                    140 ;	 function button_pressed
                                    141 ;	-----------------------------------------
      00807C                        142 _button_pressed:
      00807C 52 0E            [ 2]  143 	sub	sp, #14
      00807E 1F 0D            [ 2]  144 	ldw	(0x0d, sp), x
      008080 90 97            [ 1]  145 	ld	yl, a
                                    146 ;	input.c: 14: uint8_t current_state = *idr & (1 << pin);  // Lecture du bit correspondant au bouton
      008082 1E 0D            [ 2]  147 	ldw	x, (0x0d, sp)
      008084 1F 01            [ 2]  148 	ldw	(0x01, sp), x
      008086 F6               [ 1]  149 	ld	a, (x)
      008087 93               [ 1]  150 	ldw	x, y
      008088 88               [ 1]  151 	push	a
      008089 A6 01            [ 1]  152 	ld	a, #0x01
      00808B 6B 04            [ 1]  153 	ld	(0x04, sp), a
      00808D 9F               [ 1]  154 	ld	a, xl
      00808E 4D               [ 1]  155 	tnz	a
      00808F 27 05            [ 1]  156 	jreq	00141$
      008091                        157 00140$:
      008091 08 04            [ 1]  158 	sll	(0x04, sp)
      008093 4A               [ 1]  159 	dec	a
      008094 26 FB            [ 1]  160 	jrne	00140$
      008096                        161 00141$:
      008096 84               [ 1]  162 	pop	a
      008097 14 03            [ 1]  163 	and	a, (0x03, sp)
      008099 6B 04            [ 1]  164 	ld	(0x04, sp), a
                                    165 ;	input.c: 17: if (current_state != (last_state[pin] & (1 << pin))) {
      00809B 5F               [ 1]  166 	clrw	x
      00809C 41               [ 1]  167 	exg	a, xl
      00809D 90 9F            [ 1]  168 	ld	a, yl
      00809F 41               [ 1]  169 	exg	a, xl
      0080A0 1C 00 01         [ 2]  170 	addw	x, #(_button_pressed_last_state_65536_5+0)
      0080A3 1F 05            [ 2]  171 	ldw	(0x05, sp), x
      0080A5 F6               [ 1]  172 	ld	a, (x)
      0080A6 6B 0C            [ 1]  173 	ld	(0x0c, sp), a
      0080A8 5F               [ 1]  174 	clrw	x
      0080A9 5C               [ 1]  175 	incw	x
      0080AA 1F 07            [ 2]  176 	ldw	(0x07, sp), x
      0080AC 90 9F            [ 1]  177 	ld	a, yl
      0080AE 4D               [ 1]  178 	tnz	a
      0080AF 27 07            [ 1]  179 	jreq	00143$
      0080B1                        180 00142$:
      0080B1 08 08            [ 1]  181 	sll	(0x08, sp)
      0080B3 09 07            [ 1]  182 	rlc	(0x07, sp)
      0080B5 4A               [ 1]  183 	dec	a
      0080B6 26 F9            [ 1]  184 	jrne	00142$
      0080B8                        185 00143$:
      0080B8 7B 0C            [ 1]  186 	ld	a, (0x0c, sp)
      0080BA 6B 0A            [ 1]  187 	ld	(0x0a, sp), a
      0080BC 0F 09            [ 1]  188 	clr	(0x09, sp)
      0080BE 7B 0A            [ 1]  189 	ld	a, (0x0a, sp)
      0080C0 14 08            [ 1]  190 	and	a, (0x08, sp)
      0080C2 6B 0C            [ 1]  191 	ld	(0x0c, sp), a
      0080C4 7B 09            [ 1]  192 	ld	a, (0x09, sp)
      0080C6 14 07            [ 1]  193 	and	a, (0x07, sp)
      0080C8 6B 0B            [ 1]  194 	ld	(0x0b, sp), a
      0080CA 7B 04            [ 1]  195 	ld	a, (0x04, sp)
      0080CC 6B 0A            [ 1]  196 	ld	(0x0a, sp), a
      0080CE 0F 09            [ 1]  197 	clr	(0x09, sp)
      0080D0 1E 09            [ 2]  198 	ldw	x, (0x09, sp)
      0080D2 13 0B            [ 2]  199 	cpw	x, (0x0b, sp)
      0080D4 27 39            [ 1]  200 	jreq	00106$
                                    201 ;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080D6 90 5F            [ 1]  202 	clrw	y
      0080D8 5F               [ 1]  203 	clrw	x
      0080D9 1F 07            [ 2]  204 	ldw	(0x07, sp), x
      0080DB                        205 00110$:
      0080DB 90 A3 11 58      [ 2]  206 	cpw	y, #0x1158
      0080DF 7B 08            [ 1]  207 	ld	a, (0x08, sp)
      0080E1 A2 00            [ 1]  208 	sbc	a, #0x00
      0080E3 7B 07            [ 1]  209 	ld	a, (0x07, sp)
      0080E5 A2 00            [ 1]  210 	sbc	a, #0x00
      0080E7 24 0C            [ 1]  211 	jrnc	00108$
                                    212 ;	input.c: 8: __asm__("nop");         // Instruction vide pour consommer du temps
      0080E9 9D               [ 1]  213 	nop
                                    214 ;	input.c: 7: for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
      0080EA 90 5C            [ 1]  215 	incw	y
      0080EC 26 ED            [ 1]  216 	jrne	00110$
      0080EE 1E 07            [ 2]  217 	ldw	x, (0x07, sp)
      0080F0 5C               [ 1]  218 	incw	x
      0080F1 1F 07            [ 2]  219 	ldw	(0x07, sp), x
      0080F3 20 E6            [ 2]  220 	jra	00110$
                                    221 ;	input.c: 18: delay_ms(5);  // Pause pour laisser passer les rebonds
      0080F5                        222 00108$:
                                    223 ;	input.c: 19: current_state = *idr & (1 << pin);  // Relire après stabilisation
      0080F5 1E 01            [ 2]  224 	ldw	x, (0x01, sp)
      0080F7 F6               [ 1]  225 	ld	a, (x)
      0080F8 14 03            [ 1]  226 	and	a, (0x03, sp)
                                    227 ;	input.c: 22: if (current_state != (last_state[pin] & (1 << pin))) {
      0080FA 6B 0A            [ 1]  228 	ld	(0x0a, sp), a
      0080FC 5F               [ 1]  229 	clrw	x
      0080FD 97               [ 1]  230 	ld	xl, a
      0080FE 13 0B            [ 2]  231 	cpw	x, (0x0b, sp)
      008100 27 0D            [ 1]  232 	jreq	00106$
                                    233 ;	input.c: 23: last_state[pin] = *idr;         // Mémoriser le nouvel état
      008102 1E 01            [ 2]  234 	ldw	x, (0x01, sp)
      008104 F6               [ 1]  235 	ld	a, (x)
      008105 1E 05            [ 2]  236 	ldw	x, (0x05, sp)
      008107 F7               [ 1]  237 	ld	(x), a
                                    238 ;	input.c: 24: if (!(current_state)) {         // Si le niveau est bas (appui)
      008108 0D 0A            [ 1]  239 	tnz	(0x0a, sp)
      00810A 26 03            [ 1]  240 	jrne	00106$
                                    241 ;	input.c: 25: return 1;                   // Retourner 1 : bouton pressé
      00810C A6 01            [ 1]  242 	ld	a, #0x01
                                    243 ;	input.c: 30: return 0;  // Aucun appui détecté
      00810E 21                     244 	.byte 0x21
      00810F                        245 00106$:
      00810F 4F               [ 1]  246 	clr	a
      008110                        247 00112$:
                                    248 ;	input.c: 31: }
      008110 5B 0E            [ 2]  249 	addw	sp, #14
      008112 81               [ 4]  250 	ret
                                    251 ;	input.c: 33: void main() {
                                    252 ;	-----------------------------------------
                                    253 ;	 function main
                                    254 ;	-----------------------------------------
      008113                        255 _main:
                                    256 ;	input.c: 35: PD_DDR |= (1 << 3);      // Direction : sortie
      008113 72 16 50 11      [ 1]  257 	bset	0x5011, #3
                                    258 ;	input.c: 36: PD_CR1 |= (1 << 3);      // Sortie push-pull
      008117 72 16 50 12      [ 1]  259 	bset	0x5012, #3
                                    260 ;	input.c: 41: PA_DDR &= ~(1 << 3);    // PA3 en entrée
      00811B 72 17 50 02      [ 1]  261 	bres	0x5002, #3
                                    262 ;	input.c: 42: PA_CR1 |= (1 << 3);     // Pull-up interne activée
      00811F 72 16 50 03      [ 1]  263 	bset	0x5003, #3
                                    264 ;	input.c: 45: while (1) {
      008123                        265 00104$:
                                    266 ;	input.c: 46: if (button_pressed(&PA_IDR, 3)) {   // Si le bouton est pressé (PA3 à 0)
      008123 A6 03            [ 1]  267 	ld	a, #0x03
      008125 AE 50 01         [ 2]  268 	ldw	x, #0x5001
      008128 CD 80 7C         [ 4]  269 	call	_button_pressed
      00812B 4D               [ 1]  270 	tnz	a
      00812C 27 F5            [ 1]  271 	jreq	00104$
                                    272 ;	input.c: 47: PD_ODR ^= (1 << 3);             // Inverser l’état de la LED sur PB5
      00812E 90 16 50 0F      [ 1]  273 	bcpl	0x500f, #3
      008132 20 EF            [ 2]  274 	jra	00104$
                                    275 ;	input.c: 50: }
      008134 81               [ 4]  276 	ret
                                    277 	.area CODE
                                    278 	.area CONST
                                    279 	.area INITIALIZER
                                    280 	.area CABS (ABS)
