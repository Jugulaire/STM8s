# STM8 et C bas niveau 

## Comprendre le décalage de bit et la manipulation de registre 

### Lire un bit (tester si bit N = 1)

```c
if (REG & (1 << N)) {
    // Bit N est à 1
}
```
REG : registre (uint8_t ou autre)
N : position du bit (0 à 7)

### Mettre un bit N à 1 (sans toucher aux autres)

```c
REG |= (1 << N);
```

### Mettre un bit N à 0 (sans toucher aux autres)

```c
REG &= ~(1 << N);
```

### Inverser (toggle) un bit N

```c
REG ^= (1 << N);
```

### Mettre plusieurs bits (N1, N2, ..., Nk) à 1

```c
REG |= ( (1 << N1) | (1 << N2) | ... | (1 << Nk) );
```

### Mettre plusieurs bits à 0

```c
REG &= ~( (1 << N1) | (1 << N2) | ... | (1 << Nk) );
```

### Lire plusieurs bits (ex: bits N1, N2)

```c
uint8_t mask = (1 << N1) | (1 << N2);
uint8_t value = REG & mask;
```

### Écrire des bits sélectionnés à une certaine valeur (val), sans modifier les autres bits :


```c
REG = (REG & ~mask) | ( (val << N_min) & mask );
```

mask = masque sur les bits à modifier
val = nouvelle valeur (alignée sur bits concernés)
N_min = position du bit le plus bas dans mask

Exemple : modifier bits 2 et 3 avec val = 0b10 (bit 3 = 1, bit 2 = 0)

```c
uint8_t mask = (1 << 2) | (1 << 3);  // 0b00001100
uint8_t val = 0b10;                   // valeur à écrire sur bits 3 et 2
REG = (REG & ~mask) | ((val << 2) & mask);
```

### Méthode plus complexe 

Prenons cet exemple : 

```c
/* Port access operation */
PORTB = (1 << PB2);
```

Détaillons le : 

- `PORTB` est un **nom symbolique** défini dans `<avr/io.h>`. Il correspond à une adresse mémoire (0x25 sur ATmega328P).
- `PB2` vaut `2` → donc `(1 << PB2)` = `0b00000100` = `0x04`
- Cela signifie : **mettre à 1 le bit 2 de PORTB**, les autres à 0.
- mettre **uniquement PB2 à HIGH**, les autres à 0 

Un autre exemple : 

```c
/* Expanding macros (same as above) */
(* (volatile uint8_t *) ((0x05) + 0x20)) = (1 << 2);

```

Que fait ce code : 

- `0x05` est le **registre I/O** `PORTB`, et `+ 0x20` est un **décalage spécifique** aux **AVR** quand on accède à la mémoire via des pointeurs.

- `volatile uint8_t *` signifie : "pointeur vers un octet en mémoire qui peut changer à tout moment" (typiquement un registre hardware).

- `(1 << 2)` = `0x04`


Puis pour finir : 

```c
/* Same as above */
* (volatile uint8_t *) 0x25 = 0x04;
```

- Cette fois on écris directement la valeur dans la bonne adresse mémoire.

### Exemple concret complet

