#!/bin/bash

if [ ! -d "riscv/vexriscv/VexRiscv" ]; then
	cd riscv/vexriscv
	git clone https://github.com/SpinalHDL/VexRiscv.git
	git clone https://github.com/SpinalHDL/SpinalHDL.git -b master
	cd SpinalHDL
	sbt clean compile publishLocal
	cd ../VexRiscv
else
	cd riscv/vexriscv/VexRiscv
	git pull
fi

git reset HEAD --hard
git apply ../vexriscv_tapasco.patch
sbt "runMain vexriscv.demo.VexRiscvAxi4WithIntegratedJtag"

mkdir -p ../../../IP/riscv/VexRiscv
cp VexRiscvAxi4.v ../../../IP/riscv/VexRiscv

cd ../../..

vivado -nolog -nojournal -mode batch -source riscv/vexriscv/vexriscv_ip.tcl
