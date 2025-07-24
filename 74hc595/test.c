#include "../stm8s.h"
#include <stdint.h>
#include <stdio.h>

void delay_ms(uint16_t ms) {
    for (uint16_t i = 0; i < ms * 1000; i++)
        __asm__("nop");
}

void shift_register_init(void) {
    PA_DDR |= (1 << 1) | (1 << 2) | (1 << 3);  // PA1, PA2, PA3 = output
    PA_CR1 |= (1 << 1) | (1 << 2) | (1 << 3);  // push-pull
    PA_ODR &= ~((1 << 1) | (1 << 2) | (1 << 3)); // start low
}

void shift_register_send(uint8_t segments, uint8_t digits) {
    // 1er → SEGMENTS (va au 1er 595)
    for (int8_t i = 7; i >= 0; i--) {
        if (segments & (1 << i)) PA_ODR |= (1 << 3);
        else                     PA_ODR &= ~(1 << 3);
        PA_ODR |= (1 << 1); PA_ODR &= ~(1 << 1);
    }

    // 2e → DIGITS (va au 2e 595)
    for (int8_t i = 7; i >= 0; i--) {
        if (digits & (1 << i)) PA_ODR |= (1 << 3);
        else                   PA_ODR &= ~(1 << 3);
        PA_ODR |= (1 << 1); PA_ODR &= ~(1 << 1);
    }

    // LATCH
    PA_ODR |= (1 << 2);
    PA_ODR &= ~(1 << 2);
}



void main(void) {
    shift_register_init();

    while (1) {
        shift_register_send(0b11111111, 0b11101111); // Affiche "8" sur DS4
        delay_ms(2000);
        shift_register_send(0b11111111, 0b11110111);
        delay_ms(2000);
        shift_register_send(0b11111111, 0b11111011);
        delay_ms(2000);
        shift_register_send(0b11111111, 0b11111101);
        delay_ms(2000);
        
    }
}