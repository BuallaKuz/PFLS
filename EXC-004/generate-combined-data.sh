#!/bin/bash

set -e  # Exit immediately if any command exits with a non-zero status

output_dir="COMBINED-DATA"

## Remove existing output directory if it exists and create a new one
rm -rf "$output_dir" && mkdir "$output_dir"

## Find all directories starting with 'DNA' under RAW-DATA
find RAW-DATA -type d -name 'DNA*' | while read dir; do
    culture=$(basename "$dir")
    new_name=$(awk -v c="$culture" '$1 == c {print $2}' RAW-DATA/sample-translation.txt)

    ## Copy checkm and GTDB taxonomy files with new names
    cp "$dir/checkm.txt" "$output_dir/${new_name}-CHECKM.txt" || echo "Failed to copy ${new_name}-CHECKM.txt"
    cp "$dir/gtdb.gtdbtk.tax" "$output_dir/${new_name}-GTDB-TAX.txt" || echo "Failed to copy ${new_name}-GTDB-TAX.txt"

    mag_idx=1
    bin_idx=1

    ## Loop through all fasta files in the bins directory
    for fasta in "$dir/bins"/*.fasta; do
        bin=$(basename "$fasta" .fasta)

        ## Extract completeness and contamination values using grep and awk
        read comp cont <<< "$(grep "$bin" "$dir/checkm.txt" | awk '{print $13, $14}')"


        ## Determination of file naming based on completeness and contamination
        if [[ "$bin" == "bin-unbinned" ]]; then
            fname="${new_name}_UNBINNED.fa"
        elif (( $(echo "$comp >= 50" | bc -l) && $(echo "$cont < 5" | bc -l) )); then
            fname=$(printf "%s_MAG_%03d.fa" "$new_name" $mag_idx)
            ((mag_idx++))
        else
            fname=$(printf "%s_BIN_%03d.fa" "$new_name" $bin_idx)
            ((bin_idx++))
        fi

        ## Copy fasta files and echo message only if the copy fails
        cp "$fasta" "$output_dir/$fname" || echo "Failed to copy $fname"
    done

done

## Echo success message after all operations
echo "THE SCRIPT HAS WORKED SUCCESSFULLY, GO AHEAD AND CHECK the COMBINED DATA DIRECTORY"
