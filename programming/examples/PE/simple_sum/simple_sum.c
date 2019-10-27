#include "../rv_pe.h"

int main()
{
	int a = readFromCtrl(ARG1);
	int b = readFromCtrl(ARG2);
	writeToCtrl(RETL, a + b);
	
	setIntr();
	return 0;
}
