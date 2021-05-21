CC := c++
FLAGS := -std=c++17 -g

ifndef CAPN_PATH
	$(error CAPN_PATH is undefined)
endif

all: main.cpp dm_interface.cpp tapasco-riscv.capnp.c $(CAPN_PATH)/lib/*.o
	$(CC) -o logdbg $(FLAGS) $^ -lpthread
