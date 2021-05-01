#!/bin/bash

mkdir -p IP/riscv/
cd riscv/cva6
rm -rf cva6
git clone https://github.com/jschj/cva6.git
cd cva6
#git checkout master
#git checkout trials
#git apply ../scr1_tapasco.patch
export RV_ROOT=$(pwd)
#cd ..
cd src

#vivado -nolog -nojournal -mode batch -source ../../package.tcl

#if [ ! -d "../../../../IP/riscv/CVA6/xgui" ]; then
#    echo "Unzipping SCR1..."
#    unzip risc-v_cva6.zip -d ../../../../IP/riscv/CVA6/
#fi

#cd ../..
#cd ../..

#echo "Finished CVA6 Setup!"
