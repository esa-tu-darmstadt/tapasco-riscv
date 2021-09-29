#define CTRL_OFFSET 0x11000000
#define IAR  0x1000
#define RETL 0x04
#define RETH 0x05
#define ARG0 0x08
#define ARG1 0x0C
#define ARG2 0x10
#define ARG3 0x14
#define ARG4 0x18
#define COUNTER 0x1c
#define COUNTERH 0x1d

#define STREAM0 0x10000
#define STREAM1 0x20000
#define STREAM2 0x30000
#define STREAM3 0x40000


/**
	Writes the value at the specified register.
	Example: writeToCtrl(RETL, 42); writes 42 to the lower 32 bits of return value register.
	@param reg The target register
	@param value The value to write to
**/
void writeToCtrl(int reg, int value)
{
	int* start = (int*)CTRL_OFFSET;
	int* addr = start + reg;
	*addr = value;
}


/**
	Returns the value of the specified reg from the RVController.
	Example: readFromCtrl(ARG0) -> returns value of ARG0 register
	@param reg The register to read from
	@return Value of reg.
**/
int readFromCtrl(int reg)
{
	int* start = (int*)CTRL_OFFSET;
	return *(start + reg);
}

/**
	Emits the interrupt from the RVController. Signals end of job. This function needs to be called *once* at the end of main.
**/
void setIntr()
{
	int* start = (int*)CTRL_OFFSET;
	int* addr = start + IAR;
	*addr = 1;
	while(1){}
}
