#!/usr/bin/env python3

import argparse
import os.path
import sys
import binascii


parser = argparse.ArgumentParser(description='Convert binary file to verilog rom')
parser.add_argument('filename', metavar='filename', nargs=1,
                   help='filename of input binary')

args = parser.parse_args()
file = args.filename[0]

# check that file exists
if not os.path.isfile(file):
    print("File {} does not exist.".format(filename))
    sys.exit(1)

filename = os.path.splitext(file)[0]

with open(file, 'rb') as f:
    rom = binascii.hexlify(f.read())
    rom = list(map(chr, rom))
    rom = map(''.join, zip(rom[::2], rom[1::2]))

# convert map to list
rom = list(rom)

# align to 64 bit
align = (int((len(rom) + 7) / 8 )) * 8

for i in range(len(rom), align):
    rom.append("00")


# Auto generate string for initial block
rom_str = ""
# process in junks of 64 bit (8 byte)
for i in reversed(range(int(len(rom)/8))):
    instr_str = "".join(rom[i*8+4:i*8+8][::-1]) + "_" + "".join(rom[i*8:i*8+4][::-1])
    # Skip zero regions!
    if instr_str != "00000000_00000000":
        rom_str += "        ram["+str(i)+"] = 64'h" + instr_str + ";\n"

print (rom_str)
