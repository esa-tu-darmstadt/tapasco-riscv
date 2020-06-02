#!/bin/bash
echo "Setting up Orca IP..."
if [ ! -d "Orca/orca" ]; then
	mkdir Orca
	cd Orca
	git clone https://github.com/cahz/orca.git
	cd ..
fi

IP_DIR="IP/riscv/Orca"

if [ ! -d $IP_DIR ]; then
	mkdir -p $IP_DIR
	cd Orca/orca
	git pull
	echo "Copying IP..."
	cp -rf ip/orca/ ../../$IP_DIR/
	cp -rf ip/orca-timer/ ../../$IP_DIR/
fi

echo "Finished Orca setup!"
