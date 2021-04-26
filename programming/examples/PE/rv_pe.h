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

/*  */
#ifdef RV_64
static uint64_t *const rv_mtvec = 0x0;
#else
/* Only 1 entry, we only support direct mode for now! */
static int rv_mtvec[1] __attribute__((aligned(64)));
static_assert(sizeof(rv_mtvec[0]) == 4);
#endif

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

void defaultIRQ()
{
	setIntr();
}

void initInterrupts()
{
	/* set trap base vector address */
	int addr_and_mode = (int)rv_mtvec | 0x0; // 0x0 is direct mode

	__asm__(
		"csrw mtvec, %0"
		: "r" (addr_and_mode)
	);

	rv_mtvec[0] = (int)defaultIRQ;
}