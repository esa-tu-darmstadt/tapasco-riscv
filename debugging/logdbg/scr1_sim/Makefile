# Capnproto is requried for the openocd simulation interface
ifndef CAPN_PATH
	$(error CAPN_PATH is undefined)
endif

# Core specific settings:
# Specify the root (system-)verilog directory of the core as relative path from the Makefile
SRC ?= scr1/src
# Specify files that are `cat`ed to retrieve the required (system-)verilog files
SRC_FILES ?= scr1/src/core.files scr1/src/axi_top.files
# Optionally specify a prefix that should be added to all entries in the files listed in $SRC_FILES
SRC_PREFIX ?= scr1/src/
# Additional (system-)verilog that are required in the simulation but not listed in $SRC_FILES
ADD_SRCS ?= scr1/src/tb/scr1_memory_tb_axi.sv scr1/src/tb/scr1_top_tb_axi_dmi.sv
# Include directories, which verilator should use to resolve `include directives in the (system-)verilog code
INCLUDE_DIR ?= scr1/src/includes
# Specify the top module to use for the simulation
DEFAULT_TOP_MODULE := scr1_top_tb_axi_dmi

# Core specific verilator settings, i.e. set defines, ignore warnings etc
V_FLAGS :=

# Typically you do not have to adjust the following settings
# Directory that contains the verilator c++ testbench/simulation code
SIM_SRC ?= sim_src
# simulation build directory
V_DIR ?= sim_build

# Additional defines to set for simulation specific verilog preprocessor directives
SIM_DEFS ?= -DRUN_SIM

# provide the option to set a prefix where to find verilator if not already set via the PATH variable
# i.e. `make VERILATOR_PREFIX=/home/user/verilator`
VERILATOR_PREFIX ?=
VERILATOR := $(VERILATOR_PREFIX)verilator

# Helper function to recursively search for files with a given pattern, i.e. all c++ files in a directory and all its subdirectories
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

# Get all source files listed in the $SRC_FILES and prepend the $SRC_PREFIX
srcs := $(addprefix $(SRC_PREFIX),$(shell cat $(SRC_FILES)))
# Also add the additional source files
srcs += $(ADD_SRCS)

sim_targets := $(wildcard $(SIM_SRC)/sim_*.cpp)
sim_tops := $(patsubst sim_%.cpp,%,$(notdir $(sim_targets)))

deps := $(call rwildcard,$(V_DIR),*.d)

# Get the directory of the makefile. This is needed to build some relative paths
PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Add all c/c++ files of the shared directory to the c++ simulation files
# This includes i.e the code for handling openocd connections
COMMON_DIR := $(PWD)../common
srcs += $(call rwildcard,$(COMMON_DIR),*.cpp)
srcs += $(call rwildcard,$(COMMON_DIR),*.c)

# verilated c++ files compile flags, i.e. add include paths for capnproto
V_CCFLAGS := -g -Wall -O3 -I$(PWD)$(SIM_SRC) -I$(COMMON_DIR) -I$(CAPN_PATH)/lib
V_LDFLAGS := -lpthread

.PHONY: all clean sim preparebuild

all: preparebuild sim

# make target to get the core source code / update it
preparebuild:
	git clone https://github.com/7FM/scr1.git && cd scr1 && git checkout master || cd scr1 && git pull

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
