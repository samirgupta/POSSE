#! /bin/bash

# take a word
word=$1

# search for it in normal methods
grep " $word" ../context/normal.methods > ../context/normal-top/$word.methods 
grep " $word" ../context/normal.fields > ../context//normal-top/$word.fields
# search for in constructors
grep " $word" ../context/cons > ../context/cons-top/$word.methods
# search for in -ed methods
grep " $word" ../context/pp.methods > ../context/pp-top/$word.methods
grep " $word" ../context/pp.fields > ../context/pp-top/$word.fields
#done

# sort them based on location
../context/sort.pl ../context/normal-top/$word.methods
../context/sort.pl ../context/normal-top/$word.fields


# count up each one
# add up for verb vs noun in normal
nverb=$((`wc -l ../context/normal-top/$word.methods.start | awk '{ print $1 }'`+`wc -l ../context/normal-top/$word.fields.single | awk '{ print $1 }'`))
#nnoun=$((`wc -l ../context/normal-top/$word.fields.single | awk '{ print $1 }'`+`wc -l ../context/normal-top/$word.fields.end | awk '{ print $1 }'`))
nnoun=$((`wc -l ../context/normal-top/$word.methods.end | awk '{ print $1 }'`+`wc -l ../context/normal-top/$word.fields.single | awk '{ print $1 }'`+`wc -l ../context/normal-top/$word.fields.end | awk '{ print $1 }'`))
# normal ratio
nadj=$((`wc -l ../context/normal-top/$word.methods.other | awk '{ print $1 }'`+`wc -l ../context/normal-top/$word.fields.other | awk '{ print $1 }'`+`wc -l ../context/normal-top/$word.fields.start | awk '{ print $1 }'`));
#nratio=`echo "scale=4;$nverb/($nnoun+$nverb+$nadj)" | bc`
nratio=`echo "scale=4;$nverb/($nnoun+$nverb)" | bc`
#aratio=`echo "scale=3;$nadj/($nverb+nnoun)" | bc`
#vratio=`echo "scale=3;$nverb/($nadj+$nnoun)" | bc`
#echo "$word,$nratio,$aratio,$vratio,$nverb,$nnoun,$nadj" >> results

echo -n $nratio

# sort by ratio
#sort results -o results

# add up for verb vs noun in constructor
#cverb=$((`wc -l cons-top/$word.methods.single | awk '{ print $1 }'`+`wc -l cons-top/$word.methods.start | awk '{ print $1 }'`))
#cnoun=$((`wc -l cons-top/$word.methods.end | awk '{ print $1 }'`))
# cons ratio
#cratio=`echo "scale=3;$cverb/$cnoun" | bc`


# add up pp ending
#pverb=$((`wc -l pp-top/$word.methods.start | awk '{ print $1 }'`))


#echo "$word $nratio $nverb $nnoun $cratio $cnoun $cverb $pverb" >> results
#done
