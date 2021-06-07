ifndef CAPN_PATH
	$(error CAPN_PATH is undefined)
endif

SRC ?= cva6/src
SRC_FILES ?= ../../../riscv/cva6/core.files
ADD_SCRS ?= cva6/tb/ariane_custom_tb_top.sv cva6/tb/ariane_soc_pkg.sv
INCLUDE_DIR ?= cva6/include
SIM_SRC ?= sim_src
V_DIR ?= sim_build

SIM_DEFS ?= -DRUN_SIM

DEFAULT_TOP_MODULE := ariane_custom_tb_top

VERILATOR_PREFIX ?=
VERILATOR := $(VERILATOR_PREFIX)verilator

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

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

.PHONY: all clean sim preparebuild cva6

all: preparebuild cva6 sim

preparebuild:
#	cp dm_interface.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp dm_testbench_interface.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp tapasco-riscv.capnp.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)

cva6:
	git clone https://github.com/jschj/cva6 && cd cva6 && git checkout master || cd cva6 && git pull

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
	rm -f $(SIM_SRC)/$(DEFAULT_TOP_MODULE)/dm_interface.*
	rm -f $(SIM_SRC)/$(DEFAULT_TOP_MODULE)/dm_testbench_interface.*
	rm -f $(SIM_SRC)/$(DEFAULT_TOP_MODULE)/tapasco-riscv.capnp.*

-include $(deps)
