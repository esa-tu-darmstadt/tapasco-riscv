#include "../rv_pe.h"

const int b = 1337;

int main()
{
	const int a = 42;

	int* db = (int*)0x10000;
	*db = 0xDEADBEEF;
	writeToCtrl(RETL, a + b);
	
	setIntr();
	return 0;
}
