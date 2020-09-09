SIZE?=0x4000
MARCH?=rv32im
MABI?=ilp32
PROGRAM?=picolibtest
RV_FLAGS:=-march=$(MARCH) -mabi=$(MABI) -T picolibclink_$(SIZE).ld
LD_FLAGS:=-lm
SPEC:=--specs=../../../../picolibc_support/specs/picolibc.specs
GCC_VERSION?=riscv64

program: setup
	$(GCC_VERSION)-unknown-elf-gcc $(SPEC) $(RV_FLAGS) $(PROGRAM).c -o elf/$(PROGRAM)_pe.elf $(LD_FLAGS)
	$(GCC_VERSION)-unknown-elf-objcopy -O binary elf/$(PROGRAM)_pe.elf bin/$(PROGRAM).bin
	$(GCC_VERSION)-unknown-elf-objdump --disassemble-all elf/picolibtest_pe.elf > elf/tmp.s

setup:
	mkdir -p elf bin
	sed s/SIZE/$(SIZE)/ picolibclink.ld > picolibclink_$(SIZE).ld
	
clean:
	rm -rf bin elf
