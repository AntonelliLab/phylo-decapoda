#!/bin/bash
# SUPERSMART workflow for Decapoda. Must run script 'insert-seqs.sh' in order to include the custom species!

INGROUP=Decapoda
OUTGROUP=Eumunida

export WORKDIR=$PWD/../results/2016-07-06
# `date +%Y-%m-%d`

if [ ! -d $WORKDIR ]; then
    mkdir $WORKDIR
fi

# copy this script in the working directory so 
# parameter settings are stored
cp $BASH_SOURCE $WORKDIR

## copy config file to workdir so parameters 
cp $SUPERSMART_HOME/conf/supersmart.ini $WORKDIR

cd $WORKDIR

## Start the SUPERSMART pipeline
smrt taxize -r $INGROUP,$OUTGROUP -b -w $WORKDIR

smrt align -w $WORKDIR

## Copy custom alignments into alignment folder
cp ../../data/cleaned/*inserted*.fa alignments/

smrt orthologize

export SUPERSMART_BACKBONE_MIN_COVERAGE=4
export SUPERSMART_BACKBONE_MAX_COVERAGE=4
smrt bbmerge -o supermatrix-cover-4-4.phy

smrt bbinfer --inferencetool=exabayes -t species.tsv -o backbone.dnd -s supermatrix-cover-4-4.phy

smrt bbreroot -g $OUTGROUP --smooth --ultrametricize -w $WORKDIR

smrt consense -i backbone-rerooted.dnd -b 0.2 --prob -w $WORKDIR

export SUPERSMART_CLADE_MAX_DISTANCE="0.2"
export SUPERSMART_CLADE_MIN_DENSITY="0.5"

smrt bbdecompose -w $WORKDIR

smrt clademerge --enrich -w $WORKDIR

smrt cladeinfer --ngens=30_000_000 --sfreq=1000 --lfreq=1000 -w $WORKDIR

smrt cladegraft -w $WORKDIR
