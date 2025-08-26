/* UART.c — version étendue pour inclure un test SPI vers nRF24L01(+)
 * Cible : STM8S103 (ou proche), SDCC
 * Câblage nRF24L01(+): 
 *   SCK  -> PC5 (nRF pin 5)
 *   MOSI -> PC6 (nRF pin 6)
 *   MISO -> PC7 (nRF pin 7)
 *   CSN  -> PD2 (nRF pin 4)
 *   CE   -> PD1 (nRF pin 3)
 *   VCC  -> 3V3
 *   GND  -> GND
 */
/* Compiler l’émetteur avec -DROLE_PTX ; le récepteur sans cette macro */
#include <stdint.h>
#include <stdio.h>
#include "../stm8s.h"

#define F_CPU 16000000UL //16MHz
#define BAUDRATE 9600

#define RF_CHAN        76
#define PAYLOAD_LEN    32
/* ============================================================
 * === UART EXISTANT (colle ici ton code UART d’origine)    ===
 * ============================================================
*/

void uart_config() {
    CLK_CKDIVR = 0x00; // force 16 mhz 
    // Calcul du diviseur USARTDIV pour la vitesse de transmission
    uint16_t usartdiv = (F_CPU + BAUDRATE / 2) / BAUDRATE;

    // Extraction des bits pour BRR1 et BRR2 :
    // - BRR1 prend les bits 11 à 4 (poids forts)
    // - BRR2 combine les bits 3 à 0 (LSB) et la fraction sur 4 bits (MSB)

    uint8_t brr1 = (usartdiv >> 4) & 0xFF;               // Bits 11:4
    uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);  // Bits 3:0 + Bits 11:8

    UART1_BRR1 = brr1;
    UART1_BRR2 = brr2;
    UART1_CR1 = 0x00;    // 8 data bits, no parity
    UART1_CR3 = 0x00;    // 1 stop bit
    UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // active RX et TX
    //Nettoyage des registres 
    (void)UART1_SR;
    (void)UART1_DR;
}

void uart_write(uint8_t data) {
    UART1_DR = data;
    PB_ODR &= ~(1 << 5);  // LED OFF
    while (!(UART1_SR & (1 << UART1_SR_TC)));
    PB_ODR |= (1 << 5);   // LED ON
}

uint8_t uart_read() {
    while (!(UART1_SR & (1 << UART1_SR_RXNE)));
    return UART1_DR;
}

int putchar(int c) {
    uart_write(c);
    return 0;
}

static inline void delay_ms(uint16_t ms) {
    uint32_t i;
    for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
        __asm__("nop");
}

/* ============================================================
 * === AJOUT : Test SPI nRF24L01(+)                        ===
 * ============================================================
 */

#ifndef BIT
#define BIT(n) (1U << (n))
#endif

/* Commandes/Registres nRF24L01(+) */
#define NRF_R_REGISTER     0x00
#define NRF_W_REGISTER     0x20
#define NRF_NOP            0xFF
#define NRF_REG_CONFIG     0x00
#define NRF_REG_STATUS     0x07
#define NRF_REG_EN_AA      0x01
#define NRF_REG_EN_RXADDR  0x02
#define NRF_REG_SETUP_AW   0x03
#define NRF_REG_SETUP_RETR 0x04
#define NRF_REG_RF_CH      0x05
#define NRF_REG_RF_SETUP   0x06
#define NRF_REG_RX_ADDR_P0 0x0A
#define NRF_REG_TX_ADDR    0x10
#define NRF_REG_FEATURE    0x1D
#define NRF_CMD_FLUSH_TX   0xE1
#define NRF_CMD_FLUSH_RX   0xE2
#define NRF_W_TX_PAYLOAD   0xA0
#define NRF_REG_OBSERVE_TX 0x08
#define NRF_R_RX_PAYLOAD   0x61
#define NRF_REG_RX_PW_P0   0x11
#define NRF_REG_FIFO_STATUS 0x17

