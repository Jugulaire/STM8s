#include "../stm8s.h"
#include <stdio.h>
#define F_CPU 16000000UL //16MHz
#define BAUDRATE 9600

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


uint16_t adc_read(uint8_t channel) {
    if (channel > 7) return 0; // Sanity check

    // Sélectionner le canal souhaité
    ADC1_CSR = (ADC1_CSR & 0xF8) | (channel & 0x07);

    // Démarrer une conversion (phase 2 d'activation)
    ADC1_CR1 |= (1 << ADC1_CR1_ADON);

    // Attendre la fin de conversion
    while (!(ADC1_CSR & (1 << ADC1_CSR_EOC)));

    // Lire les données (alignement à droite)
    uint8_t adcL = ADC1_DRL;
    uint8_t adcH = ADC1_DRH;

    // Réinitialiser le flag de fin de conversion (pas strictement nécessaire ici)
    ADC1_CSR &= ~(1 << ADC1_CSR_EOC);

    return ((uint16_t)adcH << 8) | adcL;
}

void adc_init(uint8_t channel) {
    if (channel > 7) return; // Sanity check pour STM8S103

    CLK_PCKENR2 |= (1 << 3); // Activer horloge ADC1

    // Configurer le canal ADC (0–7) dans ADC1_CSR
    ADC1_CSR = (ADC1_CSR & 0xF8) | (channel & 0x07);

    // Alignement à droite des données ADC
    ADC1_CR2 |= (1 << ADC1_CR2_ALIGN);

    // Allumer l'ADC (phase 1)
    ADC1_CR1 |= (1 << ADC1_CR1_ADON);
}


void main() {

    uart_config();   // UART pour debug série
    adc_init(4);      // Initialise ADC sur PD3 (ADC2)

    while (1) {
        uint16_t value = adc_read(4);  // Lecture
        uint16_t millivolts = (value * 5000UL) / 1023;
        printf("ADC:%u,Voltage:%u\r\n", value, millivolts);
        delay_ms(1500); // mini delay
    }
}