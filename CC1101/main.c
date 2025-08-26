/* STM8S103 + CC1101 TX test (SDCC)
 * SPI:  PC5=SCK, PC6=MOSI, PC7=MISO  (par défaut)
 *       Mettre SWAP_MOSI_MISO=1 pour tester PC7=MOSI, PC6=MISO
 * CSN:  PD2
 * GDO0: PD4
 * UART: 9600 8N1
 */

#include <stdint.h>
#include <stdio.h>
#include "../stm8s.h"

/* ==================== Config ==================== */
#define F_CPU 16000000UL
#define BAUDRATE 9600
#define SWAP_MOSI_MISO  0   /* <-- mets à 1 si besoin d’inverser */

/* ============ UART minimal ============ */
static void uart_init(void){
  CLK_CKDIVR = 0x00;
  uint16_t div = (F_CPU + BAUDRATE/2) / BAUDRATE;
  UART1_BRR1 = (div >> 4) & 0xFF;
  UART1_BRR2 = ((div & 0x0F) | ((div >> 8) & 0xF0));
  UART1_CR1 = 0x00; UART1_CR3 = 0x00;
  UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
  (void)UART1_SR; (void)UART1_DR;
}
int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; }
static inline void delay_cycles(volatile uint16_t n){ while(n--) __asm__("nop"); }
static void delay_ms(uint16_t ms){ for(uint32_t i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop"); }

/* ============ GPIO / SPI ============ */
#define CSN_LOW()   (PD_ODR &= (uint8_t)~(1<<2))
#define CSN_HIGH()  (PD_ODR |=  (1<<2))
#define GDO0_READ() ( (PD_IDR & (1<<4)) ? 1:0 )

#if SWAP_MOSI_MISO
  #define MISO_BIT 6  /* PC6 = MISO */
  #define MOSI_BIT 7  /* PC7 = MOSI */
#else
  #define MISO_BIT 7  /* PC7 = MISO */
  #define MOSI_BIT 6  /* PC6 = MOSI */
#endif
#define MISO_IS_HIGH() ( (PC_IDR & (1<<MISO_BIT)) ? 1:0 )

static void gpio_init(void){
  /* SCK + MOSI out */
  PC_DDR |= (1<<5) | (1<<MOSI_BIT);
  PC_CR1 |= (1<<5) | (1<<MOSI_BIT);
  /* MISO in flottant */
  PC_DDR &= (uint8_t)~(1<<MISO_BIT);
  PC_CR1 &= (uint8_t)~(1<<MISO_BIT);
  /* CSN PD2 out, HIGH idle */
  PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
  /* GDO0 PD4 in */
  PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
}

static void spi_init(void){
  /* Master, mode0, très lent /128 pour commencer (BR2|BR1|BR0) */
  SPI_CR1 = (1<<SPI_CR1_MSTR) | (1<<SPI_CR1_BR2) | (1<<SPI_CR1_BR1) | (1<<SPI_CR1_BR0);
  SPI_CR2 = (1<<SPI_CR2_SSM) | (1<<SPI_CR2_SSI);
  SPI_CR1 |= (1<<SPI_CR1_SPE);
}
static uint8_t spi_txrx(uint8_t v){
  SPI_DR = v;
  while(!(SPI_SR & (1<<SPI_SR_TXE)));
  while(!(SPI_SR & (1<<SPI_SR_RXNE)));
  return SPI_DR;
}
static void spi_wait_idle(void){ while(SPI_SR & (1<<SPI_SR_BSY)); }

/* ============ CC1101 bas niveau ============ */
#define CC_READ   0x80
#define CC_BURST  0x40
#define SRES      0x30
#define SIDLE     0x36
#define SFRX      0x3A
#define SFTX      0x3B
#define STX       0x35
#define PARTNUM   0x30
#define VERSION   0x31
#define MARCSTATE 0x35
#define TXFIFO    0x3F

static uint8_t cc_select(void){
  CSN_LOW();
  /* attendre MISO=0 (prérequis TI) */
  uint32_t guard=0;
  while(MISO_IS_HIGH()){
    if(++guard>100000UL){ CSN_HIGH(); return 0; }
  }
  return 1;
}
static inline void cc_deselect(void){ spi_wait_idle(); CSN_HIGH(); }

static uint8_t cc_strobe(uint8_t st){
  if(!cc_select()) return 0xFF;
  uint8_t s = spi_txrx(st);
  cc_deselect();
  return s;
}
static void cc_write_reg(uint8_t a, uint8_t v){
  if(!cc_select()) return;
  spi_txrx(a); spi_txrx(v);
  cc_deselect();
}
static uint8_t cc_read_status(uint8_t addr){
    uint8_t v = 0xFF;
    if(!cc_select()) return 0xFF;
    (void)spi_txrx(addr | 0xC0);   // 0x80 -> 0xC0
    v = spi_txrx(0xFF);
    cc_deselect();
    return v;
}


/* Reset très soigneux */
static void cc_reset(void){
  CSN_HIGH(); delay_ms(5);
  CSN_LOW();  delay_ms(5);
  CSN_HIGH(); delay_ms(5);
  if(!cc_select()) return;
  spi_txrx(SRES);
  cc_deselect();
  delay_ms(5);
}

/* Config minimale 868 MHz (GFSK ~2.4 kbps, CRC, variable length) */
static void cc_config_868(void){
  cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
  cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
  cc_write_reg(0x0B,0x06); cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
  cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
  cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
  cc_write_reg(0x15,0x15); cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
  cc_write_reg(0x1B,0x43); cc_write_reg(0x22,0x11);
  cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
  cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
  cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
  delay_ms(2);
}

/* Envoi d’un petit paquet */
static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
  if(len==0 || len>61) return 0;
  cc_strobe(SIDLE); cc_strobe(SFTX);
  if(!cc_select()) return 0;
  spi_txrx(TXFIFO | CC_BURST);
  spi_txrx(len);
  for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
  cc_deselect();
  cc_strobe(STX);
  uint32_t guard=0;
  while(!GDO0_READ() && ++guard<150000UL){}   // front haut
  while( GDO0_READ() && ++guard<400000UL){}   // retour bas
  return (guard<400000UL);
}

/* ============ Debug ============ */
static void dump_once(const char* tag){
  uint8_t pn = cc_read_status(PARTNUM);
  uint8_t vr = cc_read_status(VERSION);
  uint8_t ms = cc_read_status(MARCSTATE);
  printf("[%s] PART=0x%02X VER=0x%02X MARC=0x%02X  (MISO=%d)\r\n",
         tag, pn, vr, ms, MISO_IS_HIGH());
}

/* ============ main ============ */
void main(void){
  uart_init(); gpio_init(); spi_init();
  printf("\r\n[STM8S] CC1101 TX test @868 MHz  (SWAP=%d)\r\n", SWAP_MOSI_MISO);

  /* Power-up delay pour laisser l’AMS1117/LD0 se stabiliser */
  delay_ms(20);

  /* Status avant reset (doit déjà changer si CSn/MISO ok) */
  dump_once("BEFORE");

  cc_reset();
  dump_once("AFTER_RST");

  cc_config_868();
  dump_once("AFTER_CFG");

  for(;;){
    uint8_t pkt[4] = {0x01,0x00,0xEA,0xEB};
    uint8_t ok = cc_send_packet(pkt, sizeof(pkt));
    dump_once(ok?"TX_OK":"TX_TO");
    delay_ms(1500);
  }
}
