#!/bin/bash

export REPO_ROOT=$(pwd)
cd picolibc_support
git clone https://github.com/picolibc/picolibc.git picolibc-git
cd picolibc-git
mkdir -p build

## replace picolibc linker script with own adjusted linker script
## because data sections need to be place immediately to data memory (ram section)
for file in $(find . -name "picolibc.ld")
do
	cp $REPO_ROOT/picolibc_support/picolibc_adjusted.ld $file
done

## delete memcpy copying the data section from startup code and reference to __data_source since it is not necessary in our case
for file in $(find . -name "crt0.h")
do
	sed -i '/data_source/d' $file
done

## add linking path for own __iob struct for printf-support
for file in $(find . -name "picolibc.specs.in")
do
	sed -i "s:%{\!T:-L$REPO_ROOT/picolibc_support/tapasco_iob/lib/%M %{\!T:" $file
	sed -i "s:--end-group:-ltapascoiob --end-group:" $file
done

## find out if riscv32 or riscv64 GCC must be used
if command -v riscv64-unknown-elf-gcc &> /dev/null
then
	echo "Using RISC-V 64-bit GCC"
	cd build
	# disable tests to prevent failing build with self built compiler
	../scripts/do-configure riscv64-unknown-elf -Dtests=false -Dprefix=$REPO_ROOT/picolibc_support -Dspecsdir=specs
	ninja install
	export GCC_ARCH=riscv64
elif command -v riscv32-unknown-elf-gcc &> /dev/null
then
	echo "Using RISC-V 32-bit GCC"
	cd scripts
	cp cross-riscv64-unknown-elf.txt cross-riscv32-unknown-elf.txt
	sed -i 's/riscv64/riscv32/' cross-riscv32-unknown-elf.txt
	cd ../build
	../scripts/do-configure riscv32-unknown-elf -Dtests=false -Dprefix=$REPO_ROOT/picolibc_support -Dspecsdir=specs
	ninja install
	export GCC_ARCH=riscv32
else
	echo "No RISC-V compiler found...exiting"
	exit
fi



## remove git folder
cd $REPO_ROOT/picolibc_support
rm -rf picolibc-git

## compile iob.c for all supported architectures of compiler to have full compatibility with picolib
cd tapasco_iob
mkdir -p lib
if [ "$GCC_ARCH" == "riscv32" ]
then
	export AR_TARGET=--target=elf32-littleriscv
fi
while read line
do
	IFS=';' read -a array <<< "$line";
	len=${#array[@]}
	if [ "$len" -gt "1" ]
	then
		IFS='@' read -a array2 <<< "${array[1]}"
		mkdir -p "lib/${array[0]}"
		$GCC_ARCH-unknown-elf-gcc -c --specs=$REPO_ROOT/picolibc_support/specs/picolibc.specs -${array2[1]} -${array2[2]} -o lib/${array[0]}/iob.o iob.c
		$GCC_ARCH-unknown-elf-ar $AR_TARGET -cq lib/${array[0]}/libtapascoiob.a lib/${array[0]}/iob.o
	else
		$GCC_ARCH-unknown-elf-gcc -c --specs=$REPO_ROOT/picolibc_support/specs/picolibc.specs -o lib/iob.o iob.c
		$GCC_ARCH-unknown-elf-ar $AR_TARGET -cq lib/libtapascoiob.a lib/iob.o
	fi
done <<< $($GCC_ARCH-unknown-elf-gcc --print-multi-lib)


