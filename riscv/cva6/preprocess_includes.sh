#!/bin/bash

printf "Preprocessing files in core.files ...\n"

SRC=$(pwd)
INCLUDE_LINE="\`include \"tapasco_riscv_settings.sv\""

for FILE in $(cat ../core.files)
do
    FILE_PATH="${SRC}/${FILE}"
    #echo "Applying include directive to file" "${SRC}/${FILE}"

    FIRST_LINE=$(head -n 1 $FILE_PATH)
    
    if ! echo $FIRST_LINE | grep -q "$INCLUDE_LINE"; then
        echo "Applying include directive to file" $FILE_PATH
        printf "${INCLUDE_LINE}\n $(cat $FILE_PATH)" > $FILE_PATH
    else
        echo "Not applying include directive to file" $FILE_PATH "; Include was already applied!"
    fi
    #echo $FILE
done