/* Bits STATUS */
#define TX_DS   5
#define MAX_RT  4
#define RX_DR   6

static const uint8_t ADDR_NODE1[5] = { 'N','O','D','E','1' };

/* Broches de contrôle (selon câblage) */
#define CE_LOW()   (PD_ODR &= (uint8_t)~(1<<4))
#define CE_HIGH()  (PD_ODR |=  (1<<4))
#define CSN_LOW()  (PD_ODR &= (uint8_t)~(1<<2))
#define CSN_HIGH() (PD_ODR |=  (1<<2))

static void delay_cycles(volatile uint16_t n) {
    while (n--) { __asm__("nop"); }
}

/* --- Init GPIO pour SPI + lignes nRF --- */
static void gpio_init_spi(void) {
    // SPI: PC5=SCK, PC6=MOSI -> sorties push-pull
    PC_DDR |= (1<<5) | (1<<6);
    PC_CR1 |= (1<<5) | (1<<6);

    // PC7=MISO -> entrée flottante
    PC_DDR &= (uint8_t)~(1<<7);
    PC_CR1 &= (uint8_t)~(1<<7);

    // CSN sur PD2 -> sortie push-pull, à l'état HAUT au repos
    PD_DDR |= (1<<2);
    PD_CR1 |= (1<<2);
    CSN_HIGH();

    // CE sur PD4 -> sortie push-pull, à l'état BAS au repos
    PD_DDR |= (1<<4);
    PD_CR1 |= (1<<4);
    CE_LOW();
}

/* --- Init contrôleur SPI (mode 0, maître, /16) --- */
static void spi_init(void) {
    /* CPOL=0, CPHA=0 par défaut; maître; BR[2:0]=0b011 => /16 pour commencer */
    //SPI_CR1 = BIT(SPI_CR1_MSTR) | BIT(SPI_CR1_BR1) | BIT(SPI_CR1_BR0);
    SPI_CR1 = BIT(SPI_CR1_MSTR) | BIT(SPI_CR1_BR2); // /64
    /* NSS logiciel, SSI à 1 */
    SPI_CR2 = BIT(SPI_CR2_SSM) | BIT(SPI_CR2_SSI);
    /* Enable SPI */
    SPI_CR1 |= BIT(SPI_CR1_SPE);
}

/* --- Échange SPI 8 bits --- */
static uint8_t spi_txrx(uint8_t v) {
    SPI_DR = v;
    while (!(SPI_SR & BIT(SPI_SR_TXE)));
    while (!(SPI_SR & BIT(SPI_SR_RXNE)));
    return SPI_DR;
}

/* --- Attendre SPI au repos avant de relâcher CSN --- */
static void spi_wait_idle(void) {
    while (SPI_SR & BIT(SPI_SR_BSY));
}

/* --- Accès registres nRF --- */
static uint8_t nrf_read_reg(uint8_t reg) {
    uint8_t val;
    CSN_LOW();
    (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F)); /* renvoie STATUS, ignoré ici */
    val = spi_txrx(0xFF);
    spi_wait_idle();
    CSN_HIGH();
    return val;
}

static void nrf_write_reg(uint8_t reg, uint8_t val) {
    CSN_LOW();
    (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F)); /* renvoie STATUS, ignoré ici */
    (void)spi_txrx(val);
    spi_wait_idle();
    CSN_HIGH();
}

static uint8_t nrf_read_status(void) {
    uint8_t s;
    CSN_LOW();
    s = spi_txrx(NRF_NOP); /* renvoie STATUS */
    spi_wait_idle();
    CSN_HIGH();
    return s;
}

/* Lecture burst de N octets depuis un registre (ex: TX_ADDR sur 5 octets) */
static void nrf_read_reg_n(uint8_t reg, uint8_t *buf, uint8_t len) {
    uint8_t i;
    CSN_LOW();
    (void)spi_txrx(NRF_R_REGISTER | (reg & 0x1F));
    for (i = 0; i < len; i++) buf[i] = spi_txrx(0xFF);
    spi_wait_idle();
    CSN_HIGH();
}

