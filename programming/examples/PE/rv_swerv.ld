OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
    ICCM    : ORIGIN = 0xee000000, LENGTH = 0x80000
    DCCM    : ORIGIN = 0xf0040000, LENGTH = 0x10000
}

SECTIONS
{
	.text.init : {
			* (.text.init);
	} > ICCM
	.text : {
	      * (.text);
	} > ICCM
	.data : {
	      * (.data);
	} > DCCM
	.srodata : {
	      * (.srodata);
	} > DCCM
	.rodata : {
	      * (.rodata);
	} > DCCM
	.bss : {
	     * (.bss);
	} > DCCM
}
