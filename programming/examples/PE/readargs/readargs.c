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

    //const char *codeAddr = (char*)readFromCtrl(ARG0);

    /*
    int firstProgBytes = codeAddr[0];
    firstProgBytes <<= 8;
    firstProgBytes |= codeAddr[1];
    firstProgBytes <<= 8;
    firstProgBytes |= codeAddr[2];
    firstProgBytes <<= 8;
    firstProgBytes |= codeAddr[3];
    */

    //writeToCtrl(RETL, (int)codeAddr);

    // magic RAM offset, taken from PR of picolib
    char *buf = (char *)readFromCtrl(ARG3) + 0x80000000;
    /*
    buf[0] = 'H';
    buf[1] = 'i';
    buf[2] = '!';
    buf[3] = '\0';
    */

    print("Hello World!");

    setIntr();
    return 0;
}
