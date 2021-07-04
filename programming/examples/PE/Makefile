# Usage CORE={swerv, scr1, cva6} [RV64=1] [CCM=1] [ESOTERIC=1] [PROGRAM={simple_sum, localsum, readargs}]
SIZE?=0x4000
STACK_START!=printf "0x%08x" $$(($(SIZE) + $(SIZE)))

ifdef RV64
	MARCH?=rv64im
	MABI?=lp64
else
	MARCH?=rv32im
	MABI?=ilp32
endif

PROGRAM?=simple_sum
RV_FLAGS:=-march=$(MARCH) -mabi=$(MABI) -nostdlib -g

ifeq ($(CORE),swerv)
	# assumes CCM
	RV_FLAGS+= -T rv_swerv.ld startup_swerv.s
else ifeq ($(CORE),scr1)
	ifndef CCM
		RV_FLAGS+= -T rv_$(SIZE).ld startup_$(SIZE)1.s
	else
		ifdef ESOTERIC
			RV_FLAGS+= -T rv_scr1.ld startup_scr1_esoteric.s
		else
			RV_FLAGS+= -T rv_scr1.ld startup_scr1.s
		endif
	endif
else ifeq ($(CORE),cva6)
	ifdef ESOTERIC
		RV_FLAGS+= -T rv_cva6.ld startup_cva6_esoteric.s
	else
		RV_FLAGS+= -T rv_cva6.ld startup_cva6.s
	endif
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
