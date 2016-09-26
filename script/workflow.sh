#!/bin/bash
# SUPERSMART workflow for Decapoda. Must run script 'insert-seqs.sh' in order to include the custom species!

# INGROUP=$1
OUTGROUP=Polycheles,Stereomastis,Astacus,Pacifastacus,Pontastacus,Austropotamobius,Cherax,Homarus,Nephrops,Metanephrops,Enoplometopus,Palinurus,Thenus,Scyllarides,Orconectes,Cambarellus,Callianassa,Upogebia,Callianidea,Thomassinia,Thalassina

export WORKDIR=$PWD/../results/2016-09-26/$INGROUP
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
smrt taxize -i ../../../data/Meiura_names.txt -w $WORKDIR -v

smrt align -w $WORKDIR -v

## Copy custom alignments into alignment folder
cp ../../../data/cleaned/*inserted*.fa alignments/

smrt orthologize -v

export SUPERSMART_BACKBONE_MIN_COVERAGE=3
export SUPERSMART_BACKBONE_MAX_COVERAGE=10
smrt bbmerge -o supermatrix.phy -v

export SUPERSMART_NODES=4
smrt bbinfer -i exabayes -t species.tsv -o backbone.dnd -s supermatrix.phy -v

smrt bbreroot -g $OUTGROUP --smooth -w $WORKDIR -v

## copy fossil table (with only one age) and calibrate
cp ../../../data/fossils.tsv .
smrt bbcalibrate -t backbone-rerooted.dnd -f fossils.tsv -s supermatrix.phy -w $WORKDIR -v

smrt consense -i chronogram.dnd -b 0.2 --prob -w $WORKDIR -v

export SUPERSMART_CLADE_MAX_DISTANCE="0.2"
export SUPERSMART_CLADE_MIN_DENSITY="0.5"

smrt bbdecompose -w $WORKDIR -v

smrt clademerge --enrich -w $WORKDIR -v

smrt cladeinfer --ngens=30_000_000 --sfreq=1000 --lfreq=1000 -w $WORKDIR -v

smrt cladegraft -w $WORKDIR -v