```c
#include <stdint.h>
#include <stdio.h>

int main() {
    uint8_t REG = 0b10101100;  // Exemple de registre

    // -------------------------------
    // 1. Lire un bit N (exemple N=5)
    if (REG & (1 << 5)) {
        printf("Bit 5 est à 1\n");
    } else {
        printf("Bit 5 est à 0\n");
    }

    // -------------------------------
    // 2. Mettre un bit N à 1 (exemple N=0)
    REG |= (1 << 0);  // Met bit 0 à 1

    // -------------------------------
    // 3. Mettre un bit N à 0 (exemple N=3)
    REG &= ~(1 << 3);  // Met bit 3 à 0

    // -------------------------------
    // 4. Inverser un bit N (exemple N=2)
    REG ^= (1 << 2);   // Toggle bit 2

    // -------------------------------
    // 5. Mettre plusieurs bits (ex: bits 2 et 5) à 1
    REG |= (1 << 2) | (1 << 5);

    // -------------------------------
    // 6. Mettre plusieurs bits (ex: bits 2 et 5) à 0
    REG &= ~((1 << 2) | (1 << 5));

    // -------------------------------
    // 7. Lire plusieurs bits (exemple bits 3 et 4)
    uint8_t mask = (1 << 3) | (1 << 4);
    uint8_t bits_val = (REG & mask) >> 3;  // Décalage à droite pour "aligner" sur bit 0
    // bits_val contient la valeur des bits 4 et 3 dans les bits 1 et 0

    printf("Valeur des bits 4 et 3 : 0b%02x\n", bits_val);

    // -------------------------------
    // 8. Écrire plusieurs bits (ex: bits 2 et 3) avec une valeur donnée (val=0b10)
    mask = (1 << 2) | (1 << 3);
    uint8_t val = 0b10;
    REG = (REG & ~mask) | ((val << 2) & mask);

    printf("REG après modification bits 2 et 3 : 0b%02x\n", REG);

    return 0;
}

```

## Les registre des GPIO 

Page 31 de la doc on trouve un tableau qui résume les divers registres liée aux GPIO : 

![STM8_gpio_addr](/home/jugu-ubuntu/Documents/writeups/img/STM8_gpio_addr.png)

Dans mon cas j'ai connecté une diode sur le port D3 de la carte STM8s : 

![](/home/jugu-ubuntu/Documents/writeups/img/STM8_pinout.png)

Il faut donc configurer les bons registres pour permettre d'exploiter le Port D en sortie avec les réglages des différents registres.

![portconfig_stm8](/home/jugu-ubuntu/Documents/writeups/img/portconfig_stm8.JPG)

Détaillons ce que font chacun d'entre eux : 

- DDR : Data direction register définis si le pin GPIO seras une sortie ou une entrée
- ODR : Output Data register sert a définir l’état du pin GPIO 
- IDR : Input Data Register sert a lire l'état d'un GPIO
- CR1 et CR2 servent a configurer le comportement du GPIO 

### Les sorties 

Nous allons expliquer les sorties avec un exemple simple sur un clignotement de led.

Dans notre cas il faut donc travailler sur le Port D sur les registres DDR pour configurer le pin 3 en sortie (valeur a 1), CR1 pour definir le pin en mode Push-pull puis enfin alterner entre l'état haut et bas sur ODR.

> Mode push pull (1) pour jouer avec des leds, mode Open Drain (0) pour du bus type i2c ou onewire

Voici le code : 

```c
//Definition des 3 adresses des registres du port D conformément au datasheet
#define PD_ODR *(volatile char*)0x500F
#define PD_DDR *(volatile char*)0x5011
#define PD_CR1 *(volatile char*)0x5012

void main() { // Fonction principale

  // Configuration du pin 3 du port D (PD3)
  PD_CR1= (1 << 3); // en mode push-pull (valeur 1)
  PD_DDR = (1 << 3); // en mode output (valeur 1)

  while(1) { // boucle infini
    PD_ODR ^= (1 << 3); // toggle de la valeur du registre 1->0, 0->1
    for(int i = 0; i < 30000; i++){;} // mimick de delay
  }

}
```

Je le compile : 

```bash
sdcc -lstm8 -mstm8 --out-fmt-ihx --std-sdcc11 blink.c
```

Je le pousse dans le STM8 : 

```bash
stm8flash -c stlinkv2 -p stm8s003f3 -w blink.ihx
```

### Les entrées binaires

Il faut déjà câbler le bouton au STM8 : 

```c
[3.3V]
   |
  [R] 10k pull-up
   |
  PA3 ---- Bouton ---- GND

```

Ensuite définir dans le code le mode de fonctionnement : 

