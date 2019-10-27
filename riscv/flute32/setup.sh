#!/bin/bash

mkdir -p IP/riscv/
cd riscv/flute32
git clone https://github.com/bluespec/Flute.git
cd Flute
git apply ../flute_tapasco.patch
cd ..

for ARCH in RV32ACIMU RV64ACIMU
do
	if [ ! -d "../../IP/riscv/Flute$ARCH/xgui" ]; then
		cd Flute/builds/${ARCH}_Flute_verilator
		make compile
		cd ../../..
		vivado -nolog -nojournal -mode batch -source package.tcl -tclargs $ARCH
		unzip bluespec.com_risc-v_flute_$ARCH.zip -d ../../IP/riscv/Flute$ARCH/
	fi 
done

cd ../..

echo "Finished Flute Setup!"
