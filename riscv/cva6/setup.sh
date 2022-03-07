#!/bin/bash

mkdir -p IP/riscv/
cd riscv/cva6

rm -rf cva6
git clone --recursive https://github.com/jschj/cva6.git
cd cva6
git apply ../submodulePatches.patch

export RV_ROOT=$(pwd)

# Add settings include to all files
../preprocess_includes.sh "core.files"
../preprocess_includes.sh "dm_core.files"
../preprocess_includes.sh "clint_core.files"

# Package cva6 components
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

echo "Finished CVA6 Setup!"