```c
PA_DDR &= ~(1 << 3);  // PA3 en entrée
PA_CR1 |= (1 << 3);   // Pull-up interne activée
PA_CR2 &= ~(1 << 3);  // Interruption désactivée (pour l’instant)
```

> Pour rappel : 
> ![portconfig_stm8](/home/jugu-ubuntu/Documents/writeups/img/portconfig_stm8.JPG)

Il est ensuite possible de récupérer l'état du bouton pour par exemple allumer un LED : 

```c
if (!(PA_IDR & (1 << 3))) {
    PB_ODR ^= (1 << 5);  // Inverse LED sur PB5
    delay_ms(200);       // Anti-rebond simple
}
```

Le problème ici est que la gestion des rebonds sur l’appui d'un bouton est géré de manière basique et non fiable. Il faut pour cela utiliser un algorithme que se base sur une gestion d'état du bouton plutôt que sur un délai arbitraire : 

```c
int8_t button_pressed(volatile uint8_t* idr, uint8_t pin) {
    static uint8_t last_state[8] = {0xFF};  // Mémorise les derniers états (1 = repos, car pull-up active)
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
```

> Quand on appuies sur un bouton, les contacts mécaniques ne se ferment pas proprement d’un seul coup.
> Ils "vibrent" pendant quelques millisecondes et crée des petits allers-retours rapides entre 0 et 1.
>
> Ainsi, a la place d'avoir un valeur de 1 puis 0 le STM8 voit 1,0,1,1,0,1 et fait n'importe quoi car il pense que plusieurs appuis ont eu lieu au lieu d'un seul.
>
> Il faut donc utiliser un algorithme pour endiguer cet effet.

Cette fonction fait trois choses :

1. Elle lit l’état actuel du bouton (sur la broche indiquée)
2. Si l’état a changé par rapport au précédent :
   - Elle attend 20 ms
   - Elle vérifie si le changement est stable
   - Si c’est un appui (niveau bas), elle retourne `1`
3. Sinon, elle retourne `0` (pas de nouvel appui)

Elle garantit que chaque appui est détecté une seule fois, même si le bouton rebondit.

Voici le code final :

```c
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
```

### Entrée binaires avec interruptions 

Avant de se lancer dans le code, il faut prendre en compte l'aspect matériel de notre carte de développement. 
Nous avons une LED branchée sur PD3 et un bouton sur PA3. Notre interruption externe auras donc lieux sur le port A de notre microcontrôleur. 

Voyons ce que dis la datasheet : 

![portconfig_stm8](/home/jugu-ubuntu/Documents/writeups/img/STM8_External-interrupt.png) 

La configuration des sources block est la suivante dans mon fichier entête :

```c 
#define EXTI0_ISR               3
#define EXTI1_ISR               4
#define EXTI2_ISR               5
#define EXTI3_ISR               6
#define EXTI4_ISR               7
```

La fonction qui seras appelée par l’interruption auras donc cette allure la : 

```c
void button_handler(void) __interrupt(3) {
    printf("Interruption lancée\r\n"); //debug facultatif
    PD_ODR ^= (1 << 3); //toggle de la led sur PD3
}
```

La doc précise ensuite ceci : 

> You can configure an I/O as an input with interrupt by setting the CR2x bit while the I/O is in input mode. In this configuration, a signal edge or level input on the I/O generates an interrupt request

Il faut donc definir PA3 en entrée et mettre son registre CR2 a 1 pour activer l'interruption externe : 

```c
// Bouton sur PA3
PA_DDR &= ~(1 << 3);   // Entrée
PA_CR1 |= (1 << 3);    // Pull-up
PA_CR2 |= (1 << 3);    // Active interruption pour PA3
```

Il faut ensuite configurer la sensibilité des interruptions par port sur `EXT_CR1`: 

