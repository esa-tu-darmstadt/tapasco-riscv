#include "../rv_pe.h"

const int b = 1337;

int main()
{
	initInterrupts();

	const int a = 42;

	// This causes a trap because 0x10000 is outside of the default memory size of 0x8000
	int* db = (int*)0x10000;
	*db = 0xDEADBEEF;
	writeToCtrl(RETL, a + b);
	
	setIntr();
	return 0;
}
