#!/bin/bash

mkdir -p IP/riscv/
cd riscv/cva6
rm -rf cva6
git clone --recursive https://github.com/jschj/cva6.git
#git clone https://github.com/jschj/cva6.git
cd cva6
git apply ../submodulePatches.patch
#git apply ../cva6_tapasco.patch
export RV_ROOT=$(pwd)
#cd ..
#cd src

../preprocess_includes.sh "core.files"
../preprocess_includes.sh "dm_core.files"
../preprocess_includes.sh "clint_core.files"

# Pre compile system verilog files to verilog
sv2v -D SYNTHESIS -D VERILATOR -I "include" -I "src/common_cells/include" -I "src/common_cells/include/common_cells" -w cva6_top.v `cat ../core.files`
# Dirty hack to remove a type cast that vivado does not like...
sed -i "s/int unsigned'//g" cva6_top.v
sv2v -D SYNTHESIS -D VERILATOR -I "include" -I "src/common_cells/include" -I "src/common_cells/include/common_cells" -w dm_top.v `cat ../dm_core.files`
sv2v -D SYNTHESIS -D VERILATOR -I "include" -I "src/common_cells/include" -I "src/common_cells/include/common_cells" -w clint_top.v `cat ../clint_core.files`
mv cva6_top.v cva6_top.sv
mv dm_top.v dm_top.sv
mv clint_top.v clint_top.sv

vivado -nolog -nojournal -mode batch -source ../package.tcl
vivado -nolog -nojournal -mode batch -source ../package_timer.tcl
vivado -nolog -nojournal -mode batch -source ../package_dm.tcl

if [ ! -d "../../../IP/riscv/CVA6/cva6" ]; then
    mkdir -p "../../../IP/riscv/CVA6/cva6"
    echo "Unzipping CVA6..."
    unzip risc-v_cva6.zip -d ../../../IP/riscv/CVA6/cva6
fi

if [ ! -d "../../../IP/riscv/CVA6/timer" ]; then
    mkdir -p "../../../IP/riscv/CVA6/timer"
    echo "Unzipping CVA6 Timer..."
    unzip risc-v_cva6_timer.zip -d ../../../IP/riscv/CVA6/timer
fi

if [ ! -d "../../../IP/riscv/CVA6/dm" ]; then
    mkdir -p "../../../IP/riscv/CVA6/dm"
    echo "Unzipping CVA6 Debug Module..."
    unzip risc-v_cva6_dm.zip -d ../../../IP/riscv/CVA6/dm
fi


cd ../../..
#cd ../..

echo "Finished CVA6 Setup!"
