#include "../stm8s.h"       // Définition des registres STM8S103F3P6
#include <stdio.h>          // Pour printf
#define F_CPU 16000000UL    // Fréquence CPU = 16 MHz
#define BAUDRATE 9600       // Baudrate UART

// === Définition de la pin DATA du capteur DS18B20 ===
#define DS_PIN 3            // Le capteur est connecté sur PD3

// === Macros bas-niveau pour manipuler la pin PD3 en mode 1-Wire ===
#define DS_LOW()    (PD_ODR &= ~(1 << DS_PIN))           // Force PD3 à 0V (sortie basse)
#define DS_HIGH()   (PD_ODR |=  (1 << DS_PIN))           // Force PD3 à 1 (sortie haute)
#define DS_INPUT()  (PD_DDR &= ~(1 << DS_PIN))           // Configure PD3 en entrée
#define DS_OUTPUT() (PD_DDR |=  (1 << DS_PIN))           // Configure PD3 en sortie
#define DS_READ()   (PD_IDR & (1 << DS_PIN))             // Lit l'état logique de PD3 (1 ou 0)

// === Configuration UART1 pour communication série ===
void uart_config() {
    CLK_CKDIVR = 0x00; // Horloge non divisée (reste à 16 MHz)

    uint16_t usartdiv = (F_CPU + BAUDRATE / 2) / BAUDRATE; // Calcul du diviseur baudrate

    // Configuration des registres BRR1 et BRR2 selon STM8 datasheet
    uint8_t brr1 = (usartdiv >> 4) & 0xFF;
    uint8_t brr2 = ((usartdiv & 0x0F)) | ((usartdiv >> 8) & 0xF0);

    UART1_BRR1 = brr1;
    UART1_BRR2 = brr2;

    UART1_CR1 = 0x00; // Pas de parité, 8 bits de données
    UART1_CR3 = 0x00; // 1 bit de stop
    UART1_CR2 = (1 << UART1_CR2_TEN) | (1 << UART1_CR2_REN); // Active TX et RX

    // Vide les registres pour éviter des erreurs
    (void)UART1_SR;
    (void)UART1_DR;
}

// Émission UART d'un octet
void uart_write(uint8_t data) {
    UART1_DR = data;                    // Envoie l'octet
    PB_ODR &= ~(1 << 5);                // Éteint une LED (facultatif pour debug)
    while (!(UART1_SR & (1 << UART1_SR_TC))); // Attente que la transmission soit terminée
    PB_ODR |= (1 << 5);                 // Allume la LED (facultatif)
}

// Réception UART bloquante
uint8_t uart_read() {
    while (!(UART1_SR & (1 << UART1_SR_RXNE))); // Attente réception
    return UART1_DR;
}

// Redirection de printf() vers UART
int putchar(int c) {
    uart_write(c);
    return 0;
}

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

// === Fonction principale ===
void main() {

    uart_config();   // Initialise l'UART (9600 bauds sur UART1)
    
    // Configuration de la broche PD3 (déjà manipulée par les macros 1-Wire)
    PD_DDR &= ~(1 << 3);    // PD3 en entrée
    PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)

    while (1) {
        ds18b20_start_conversion(); // Démarre une conversion de température
        delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)

        int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
        
        // Conversion sans float : (valeur x 0.0625 * 100) = (valeur * 625 / 10000)
        int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100

        // Affiche formaté : ex. 2437 => 24.37 °C
        printf("Température : %d.%02d °C\r\n", temp_x100 / 100, temp_x100 % 100);

        delay_ms(1000); // Pause entre chaque mesure
    }
}