| Port   | Bits dans `EXTI_CR1` | Nom des bits |
| ------ | -------------------- | ------------ |
| Port A | 1:0                  | `PAIS[1:0]`  |
| Port B | 3:2                  | `PBIS[1:0]`  |
| Port C | 5:4                  | `PCIS[1:0]`  |
| Port D | 7:6                  | `PDIS[1:0]`  |

Dans chaque couple de bits une sensibilité est définie : 

| Valeur binaire | Mode déclenchement            | Cas d’usage typique                      |
| -------------- | ----------------------------- | ---------------------------------------- |
| `00`           | Falling edge **et** low level | Rare, risque de rebond multiple          |
| `01`           | Rising edge **seulement**     | Bouton en **pull-down**                  |
| `10`           | Falling edge **seulement**    | Bouton en **pull-up** (cas le + courant) |
| `11`           | Rising **et** falling edge    | Double détection (toggle, compteur…)     |

Voici un tableau qui résume les valeurs a mettre en place en fonction du port choisis:  

| **Port** | **Bits dans `EXTI_CR1`** | **Type de front**    | **Valeur à écrire** |
| -------- | ------------------------ | -------------------- | ------------------- |
| Port A   | bits 1:0                 | Niveau bas + Falling | `(0b00 << 0)`       |
|          |                          | Rising               | `(0b01 << 0)`       |
|          |                          | Falling              | `(0b10 << 0)`       |
|          |                          | Rising + Falling     | `(0b11 << 0)`       |
| Port B   | bits 3:2                 | Niveau bas + Falling | `(0b00 << 2)`       |
|          |                          | Rising               | `(0b01 << 2)`       |
|          |                          | Falling              | `(0b10 << 2)`       |
|          |                          | Rising + Falling     | `(0b11 << 2)`       |
| Port C   | bits 5:4                 | Niveau bas + Falling | `(0b00 << 4)`       |
|          |                          | Rising               | `(0b01 << 4)`       |
|          |                          | Falling              | `(0b10 << 4)`       |
|          |                          | Rising + Falling     | `(0b11 << 4)`       |
| Port D   | bits 7:6                 | Niveau bas + Falling | `(0b00 << 6)`       |
|          |                          | Rising               | `(0b01 << 6)`       |
|          |                          | Falling              | `(0b10 << 6)`       |
|          |                          | Rising + Falling     | `(0b11 << 6)`       |

Il faut ensuite configurer le registre : 

```c
// Interruption sur front descendant (EXTI3)
EXTI_CR1 &= ~(0b11 << 0);   // Efface les bits PAIS[1:0]
EXTI_CR1 |=  (0b10 << 0);   // Met 10 = front descendant
```

Il est maintenant possible de tout assembler pour obtenir un code fonctionnel : 

```c
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
```

### Le mode Halt 

Le STM8s permets de rentrer en mode sommeil. Il est donc possible d'exploiter une interruption externe pour le réveiller : 

```c
#include "../stm8s.h"
#include <stdio.h>
#define F_CPU 16000000UL //16MHz
#define BAUDRATE 9600

volatile uint32_t last_press_time = 0; //debounce interruption
volatile uint8_t wake_pending = 0; // flag sommeil

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

void button_handler(void) __interrupt(3) {
    static uint32_t now = 0;
    now += 1;  // Incrémente à chaque IT, ou via timer en fond si dispo
    if ((now - last_press_time) > 1) {  // 1 "ticks" d'écart
        if (!(PA_IDR & (1 << 3))) {
            wake_pending = 1;  // Juste un flag de réveil
            last_press_time = now;
        }
    }
}

void main() {

    uart_config();
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

    __asm__("rim");  // autorise les interruptions

    while (1) {
        __asm__("halt");  // Va en sommeil
        // À la sortie de HALT (donc MCU réveillé ici)
        if (wake_pending) {
            delay_ms(5); // timer pour un filtre anti rebond
            wake_pending = 0;
            PD_ODR |= (1 << 3);  
            printf("Réveillé !\r\n");
            delay_ms(50);
            printf("ZZZzzzzzZZZZZzzzzZZZ\r\n");
            PD_ODR &= ~(1 << 3);
        }
    }
    
}
```

