/* nRF24L01+ TX minimal propre — STM8S103 / SDCC
 * Câblage :
 *   SCK  -> PC5   | MOSI -> PC6   | MISO -> PC7
 *   CSN  -> PD2   | CE   -> PD4   | VCC 3V3 | GND
 *
 * Compiler avec -DROLE_PTX (TX uniquement)
 */

#include <stdint.h>
#include <stdio.h>
#include "../stm8s.h"

#define F_CPU      16000000UL
#define BAUDRATE   9600
#define RF_CHAN    76
#define PAYLOAD_LEN 32

/* ---------- UART ---------- */
static inline void uart_config(void) {
  CLK_CKDIVR = 0x00; // 16 MHz
  uint16_t usartdiv = (F_CPU + BAUDRATE/2)/BAUDRATE;
  UART1_BRR1 = (usartdiv >> 4) & 0xFF;
  UART1_BRR2 = ((usartdiv & 0x0F) | ((usartdiv >> 8) & 0xF0));
  UART1_CR1 = 0x00;
  UART1_CR3 = 0x00;
  UART1_CR2 = (1<<UART1_CR2_TEN) | (1<<UART1_CR2_REN);
  (void)UART1_SR; (void)UART1_DR;
}
static inline void uart_write(uint8_t b){ UART1_DR=b; while(!(UART1_SR&(1<<UART1_SR_TC))); }
int putchar(int c){ uart_write((uint8_t)c); return 0; }

static inline void delay_cycles(volatile uint16_t n){ while(n--){ __asm__("nop"); } }
static inline void delay_ms(uint16_t ms){
  uint32_t i; for(i=0;i<((F_CPU/18000UL)*ms);i++) __asm__("nop");
}

/* ---------- nRF24: defs ---------- */
#ifndef BIT
#define BIT(n) (1U<<(n))
#endif

#define NRF_R_REGISTER      0x00
#define NRF_W_REGISTER      0x20
#define NRF_NOP             0xFF

#define NRF_REG_CONFIG      0x00
#define NRF_REG_EN_AA       0x01
#define NRF_REG_EN_RXADDR   0x02
#define NRF_REG_SETUP_AW    0x03
#define NRF_REG_SETUP_RETR  0x04
#define NRF_REG_RF_CH       0x05
#define NRF_REG_RF_SETUP    0x06
#define NRF_REG_STATUS      0x07
#define NRF_REG_OBSERVE_TX  0x08
#define NRF_REG_RX_ADDR_P0  0x0A
#define NRF_REG_TX_ADDR     0x10
#define NRF_REG_RX_PW_P0    0x11
#define NRF_REG_FIFO_STATUS 0x17
#define NRF_REG_FEATURE     0x1D

#define CFG_EN_CRC   (1<<3)
#define CFG_CRCO     (1<<2)
#define CFG_PWR_UP   (1<<1)
#define CFG_PRIM_RX  (1<<0)


#define NRF_CMD_FLUSH_TX    0xE1
#define NRF_CMD_FLUSH_RX    0xE2
#define NRF_W_TX_PAYLOAD    0xA0

/* STATUS bits */
#define RX_DR  6
#define TX_DS  5
#define MAX_RT 4

static const uint8_t ADDR_NODE1[5] = { 'N','O','D','E','1' };

/* CE/CSN macros: CE=PD4, CSN=PD2 */
#define CE_LOW()   (PD_ODR &= (uint8_t)~(1<<4))
#define CE_HIGH()  (PD_ODR |=  (1<<4))
#define CSN_LOW()  (PD_ODR &= (uint8_t)~(1<<2))
#define CSN_HIGH() (PD_ODR |=  (1<<2))

