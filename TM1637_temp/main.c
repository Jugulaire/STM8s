// Code permettant de lire la valeur de température dans un DS18b20 
// et de l'afficher sur un afficheur 7 segment TM1637

#include "../stm8s.h"
#include <stdio.h>

#define F_CPU 16000000UL
#define BAUDRATE 9600

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


// === Table de conversion chiffre vers segments
const uint8_t digit_to_segment[10] = {
    0b00111111, // 0
    0b00000110, // 1
    0b01011011, // 2
    0b01001111, // 3
    0b01100110, // 4
    0b01101101, // 5
    0b01111101, // 6
    0b00000111, // 7
    0b01111111, // 8
    0b01101111  // 9
};

// === Fonctions bas niveau TM1637 ===
void tm_delay() {
    for (volatile int i = 0; i < 50; i++) __asm__("nop");
}

void tm_start() {
    TM_DIO_DDR |= (1 << TM_DIO_PIN);
    TM_CLK_DDR |= (1 << TM_CLK_PIN);
    TM_DIO_PORT |= (1 << TM_DIO_PIN);
    TM_CLK_PORT |= (1 << TM_CLK_PIN);
    tm_delay();
    TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
    tm_delay();
    TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
}

void tm_stop() {
    TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
    TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
    tm_delay();
    TM_CLK_PORT |= (1 << TM_CLK_PIN);
    tm_delay();
    TM_DIO_PORT |= (1 << TM_DIO_PIN);
}

void tm_write_byte(uint8_t b) {
    for (uint8_t i = 0; i < 8; i++) {
        TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
        if (b & 0x01)
            TM_DIO_PORT |= (1 << TM_DIO_PIN);
        else
            TM_DIO_PORT &= ~(1 << TM_DIO_PIN);
        tm_delay();
        TM_CLK_PORT |= (1 << TM_CLK_PIN);
        tm_delay();
        b >>= 1;
    }

    // Acquittement (on ignore ici)
    TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
    TM_DIO_DDR &= ~(1 << TM_DIO_PIN); // entrée
    tm_delay();
    TM_CLK_PORT |= (1 << TM_CLK_PIN);
    tm_delay();
    TM_CLK_PORT &= ~(1 << TM_CLK_PIN);
    TM_DIO_DDR |= (1 << TM_DIO_PIN); // repasse en sortie
}

// === Fonction de mise à jour de l'afficheur ===
void tm_set_segments(uint8_t *segments, uint8_t length) {
    tm_start();
    tm_write_byte(0x40); // Commande : auto-increment mode
    tm_stop();

    tm_start();
    tm_write_byte(0xC0); // Adresse de départ = 0
    for (uint8_t i = 0; i < length; i++) {
        tm_write_byte(segments[i]);
    }
    tm_stop();

    tm_start();
    tm_write_byte(0x88 | 0x07); // Affichage ON, luminosité max (0x00 à 0x07)
    tm_stop();
}

// == Fonction qui affiche la température sous la forme d'une valeur x100 (1337 = 13,37)
void tm_display_temp_x100(int temp_x100) {
    int val = temp_x100;
    if (val < 0) val = -val;  // Ignore le signe ici (optionnel à améliorer)

    uint8_t digits[4];

    for (int i = 3; i >= 0; i--) {
        digits[i] = digit_to_segment[val % 10];
        val /= 10;
    }

    // Active le point décimal entre le 2e et 3e chiffre
    digits[1] |= 0x80;

    tm_set_segments(digits, 4);
}


void main() {

    CLK_CKDIVR = 0x00; // forcer la frequence CPU

    // Init ports afficheur 
    PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
    PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull
    // Configuration de la broche PD3 (déjà manipulée par les macros 1-Wire)
    PD_DDR &= ~(1 << 3);    // PD3 en entrée
    PD_CR1 |= (1 << 3);     // Pull-up interne activée (optionnel)

    // === Boucle principale ===
    while (1) {
        ds18b20_start_conversion(); // Démarre une conversion de température
        delay_ms(750);              // Attente obligatoire (750 ms pour 12 bits)

        int16_t raw = ds18b20_read_raw(); // Lecture de la température brute (x16)
        
        // Conversion sans float : (valeur x 0.0625 * 100) = (valeur * 625 / 10000)
        int16_t temp_x100 = (raw * 625UL) / 100; // Résultat en °C * 100

        // Affiche formaté : ex. 2437 => 24.37 °C
        tm_display_temp_x100(temp_x100);

        delay_ms(1000); // Pause entre chaque mesure
    }
}