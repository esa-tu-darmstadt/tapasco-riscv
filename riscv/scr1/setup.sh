#!/bin/bash

mkdir -p IP/riscv/
cd riscv/scr1
rm -rf scr1

git clone https://github.com/7FM/scr1.git
cd scr1
git checkout master

export RV_ROOT=$(pwd)
cd src

vivado -nolog -nojournal -mode batch -source ../../package.tcl

if [ ! -d "../../../../IP/riscv/SCR1/xgui" ]; then
    echo "Unzipping SCR1..."
    unzip risc-v_scr1.zip -d ../../../../IP/riscv/SCR1/
fi

cd ../..
cd ../..

echo "Finished SCR1 Setup!"
