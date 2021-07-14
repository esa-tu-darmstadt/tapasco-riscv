#include "../rv_pe.h"

int main() {
    initInterrupts();
    initPrint();

    int a = readFromCtrl(ARG1);
    int b = readFromCtrl(ARG2);

    print("Hello world3!\n");
    print_hex(0xF457F00D);
    print("\n");

    int *dm_memory = 0x12000000;
    // HaltAddress = 64'h800
    // RomSize = 19
    const int *dm_rom_memory = dm_memory + (0x0800 / sizeof(int));
    const int *dm_rom_memory_end = dm_rom_memory + 19;

    print("DM Rom: 0x");
    print_hex(dm_rom_memory);
    print(" - 0x");
    print_hex(dm_rom_memory_end);
    print(":\n");
    for (const int *it = dm_rom_memory; it != dm_rom_memory_end; ++it) {
        print_hex(*it);
        print("\n");
    }

    writeToCtrl(RETL, *dm_rom_memory);

    setIntr();
    return 0;
}
