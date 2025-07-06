#include "../stm8s.h"
#include <stdio.h>
#define F_CPU 16000000UL //16MHz

volatile uint32_t last_press_time = 0; //debounce interruption

static inline void delay_ms(uint16_t ms) {
    uint32_t i;
    for (i = 0; i < ((F_CPU / 18000UL) * ms); i++)
        __asm__("nop");
}

void button_handler(void) __interrupt(3) {
    static uint32_t now = 0;
    now += 1;  // Incrémente à chaque IT, ou via timer en fond si dispo
    delay_ms(5); // timer pour un filtre anti rebond
    if ((now - last_press_time) > 1) {  // 1 "ticks" d'écart
        if (!(PA_IDR & (1 << 3))) {
            PD_ODR ^= (1 << 3);
            last_press_time = now;
        }
    }
}

void main() {

    // LED sur PD3
    PD_DDR |= (1 << 3);
    PD_CR1 |= (1 << 3);
    PD_ODR &= ~(1 << 3);  // LED éteinte

    // Bouton sur PA3
    PA_DDR &= ~(1 << 3);   // Entrée
    PA_CR1 |= (1 << 3);    // Pull-up
    PA_CR2 |= (1 << 3);    // Active interruption pour PA3

    // Interruption sur front descendant (EXTI3)
    EXTI_CR1 &= ~(0b11 << 0);   // Efface les bits PAIS[1:0]
    EXTI_CR1 |=  (0b10 << 0);   // Met 10 = front descendant

    __asm__("rim");  // Active les interruptions globales
    while (1);  // Boucle vide, tout est géré par interruption
    
}