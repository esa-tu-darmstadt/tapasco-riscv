#include "rv_pe.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int testval = 0;

int main()
{
	/* Your code starts here */
	
	// short program to check the memcpy function of picolib
	//int * base_in = (int *) (readFromCtrl(ARG1) + 0x80000000);
	//int * base_out = (int *) (readFromCtrl(ARG2) + 0x80000000);
	//int count = readFromCtrl(ARG3);
	
	//memcpy(base_out, base_in, count);
	
	//memcpy(base_out, local_array, 8*sizeof(int));
	
	char *buffer;
	int buf_size = 128;

	// allocate a buffer	
	buffer = (char *)malloc(buf_size * sizeof(char));
	if (buffer == NULL) {
		printf("Could not allocate buffer!\n");
		setIntr();
		return 0;
	}
	
	// read a line from stdin
	fgets(buffer, buf_size, stdin);
	
	// use scanf to read a number from stdin
	int number;
	scanf("%d\n", &number);
	
	// calculate the square root
	double result = sqrt(number);
	
	
	printf("-------- output starts ----------\n");
	printf("Input line: %s", buffer);
	printf("sqrt(%d) = %f\n", number, result);
	printf("------- output ends ------------\n");
	/* Your code ends here */
	
	// Signal job finish to TaPaSCo
	setIntr();
	return 0;
}
