OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
    ICCM    : ORIGIN = 0x00480000, LENGTH = 0x4000
    DCCM    : ORIGIN = 0x00484000, LENGTH = 0x4000
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