Il suffit ici de rajouter le `halt` pour avoir un MCU en sommeil qui ne consomme rien. 

### Les entrées avec ADC

## UART 

L'UART est une interface série qui permets dans notre cas d'usage de réaliser du debug. 

Voici les broches de l'UART : 

| Fonction       | Broche STM8S103F3 | Broche physique |
| -------------- | ----------------- | --------------- |
| TX (USART1_TX) | PD5               | pin 20          |
| RX (USART1_RX) | PD6               | pin 19          |

> TX doit être connecté sur le RX du module USB série et RX sur le TX du module USB série. 

Ensuite il faut configurer les sorties GPIO comme nous l'avons vu dans le précédent chapitre : 

```c
// TX - PD5
PD_DDR |= (1 << 5);   // Data Direction Register: 1 = Output
PD_CR1 |= (1 << 5);   // Control Register 1: 1 = Push-Pull
PD_CR2 |= (1 << 5);   // Control Register 2: 1 = Fast Mode

// RX - PD6
PD_DDR &= ~(1 << 6);  // 0 = Input
PD_CR1 |= (1 << 6);   // Pull-up enabled
PD_CR2 &= ~(1 << 6);  // Disable interrupt for now
```

Dans le cas standard nous allons travailler a une vitesse de 9600 bauds. Sur STM8s la manière de configurer le baud rate est pour le moins spéciale. 

Il faut déjà calculer la valeur requise pour subdiviser l'horloge principale (16 MHz) et obtenir une vitesse de transmission de 9600 bauds : 

```
USARTDIV = f_master / (16 × BaudRate)
```

Il faut ensuite découper ce resultat en deux partie : 

- Une mantisse (la partie avant la virgule)
- Une fraction (4 bit de poids faibles)

Si on applique le calcul précédent on obtiens ceci : 

``` 
USARTDIV = 16,000,000 / (16 * 9600) = 104.166666...
```

- La mantisse vaut 104
- La fraction vaut 16 x 0,166666 soit 2.66 que l'on va arrondir a 3 soit 0011 en binaire

Les registres sont donc les suivants : 

| Registre | Bits utilisés | Contenu                    | Source            |
| -------- | ------------- | -------------------------- | ----------------- |
| `BRR1`   | [7:0]         | Bits 11 à 4 de la mantisse | `mantisse >> 4`   |
| `BRR2`   | [7:4]         | Bits 3 à 0 de la mantisse  | `mantisse & 0x0F` |
| `BRR2`   | [3:0]         | Bits 3 à 0 de la fraction  | `(fraction * 16)` |

Donc :

- `USARTDIV = 104.166`
- En binaire, 104 = `01101000`
- bits 11–4 = `01101000`  va dans **`BRR1`**
- bits 3–0 = `1000`  va dans **`BRR2[7:4]`**
- fraction = `.1666 × 16 = 2.666 = 3` soit `0011`  va dans **`BRR2[3:0]`**

Voici ce que cela donne concrètement : 

```c
UART1_BRR1 = 0x68;   // 104 decimal
UART1_BRR2 = 0x83;   // 0x80 | 0x03
```

- 0x80 = `10000000` → BRR2[7:4] = `1000`
- 0x03 = `00000011` → BRR2[3:0] = `0011`

Voici une fonction pour faire le taf : 

```c
void uart_config() {
    uint16_t div = (F_CPU + BAUDRATE / 2) / BAUDRATE;
    UART1_BRR2 = ((div >> 8) & 0xF0) + (div & 0x0F);
    UART1_BRR1 = div >> 4;
}
```

Ensuite il faut configurer l'UART : 

```c
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
 }
```

