#!/bin/bash

## This script uses muscle to align the cleaned decapoda
## input files, produced by 'process-deflines.R'

WORKDIR="../data/cleaned/"

for i in $(ls $WORKDIR); do
	echo "Aligning file $i"
	outfile=${i/.fa/-aligned.fa}
	echo "Outfile: $outfile"
	muscle -in $WORKDIR/$i -out $WORKDIR/$outfile
done

