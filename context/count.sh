#! /bin/bash

# take a word
#cat top200 | while read word; do 
# search for it in normal methods
#grep " $word" normal.methods > ./normal-top/$word.methods 
#grep " $word" normal.fields > ./normal-top/$word.fields
# search for in constructors
#grep " $word" cons > ./cons-top/$word.methods
# search for in -ed methods
#grep " $word" pp.methods > ./pp-top/$word.methods
#grep " $word" pp.fields > ./pp-top/$word.fields
#done
# sort them based on location
#./sort.pl ./*-top/*


# count up each one
cat top200 | while read word; do
# add up for verb vs noun in normal
nverb=$((`wc -l normal-top/$word.methods.start | awk '{ print $1 }'`))
nnoun=$((`wc -l normal-top/$word.methods.end | awk '{ print $1 }'`+`wc -l normal-top/$word.fields.single | awk '{ print $1 }'`+`wc -l normal-top/$word.fields.end | awk '{ print $1 }'`))
# normal ratio
nadj=$((`wc -l normal-top/$word.methods.other | awk '{ print $1 }'`+`wc -l normal-top/$word.fields.other | awk '{ print $1 }'`+`wc -l normal-top/$word.fields.start | awk '{ print $1 }'`));
nratio=`echo "scale=3;$nnoun/($nverb+$nadj)" | bc`
aratio=`echo "scale=3;$nadj/($nverb+nnoun)" | bc`
vratio=`echo "scale=3;$nverb/($nadj+$nnoun)" | bc`
echo "$word,$nratio,$aratio,$vratio,$nverb,$nnoun,$nadj" >> results

# sort by ratio
sort results -o results

if [ 0 ]; then
# add up for verb vs noun in constructor
cverb=$((`wc -l cons-top/$word.methods.single | awk '{ print $1 }'`+`wc -l cons-top/$word.methods.start | awk '{ print $1 }'`))
cnoun=$((`wc -l cons-top/$word.methods.end | awk '{ print $1 }'`))
# cons ratio
cratio=`echo "scale=3;$cverb/$cnoun" | bc`


# add up pp ending
pverb=$((`wc -l pp-top/$word.methods.start | awk '{ print $1 }'`))


#echo "$word $nratio $nverb $nnoun $cratio $cnoun $cverb $pverb" >> results
fi
done