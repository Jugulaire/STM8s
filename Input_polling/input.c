#include "../stm8s.h"           // Inclusion au STM8S
#define F_CPU 16000000UL        // Définition de la fréquence CPU à 16 MHz

// Fonction de délai (bloquante) pour simuler delay_ms
static inline void delay_ms(uint16_t ms) {
    uint32_t i;
    for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
        __asm__("nop");         // Instruction vide pour consommer du temps
}

// Fonction de détection d'appui sur un bouton avec anti-rebond
int8_t button_pressed(volatile uint8_t* idr, uint8_t pin) {
    static uint8_t last_state[8] = {0x00};  // Mémorise les derniers états (1 = repos, car pull-up active)
    uint8_t current_state = *idr & (1 << pin);  // Lecture du bit correspondant au bouton

    // Si changement détecté (rebond ou appui réel)
    if (current_state != (last_state[pin] & (1 << pin))) {
        delay_ms(5);  // Pause pour laisser passer les rebonds
        current_state = *idr & (1 << pin);  // Relire après stabilisation

        // Si l’état est toujours différent après le délai
        if (current_state != (last_state[pin] & (1 << pin))) {
            last_state[pin] = *idr;         // Mémoriser le nouvel état
            if (!(current_state)) {         // Si le niveau est bas (appui)
                return 1;                   // Retourner 1 : bouton pressé
            }
        }
    }

    return 0;  // Aucun appui détecté
}

void main() {
    // --- Configuration de la LED sur PD3 ---
    PD_DDR |= (1 << 3);      // Direction : sortie
    PD_CR1 |= (1 << 3);      // Sortie push-pull

    // --- Configuration du bouton sur PA3 ---
    PA_DDR &= ~(1 << 3);    // PA3 en entrée
    PA_CR1 |= (1 << 3);     // Pull-up interne activée

    // --- Boucle principale ---
    while (1) {
        if (button_pressed(&PA_IDR, 3)) {   // Si le bouton est pressé (PA3 à 0)
            PD_ODR ^= (1 << 3);             // Inverser l’état de la LED sur PB5
        }
    }
}