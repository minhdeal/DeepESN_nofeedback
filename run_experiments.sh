#!/bin/bash

# Virtual Environment
source ~/keras-tf-venv3/bin/activate

# Don't want numpy to use OMP. Parallelization via SCOOP.
export OMP_NUM_THREADS=1

# Find config/data files and names
shopt -s nullglob
BASEDIR=.
CONFIGDIR=configs/user
RECONSTRUCTDIR=configs/reconstruct
RESERVOIRDIR=configs/reservoir

CONFIGPREFIX=${BASEDIR}/${CONFIGDIR}/
RECONSTRUCTPREFIX=${BASEDIR}/${RECONSTRUCTDIR}/
RESERVOIRPREFIX=${BASEDIR}/${RESERVOIRDIR}/
CONFIGFILES=(${CONFIGPREFIX}*.json)
RESERVOIRFILES=(${RESERVOIRPREFIX}*.json)

ESNCONFIGDIR=${BASEDIR}/configs/esn

DATADIR=data
DATAPREFIX=$BASEDIR/$DATADIR/
DATAFILES=(${DATAPREFIX}*)

RESULTDIR=$BASEDIR/results
shopt -u nullglob

# Create result and esn config directory
if [ ! -d "$RESULTDIR" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    mkdir $RESULTDIR
fi
if [ ! -d "$ESNCONFIGDIR" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    mkdir $ESNCONFIGDIR
fi

# Remove json file extension (and path for confignames/datanames)
SUFFIX=".json"

idx=0
for i in ${CONFIGFILES[@]}; do
  i=${i%$SUFFIX}
  CONFIGFILES[idx]=${i}
  CONFIGNAMES[idx]=${i#$CONFIGPREFIX}

  idx=${idx}+1
done

idx=0
for i in ${RESERVOIRFILES[@]}; do
  i=${i%$SUFFIX}
  RESERVOIRFILES[idx]=${i}
  RESERVOIRNAMES[idx]=${i#$RESERVOIRPREFIX}

  idx=${idx}+1
done

idx=0
for i in ${DATAFILES[@]}; do
  i=${i#$DATAPREFIX}
  DATANAMES[idx]=${i}

  idx=${idx}+1
done

# Initialize the experiment
for DATANAME in ${DATANAMES[@]}; do
  for CONFIGNAME in ${CONFIGNAMES[@]}; do
    for RESERVOIRNAME in ${RESERVOIRNAMES[@]}; do
        FILENAME=${DATANAME}_${CONFIGNAME}_${RESERVOIRNAME}
        DATAFILE=${DATAPREFIX}${DATANAME}
        CONFIGFILE=${CONFIGPREFIX}${CONFIGNAME}
        ESNCONFIG=$ESNCONFIGDIR/$FILENAME
        RECONSTRUCTFILE=${RECONSTRUCTPREFIX}${DATANAME}
        RESERVOIRFILE=${RESERVOIRPREFIX}${RESERVOIRNAME}
        RUNS=20

        # Spawn process.
        # Note: unbuffer is in the 'expect' package and ensures that the output is flushed to stdout right away.
        # 2>&1 | tee ... writes to the file AND shows it in the console.
        unbuffer ./run_single_experiment.sh $DATAFILE $CONFIGFILE $ESNCONFIG $RECONSTRUCTFILE $RESERVOIRFILE $RUNS 2>&1 | tee $RESULTDIR/$FILENAME
    done
  done
done
