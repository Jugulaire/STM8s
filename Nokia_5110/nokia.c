#include "../stm8s.h"
#include "big-font.h"
#include <stdio.h>

#define F_CPU 16000000UL
#define BAUDRATE 9600

// === DS18B20 sur PB5 ===
#define DS_PIN 5
#define DS_LOW()    (PB_ODR &= ~(1 << DS_PIN))
#define DS_HIGH()   (PB_ODR |=  (1 << DS_PIN))
#define DS_INPUT()  (PB_DDR &= ~(1 << DS_PIN))  // Entrée
#define DS_OUTPUT() (PB_DDR |=  (1 << DS_PIN))  // Sortie
#define DS_READ()   (PB_IDR & (1 << DS_PIN))


// === LCD sur PC5 (CLK), PC6 (DIN), PC4 (DC), PC7 (RST), PD1 (CE) ===
#define LCD_RST_LOW()    (PC_ODR &= ~(1 << 7))
#define LCD_RST_HIGH()   (PC_ODR |=  (1 << 7))
#define LCD_CE_LOW()     (PD_ODR &= ~(1 << 1))
#define LCD_CE_HIGH()    (PD_ODR |=  (1 << 1))
#define LCD_DC_LOW()     (PC_ODR &= ~(1 << 4))
#define LCD_DC_HIGH()    (PC_ODR |=  (1 << 4))
#define LCD_CLK_LOW()    (PC_ODR &= ~(1 << 5))
#define LCD_CLK_HIGH()   (PC_ODR |=  (1 << 5))
#define LCD_DIN_LOW()    (PC_ODR &= ~(1 << 6))
#define LCD_DIN_HIGH()   (PC_ODR |=  (1 << 6))

const uint8_t* big_digits[10] = {
    big_digit_0,
    big_digit_1,
    big_digit_2,
    big_digit_3,
    big_digit_4,
    big_digit_5,
    big_digit_6,
    big_digit_7,
    big_digit_8,
    big_digit_9
};

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

// === 1-Wire Protocole (DS18B20) ===
uint8_t onewire_reset(void) {
    DS_OUTPUT(); DS_LOW();
    delay_us(480);
    DS_INPUT();
    delay_us(70);
    uint8_t presence = !DS_READ();
    delay_us(410);
    return presence;
}

void onewire_write_bit(uint8_t bit) {
    DS_OUTPUT(); DS_LOW();
    delay_us(bit ? 6 : 60);
    DS_INPUT();
    delay_us(bit ? 64 : 10);
}

uint8_t onewire_read_bit(void) {
    uint8_t bit;
    DS_OUTPUT(); DS_LOW();
    delay_us(6);
    DS_INPUT();
    delay_us(9);
    bit = (DS_READ() ? 1 : 0);
    delay_us(55);
    return bit;
}

void onewire_write_byte(uint8_t byte) {
    for (uint8_t i = 0; i < 8; i++) {
        onewire_write_bit(byte & 0x01);
        byte >>= 1;
    }
}

uint8_t onewire_read_byte(void) {
    uint8_t byte = 0;
    for (uint8_t i = 0; i < 8; i++) {
        byte >>= 1;
        if (onewire_read_bit()) byte |= 0x80;
    }
    return byte;
}

void ds18b20_start_conversion(void) {
    onewire_reset();
    onewire_write_byte(0xCC);
    onewire_write_byte(0x44);
}

int16_t ds18b20_read_raw(void) {
    onewire_reset();
    onewire_write_byte(0xCC);
    onewire_write_byte(0xBE);
    uint8_t lsb = onewire_read_byte();
    uint8_t msb = onewire_read_byte();
    return ((int16_t)msb << 8) | lsb;
}

// Envoie un octet à l'écran via SPI logiciel (bit-banging)
// Chaque bit est envoyé de MSB à LSB (bit 7 vers bit 0)
void lcd_send_byte(uint8_t data) {
    for (uint8_t i = 0; i < 8; i++) {
        if (data & 0x80) LCD_DIN_HIGH();  // Si bit courant = 1, ligne DIN à 1
        else LCD_DIN_LOW();               // Sinon ligne DIN à 0

        LCD_CLK_HIGH();  // Front montant : le LCD lit le bit ici
        LCD_CLK_LOW();   // Front descendant : prêt pour le bit suivant

        data <<= 1;  // Décale vers la gauche pour le prochain bit
    }
}


// Envoie une commande de configuration à l'écran
void lcd_write_cmd(uint8_t cmd) {
    LCD_DC_LOW();     // On sélectionne le mode "commande"
    LCD_CE_LOW();     // Active la communication avec l'écran
    lcd_send_byte(cmd); // Envoie la commande
    LCD_CE_HIGH();    // Termine la communication
}


// Envoie une donnée à afficher (pixel) à l'écran
void lcd_write_data(uint8_t data) {
    LCD_DC_HIGH();     // Mode "donnée"
    LCD_CE_LOW();      // Active la communication avec l'écran
    lcd_send_byte(data);  // Envoie la donnée (1 octet = 8 pixels verticaux)
    LCD_CE_HIGH();     // Termine la communication
}


