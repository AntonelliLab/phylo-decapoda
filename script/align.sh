#!/bin/bash

## This script uses muscle to align the cleaned decapoda
## input files, produced by 'process-deflines.R'

WORKDIR="../data/seqs-jan"

for i in $(ls $WORKDIR/*.fa); do
	echo "Aligning file $i"
	outfile=${i/.fa/-aligned.fa}
	echo "Outfile: $outfile"
	muscle -in $i -out $outfile
done