/* Écriture burst de N octets vers un registre (rarement utile ici, mais pratique) */
static void nrf_write_reg_n(uint8_t reg, const uint8_t *buf, uint8_t len) {
    uint8_t i;
    CSN_LOW();
    (void)spi_txrx(NRF_W_REGISTER | (reg & 0x1F));
    for (i = 0; i < len; i++) (void)spi_txrx(buf[i]);
    spi_wait_idle();
    CSN_HIGH();
}

/* Émission d’une commande simple (ex: FLUSH_RX/TX) et lecture du STATUS renvoyé */
static uint8_t nrf_cmd(uint8_t cmd) {
    uint8_t s;
    CSN_LOW();
    s = spi_txrx(cmd);
    spi_wait_idle();
    CSN_HIGH();
    return s;
}

/* --- Auto‑test enrichi --- */
static void nrf_spi_selftest(void) {
    uint8_t before, after, status;
    uint8_t txaddr[5], rx0[5];
    uint8_t rf_ch, rf_setup, fifo;

    /* petite tempo après power‑up du nRF */
    delay_cycles(50000);

    /* 1) Lecture CONFIG puis écriture/lecture de contrôle */
    before = nrf_read_reg(NRF_REG_CONFIG);
    printf("CONFIG avant = 0x%02X\r\n", before);

    CE_LOW(); /* CE bas pour config */
    nrf_write_reg(NRF_REG_CONFIG, 0x08); /* valeur « neutre »: PWR_UP=0, PRIM_RX=0, EN_CRC=1 */
    after = nrf_read_reg(NRF_REG_CONFIG);
    printf("CONFIG ecrit=0x08 -> lu = 0x%02X\r\n", after);

    nrf_write_reg(NRF_REG_CONFIG, 0x0B); /* PRIM_RX=1, PWR_UP=1, EN_CRC=1 */
    after = nrf_read_reg(NRF_REG_CONFIG);
    printf("CONFIG ecrit=0x0B -> lu = 0x%02X\r\n", after);

    /* 2) Lecture registres simples */
    rf_ch    = nrf_read_reg(NRF_REG_RF_CH);
    rf_setup = nrf_read_reg(NRF_REG_RF_SETUP);
    printf("RF_CH=0x%02X, RF_SETUP=0x%02X\r\n", rf_ch, rf_setup);

    /* 3) Lecture adresses par défaut (burst 5 octets) */
    nrf_read_reg_n(NRF_REG_TX_ADDR, txaddr, 5);
    nrf_read_reg_n(NRF_REG_RX_ADDR_P0, rx0, 5);
    printf("TX_ADDR = %02X %02X %02X %02X %02X\r\n",
           txaddr[0], txaddr[1], txaddr[2], txaddr[3], txaddr[4]);
    printf("RX0_ADDR= %02X %02X %02X %02X %02X\r\n",
           rx0[0], rx0[1], rx0[2], rx0[3], rx0[4]);

    /* 4) Nettoyage IRQ + flush FIFOs pour partir propre */
    status = nrf_read_status();
    printf("STATUS avant clear = 0x%02X\r\n", status);
    nrf_write_reg(NRF_REG_STATUS, 0x70); /* clear RX_DR, TX_DS, MAX_RT */
    status = nrf_read_status();
    printf("STATUS apres clear = 0x%02X\r\n", status);

    (void)nrf_cmd(NRF_CMD_FLUSH_RX);
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);
    fifo = nrf_read_reg(NRF_REG_FIFO_STATUS);
    printf("FIFO_STATUS = 0x%02X\r\n", fifo);

    /* 5) Exemple: changer temporairement RF_CH puis restaurer */
    nrf_write_reg(NRF_REG_RF_CH, rf_ch ^ 0x01); /* toggle bit0 juste pour voir */
    printf("RF_CH modifie = 0x%02X\r\n", nrf_read_reg(NRF_REG_RF_CH));
    nrf_write_reg(NRF_REG_RF_CH, rf_ch);
    printf("RF_CH restore = 0x%02X\r\n", nrf_read_reg(NRF_REG_RF_CH));

    /* Fin des vérifs — laisser CE bas tant qu’on ne passe pas en RX/TX réel */
}

