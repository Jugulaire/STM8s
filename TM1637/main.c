// Test de base pour afficher des chiffres sur l'écran 

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


// == Fonction de timmimg 
void delay_us(uint16_t us) {
    while(us--) {
        __asm__("nop"); __asm__("nop"); __asm__("nop");
        __asm__("nop"); __asm__("nop"); __asm__("nop");
    }
}

void delay_ms(uint16_t ms) {
    uint32_t i;
    for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
        __asm__("nop");
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
        // Init ports
    PA_DDR |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // CLK & DIO en sortie
    PA_CR1 |= (1 << TM_CLK_PIN) | (1 << TM_DIO_PIN); // Push-pull

    // === Boucle principale ===
    while (1) {
        tm_display_temp_x100(1337);
        delay_ms(1000);
    }
}