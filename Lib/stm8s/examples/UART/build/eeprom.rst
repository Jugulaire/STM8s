                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module eeprom
                                      6 	.optsdcc -mstm8
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _eeprom_unlock
                                     12 	.globl _option_bytes_unlock
                                     13 	.globl _eeprom_lock
                                     14 	.globl _eeprom_wait_busy
                                     15 ;--------------------------------------------------------
                                     16 ; ram data
                                     17 ;--------------------------------------------------------
                                     18 	.area DATA
                                     19 ;--------------------------------------------------------
                                     20 ; ram data
                                     21 ;--------------------------------------------------------
                                     22 	.area INITIALIZED
                                     23 ;--------------------------------------------------------
                                     24 ; absolute external ram data
                                     25 ;--------------------------------------------------------
                                     26 	.area DABS (ABS)
                                     27 
                                     28 ; default segment ordering for linker
                                     29 	.area HOME
                                     30 	.area GSINIT
                                     31 	.area GSFINAL
                                     32 	.area CONST
                                     33 	.area INITIALIZER
                                     34 	.area CODE
                                     35 
                                     36 ;--------------------------------------------------------
                                     37 ; global & static initialisations
                                     38 ;--------------------------------------------------------
                                     39 	.area HOME
                                     40 	.area GSINIT
                                     41 	.area GSFINAL
                                     42 	.area GSINIT
                                     43 ;--------------------------------------------------------
                                     44 ; Home
                                     45 ;--------------------------------------------------------
                                     46 	.area HOME
                                     47 	.area HOME
                                     48 ;--------------------------------------------------------
                                     49 ; code
                                     50 ;--------------------------------------------------------
                                     51 	.area CODE
                                     52 ;	../../lib/eeprom.c: 3: void eeprom_unlock() {
                                     53 ;	-----------------------------------------
                                     54 ;	 function eeprom_unlock
                                     55 ;	-----------------------------------------
      008074                         56 _eeprom_unlock:
                                     57 ;	../../lib/eeprom.c: 4: FLASH_DUKR = FLASH_DUKR_KEY1;
      008074 35 AE 50 64      [ 1]   58 	mov	0x5064+0, #0xae
                                     59 ;	../../lib/eeprom.c: 5: FLASH_DUKR = FLASH_DUKR_KEY2;
      008078 35 56 50 64      [ 1]   60 	mov	0x5064+0, #0x56
                                     61 ;	../../lib/eeprom.c: 6: while (!(FLASH_IAPSR & (1 << FLASH_IAPSR_DUL)));
      00807C                         62 00101$:
      00807C 72 07 50 5F FB   [ 2]   63 	btjf	0x505f, #3, 00101$
                                     64 ;	../../lib/eeprom.c: 7: }
      008081 81               [ 4]   65 	ret
                                     66 ;	../../lib/eeprom.c: 9: void option_bytes_unlock() {
                                     67 ;	-----------------------------------------
                                     68 ;	 function option_bytes_unlock
                                     69 ;	-----------------------------------------
      008082                         70 _option_bytes_unlock:
                                     71 ;	../../lib/eeprom.c: 10: FLASH_CR2 |= (1 << FLASH_CR2_OPT);
      008082 72 1E 50 5B      [ 1]   72 	bset	0x505b, #7
                                     73 ;	../../lib/eeprom.c: 11: FLASH_NCR2 &= ~(1 << FLASH_NCR2_NOPT);
      008086 72 1F 50 5C      [ 1]   74 	bres	0x505c, #7
                                     75 ;	../../lib/eeprom.c: 12: }
      00808A 81               [ 4]   76 	ret
                                     77 ;	../../lib/eeprom.c: 14: void eeprom_lock() {
                                     78 ;	-----------------------------------------
                                     79 ;	 function eeprom_lock
                                     80 ;	-----------------------------------------
      00808B                         81 _eeprom_lock:
                                     82 ;	../../lib/eeprom.c: 15: FLASH_IAPSR &= ~(1 << FLASH_IAPSR_DUL);
      00808B 72 17 50 5F      [ 1]   83 	bres	0x505f, #3
                                     84 ;	../../lib/eeprom.c: 16: }
      00808F 81               [ 4]   85 	ret
                                     86 ;	../../lib/eeprom.c: 18: void eeprom_wait_busy() {
                                     87 ;	-----------------------------------------
                                     88 ;	 function eeprom_wait_busy
                                     89 ;	-----------------------------------------
      008090                         90 _eeprom_wait_busy:
                                     91 ;	../../lib/eeprom.c: 19: while (!(FLASH_IAPSR & (1 << FLASH_IAPSR_EOP)));
      008090                         92 00101$:
      008090 72 05 50 5F FB   [ 2]   93 	btjf	0x505f, #2, 00101$
                                     94 ;	../../lib/eeprom.c: 20: }
      008095 81               [ 4]   95 	ret
                                     96 	.area CODE
                                     97 	.area CONST
                                     98 	.area INITIALIZER
                                     99 	.area CABS (ABS)
