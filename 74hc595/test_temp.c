#include "../stm8s.h"
#include <stdint.h>
#include <stdio.h>

#define F_CPU 16000000UL    // Fréquence CPU = 16 MHz
#define BAUDRATE 9600       // Baudrate UART

// === Définition des GPIOs pour le 74HC595 ===
#define DATA_PIN    PC_ODR, 3  // DS (Pin 14)
#define CLOCK_PIN   PC_ODR, 4  // SH_CP (Pin 11)
#define LATCH_PIN   PC_ODR, 5  // ST_CP (Pin 12)

// === Définition de la pin DATA du capteur DS18B20 ===
#define DS_PIN 3            // Le capteur est connecté sur PD3

// === Macros bas-niveau pour manipuler la pin PD3 en mode 1-Wire ===
#define DS_LOW()    (PD_ODR &= ~(1 << DS_PIN))           // Force PD3 à 0V (sortie basse)
#define DS_HIGH()   (PD_ODR |=  (1 << DS_PIN))           // Force PD3 à 1 (sortie haute)
#define DS_INPUT()  (PD_DDR &= ~(1 << DS_PIN))           // Configure PD3 en entrée
#define DS_OUTPUT() (PD_DDR |=  (1 << DS_PIN))           // Configure PD3 en sortie
#define DS_READ()   (PD_IDR & (1 << DS_PIN))             // Lit l'état logique de PD3 (1 ou 0)

volatile uint8_t digits[4] = {0, 0, 0, 0}; //stocke les valeurs des digit 


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

