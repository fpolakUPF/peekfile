#!/bin/zsh
FOLDER=$1
N=$2

# Check if the FOLDER argument was passed
if [[ -z "$FOLDER" ]]; then
    FOLDER="./"
fi 

# Check if the N argument was passed
if [[ -z "$N" ]]; then
    N=0
fi

# Create a list of all fasta files in current folder and subfolders
fasta_files=$(find . "$FOLDER" -type f -name "*.fasta" -or -type f -name "*fa")

# Exit script if no fasta files are found in the provided folder
if [[ $(find . "$FOLDER" -type f -name "*.fasta" -or -type f -name "*fa" | wc -l) -lt 1 ]]; then
    echo "No fasta files found"
    exit
fi

# Print report header
echo "\n----FASTAscan Report----"
echo "Number of files:\t\t" $(echo $fasta_files | wc -l)

# Find all unique sequence IDs
unique_ids=""
for file in $(echo $fasta_files); do
    unique_ids+=$(grep ">" $file | awk '{print $1}' | sort | uniq -c)
done
echo "Total umber of unique IDs:\t" $(echo $unique_ids | sort | uniq -c | wc -l) "\n"

# Iterate through all fasta files
for file in $(echo $fasta_files); do
    # File header
    echo "===$file :"
    # Check if the file is a symbolic link or not
    if [[ -h $file ]]; then 
		echo "(SYMBOLIC LINK)"
	else
		echo "(NOT A SYMBOLIC LINK)"
	fi

    # Check if the file contains amino acid or nucleotide sequences
    if [[ $(grep -v ">" $file | grep "[DEFHIKLMPQRSVWY]" | wc -l) -gt 0 ]]; then
        echo "File contains amino acid sequences"
    else
        echo "File contains nucleotide sequences"
    fi

    echo "Number of sequences:\t" $(grep ">" $file | wc -l) # total number of sequences in file
    seqs_length=0

    # Iterate through each line in file 
    # and update the seqs_length variable to get the total sequence length
    while read -r line; do
        if [[ $line != ">*" ]]; then
            seqs_length=$(( $seqs_length + $(echo $line | awk '{ gsub(/[^A-Z]/, ""); print }' | wc -c) ))
        fi
    done < "$file"
    echo "Total sequence length:\t" $seqs_length
    
    # Print the requested number of lines
    if [[ $N -gt 0 ]]; then
        if [[ $(cat $file | wc -l) -lt  $(( 2 * $N )) ]]; then
            cat $file
        else
            head -n $N $file
            echo "..."
            tail -n $N $file
            echo "\n"
        fi
    else
        echo "\n"
    fi
done

echo "----END----"