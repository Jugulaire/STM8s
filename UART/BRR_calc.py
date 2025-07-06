def calc_brr(f_cpu_hz, baudrate):
    usartdiv = f_cpu_hz / (16 * baudrate)
    mantissa = int(usartdiv)
    fraction = int(round((usartdiv - mantissa) * 16))

    # Correction si l'arrondi du fraction fait dépasser la mantisse
    if fraction >= 16:
        mantissa += 1
        fraction = 0

    brr1 = (mantissa >> 4) & 0xFF
    brr2 = ((mantissa & 0x0F) << 4) | (fraction & 0x0F)

    print(f"Pour f_CPU = {f_cpu_hz} Hz et Baudrate = {baudrate}:")
    print(f"  USARTDIV = {usartdiv:.4f}")
    print(f"  Mantissa = {mantissa}, Fraction = {fraction}")
    print(f"  BRR1 = 0x{brr1:02X}")
    print(f"  BRR2 = 0x{brr2:02X}")

    return brr1, brr2

# Exemple : 16 MHz, 9600 bauds
if __name__ == "__main__":
    f_cpu = 20_000_000  # 16 MHz
    baud = 9600
    calc_brr(f_cpu, baud)