Ensuite on code des fonctions pour envoyer et recevoir des octets : 

```c
void uart_write(uint8_t data) {
    UART1_DR = data;
    while (!(UART1_SR & (1 << UART1_SR_TXE)));
}

uint8_t uart_read() {
    while (!(UART1_SR & (1 << UART1_SR_RXNE)));
    return UART1_DR;
}
```

Il est aussi possible de rediriger stdout avec SDCC : 

```c
int putchar(int c) {
    uart1_send_byte(c);
    return 0;
}
```

Voici le code complet : 

```c
#include <stdint.h> 
#include <stdio.h>
#include "../stm8s.h"

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

void main() {
    CLK_CKDIVR = 0x00;  // Set system clock to full 16 MHz
    uint8_t counter = 0;
    uart_config();

    // LED onboard
    PB_CR1= (1 << 5);
    PB_DDR = (1 << 5);

    while (1) {
        uint8_t c = uart_read();   // Attendre un caractère du terminal
        printf("Echo : %c \r\n", c);
    }
}
```



## Les timers 

> A partir de la il faut utiliser des entêtes externes. Sans elle je ne suis pas parvenus a faire marcher le code. Il se trouve dans le repo, dossier other, Lib

Le Timer4 est un **timer 8 bits** qui compte des cycles d’horloge. Il est souvent utilisé pour des interruptions basiques.
Il possède plusieurs **registres** pour :

- Démarrer / arrêter le timer
- Choisir le **prescaler** (diviseur d’horloge)
- Définir la valeur de comptage
- Attendre un **overflow** ou comparer une valeur

Voici les registres a retenir : 

| **Nom du registre** | **Adresse** | **Description**                                              |
| ------------------- | ----------- | ------------------------------------------------------------ |
| `TIM4_CR1`          | `0x5340`    | Control Register 1 — Démarrage/arrêt du timer, mode de comptage |
| `TIM4_PSCR`         | `0x5341`    | Prescaler Register — Définit la division de fréquence        |
| `TIM4_ARR`          | `0x5342`    | Auto-Reload Register — Valeur de débordement (overflow)      |
| `TIM4_CNTR`         | `0x5343`    | Counter Register — Valeur actuelle du compteur               |
| `TIM4_SR`           | `0x5344`    | Status Register — Contient le flag d'overflow (UIF)          |
| `TIM4_IER`          | `0x5345`    | Interrupt Enable Register — Active les interruptions (UIE)   |
| `TIM4_EGR` *(rare)* | `0x5346`    | Event Generation Register — Génère des événements manuels (pas toujours utilisé) |

Dans notre cas nous allons crée une fonction delay standard pour notre blink d'avant. 

Détaillons de manière synthétique le fonctionnement du timer : 

- **Division de l’horloge**

  - On prend l’**horloge système** (ici 2mhz)
  - On la divise avec le **prescaler** (`TIMx_PSCR`)
  - Exemple : `2 MHz / 128 =  1 tick = 1 ms`

  **Comptage des ticks**

  - Le **compteur** (`TIMx_CNTR`) s’incrémente à chaque tick
  - Il compte **jusqu’à la valeur de `ARR`** (auto-reload register)

  **Événement à la fin du comptage**

  - Quand `CNTR` atteint `ARR` :
    - Le timer **revient à 0** (sauf si mode "one-shot")
    - Il **lève le flag `UIF`** (Update Interrupt Flag, dans `TIMx_SR1`)
    - Optionnellement, il peut **déclencher une interruption**

Il faut tout d'abord choisir la fréquence du timer :

```c
TIM4_PSCR = 7; // Prescaler = 2^7 = 128 → chaque tick = 1 / (2 MHz / 128) = 64 µs
```

PSCR est definis avec une puissance de 2 : 

