#include "../rv_pe.h"


int main()
{
    initInterrupts();

    const int a = 42;
    const int b = 123;

    // Depending on the core implementation this might causes a trap because 0x10000 is outside of the default memory size of 0x8000
    //int* db = (int*)0x10000;
    //*db = 0xDEADBEEF;

    writeToCtrl(RETL, a + b);

    print("Hello World!");

    setIntr();
    return 0;
}
