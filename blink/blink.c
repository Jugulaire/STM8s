#define PB_ODR *(volatile char*)0x5005
#define PB_DDR *(volatile char*)0x5007
#define PB_CR1 *(volatile char*)0x5008

void main() {

  PB_CR1= (1 << 5);
  PB_DDR = (1 << 5);

  while(1) {
    PB_ODR ^= (1 << 5);
    for(int i = 0; i < 30000; i++){;}
  }

}
