#!/bin/bash

mkdir -p IP/riscv
cd riscv/taiga32_bsv
git clone --recursive git@github.com:esa-tu-darmstadt/Taiga-bsv.git
cd Taiga-bsv
git apply ../taiga32_bsv_tapasco.patch
cd ..
cd Taiga-bsv/core && make clean && make SIM_TYPE=VERILOG ip
cp -r build/ip/* ../../../../IP/riscv
echo "Finished taiga32_bsv Setup!"
