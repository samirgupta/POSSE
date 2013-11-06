#! /bin/bash

# take a word
file=$1

# count up each one
cat $file | while read word; do
# add up for verb vs noun in normal
ratios=`../context/countWord.sh $word`
ratio=`echo "scale=4;$ratios" | bc` 
echo "$ratio,$word" >> results
done

# sort by ratio
sort results -o results