static void nrf_set_common(uint8_t rf_ch) {
    /* Largeur d'adresse 5B, canal RF, 1Mbps/0dBm (~0x06) ou laisse 0x0F si 2Mbps */
    nrf_write_reg(NRF_REG_SETUP_AW, 0x03);  /* 5 bytes */
    nrf_write_reg(NRF_REG_RF_CH, rf_ch);    /* 0x02 chez toi */
    nrf_write_reg(NRF_REG_RF_SETUP, 0x06);  /* optionnel: 1Mbps, 0dBm */
    /* RX/TX addr identiques pour pipe0 (auto-ack) */
    nrf_write_reg_n(NRF_REG_TX_ADDR, ADDR_NODE1, 5);
    nrf_write_reg_n(NRF_REG_RX_ADDR_P0, ADDR_NODE1, 5);
    /* Nettoie IRQ & FIFOs */
    nrf_write_reg(NRF_REG_STATUS, 0x70);
    (void)nrf_cmd(NRF_CMD_FLUSH_RX);
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);
    delay_ms(5);
}

/* --- Mettre le nRF en mode TX, sans auto-ack --- */
static void nrf_set_tx_mode_noack(void) {
    nrf_set_common(RF_CHAN);
    nrf_write_reg(NRF_REG_EN_AA,      0x00); // pas d’ACK
    nrf_write_reg(NRF_REG_EN_RXADDR,  0x01); // pipe0 actif (ne gêne pas)
    nrf_write_reg(NRF_REG_SETUP_RETR, 0x00); // pas de retries
    nrf_write_reg(NRF_REG_CONFIG,     0x0C); // PWR_UP=1, PRIM_RX=0, CRC16
    delay_ms(5);                               /* tpd2stby ~1.5ms */
}

static uint8_t nrf_tx_noack(const uint8_t *data, uint8_t len){
    nrf_write_reg(NRF_REG_STATUS, 0x70);
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);

    CSN_LOW(); (void)spi_txrx(NRF_W_TX_PAYLOAD);
    for(uint8_t i=0;i<32;i++) (void)spi_txrx((i<len)?data[i]:0);
    spi_wait_idle(); CSN_HIGH();

    CE_HIGH(); delay_cycles(640); CE_LOW(); // ~40 µs

    // En no-ack, TX_DS doit se lever quand la trame est émise
    uint32_t guard=0;
    while(1){
        uint8_t s = nrf_read_status();
        if (s & (1<<TX_DS)) { nrf_write_reg(NRF_REG_STATUS,(1<<TX_DS)); return 1; }
        if (++guard > 1000000UL) { return 0; } // time-out soft
    }
}

/* --- Ecrit un payload dans TX FIFO et émet (CE pulse >10us) --- */
static void nrf_tx_payload(const uint8_t *data) {
    uint8_t i;

    /* Clear flags éventuels (RX_DR, TX_DS, MAX_RT) */
    nrf_write_reg(NRF_REG_STATUS, 0x70);

    /* Charger le payload */
    CSN_LOW();
    (void)spi_txrx(NRF_W_TX_PAYLOAD);
    for (i = 0; i < PAYLOAD_LEN; i++) (void)spi_txrx(data[i]);
    spi_wait_idle();
    CSN_HIGH();

    /* Pulse CE pour lancer l’émission (>=10 µs) */
    CE_HIGH();
    delay_cycles(400);   /* ~quelques µs @16 MHz; augmente si besoin */
    CE_LOW();

    /* Attendre la fin: simple tempo (ou bien tu peux poller STATUS) */
    delay_ms(2);
}

