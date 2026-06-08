#define PD_ODR (*(volatile unsigned char*)0x500F)
#define PD_DDR (*(volatile unsigned char*)0x5011)
#define PD_CR1 (*(volatile unsigned char*)0x5012)

void delay(void)
{
    for(volatile unsigned int i = 0; i < 30000; i++);
}

void main(void)
{
    PD_DDR |= (1 << 4);   // PD4 en sortie
    PD_CR1 |= (1 << 4);   // push-pull

    while(1)
    {
        PD_ODR ^= (1 << 4);
        delay();
    }
}
