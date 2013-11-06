#! /bin/bash

file=$1
base=`basename $file ".field-names"`
rm ../9-Names/$base.field-in-methods;
touch ../9-Names/$base.field-in-methods;
IFS=$'\n'
for line in $(cat $file); do 
	res=`echo $line | grep " "`;
	if [[ ${#res} > 0  ]]; 
	then
		echo "-- $line" >> ../9-Names/$base.field-in-methods;
		grep "$line" ../3-Phrases/$base >> ../9-Names/$base.field-in-methods;
	fi
done 