static void dump_config_addrs(void) {
    uint8_t cfg;
    uint8_t txaddr[5], rx0addr[5];

    // Lire CONFIG (registre 0x00)
    cfg = nrf_read_reg(NRF_REG_CONFIG);
    printf("CONFIG = 0x%02X\r\n", cfg);

    // Lire TX_ADDR (registre 0x10, 5 octets)
    nrf_read_reg_n(NRF_REG_TX_ADDR, txaddr, 5);
    printf("TX_ADDR = %02X %02X %02X %02X %02X\r\n",
           txaddr[0], txaddr[1], txaddr[2], txaddr[3], txaddr[4]);

    // Lire RX_ADDR_P0 (registre 0x0A, 5 octets)
    nrf_read_reg_n(NRF_REG_RX_ADDR_P0, rx0addr, 5);
    printf("RX_ADDR_P0 = %02X %02X %02X %02X %02X\r\n",
           rx0addr[0], rx0addr[1], rx0addr[2], rx0addr[3], rx0addr[4]);
}

/* --- Petit helper pour afficher l’état TX --- */
static void nrf_dump_tx_state(void) {
    uint8_t status = nrf_read_status();
    uint8_t obs    = nrf_read_reg(NRF_REG_OBSERVE_TX);
    uint8_t fifo   = nrf_read_reg(NRF_REG_FIFO_STATUS);
    printf("STATUS=0x%02X OBSERVE_TX=0x%02X FIFO_STATUS=0x%02X\r\n", status, obs, fifo);
}

/* --- Démo: envoi d’un payload 5 octets “HELLO” --- */
static void nrf_tx_smoketest(void) {
    static const uint8_t msg[] = { 'H','E','L','L','O' };

    printf("== TX smoketest no-ack ==\r\n");
    nrf_set_tx_mode_noack(); /* ton canal actuel */

    /* vider le TX FIFO au cas où */
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);

    nrf_dump_tx_state();
    nrf_tx_payload(msg);
    nrf_dump_tx_state();

    /* Nettoyage flags & FIFO pour revenir propre */
    nrf_write_reg(NRF_REG_STATUS, 0x70);
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);
    nrf_dump_tx_state();
}


/* ------- Récepteur (PRX) ------- */
static void nrf_prx_start(uint8_t payload_len) {
    nrf_set_common(RF_CHAN);
    nrf_write_reg(NRF_REG_EN_RXADDR, 0x01);    /* pipe0 active */
    nrf_write_reg(NRF_REG_EN_AA,     0x01);    /* auto-ack pipe0 */
    nrf_write_reg(NRF_REG_RX_PW_P0,  payload_len); /* taille fixe */
    nrf_write_reg(NRF_REG_SETUP_RETR,0x5F);    /* Retries: 1.25 ms, 15 tentatives */
    /* CONFIG: PWR_UP=1, PRIM_RX=1, EN_CRC=1 (1 byte) => 0x0B */
    nrf_write_reg(NRF_REG_CONFIG, 0x0B);
    delay_ms(2);        /* tpd2stby */
    CE_HIGH();          /* entrer en RX */
}

static uint8_t nrf_rx_payload(uint8_t *buf, uint8_t maxlen) {
    uint8_t s = nrf_read_status();
    if (!(s & (1<<RX_DR))) return 0;  /* rien à lire */
    CSN_LOW();
    (void)spi_txrx(NRF_R_RX_PAYLOAD);
    for (uint8_t i=0;i<maxlen;i++) buf[i]=spi_txrx(0xFF);
    spi_wait_idle();
    CSN_HIGH();
    nrf_write_reg(NRF_REG_STATUS, (1<<RX_DR)); /* clear RX_DR */
    return maxlen;
}

