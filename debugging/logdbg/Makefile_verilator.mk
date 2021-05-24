ifndef CAPN_PATH
	$(error CAPN_PATH is undefined)
endif

SRC ?= scr1/src
SRC_PREFIX ?= scr1/src/
SRC_FILES ?= scr1/src/core.files scr1/src/axi_top.files
ADD_SCRS ?= scr1/src/tb/scr1_memory_tb_axi.sv scr1/src/tb/scr1_top_tb_axi_dmi.sv
INCLUDE_DIR ?= scr1/src/includes
SIM_SRC ?= sim_src
V_DIR ?= sim_build

SIM_DEFS ?= -DRUN_SIM

DEFAULT_TOP_MODULE := scr1_top_tb_axi_dmi

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

.PHONY: all clean sim build scr1

all: preparebuild scr1 sim

preparebuild:
	cp dm_interface.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
	cp tapasco-riscv.capnp.* $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp *.cpp $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp *.c $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp *.h $(SIM_SRC)/$(DEFAULT_TOP_MODULE)
#	cp *.hpp $(SIM_SRC)/$(DEFAULT_TOP_MODULE)

scr1:
	git clone https://github.com/7FM/scr1.git && cd scr1 && git checkout trials || cd scr1 && git pull

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

-include $(deps)