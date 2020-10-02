#!/bin/bash

export REPO_ROOT=$(pwd)
cd picolibc_support
git clone https://github.com/picolibc/picolibc.git picolibc-git

## include own iob lib for printf support in picolibc meson build
cp -r tapasco_iob picolibc-git
sed -i "/subdir('semihost')/a subdir('tapasco_iob')" picolibc-git/meson.build

cd picolibc-git
mkdir -p build

## replace picolibc linker script with own adjusted linker script
## because data sections need to be place immediately to data memory (ram section)
for file in $(find . -name "picolibc.ld")
do
	cp $REPO_ROOT/picolibc_support/linker_script/picolibc_adjusted.ld $file
done

## delete memcpy copying the data section from startup code and reference to __data_source since it is not necessary in our case
for file in $(find . -name "crt0.h")
do
	sed -i '/data_source/d' $file
done

## add link forown iob library for printf support
for file in $(find . -name "picolibc.specs.in")
do
	sed -i "s:--end-group:-ltapascoiob --end-group:" $file
done

## find out if riscv32 or riscv64 GCC must be used
if command -v riscv64-unknown-elf-gcc &> /dev/null
then
	echo "Using RISC-V 64-bit GCC"
	cd build
	# disable tests to prevent failing build with self built compiler
	../scripts/do-configure riscv64-unknown-elf -Dtests=false -Dprefix=$REPO_ROOT/picolibc_support -Dspecsdir=specs $1
	ninja install
elif command -v riscv32-unknown-elf-gcc &> /dev/null
then
	echo "Using RISC-V 32-bit GCC"
	cd scripts
	cp cross-riscv64-unknown-elf.txt cross-riscv32-unknown-elf.txt
	sed -i 's/riscv64/riscv32/' cross-riscv32-unknown-elf.txt
	cd ../build
	../scripts/do-configure riscv32-unknown-elf -Dtests=false -Dprefix=$REPO_ROOT/picolibc_support -Dspecsdir=specs $1
	ninja install
else
	echo "No RISC-V compiler found...exiting"
	exit
fi

## remove git folder
cd $REPO_ROOT/picolibc_support
rm -rf picolibc-git

exit