/* ------- Émetteur (PTX) ------- */
static void nrf_ptx_start(void) {
    nrf_set_common(RF_CHAN);
    nrf_write_reg(NRF_REG_EN_AA,     0x01);    /* auto-ack sur pipe0 */
     nrf_write_reg(NRF_REG_EN_RXADDR,  0x01);  // pipe0 actif
    nrf_write_reg(NRF_REG_SETUP_RETR,0x5F);    // delay=1.25ms, count=15
     // CRC 16 bits + PWR_UP + PRIM_RX=0 -> 0x0C
    nrf_write_reg(NRF_REG_CONFIG, 0x0C);
    delay_ms(5);
}
/*
static uint8_t nrf_ptx_send(const uint8_t *data, uint8_t len) {
    uint32_t guard=0;

    // purge & clear flags 
    nrf_write_reg(NRF_REG_STATUS, 0x70);
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);

    // charge payload 
    CSN_LOW();
    (void)spi_txrx(NRF_W_TX_PAYLOAD);
    for (uint8_t i=0;i<len;i++) (void)spi_txrx(data[i]);
    spi_wait_idle();
    CSN_HIGH();

    // lancer TX 
    CE_HIGH(); delay_cycles(500); CE_LOW();

    // attendre TX_DS ou MAX_RT (polling simple)
    while (1) {
        uint8_t s = nrf_read_status();
        if (s & (1<<TX_DS)) { nrf_write_reg(NRF_REG_STATUS, (1<<TX_DS)); return 1; }
        if (s & (1<<MAX_RT)){ nrf_write_reg(NRF_REG_STATUS, (1<<MAX_RT)); (void)nrf_cmd(NRF_CMD_FLUSH_TX); return 0; }
        if (++guard > 500000UL) { // timeout brut 
            (void)nrf_cmd(NRF_CMD_FLUSH_TX);
            return 0;
        }
    }
}
*/
static uint8_t nrf_ptx_send(const uint8_t *data, uint8_t len) {
    // 1) Clear & purge
    nrf_write_reg(NRF_REG_STATUS, 0x70);
    (void)nrf_cmd(NRF_CMD_FLUSH_TX);

    // 2) Charger exactement 32 octets (padding)
    CSN_LOW();
    (void)spi_txrx(NRF_W_TX_PAYLOAD);
    for (uint8_t i = 0; i < 32; i++) {
        (void)spi_txrx((i < len) ? data[i] : 0x00);
    }
    spi_wait_idle();
    CSN_HIGH();

    // Vérif FIFO pas vide
    if ( (nrf_read_reg(NRF_REG_FIFO_STATUS) & 0x10) ) { // TX_EMPTY bit4
        printf("Warn: TX FIFO vide après chargement\r\n");
    }

    // 3) Pulse CE >=10 µs (prends de la marge)
    CE_HIGH();
    delay_cycles(640);   // ≈ 40 µs @16 MHz
    CE_LOW();

    // 4) Attendre issue
    uint32_t guard = 0;
    while (1) {
        uint8_t s = nrf_read_status();
        if (s & (1<<TX_DS)) {
            nrf_write_reg(NRF_REG_STATUS, (1<<TX_DS));
            return 1;
        }
        if (s & (1<<MAX_RT)) {
            nrf_write_reg(NRF_REG_STATUS, (1<<MAX_RT));
            (void)nrf_cmd(NRF_CMD_FLUSH_TX);
            return 0;
        }
        if (++guard > 1000000UL) { // ~time-out soft
            (void)nrf_cmd(NRF_CMD_FLUSH_TX);
            return 0;
        }
    }
}

