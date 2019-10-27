#!/bin/bash

mkdir -p IP/riscv/
cd riscv/taiga
git clone https://gitlab.com/sfu-rcl/Taiga.git
cd Taiga
git apply ../taiga_tapasco.patch
cd ..
vivado -nolog -nojournal -mode batch -source package.tcl

if [ ! -d "../../IP/riscv/Taiga/xgui" ]; then
	echo "Unzipping Taiga..."
	unzip sfu-rcl_risc-v_taiga.zip -d ../../IP/riscv/Taiga/
fi

cd ../..

echo "Finished Taiga Setup!"
