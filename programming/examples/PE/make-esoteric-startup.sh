#!/bin/bash
# use this script to generate program bytes that are easily traceable in GTKwave

N=$1

BYTES="0"

for i in $(seq $((N - 1)));
do
	BYTES="$BYTES, $i"
done

echo $BYTES

cat > $2 << EOF
.section ".text.init"
.globl _start
_start:
        .word $BYTES
init_stack:
	lui sp, 0x00488
	addi sp, sp, 0x000
	jal main
EOF

