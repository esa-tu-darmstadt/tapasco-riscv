#!/bin/bash

mkdir -p IP/riscv/
cd riscv/piccolo32
git clone https://github.com/bluespec/Piccolo.git
cd Piccolo
git apply ../piccolo_tapasco.patch
cd ..

for ARCH in RV32ACIMU RV64ACIMU
do
	if [ ! -d "../../IP/riscv/Piccolo$ARCH/xgui" ]; then
		cd Piccolo/builds/${ARCH}_Piccolo_verilator
		make compile
		cd ../../..
		vivado -nolog -nojournal -mode batch -source package.tcl -tclargs $ARCH
		unzip bluespec.com_risc-v_piccolo_$ARCH.zip -d ../../IP/riscv/Piccolo$ARCH/
	fi 
done

cd ../..

echo "Finished Piccolo Setup!"
