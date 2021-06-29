ifndef CAPN_PATH
	$(error CAPN_PATH is undefined)
endif

SRC ?= cva6/src
SRC_PREFIX ?= cva6/
SRC_FILES ?= ../../../riscv/cva6/core.files
ADD_SCRS ?= $(SRC_PREFIX)include/axi_intf.sv $(SRC_PREFIX)tb/ariane_soc_pkg.sv $(SRC_PREFIX)tb/ariane_axi_soc_pkg.sv $(SRC_PREFIX)tb/ariane_custom_tb_top.sv
INCLUDE_DIR ?= $(SRC_PREFIX)include -I$(SRC_PREFIX)src/common_cells/include -I$(SRC_PREFIX)src/common_cells/include/common_cells
SIM_SRC ?= sim_src
V_DIR ?= sim_build

SIM_DEFS ?= -DRUN_SIM

DEFAULT_TOP_MODULE := ariane_custom_tb_top

VERILATOR_PREFIX ?=
VERILATOR := $(VERILATOR_PREFIX)verilator

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

srcs := $(addprefix $(SRC_PREFIX),$(shell cat $(SRC_FILES)))
srcs += $(ADD_SCRS)
#srcs += $(call rwildcard,$(SRC),*.v)
#srcs += $(call rwildcard,$(SRC),*.sv)

#sim_srcs := $(call rwildcard,$(SIM_SRC),*.cpp)
sim_targets := $(wildcard $(SIM_SRC)/sim_*.cpp)
sim_tops := $(patsubst sim_%.cpp,%,$(notdir $(sim_targets)))

deps := $(call rwildcard,$(V_DIR),*.d)

PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
V_CCFLAGS := -g -Wall -O3 -I$(PWD)$(SIM_SRC) -I$(CAPN_PATH)/lib
V_LDFLAGS := -lpthread

# Choose the correct cache version, the other one is deprecated
V_FLAGS := -DWT_DCACHE \
           -Wno-fatal \
           -Wno-PINCONNECTEMPTY \
           -Wno-ASSIGNDLY \
           -Wno-DECLFILENAME \
           -Wno-UNUSED \
           -Wno-UNOPTFLAT \
           -Wno-BLKANDNBLK \
           -Wno-style

.PHONY: all clean sim preparebuild cva6

all: preparebuild cva6 sim

preparebuild:
#	cp dm_interface.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp dm_testbench_interface.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp tapasco-riscv.capnp.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)

cva6:
	git clone --recursive https://github.com/jschj/cva6 && cd cva6 && git checkout master || cd cva6 && git pull

define GEN_SIM_RULES
.PHONY: sim_$(sim_top)

sim_$(sim_top): $$(V_DIR)/$(sim_top)/Vsim_$(sim_top).mk $$(SIM_SRC)/sim_$(sim_top).cpp $$(call rwildcard,$$(SIM_SRC)/$(sim_top),*.cpp) $$(call rwildcard,$$(SIM_SRC)/$(sim_top),*.c) $(CAPN_PATH)/lib/*.o $$(srcs)
	@make -j$$(shell nproc) -C $$(V_DIR)/$(sim_top) -f V$(sim_top).mk V$(sim_top)
	@echo "============================================================================================"

$$(V_DIR)/$(sim_top)/Vsim_$(sim_top).mk: $$(call rwildcard,$$(SIM_SRC)/$(sim_top),*.cpp) $$(call rwildcard,$$(SIM_SRC)/$(sim_top),*.c) $(CAPN_PATH)/lib/*.o $$(srcs)
	@mkdir -p $$(V_DIR)/$(sim_top)
	@mkdir -p $$(V_DIR)/$(sim_top)/$$(SIM_SRC)
	$$(VERILATOR) -j $$(shell nproc) \
		-Wall -Werror-IMPLICIT -Werror-PINMISSING \
		$$(V_FLAGS) \
		--MMD --MP $$(SIM_DEFS) \
	 	--Mdir $$(V_DIR)/$(sim_top) --cc -O3 \
		-CFLAGS "$$(V_CCFLAGS) -I$$(PWD)$$(SIM_SRC)/$(sim_top)" \
	 	-LDFLAGS "$$(V_LDFLAGS)" \
		-I$$(SRC) -I$$(INCLUDE_DIR) \
		--exe $$(PWD)$$(SIM_SRC)/sim_$(sim_top).cpp $$(call rwildcard,$$(PWD)$$(SIM_SRC)/$(sim_top),*.cpp) $$(call rwildcard,$$(PWD)$$(SIM_SRC)/$(sim_top),*.c) $(CAPN_PATH)/lib/*.o \
		-sv --top-module $(sim_top) --trace --trace-structs $$(srcs) || true
	@echo "============================================================================================"
endef

$(foreach sim_top,$(sim_tops), \
	$(eval $(GEN_SIM_RULES)) \
)

sim: sim_$(DEFAULT_TOP_MODULE)

clean:
	rm -rf $(V_DIR)

-include $(deps)
