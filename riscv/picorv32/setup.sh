#!/bin/bash

if [ ! -d "riscv/picorv32/picorv32" ]; then
	cd riscv/picorv32
	git clone https://github.com/YosysHQ/picorv32.git
	cd picorv32
else
	cd riscv/picorv32/picorv32
	git pull
fi
cd ..
mkdir -p ../../IP/riscv/PicoRV32
cp picorv32/picorv32.v ../../IP/riscv/PicoRV32

cd ../..
vivado -nolog -nojournal -mode batch -source riscv/picorv32/picorv32_ip.tcl
