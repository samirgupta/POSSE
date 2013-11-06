#!/bin/bash

file=$1;
sort -u -t"|" -k 1,1 "$file" > "$file.noDup"

mv "$file.noDup" $file