static void dump_tx_regs(void){
    uint8_t enaa    = nrf_read_reg(NRF_REG_EN_AA);
    uint8_t enrx    = nrf_read_reg(NRF_REG_EN_RXADDR);
    uint8_t retr    = nrf_read_reg(NRF_REG_SETUP_RETR);
    uint8_t rfch    = nrf_read_reg(NRF_REG_RF_CH);
    uint8_t rfsetup = nrf_read_reg(NRF_REG_RF_SETUP);
    printf("EN_AA=0x%02X EN_RXADDR=0x%02X SETUP_RETR=0x%02X RF_CH=0x%02X RF_SETUP=0x%02X\r\n",
           enaa, enrx, retr, rfch, rfsetup);
}


/* ------- Démo haut-niveau ------- */
/* Compile l’émetteur avec -DROLE_PTX ; le récepteur sans cette macro */
static void nrf_demo_pingpong(void) {
#ifdef ROLE_PTX
    static const uint8_t msg[] = {'H','E','L','L','O'};
    //nrf_ptx_start();
    nrf_set_tx_mode_noack();
    dump_tx_regs();
    printf("PTX: envoi...\r\n");
    dump_config_addrs();
    for (;;) {
        //uint8_t ok = nrf_ptx_send(msg, sizeof(msg));
        //uint8_t st = nrf_read_status();
        //uint8_t obs = nrf_read_reg(NRF_REG_OBSERVE_TX);
        //uint8_t fs  = nrf_read_reg(NRF_REG_FIFO_STATUS);
        //printf("PTX: %s, OBS=0x%02X FIFO=0x%02X\r\n", ok?"ACK":"MAX_RT/Timeout", obs, fs);
        //printf("STATUS=0x%02X OBS=0x%02X FIFO=0x%02X\r\n", st, obs, fs);
        uint8_t ok = nrf_tx_noack(msg, sizeof(msg));
        uint8_t st = nrf_read_status();
        uint8_t obs = nrf_read_reg(NRF_REG_OBSERVE_TX);
        uint8_t fs  = nrf_read_reg(NRF_REG_FIFO_STATUS);
        printf("NOACK: %s STATUS=0x%02X OBS=0x%02X FIFO=0x%02X\r\n", ok?"TX_DS":"timeout", st, obs, fs);
        delay_ms(500);
    }
#else
    uint8_t buf[5];
    nrf_prx_start(PAYLOAD_LEN);
    printf("PRX: en ecoute...\r\n");
    for (;;) {
        if (nrf_rx_payload(buf, sizeof(buf))) {
            uint8_t fs = nrf_read_reg(NRF_REG_FIFO_STATUS);
            printf("PRX: recu [%02X %02X %02X %02X %02X] FIFO=0x%02X\r\n",
                   buf[0],buf[1],buf[2],buf[3],buf[4], fs);
        }
    }
#endif
}

static uint8_t nrf_status_raw(void){
    uint8_t s;
    CSN_LOW(); delay_cycles(200);
    s = spi_txrx(NRF_NOP);
    spi_wait_idle();
    delay_cycles(200);
    CSN_HIGH();
    return s;
}

static int nrf_bus_ok(void){
    uint8_t s = nrf_status_raw();
    if (s == 0xFF || s == 0x00) return 0;  // 0xFF -> MISO en l’air, 0x00 -> tiré bas
    return 1;
}

/* ============================================================
 * === main() : conserve ton init UART puis lance le test   ===
 * ============================================================
 */
void main(void) {
    /* Si ton code UART original configure déjà l’horloge, garde-le. */
    uart_config(); /* Appel à TON init UART */

    printf("\r\n[STM8S] Test SPI nRF24L01\r\n");

    gpio_init_spi();
    spi_init();
    if (!nrf_bus_ok()) {
        printf("SPI KO: STATUS=0x%02X (verifie CSN/SCK/MOSI/MISO/VCC)\r\n", nrf_status_raw());
        while(1);
    }
    nrf_demo_pingpong();

    /* Boucle d’écho UART simple (optionnel) */
    for (;;) {
        uint8_t c = uart_read();   /* depuis TON UART */
        printf("Echo: %c\r\n", c);
    }
}
