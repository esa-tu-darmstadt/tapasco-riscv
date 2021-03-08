#!/bin/bash

mkdir -p IP/riscv/
cd riscv/swerv
git clone https://github.com/westerndigitalcorporation/swerv_eh1.git
cd swerv_eh1
git apply ../swerv_tapasco.patch
export RV_ROOT=$(pwd)
cd configs
./swerv.config -set reset_vec=0x0 -set dccm_enable=1 -set iccm_enable=1 -set icache_enable=1
cd ../..
vivado -nolog -nojournal -mode batch -source package.tcl

if [ ! -d "../../IP/riscv/SweRV/xgui" ]; then
	echo "Unzipping swerv..."
	unzip wdc_risc-v_swerv_eh1.zip -d ../../IP/riscv/SweRV/
fi

cd ../..

echo "Finished SweRV Setup!"
