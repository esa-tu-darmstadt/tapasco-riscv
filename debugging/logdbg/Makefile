CC := c++
FLAGS := -std=c++17 -g -I sim_src/scr1_top_tb_axi_dmi/

ifndef CAPN_PATH
	$(error CAPN_PATH is undefined)
endif

all: main.cpp dm_interface.cpp tapasco-riscv.capnp.c $(CAPN_PATH)/lib/*.o
	$(CC) -o logdbg $(FLAGS) $^ -lpthread