| Valeur dans PSCR | Division appliquée (prescaler) |
| ---------------- | ------------------------------ |
| 0                | 1 (pas de division)            |
| 1                | 2                              |
| 2                | 4                              |
| 3                | 8                              |
| 4                | 16                             |
| 5                | 32                             |
| 6                | 64                             |
| 7                | 128                            |

Ensuite configurer ARR pour définir quand lever le flag ou l'exception : 

```c
TIM4_ARR = 15;        // Auto-reload = 15 → Overflow toutes les (15+1)*64 µs = 1,024 ms ≈ 1 ms
```

Lancer le timer : 

```c
TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Démarre le Timer 4 (CEN = Counter Enable)
```

Et enfin attendre son débordement : 

```c
while ((TIM4_SR & (1 << TIM4_SR_UIF)) == 0);// Attente active que le Timer déborde
        TIM4_SR &= ~(1 << TIM4_SR_UIF);// Réinitialisation du flag UIF
```

Voici un code d'exemple qui se base sur les adresses de registre de la doc : 

```c
#include <stdint.h>
#include "stm8s.h"  // Fichier d'en-tête STM8 : contient les définitions de registre utiles

// Broche de sortie utilisée pour le clignotement : PD3
#define OUTPUT_PIN 3

// Macro pour activer l'horloge du Timer 4 via le registre CLK_PCKENR1 (bit 5)
#define ENABLE_TIM4_CLOCK() (CLK_PCKENR1 |= (1 << 5))

// Fonction de délai en millisecondes basée sur Timer 4
void delay_ms(uint16_t ms) {
    ENABLE_TIM4_CLOCK(); // Active l'horloge du Timer 4 (obligatoire pour qu'il fonctionne)

    TIM4_CR1 = 0;         // Arrêt du Timer pour le configurer en toute sécurité
    TIM4_PSCR = 7;        // Prescaler = 2^7 = 128 → chaque tick = 1 / (2 MHz / 128) = 64 µs
    TIM4_ARR = 15;        // Auto-reload = 15 → Overflow toutes les (15+1)*64 µs = 1,024 ms ≈ 1 ms
    TIM4_CNTR = 0;        // Remise à zéro du compteur
    TIM4_SR &= ~(1 << TIM4_SR_UIF);  // Efface le flag d'overflow (UIF : Update Interrupt Flag)

    TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Démarre le Timer 4 (CEN = Counter Enable)

    // Boucle de délai : attendre un débordement (overflow) pour chaque ms demandée
    for(uint16_t i = 0; i < ms; i++) {
        while ((TIM4_SR & (1 << TIM4_SR_UIF)) == 0);  // Attente active que le Timer déborde
        TIM4_SR &= ~(1 << TIM4_SR_UIF);               // Réinitialisation du flag UIF
    }

    TIM4_CR1 &= ~(1 << TIM4_CR1_CEN); // Stoppe le Timer après le délai
}

// Fonction principale : clignotement d'une LED branchée sur PD3
int main() {
    CLK_CKDIVR = 0x18; // Configuration de la fréquence CPU : 
                       // - HSIDIV = 8 → Horloge interne de 16 MHz divisée par 8 = 2 MHz
                       // - CPUDIV = 1 → pas de division supplémentaire pour le CPU

    // Configuration de la broche PD3 en sortie push-pull :
    PD_DDR |= (1 << 3);  // PD3 en mode "sortie"
    PD_CR1 |= (1 << 3);  // Mode push-pull (plutôt qu'open-drain)

    while(1) {
        PD_ODR ^= (1 << 3);    // Inversion de l'état logique de PD3 → toggle LED
        delay_ms(500);         // Pause de 500 ms (clignote à 1 Hz)
    }
}
```

## Les timer avec interruptions 

Cette fois nous utilisons aussi le timer 4 mais a la place de compter une durée de x ms, nous allons utiliser des interruptions. Ce systeme permets de lancer une action au débordement de `ARR` 

Voici le code complet qui vise a générer un signal de 100 hz sur la pin PD3 : 

