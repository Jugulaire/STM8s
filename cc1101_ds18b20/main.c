#include "../stm8s.h"
#include <stdio.h>

#define F_CPU 16000000UL
#define BAUDRATE 9600
#define SWAP_MOSI_MISO  0   /* 0: PC6=MOSI, PC7=MISO  |  1: PC6=MISO, PC7=MOSI */
#define NODE_ID  0x01       /* identifiant du capteur */

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
int putchar(int c){ while(!(UART1_SR & (1<<UART1_SR_TXE))); UART1_DR=c; return 0; } // Gestion des printf 

// == assignation des pins pour l'afficheur
#define TM_CLK_PORT PA_ODR
#define TM_DIO_PORT PA_ODR
#define TM_CLK_DDR  PA_DDR
#define TM_DIO_DDR  PA_DDR
#define TM_CLK_PIN  2
#define TM_DIO_PIN  1

// === Définition de la pin DATA du capteur DS18B20 ===
#define DS_PIN 3            // Le capteur est connecté sur PD3

// === Macros bas-niveau pour manipuler la pin PD3 en mode 1-Wire ===
#define DS_LOW()    (PD_ODR &= ~(1 << DS_PIN))           // Force PD3 à 0V (sortie basse)
#define DS_HIGH()   (PD_ODR |=  (1 << DS_PIN))           // Force PD3 à 1 (sortie haute)
#define DS_INPUT()  (PD_DDR &= ~(1 << DS_PIN))           // Configure PD3 en entrée
#define DS_OUTPUT() (PD_DDR |=  (1 << DS_PIN))           // Configure PD3 en sortie
#define DS_READ()   (PD_IDR & (1 << DS_PIN))             // Lit l'état logique de PD3 (1 ou 0)


// === Temporisations ===
// Délai approximatif en microsecondes (fonction lente et approximative)
void delay_us(uint16_t us) {
    while(us--) {
        __asm__("nop"); __asm__("nop"); __asm__("nop");
        __asm__("nop"); __asm__("nop"); __asm__("nop");
    }
}

// Délai en millisecondes (approx. pour F_CPU = 16 MHz)
static inline void delay_ms(uint16_t ms) {
    uint32_t i;
    for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
        __asm__("nop");
}

// === Protocole 1-Wire pour DS18B20 ===

// Envoie un reset sur la ligne 1-Wire et attend le bit de présence
uint8_t onewire_reset(void) {
    DS_OUTPUT(); DS_LOW();         // Force la ligne à 0 pendant 480µs
    delay_us(480);
    DS_INPUT();                    // Relâche la ligne
    delay_us(70);                  // Attend la réponse du capteur
    uint8_t presence = !DS_READ(); // 0 = présence détectée
    delay_us(410);                 // Fin du timing 1-Wire
    return presence;
}

// Écrit un bit sur le bus 1-Wire
void onewire_write_bit(uint8_t bit) {
    DS_OUTPUT(); DS_LOW();
    delay_us(bit ? 6 : 60);        // Bit 1 = pulse court, bit 0 = pulse long
    DS_INPUT();                    // Libère la ligne
    delay_us(bit ? 64 : 10);       // Attente avant prochain bit
}

// Lit un bit depuis le bus 1-Wire
uint8_t onewire_read_bit(void) {
    uint8_t bit;
    DS_OUTPUT(); DS_LOW();
    delay_us(6);                   // Pulse d'initiation de lecture
    DS_INPUT();                    // Libère la ligne pour lire
    delay_us(9);                   // Délai standard
    bit = (DS_READ() ? 1 : 0);     // Lecture du bit
    delay_us(55);                  // Fin du slot
    return bit;
}

// Écrit un octet complet (8 bits)
void onewire_write_byte(uint8_t byte) {
    for (uint8_t i = 0; i < 8; i++) {
        onewire_write_bit(byte & 0x01); // Envoie le bit LSB
        byte >>= 1;
    }
}

// Lit un octet depuis le bus
uint8_t onewire_read_byte(void) {
    uint8_t byte = 0;
    for (uint8_t i = 0; i < 8; i++) {
        byte >>= 1;
        if (onewire_read_bit()) byte |= 0x80; // Lit MSB en premier
    }
    return byte;
}

// Démarre une conversion de température (commandes 1-Wire)
void ds18b20_start_conversion(void) {
    onewire_reset();
    onewire_write_byte(0xCC); // Skip ROM (capteur unique sur le bus)
    onewire_write_byte(0x44); // Convert T (lance mesure)
}

// Lit la température brute (valeur sur 16 bits, unité = 0.0625 °C)
int16_t ds18b20_read_raw(void) {
    onewire_reset();
    onewire_write_byte(0xCC); // Skip ROM
    onewire_write_byte(0xBE); // Read Scratchpad

    uint8_t lsb = onewire_read_byte(); // LSB = partie fractionnaire
    uint8_t msb = onewire_read_byte(); // MSB = partie entière signée

    return ((int16_t)msb << 8) | lsb;  // Fusionne les 2 octets
}

/* ============ GPIO / SPI (CC1101) ============ */
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
  /* GDO0 PD4 in flottant */
  PD_DDR &= (uint8_t)~(1<<4); PD_CR1 &= (uint8_t)~(1<<4);
  /* 1-Wire PD3 au repos: entrée + pull-up */
  PD_DDR &= (uint8_t)~(1<<3);
  PD_CR1 |= (1<<3);
}

