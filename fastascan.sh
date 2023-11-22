#!/bin/zsh
FOLDER=$1
N=$2

if [[ -z $FOLDER ]]
then
    FOLDER=$(pwd)
fi 

if [[ -z $N ]]
then
    N=0
fi

fasta_files=$(find . "$FOLDER" -type f -name "*.fasta" -or -type f -name "*fa")
unique_ids=""

echo "\n----FASTAscan Report----"
echo "Folder selected:\t\t" $FOLDER 
echo "Number of files:\t\t" $(echo $fasta_files | wc -l)

for file in $(echo $fasta_files); do
    unique_ids+=$(grep ">" $file | awk '{print $1}' | sort | uniq -c)
done

echo "Total umber of unique IDs:\t" $(echo $unique_ids | sort | uniq -c | wc -l)


for file in $(echo $fasta_files); do
    echo "===$file :"
    if [[ -h $file ]]; then 
		echo "(SYMBOLIC LINK)"
	else
		echo "(NOT A SYMBOLIC LINK)"
	fi
    echo "Number of sequences:" $(grep ">" $file | wc -l)
    seqs_length=0
    while read -r line; do
        if [[ $line != ">*" ]]; then
            seqs_length=$(( $seqs_length + $(echo $line | awk '/[^A-Za-z]/ { gsub(/[^A-Z]/, ""); print }' | wc -c) ))
        fi
    done < "$file"
    echo "Total sequence length: " $seqs_length
    
    if [[ $N -gt 0 ]]; then
        if [[ $(cat $file | wc -l) -lt  $(( 2 * $N )) ]]; then
            cat $file
        else
            head -n $N $file
            echo "..."
            tail -n $N $file
            echo "\n"
        fi
    fi
done



