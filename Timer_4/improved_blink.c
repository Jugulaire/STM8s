#include <stdint.h>
#include "stm8s.h"

#define OUTPUT_PIN      3

volatile uint16_t tick_counter = 0;

void timer_isr() __interrupt(TIM4_ISR) {
    TIM4_SR &= ~(1 << TIM4_SR_UIF);  // Clear interrupt flag

    tick_counter++;

    if (tick_counter >= 100) {       // 100 * 5ms = 500ms
        PD_ODR ^= (1 << OUTPUT_PIN); // Toggle LED
        tick_counter = 0;
    }
}

void main() {
    CLK_CKDIVR = 0x18;               // Set clock to 2 MHz
    enable_interrupts();

    PD_DDR |= (1 << OUTPUT_PIN);     // PD3 output
    PD_CR1 |= (1 << OUTPUT_PIN);     // Push-pull

    TIM4_PSCR = 0b00000111;          // Prescaler = 128
    TIM4_ARR = 77;                   // (77+1) * 64us ≈ 5ms
    TIM4_IER |= (1 << TIM4_IER_UIE); // Enable overflow interrupt
    TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Start timer

    while (1) {
        // Main loop empty: everything done in ISR
    }
}