// Initialise le LCD en mode "normal", avec configuration de contraste et orientation
void lcd_init(void) {
    // Configure les broches PC4 à PC7 comme sorties (DC, CLK, DIN, RST)
    PC_DDR |= (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7);
    PC_CR1 |= (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7);

    // Configure PD1 (CE) comme sortie
    PD_DDR |= (1 << 1);
    PD_CR1 |= (1 << 1);

    // Effectue un reset matériel de l'écran
    LCD_RST_LOW();     // Maintient RST à 0
    delay_ms(100);     // Attend 100 ms
    LCD_RST_HIGH();    // Libère RST → redémarrage du LCD

    // Séquence d'initialisation spécifique au contrôleur PCD8544 :
    lcd_write_cmd(0x21); // Mode étendu (permet config contraste, température...)
    lcd_write_cmd(0xB0); // Contraste (valeur entre 0x80 et 0xBF, à adapter si besoin)
    lcd_write_cmd(0x04); // Coefficient de température (valeur recommandée)
    lcd_write_cmd(0x14); // Biais LCD (rapport tension segments)
    lcd_write_cmd(0x20); // Retour en mode basique
    lcd_write_cmd(0x0C); // Affichage normal (pas d’inversion, pas de tout-éteint)
}


// Efface complètement l’écran (remplit tout de zéros)
void lcd_clear(void) {
    for (uint16_t i = 0; i < 504; i++) {
        lcd_write_data(0x00); // Chaque octet = 8 pixels verticaux noirs
    }
}


// Affiche un caractère 8x8 à une position (x, y) en transposant ligne en colonne
// Chaque glyphe est dans le sens "row-major" mais l’écran affiche en "colonne verticale"
void lcd_draw_8x8_char(const uint8_t* glyph, uint8_t x, uint8_t y) {
    for (uint8_t col = 0; col < 8; col++) {
        uint8_t out = 0;
        for (uint8_t row = 0; row < 8; row++) {
            if (glyph[row] & (1 << (7 - col))) {
                out |= (1 << row);  // Transpose bit : ligne → colonne
            }
        }

        // Position du curseur dans la mémoire écran :
        lcd_write_cmd(0x40 | (y / 8));   // Page Y (chaque page = 8 lignes)
        lcd_write_cmd(0x80 | (x + col)); // Colonne X + décalage actuel

        lcd_write_data(out); // Envoie 1 colonne verticale de 8 pixels
    }
}


// Affiche un petit caractère 5x8 (format standard ascii compact)
// Utilisé pour du texte plus petit
void lcd_draw_char_small(const uint8_t *data, uint8_t x, uint8_t page) {
    lcd_write_cmd(0x80 | x);           // Position horizontale (X)
    lcd_write_cmd(0x40 | page);        // Position verticale (page Y de 8 lignes)

    for (uint8_t i = 0; i < 5; i++) {
        lcd_write_data(data[i]);       // Envoie les 5 colonnes du caractère
    }
    lcd_write_data(0x00); // Ajoute un espace de 1 colonne après
}


// Affiche une température formatée (ex. "24.37°C") avec gros chiffres
void lcd_print_temperature(int16_t temp_x100, uint8_t x, uint8_t y) {
    char buf[8];

    // Convertit la température entière/fractionnaire (ex: 2437 = 24.37°C)
    int int_part = temp_x100 / 100;
    int frac_part = temp_x100 % 100;

    if (temp_x100 < 0) {
        int_part = -int_part;
        frac_part = -frac_part;
        buf[0] = '-';
        sprintf(buf + 1, "%d.%02d", int_part, frac_part);
    } else {
        sprintf(buf, "%d.%02d", int_part, frac_part);
    }

    uint8_t cursor = x; // Position de départ

    // Affiche chaque caractère de la chaîne 
    for (uint8_t i = 0; buf[i] != '\0'; i++) {
        char c = buf[i];

        if (c >= '0' && c <= '9') {
            lcd_draw_8x8_char(big_digits[c - '0'], cursor, y);
        } else if (c == '.') {
            lcd_draw_8x8_char(big_char_dot, cursor, y);
        } else if (c == '-') {
            static const uint8_t minus[8] = {
                0b00000000,
                0b00000000,
                0b00000000,
                0b11111110,
                0b11111110,
                0b00000000,
                0b00000000,
                0b00000000
            };
            lcd_draw_8x8_char(minus, cursor, y);
        }

        cursor += 8; // Avance de 8 pixels pour le prochain caractère
    }

    // Ajoute les caractères ° et C à la fin
    lcd_draw_8x8_char(big_char_deg, cursor, y);
    cursor += 8;
    lcd_draw_8x8_char(big_char_C, cursor, y);
}



// === MAIN ===
void main() {

    CLK_CKDIVR = 0x00; // forcer la frequence CPU
    // === Initialisation du capteur DS18B20 ===

    // Configure PB5 en entrée (pour lecture du capteur)
    PB_DDR &= ~(1 << DS_PIN);    // Direction = entrée
    PB_CR1 |= (1 << DS_PIN);     // Active le pull-up (résistance interne à Vcc)

    // === Initialisation de l'écran LCD ===

    lcd_init();   // Envoie la séquence d’initialisation au LCD PCD8544
    lcd_clear();  // Efface tout l’écran

    // === Boucle principale ===
    while (1) {
        // --- Étape 1 : Démarrer la conversion de température ---
        ds18b20_start_conversion(); // Envoie la commande "Convert T"
        delay_ms(750);              // Attente du temps de conversion (max 750 ms)

        // --- Étape 2 : Lire la température ---
        int16_t raw = ds18b20_read_raw(); // Lit les 16 bits bruts (valeur signée)
        
        // Conversion en centièmes de degré Celsius (0.01°C)
        // Le capteur donne 0.0625°C par LSB → ×625 puis divisé par 100
        int16_t temp_x100 = (raw * 625UL) / 100;

        // --- Étape 3 : Affichage sur l’écran ---
        lcd_print_temperature(temp_x100, 16, 16);
        // Affiche à partir de x=16 pixels, y=16 pixels (2e ligne)

        // --- Pause entre deux mesures ---
        delay_ms(1000); // Rafraîchissement toutes les secondes
    }
}