//== Fonctions CC1101 ==
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

/* Strobes + registres utiles */
#define SRES      0x30
#define SIDLE     0x36
#define SFRX      0x3A
#define SFTX      0x3B
#define STX       0x35

#define PARTNUM   0x30
#define VERSION   0x31
#define MARCSTATE 0x35
#define TXFIFO    0x3F

#define PATABLE   0x3E

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
  if(!cc_select()) return 0xFF;
  (void)spi_txrx(addr | 0xC0);   // READ | BURST pour status regs
  uint8_t v = spi_txrx(0xFF);
  cc_deselect();
  return v;
}

/* Reset et config identiques à ton test qui marche */
static void cc_reset(void){
  CSN_HIGH(); delay_ms(5);
  CSN_LOW();  delay_ms(5);
  CSN_HIGH(); delay_ms(5);
  if(cc_select()){ spi_txrx(SRES); cc_deselect(); }
  delay_ms(5);
}

static void cc_write_patble(uint8_t pa){
  if(!cc_select()) return;
  spi_txrx(PATABLE | CC_BURST);
  for(uint8_t i=0;i<8;i++) spi_txrx(pa);
  cc_deselect();
}

static void cc_config_868(void){
  /* 868.3 MHz, GFSK ~2.4 kbps, CRC, variable-length, GDO0=0x06 */
  cc_write_reg(0x00,0x29); cc_write_reg(0x02,0x06); cc_write_reg(0x03,0x47);
  cc_write_reg(0x06,61);   cc_write_reg(0x07,0x04); cc_write_reg(0x08,0x05);
  cc_write_reg(0x0B,0x06);
  cc_write_reg(0x0D,0x21); cc_write_reg(0x0E,0x65); cc_write_reg(0x0F,0x6A);
  cc_write_reg(0x10,0xF5); cc_write_reg(0x11,0x83); cc_write_reg(0x12,0x13);
  cc_write_reg(0x13,0x22); cc_write_reg(0x14,0xF8);
  cc_write_reg(0x15,0x15);
  cc_write_reg(0x18,0x18); cc_write_reg(0x19,0x16);
  cc_write_reg(0x1B,0x43);
  cc_write_reg(0x22,0x11);
  cc_write_reg(0x23,0xE9); cc_write_reg(0x24,0x2A); cc_write_reg(0x25,0x00); cc_write_reg(0x26,0x1F);
  cc_write_reg(0x2C,0x81); cc_write_reg(0x2D,0x35); cc_write_reg(0x2E,0x09);
  cc_strobe(SIDLE); cc_strobe(SFRX); cc_strobe(SFTX);
  delay_ms(2);
  // Puissance 
  cc_write_patble(0xC0);      // mets 0x84 pour tester “0 dBm”, 0xC8 si tu veux un cran de plus
}

/* Envoi (varlen + CRC HW) */
static uint8_t cc_send_packet(const uint8_t* data, uint8_t len){
  if(len==0 || len>61) return 0;
  cc_strobe(SIDLE); 
  cc_strobe(SFTX);

  if(!cc_select()) return 0;
  spi_txrx(TXFIFO | CC_BURST);
  spi_txrx(len);
  for(uint8_t i=0;i<len;i++) spi_txrx(data[i]);
  cc_deselect();

  cc_strobe(STX);

  // pas de GDO0 -> délai fixe (~temps d’un paquet max)
  delay_ms(5);
  return 1;
}

// Fonction qui encode et envoie la température via CC1101
void cc_send_temp_x100(int16_t temp_x100) {
    // Convertir en dixièmes de degré (comme côté RX)
    int16_t temp_x10 = temp_x100 / 10;

    uint8_t pkt[4];
    pkt[0] = NODE_ID;                        // Identifiant du capteur
    pkt[1] = (uint8_t)(temp_x10 >> 8);       // MSB
    pkt[2] = (uint8_t)(temp_x10 & 0xFF);     // LSB
    pkt[3] = pkt[0] ^ pkt[1] ^ pkt[2];       // Checksum XOR

    uint8_t ok = cc_send_packet(pkt, sizeof(pkt));

    printf("[RADIO] send %d.%01d°C -> %s\r\n",
           temp_x10/10, temp_x10%10,
           ok ? "OK" : "FAIL");
}

void main() {

    CLK_CKDIVR = 0x00; // forcer la frequence CPU

    // Configuration de la broche PD3 (déjà manipulée par les macros 1-Wire)
    PD_DDR &= ~(1 << 3);    // PD3 en entrée
    PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)

    uart_init();
    gpio_init();
    spi_init();
    cc_reset();
    cc_config_868();

    uint16_t counter = 0;  // compteur en secondes

    // === Boucle principale ===
    while (1) {
        ds18b20_start_conversion(); // Démarre une conversion de température
        delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)

        int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
        
        // Conversion sans float : (valeur x 0.0625 * 100) = (valeur * 625 / 10000)
        int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100


        // Toutes les 120 secondes → envoi radio
        if (counter % 120 == 0) {
            cc_send_temp_x100(temp_x100);
        }

        counter++;
        //printf("timer %d sec \n\r", counter);

        // Attente de 120s +/- un petit offset dépendant de l’ID
        delay_ms(NODE_ID * 1000UL);
    }
}