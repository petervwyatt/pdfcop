#!/bin/bash
filename=$1
n=1
while IFS= read -r line; do
    echo -n "$n: "
    printf "$line" | od -A n -w40 -v -t c
    printf "$line" | antlr4-parse ./src/main/antlr4/com/itextpdf/antlr/PdfStream.g4 content_stream -tokens
    if [ $? != 0 ]; then
        echo "FAIL!";
    else
        echo "PASS";
    fi
    n=$((n+1))
done < $filename