/* ---------- GPIO/SPI init ---------- */
static void gpio_init_spi(void){
  /* PC5=SCK, PC6=MOSI -> sorties PP */
  PC_DDR |= (1<<5)|(1<<6); PC_CR1 |= (1<<5)|(1<<6);
  /* PC7=MISO -> entrée flottante */
  PC_DDR &= (uint8_t)~(1<<7); PC_CR1 &= (uint8_t)~(1<<7);
  /* CSN PD2 -> sortie PP, haut au repos */
  PD_DDR |= (1<<2); PD_CR1 |= (1<<2); CSN_HIGH();
  /* CE PD4 -> sortie PP, bas au repos */
  PD_DDR |= (1<<4); PD_CR1 |= (1<<4); CE_LOW();
}

/* SPI mode0, maître, BR=/64 (lent = robuste sur clones) */
static void spi_init(void){
  SPI_CR1 = BIT(SPI_CR1_MSTR) | BIT(SPI_CR1_BR2);   /* /64 */
  SPI_CR2 = BIT(SPI_CR2_SSM)  | BIT(SPI_CR2_SSI);
  SPI_CR1 |= BIT(SPI_CR1_SPE);
}
static uint8_t spi_txrx(uint8_t v){
  SPI_DR = v;
  while(!(SPI_SR & BIT(SPI_SR_TXE)));
  while(!(SPI_SR & BIT(SPI_SR_RXNE)));
  return SPI_DR;
}
static void spi_wait_idle(void){ while(SPI_SR & BIT(SPI_SR_BSY)); }

