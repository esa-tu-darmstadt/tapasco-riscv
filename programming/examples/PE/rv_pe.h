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


void fallbackDefaultIRQ()
{
	writeToCtrl(RETL, -2);
	setIntr();
}

void defaultIRQ() __attribute__((aligned(64), weak, alias("fallbackDefaultIRQ")));

void initInterrupts()
{
	/* set trap base vector address */
	const int addr_and_mode = (int)defaultIRQ | 0x0; // 0x0 is direct mode

	/* https://wiki.osdev.org/Inline_Assembly */
	__asm__(
		"csrw mtvec, %0"
		:
		: "r" (addr_and_mode)
	);

	int current_mtvec;

	/* check if mtvec is writeable */
	__asm__(
		"csrr %0, mtvec"
		: "=r" (current_mtvec)
		:
	);

	if (current_mtvec != addr_and_mode) {
		// MTVEC is not writeable -> PANIC!
		writeToCtrl(RETL, -1);
		setIntr();
	}
}

/* printing */
static char *out_buf = 0;
static int out_idx = 0;

void print(const char *str)
{
    if (!out_buf)
        out_buf = (char *)readFromCtrl(ARG3) + 0x80000000;

    for (const char *c = str; *c; ++c, ++out_idx)
        out_buf[out_idx] = *c;

    out_buf[out_idx] = '\0';
}






