#!/bin/bash

mkdir -p IP/riscv
cd riscv/taiga64_bsv
git clone --recursive git@github.com:esa-tu-darmstadt/Taiga-bsv.git

cd Taiga-bsv
git apply ../taiga64_bsv_tapasco.patch
cd ..

cd Taiga-bsv/core && make clean && make SIM_TYPE=VERILOG ARCH=RV64 ip
cp -r build/ip/* ../../../../IP/riscv
echo "Finished taiga64_bsv Setup!"
