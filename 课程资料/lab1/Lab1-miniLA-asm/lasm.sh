#!/bin/bash

if [ -z "$1" ]
then
    echo "Input file is null. Please try again."
    echo "Usage: ./lasm.sh xxx.asm"
    exit 1
else
    input_file=$(basename $1)
    file_name=${input_file%%.*}

    text_suffix="_text"
    data_suffix="_data"
    out_text=$file_name$text_suffix
    out_data=$file_name$data_suffix

    rm $file_name*.bin $file_name*.hex > /dev/null 2>&1

    loongarch32r-linux-gnusf-as $1 -o $file_name.o

    if [ $? -ne 0 ]
    then
        exit 1
    fi

    loongarch32r-linux-gnusf-objcopy -S -j .text -O binary $file_name.o text.bin
    od -w4 -tx4 -An text.bin | sed 's/^[ ]*//g' > $out_text.hex

    loongarch32r-linux-gnusf-objcopy -S -j .data -O binary $file_name.o data.bin
    if [[ -f data.bin && -s data.bin ]]
    then
        dd if=text.bin of=text1.bin bs=65536 conv=sync > /dev/null 2>&1
        cat text1.bin data.bin > $file_name.bin
        od -w4 -tx4 -An data.bin | sed 's/^[ ]*//g' > $out_data.hex
        rm text1.bin
    else
        cp text.bin $file_name.bin
        cp $out_text.hex $file_name.hex
        rm $out_text.hex $out_data.hex > /dev/null 2>&1
    fi

    rm $file_name.o text.bin data.bin
fi
