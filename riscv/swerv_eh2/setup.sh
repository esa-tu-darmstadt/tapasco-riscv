#!/bin/bash

mkdir -p IP/riscv/
cd riscv/swerv_eh2
git clone https://github.com/esa-tu-darmstadt/Cores-SweRV-EH2.git
cd Cores-SweRV-EH2
git checkout branch-1.4
# git apply ../swerv_tapasco.patch

# run swerv configuration
export RV_ROOT=$(pwd)
configs/swerv.config -unset=dccm_enable -unset=iccm_enable -unset=icache_enable -set=fpga_optimize=1


# patch eh2_pdef.vh to avoid circular include
echo "Patching swerv_eh2: eh2_pdef.vh"
sed -i '1 i\`ifndef pdef_sec \n`define pdef_sec' snapshots/default/eh2_pdef.vh
sed -i '$ a`endif' snapshots/default/eh2_pdef.vh

cd ..
vivado -nolog -nojournal -mode batch -source package.tcl

if [ ! -d "../../IP/riscv/swerv_eh2" ]; then
	echo "Unzipping swerv_eh2..."
	unzip wdc_risc-v_swerv_eh2.zip -d ../../IP/riscv/swerv_eh2/
fi

cd ../..

echo "Finished SweRV_EH2 Setup!"
