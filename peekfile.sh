#!/bin/zsh
FILE=$1
L_COUNT=$2
if [[ -z $L_COUNT ]]
then
	L_COUNT=3
fi
if [[ $(wc -l < $FILE) -le $((2 * $L_COUNT)) ]]
then
	echo "Number of lines in file smaller than requested"
	cat $FILE
else
	echo "displaying requested lines"
	head -n $L_COUNT $FILE
	echo ...
	tail -n $L_COUNT $FILE
fi