// === Table des segments pour les chiffres 0–9 ===
// Format: 0bDP-G-F-E-D-C-B-A
const uint8_t digit_segments[10] = {
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

// === SPI software (bit-banging) vers 74HC595 ===
void shift_out(uint8_t val) {
    for (uint8_t i = 0; i < 8; i++) {
        if (val & 0x80) PC_ODR |= (1 << 3);   // DATA HIGH
        else            PC_ODR &= ~(1 << 3);  // DATA LOW

        PC_ODR |= (1 << 4);  // CLOCK HIGH
        PC_ODR &= ~(1 << 4); // CLOCK LOW

        val <<= 1;
    }
}

void latch() {
    PC_ODR |= (1 << 5);  // LATCH HIGH
    PC_ODR &= ~(1 << 5); // LATCH LOW
}

// === Contrôle des digits (anode commune) ===
void disable_all_digits() {
    // METTRE LES DIGITS À HIGH pour les désactiver (cathode commune)
    PA_ODR |= (1 << 1); // D3
    PA_ODR |= (1 << 2); // D1
    PA_ODR |= (1 << 3); // D4
    PD_ODR |= (1 << 4); // D2
}

void display_digit(uint8_t value, uint8_t pos) {
    // Désactiver tous les digits (cathode commune → HIGH = OFF)
    PA_ODR |= (1 << 1); // D3
    PA_ODR |= (1 << 2); // D1
    PA_ODR |= (1 << 3); // D4
    PD_ODR |= (1 << 4); // D2

    // Envoyer segments
    shift_out(digit_segments[value]);
    latch();

    // Activer le bon digit (LOW = ON)
    // Correction pour inversion d'afficheur (afficheur monté à l'envers)
    switch (pos) {
        case 0: PA_ODR &= ~(1 << 3); break; // D4 → gauche
        case 1: PA_ODR &= ~(1 << 1); break; // D3
        case 2: PD_ODR &= ~(1 << 4); break; // D2
        case 3: PA_ODR &= ~(1 << 2); break; // D1 → droite
    }

}

void delay_us(uint16_t us) {
    while(us--) {
        __asm__("nop"); __asm__("nop"); __asm__("nop");
        __asm__("nop"); __asm__("nop"); __asm__("nop");
    }
}

// === Petite pause ===
void delay_ms(uint16_t ms) {
    for (uint16_t i = 0; i < ms; i++) {
        for (volatile uint16_t j = 0; j < 1000; j++)
            __asm__("nop");
    }
}

// === Setup STM8 ===
void setup() {
    // Segments: PC3, PC4, PC5
    PC_DDR |= (1 << 3) | (1 << 4) | (1 << 5);
    PC_CR1 |= (1 << 3) | (1 << 4) | (1 << 5);

    // Digits: PA1, PA2, PA3
    PA_DDR |= (1 << 1) | (1 << 2) | (1 << 3);
    PA_CR1 |= (1 << 1) | (1 << 2) | (1 << 3);

    // Digit: PD4
    PD_DDR |= (1 << 4);
    PD_CR1 |= (1 << 4);
}

void display_float(float value) {
    if (value < 0 || value >= 100) return; // Ne supporte que 00.00 à 99.99

    uint16_t scaled = (uint16_t)(value * 100); // Ex: 34.56 → 3456

    uint8_t digits[4];
    digits[0] = (scaled / 1000) % 10;
    digits[1] = (scaled / 100) % 10;
    digits[2] = (scaled / 10) % 10;
    digits[3] = scaled % 10;

    for (uint8_t i = 0; i < 4; i++) {
        uint8_t seg = digit_segments[digits[i]];

        // Active le point décimal sur le digit 1 (entre 4 et 5)
        if (i == 1) seg |= 0x80;

        disable_all_digits();
        shift_out(seg);
        latch();

        // Activer le bon digit (cathode commune → LOW = ON)
        switch (i) {
            case 0: PA_ODR &= ~(1 << 3); break; // D4 (pos 0)
            case 1: PA_ODR &= ~(1 << 1); break; // D3
            case 2: PD_ODR &= ~(1 << 4); break; // D2
            case 3: PA_ODR &= ~(1 << 2); break; // D1
        }

        // Augmenter la durée pour les digits sombres
        if (i == 1 || i == 3) delay_us(800); // digits 0 et 1 = 1ms
        else                  delay_us(400);  // autres = 0.7ms 
    }

}

void display_int(uint16_t temp_x100) {
    // Limite à 0–9999
    if (temp_x100 > 9999) temp_x100 = 9999;

    // Extraction des chiffres
    uint8_t d0 = (temp_x100 / 1000) % 10;
    uint8_t d1 = (temp_x100 / 100) % 10;
    uint8_t d2 = (temp_x100 / 10) % 10;
    uint8_t d3 = temp_x100 % 10;

    uint8_t digits[4] = { d0, d1, d2, d3 };

    for (uint8_t i = 0; i < 4; i++) {
        uint8_t seg = digit_segments[digits[i]];

        // Ajout du point décimal sur le 2e chiffre (d1)
        if (i == 1) seg |= 0x80;

        disable_all_digits();
        shift_out(seg);
        latch();

        // Allume le digit actif
        switch (i) {
            case 0: PA_ODR &= ~(1 << 3); break; // D4
            case 1: PA_ODR &= ~(1 << 1); break; // D3
            case 2: PD_ODR &= ~(1 << 4); break; // D2
            case 3: PA_ODR &= ~(1 << 2); break; // D1
        }

        // PWM de luminosité
        if (i == 1 || i == 3) delay_us(800);
        else                  delay_us(400);
    }
}

void display_step() {
    static uint8_t pos = 0;

    disable_all_digits();

    uint8_t seg = digit_segments[digits[pos]];

    // Allume le point décimal sur le 2e chiffre (entre 2e et 3e)
    if (pos == 1) seg |= 0x80;

    shift_out(seg);
    latch();

    // Active le bon digit
    switch (pos) {
        case 0: PA_ODR &= ~(1 << 3); break; // D4
        case 1: PA_ODR &= ~(1 << 1); break; // D3
        case 2: PD_ODR &= ~(1 << 4); break; // D2
        case 3: PA_ODR &= ~(1 << 2); break; // D1
    }

    pos = (pos + 1) % 4; // Passe au digit suivant à chaque appel
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

// === Programme principal ===
void main() {
    setup();
    uart_config();

    PD_DDR &= ~(1 << 3);
    PD_CR1 |= (1 << 3);

    uint16_t temp_x100 = 2430; // Valeur de départ par défaut
    uint16_t counter = 0;

    ds18b20_start_conversion(); // Démarre première conversion

    while (1) {
        // Affichage constant
        display_int(temp_x100);

        delay_ms(5); // assez long pour multiplexage stable

        counter += 5;
        if (counter >= 750) {
            counter = 0;

            // Lire température
            int16_t raw = ds18b20_read_raw();
            temp_x100 = (raw * 625UL) / 100;

            // Lancer conversion suivante
            ds18b20_start_conversion();
        }
    }
}


