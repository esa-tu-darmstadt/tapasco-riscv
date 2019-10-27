BRAM_SIZE?=0x4000
PYNQ=xc7z020clg400-1
XLEN?=32
CACHE?=false

ifndef TAPASCO_HOME
$(error TAPASCO_HOME is not set, make sure to source setup.sh in TaPaSCo dir)
endif

ifndef XILINX_VIVADO
$(error XILINX_VIVADO is not set, make sure that Vivado is setup correctly)
endif

CORE_LIST=$(patsubst riscv/%,%,$(wildcard riscv/*))
PE_LIST=$(addsuffix _pe, $(CORE_LIST))

all: $(PE_LIST)

list:
	@echo $(CORE_LIST)

%_pe: %_setup
	vivado -nolog -nojournal -mode batch -source riscv_pe_project.tcl -tclargs --part $(PYNQ) --bram $(BRAM_SIZE) --cache $(CACHE) --project_name $@
	@PE_ID=$$(($$(echo $(PE_LIST) | sed s/$@.*// | wc -w) + 1742)); \
	tapasco -v import IP/$@/esa.informatik.tu-darmstadt.de_tapasco_$@_1.0.zip as $$PE_ID --skipEvaluation

%_setup: riscv/%/setup.sh
	$<

uninstall:
	rm -rf $(TAPASCO_HOME)/core/{${PE_LIST}}*

clean: uninstall
	rm -rf IP/riscv/
