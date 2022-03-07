#!/bin/bash
# This script writes '`include "tapasco_riscv_settings.sv'  line in all sv files. 

printf "Preprocessing files in $1 ...\n"

SRC=$(pwd)
INCLUDE_LINE="\`include \"tapasco_riscv_settings.sv\""

for FILE in $(sed '1d' ../$1)
do
    FILE_PATH="${SRC}/${FILE}"
    #echo "Applying include directive to file" "${SRC}/${FILE}"

    FIRST_LINE=$(head -n 1 $FILE_PATH)
    
    if ! echo $FIRST_LINE | grep -q "$INCLUDE_LINE"; then
        echo "Applying include directive to file" $FILE_PATH
        printf '%s\n%s' "${INCLUDE_LINE}" "$(cat $FILE_PATH)" > $FILE_PATH
    else
        echo "Not applying include directive to file" $FILE_PATH "; Include was already applied!"
    fi
    #echo $FILE
done
