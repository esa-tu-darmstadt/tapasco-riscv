# Usage CORE={swerv, scr1, cva6} [RV64=1] [CCM=1] [ESOTERIC=1] [PROGRAM={simple_sum, localsum, readargs, read_dm}]
SIZE?=0x4000
STACK_START!=printf "0x%08x" $$(($(SIZE) + $(SIZE)))

RV_FLAGS ?= -Wall -Wl,--build-id=none

CROSS_COMPILE ?= riscv64-linux-gnu-

ifdef RV64
	MARCH?=rv64im
	MABI?=lp64
	RV_FLAGS += -DRV64
else
	MARCH?=rv32im
	MABI?=ilp32
endif

GCCVERSIONGTEQ12 := $(shell expr `${CROSS_COMPILE}gcc -dumpversion | cut -f1 -d.` \>= 12)
ifeq (${GCCVERSIONGTEQ12},1)
	MARCH:=$(MARCH)_zicsr
endif

PROGRAM?=simple_sum
RV_FLAGS+= -march=$(MARCH) -mabi=$(MABI) -nostdlib -g

ifeq ($(CCM),1)
	# CCM is active, so we need to configure for different cores
	ifeq ($(CORE),swerv)
		RV_FLAGS+= -T rv_swerv.ld startup_swerv.s
	else ifeq ($(CORE),scr1)
		ifdef ESOTERIC
			RV_FLAGS+= -T rv_scr1.ld startup_scr1_esoteric.s
		else
			RV_FLAGS+= -T rv_scr1.ld startup_scr1.s
		endif
	else ifeq ($(CORE),cva6)
		ifdef ESOTERIC
			RV_FLAGS+= -T rv_cva6.ld startup_cva6_esoteric.s
		else
			RV_FLAGS+= -T rv_cva6.ld startup_cva6.s
		endif
	else
$(error Please specify a core (make CCM=1 CORE=<core>) with CCM support.)
	endif
else
	RV_FLAGS+= -T rv_$(SIZE).ld startup_$(SIZE)1.s
endif

TOP:=`echo $(STACK_START) | cut -c3-7`
BOTTOM:=`echo $(STACK_START) | cut -c8-10`

program: setup
	$(CROSS_COMPILE)gcc $(RV_FLAGS) $(PROGRAM)/$(PROGRAM).c -o elf/$(PROGRAM)_pe.elf
	$(CROSS_COMPILE)objcopy -O binary elf/$(PROGRAM)_pe.elf bin/$(PROGRAM).bin

setup:
	mkdir -p elf bin
	sed s/TOP/$(TOP)/ startup.s > startup_$(SIZE).s
	sed s/BOTTOM/$(BOTTOM)/ startup_$(SIZE).s > startup_$(SIZE)1.s
	sed s/SIZE/$(SIZE)/ rv.ld > rv_$(SIZE).ld
