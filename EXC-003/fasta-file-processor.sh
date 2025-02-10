## for the code to stop running anytime there is an error (From Meren's old script EXC-002)
set -e

## maximum number parameters or inputs
if [ "$#" -ne 1 ]; then
    echo 'PLEASE RUN IT ON JUST A SINGLE FASTA FILE'; exit 1
fi

## number of sequence (The only command I remember very well)
num_seq=$(grep '>' $1 | wc -l)

## Extract and put sequences in one line
## Just to make sure sequences are in one line so that bash won't count spaces
## This code was stolen from solution of EXC-001 (I'm sorry Meren)
# I removed the (print;) part because Meren said it will print an empty line and it worked....well 'Hallelujah to that' 
sequence=$(awk '/>/ {if (seq) print seq; seq=""; next} {seq=seq $0} END {print seq}' "$1")


num_of_sequence_in_a_file=$(echo "$sequence" | wc -l)

## length of the longest sequences (last awk Idea from chancellors code before EXC-001)
total_length__seq=$(echo "$sequence" | awk '{print length}' | awk '{sum_seq += $1; count++} END {print sum_seq}')

## lets assing length of sequences to make it simpler
length_of_seq=$(echo "$sequence" | awk '{print length}')

## length of longest sequence
longest_seq=$(echo "$length_of_seq" | sort -n | tail -n 1)

## Length of the shortest sequence
shortest_seq=$(echo "$length_of_seq" | sort -n | head -n 1)

## average length of sequence (Guess what...This is also from the chancellors exercise)
average_seq_length=$(echo "scale=2; $total_length__seq / $num_seq" | bc -l)

##GC content calculation (Thank you for the tip)
gc_con=$(echo "$sequence" | awk '{gc_count += gsub(/[GgCc]/, "", $1)} END {print gc_count}')

##at content calculation (I just copied)
at_con=$(echo "$sequence" | awk '{at_count += gsub(/[AaTt]/, "", $1)} END {print at_count}')

## Sum of gc and ac content
sum_of_all_contents=$(echo "$at_con + $gc_con" | bc -l)

## gc percentage calculation

per_gc_content=$(echo "scale=2; ($gc_con / $sum_of_all_contents) * 100" | bc -l)

## what to display
echo "FASTA File Statistics:"
echo "----------------------"
echo "Number of sequences: $num_seq"
echo "Total length of sequences: $total_length__seq"
echo "Length of the longest sequence: $longest_seq"
echo "Length of the shortest sequence: $shortest_seq"
echo "Average sequence length: $average_seq_length"
echo "GC Content (%): $per_gc_content"