```c
#include <stdint.h>
#include <stm8s.h>

#define OUTPUT_PIN      3

void timer_isr() __interrupt(TIM4_ISR) {
    PD_ODR ^= (1 << OUTPUT_PIN);
    TIM4_SR &= ~(1 << TIM4_SR_UIF);
}

void main() {
    enable_interrupts();

    /* Set PD3 as output */
    PD_DDR |= (1 << OUTPUT_PIN);
    PD_CR1 |= (1 << OUTPUT_PIN);

    /* Prescaler = 128 */
    TIM4_PSCR = 0b00000111;

    /* Frequency = F_CLK / (2 * prescaler * (1 + ARR))
     *           = 2 MHz / (2 * 128 * (1 + 77)) = 100 Hz */
    TIM4_ARR = 77;

    TIM4_IER |= (1 << TIM4_IER_UIE); // Enable Update Interrupt
    TIM4_CR1 |= (1 << TIM4_CR1_CEN); // Enable TIM4

    while (1) {
        // do nothing
    }
}
```

Détaillons le code : 

```c
void timer_isr() __interrupt(TIM4_ISR) {
    PD_ODR ^= (1 << OUTPUT_PIN);               // Inverse l’état de la broche PD3
    TIM4_SR &= ~(1 << TIM4_SR_UIF);            // Efface le flag d’interruption (UIF)
}
```

Ici une fonction est crée et elle seras lancé une fois l’interruption de débordement déclenché. 

- `TIM4_ISR` est défini a la valeur 23 dans `stm8s.h` comme vecteur d’interruption pour TIM4. C'est une donnée fixée dans le Mcu. 

- `UIF` (Update Interrupt Flag) doit **impérativement être effacé manuellement** dans le handler.

```c
void main() {
    enable_interrupts();  // Active globalement les interruptions (RIM)

    PD_DDR |= (1 << OUTPUT_PIN);  // Configure PD3 en sortie
    PD_CR1 |= (1 << OUTPUT_PIN);  // Sortie push-pull (pas open-drain)

    TIM4_PSCR = 0b00000111;  // Prescaler = 2^7 = 128
```

Ici sont configuré les divers registres requis au bon fonctionnement du timer et les GPIO comme expliqué juste avant dans les rubriques Timer et GPIO. 

```c
TIM4_ARR = 77;   // Auto-reload = 77
```

Le timer déborde après `(ARR + 1) × tick = (77 + 1) × 64 µs ≈ 5.0 ms`. Soit 100 hz 

```c
    TIM4_IER |= (1 << TIM4_IER_UIE);  // Active l’interruption de débordement
    TIM4_CR1 |= (1 << TIM4_CR1_CEN);  // Démarre le timer
```

On active ensuite les interruption de débordement et lance ensuite le timer. 

### Blink avec interruption 

Cette fois-ci nous modifions le code pour réaliser un blink de la led sur PD3 sauf qu'au lieux de compter avec le timer, nous allons utiliser ses interruption pour incrémenter un compteur et réaliser le comptage du temps. 

```c
#include <stdint.h>
#include <stm8s.h>
#include <delay.h>

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
```

Le Timer 4 sur les STM8S103/003 est un timer 8 bits, ce qui signifie que le registre ARR (auto-reload) est limité à 8 bits

- La valeur max de TIM4_ARR est de 255 
  - Cela veut dire que le compteur comptera de 0 à 255, donc 256 pas au total avant un overflow.
- La valeur max du préscaler est de 128 sur les 3 bits de TIM4_PSCR. 
- La frequence du CPU est de 2 MHz.

On considére donc que : 

```
T_overflow = (ARR + 1) × Prescaler / F_CPU
```

Soit : 

```
T_overflow = (255 + 1) × 128 / 2_000_000
           = 256 × 128 / 2_000_000
           = 0.016384 s ≈ 16.4 ms
```