/* ---------- nRF: R/W helpers ---------- */
static uint8_t nrf_read_reg(uint8_t reg){
  uint8_t v;
  CSN_LOW(); delay_cycles(50);
  (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
  v = spi_txrx(0xFF);
  spi_wait_idle(); delay_cycles(50);
  CSN_HIGH();
  return v;
}
static void nrf_write_reg(uint8_t reg, uint8_t val){
  CSN_LOW(); delay_cycles(50);
  (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
  (void)spi_txrx(val);
  spi_wait_idle(); delay_cycles(50);
  CSN_HIGH();
}
static void nrf_read_reg_n(uint8_t reg, uint8_t *buf, uint8_t len){
  CSN_LOW(); delay_cycles(50);
  (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
  for(uint8_t i=0;i<len;i++) buf[i] = spi_txrx(0xFF);
  spi_wait_idle(); delay_cycles(50);
  CSN_HIGH();
}
static void nrf_write_reg_n(uint8_t reg, const uint8_t *buf, uint8_t len){
  CSN_LOW(); delay_cycles(50);
  (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
  for(uint8_t i=0;i<len;i++) (void)spi_txrx(buf[i]);
  spi_wait_idle(); delay_cycles(50);
  CSN_HIGH();
}
static uint8_t nrf_cmd(uint8_t cmd){
  uint8_t s;
  CSN_LOW(); delay_cycles(50);
  s = spi_txrx(cmd);
  spi_wait_idle(); delay_cycles(50);
  CSN_HIGH();
  return s;
}

/* ---------- Debug/diagnostic visuel ---------- */
static uint8_t nrf_status_raw(void){
  uint8_t s;
  CSN_LOW(); delay_cycles(50);
  s = spi_txrx(NRF_NOP);
  spi_wait_idle(); delay_cycles(50);
  CSN_HIGH(); return s;
}
static uint8_t nrf_bus_ok(void){
  uint8_t s = nrf_status_raw();
  return (s != 0xFF && s != 0x00);
}

static void nrf_dump_status(void){
  uint8_t s = nrf_status_raw();
  printf("\r\n[STATUS] 0x%02X  (RX_DR=%d TX_DS=%d MAX_RT=%d RX_PIPE=%u TX_FULL=%d)\r\n",
         s, !!(s&(1<<RX_DR)), !!(s&(1<<TX_DS)), !!(s&(1<<MAX_RT)),
         (s>>1)&0x07, !!(s&0x01));
}
static void nrf_dump_core_regs(void){
  uint8_t cfg = nrf_read_reg(NRF_REG_CONFIG);
  uint8_t rfch = nrf_read_reg(NRF_REG_RF_CH);
  uint8_t rfs  = nrf_read_reg(NRF_REG_RF_SETUP);
  uint8_t tx[5], rx0[5];
  nrf_read_reg_n(NRF_REG_TX_ADDR, tx, 5);
  nrf_read_reg_n(NRF_REG_RX_ADDR_P0, rx0, 5);

  printf("[CORE]   CONFIG=0x%02X  RF_CH=0x%02X  RF_SETUP=0x%02X\r\n", cfg, rfch, rfs);
  printf("[ADDR]   TX_ADDR=%02X %02X %02X %02X %02X  |  RX0=%02X %02X %02X %02X %02X\r\n",
         tx[0],tx[1],tx[2],tx[3],tx[4], rx0[0],rx0[1],rx0[2],rx0[3],rx0[4]);
}
static void nrf_dump_tx_regs(void){
  uint8_t enaa = nrf_read_reg(NRF_REG_EN_AA);
  uint8_t enrx = nrf_read_reg(NRF_REG_EN_RXADDR);
  uint8_t retr = nrf_read_reg(NRF_REG_SETUP_RETR);
  uint8_t pw0  = nrf_read_reg(NRF_REG_RX_PW_P0);
  printf("[TXCFG]  EN_AA=0x%02X  EN_RXADDR=0x%02X  SETUP_RETR=0x%02X  RX_PW_P0=%u\r\n",
         enaa, enrx, retr, pw0);
}
static void nrf_dump_fifo(void){
  uint8_t f = nrf_read_reg(NRF_REG_FIFO_STATUS);
  printf("[FIFO]   0x%02X  TX_EMPTY=%d TX_FULL=%d  RX_EMPTY=%d RX_FULL=%d\r\n",
         f, !!(f&0x10), !!(f&0x20), !!(f&0x01), !!(f&0x02));
}

/* ---------- Config commune TX ---------- */
static void nrf_set_common(uint8_t rf_ch){
  nrf_write_reg(NRF_REG_SETUP_AW, 0x03);     // adresse 5B
  nrf_write_reg(NRF_REG_RF_CH,    rf_ch);    // canal
  nrf_write_reg(NRF_REG_RF_SETUP, 0x06);     // 1Mbps, 0dBm
  nrf_write_reg_n(NRF_REG_TX_ADDR,    ADDR_NODE1, 5);
  nrf_write_reg_n(NRF_REG_RX_ADDR_P0, ADDR_NODE1, 5);
  nrf_write_reg(NRF_REG_STATUS, 0x70);       // clear IRQ
  (void)nrf_cmd(NRF_CMD_FLUSH_RX);
  (void)nrf_cmd(NRF_CMD_FLUSH_TX);
  delay_ms(5);                                // tpd2stby
}

/* ---------- Modes PTX ---------- */
static void nrf_ptx_start_ack(void){
  nrf_set_common(RF_CHAN);
  nrf_write_reg(NRF_REG_EN_AA,      0x01);
  nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
  nrf_write_reg(NRF_REG_RX_PW_P0,   PAYLOAD_LEN);
  nrf_write_reg(NRF_REG_SETUP_RETR, 0x5F);
  nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP); // 0x0E
  delay_ms(5);
}

static void nrf_ptx_start_noack(void){
  nrf_set_common(RF_CHAN);
  nrf_write_reg(NRF_REG_EN_AA,      0x00);
  nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
  nrf_write_reg(NRF_REG_SETUP_RETR, 0x00);
  nrf_write_reg(NRF_REG_RX_PW_P0,   PAYLOAD_LEN);
  nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP); // 0x0E
  delay_ms(5);
}

static void nrf_prx_start(uint8_t payload_len){
  nrf_set_common(RF_CHAN);
  nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);
  nrf_write_reg(NRF_REG_EN_AA,      0x01);
  nrf_write_reg(NRF_REG_RX_PW_P0,   payload_len);
  nrf_write_reg(NRF_REG_SETUP_RETR, 0x5F);
  nrf_write_reg(NRF_REG_CONFIG,     CFG_EN_CRC | CFG_CRCO | CFG_PWR_UP | CFG_PRIM_RX); // 0x0F
  delay_ms(5);
  CE_HIGH();
}

/* ---------- Envois ---------- */
static uint8_t nrf_tx32_and_pulse_ce(const uint8_t *data, uint8_t len){
  /* Clear + flush */
  nrf_write_reg(NRF_REG_STATUS, 0x70);
  (void)nrf_cmd(NRF_CMD_FLUSH_TX);

  /* Charger exactement 32 octets (padding) */
  CSN_LOW(); (void)spi_txrx(NRF_W_TX_PAYLOAD);
  for(uint8_t i=0;i<32;i++) (void)spi_txrx((i<len)?data[i]:0x00);
  spi_wait_idle(); CSN_HIGH();

  /* Vérifier FIFO après chargement */
  nrf_dump_fifo();

  /* Pulse CE >= 40 µs */
  CE_HIGH(); delay_ms(2); CE_LOW();

  /* Attente issue */
  uint32_t guard=0;
  while(guard++ < 60000UL){
    uint8_t s = nrf_status_raw();
    if (s & (1<<TX_DS)) { nrf_write_reg(NRF_REG_STATUS,(1<<TX_DS)); return 1; }
    if (s & (1<<MAX_RT)) { nrf_write_reg(NRF_REG_STATUS,(1<<MAX_RT)); (void)nrf_cmd(NRF_CMD_FLUSH_TX); return 0; }
  }
  /* time-out soft: purger pour repartir propre */
  (void)nrf_cmd(NRF_CMD_FLUSH_TX);
  return 0;
}

static uint8_t nrf_ptx_send_noack(const uint8_t *data, uint8_t len){
  return nrf_tx32_and_pulse_ce(data, len); /* TX_DS quand la trame est émise */
}
static uint8_t nrf_ptx_send_ack(const uint8_t *data, uint8_t len){
  return nrf_tx32_and_pulse_ce(data, len); /* TX_DS si ACK reçu, MAX_RT sinon */
}

/* ---------- Démo TX ---------- */
static void demo_tx_loop(void){
  static const uint8_t msg[] = { 'H','E','L','L','O' };

  printf("\r\n===== nRF24 TX NO-ACK @ch=%u, 1Mbps, CRC16 =====\r\n", RF_CHAN);
  nrf_ptx_start_noack();
  nrf_dump_core_regs();
  nrf_dump_tx_regs();
  nrf_dump_status();

  for(;;){
    uint8_t ok = nrf_ptx_send_noack(msg, sizeof(msg));
    printf("[NOACK] %s\r\n", ok ? "TX_DS" : "timeout");
    nrf_dump_status();
    nrf_dump_fifo();
    delay_ms(500);
  }
}

/* Si tu veux tester l’ACK à la place, commente la boucle ci-dessus
   et décommente ceci :
static void demo_tx_loop(void){
  static const uint8_t msg[] = { 'H','E','L','L','O' };

  printf("\r\n===== nRF24 TX ACK @ch=%u, 1Mbps, CRC16 =====\r\n", RF_CHAN);
  nrf_ptx_start_ack();
  nrf_dump_core_regs();
  nrf_dump_tx_regs();
  nrf_dump_status();

  for(;;){
    uint8_t ok = nrf_ptx_send_ack(msg, sizeof(msg));
    printf("[ACK  ] %s\r\n", ok ? "TX_DS (ACK)" : "MAX_RT");
    nrf_dump_status();
    nrf_dump_fifo();
    delay_ms(500);
  }
}
*/



/* ---------- main ---------- */
void main(void){
  uart_config();
  printf("\r\n[STM8S] nRF24L01+ TX\r\n");
  gpio_init_spi();
  spi_init();

  if(!nrf_bus_ok()){
    printf("SPI KO: STATUS=0x%02X (verifie CSN/SCK/MOSI/MISO/VCC)\r\n", nrf_status_raw());
    while(1);
  }

  demo_tx_loop(); /* NO-ACK par défaut (simple à valider) */
}