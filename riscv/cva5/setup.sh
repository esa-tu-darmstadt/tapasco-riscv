#!/bin/bash

mkdir -p IP/riscv/
cd riscv/cva5
git clone https://github.com/openhwgroup/cva5.git
cd cva5
git apply ../cva5_tapasco.patch
cd ..
vivado -nolog -nojournal -mode batch -source package.tcl

if [ ! -d "../../IP/riscv/cva5/xgui" ]; then
	echo "Unzipping cva5..."
	unzip openhwgroup_risc-v_cva5.zip -d ../../IP/riscv/cva5/
fi

cd ../..

echo "Finished Taiga Setup!"
