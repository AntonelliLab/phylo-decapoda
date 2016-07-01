#!/bin/bash

## This scripts inserts the aligned sequences produced by 'align.sh'
##  into the SUPERSMART database

WORKDIR="../data/cleaned"
cd $WORKDIR

for aln in $(ls *aligned.fa); do
	smrt-utils dbinsert -a $aln -p DECAPODA -d "additional decapoda data" -g 
done

