SIZE?=0x4000
STACK_START!=printf "0x%08x" $$(($(SIZE) + $(SIZE)))
MARCH?=rv32im
MABI?=ilp32
PROGRAM?=simple_sum
RV_FLAGS:=-march=$(MARCH) -mabi=$(MABI) -nostdlib -g
ifndef SWERV_CCM
	RV_FLAGS+= -T rv_$(SIZE).ld startup_$(SIZE)1.s
else
	RV_FLAGS+= -T rv_swerv.ld startup_swerv.s
endif

TOP:=`echo $(STACK_START) | cut -c3-7`
BOTTOM:=`echo $(STACK_START) | cut -c8-10`

program: setup
	riscv32-unknown-elf-gcc $(RV_FLAGS) $(PROGRAM)/$(PROGRAM).c -o elf/$(PROGRAM)_pe.elf
	riscv32-unknown-elf-objcopy -O binary elf/$(PROGRAM)_pe.elf bin/$(PROGRAM).bin

setup:
	mkdir -p elf bin
	sed s/TOP/$(TOP)/ startup.s > startup_$(SIZE).s
	sed s/BOTTOM/$(BOTTOM)/ startup_$(SIZE).s > startup_$(SIZE)1.s
	sed s/SIZE/$(SIZE)/ rv.ld > rv_$(SIZE).ld
