#!/bin/bash

# UNI: xl2891
# Name: Xudong Liang (Brandon)

# Note: to use 'greadlink', you need to have coreutils installed on your MacOS ("brew install coreutils")
#       if you are on Linux, use 'readlink' instead

#SCRIPT=`greadlink -f "$0"`
SCRIPT=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT"`
APP_HOME="$SCRIPT_DIR"/..

CONF=$APP_HOME/conf
PYTHON_DIR=$APP_HOME/python
ENV="$CONF"/env.sh # configuration file
source "$ENV"

mkdir -p $KALDI_MODEL_LOCATION

# 0. converts in Arpa format LM into the ConstArpLm format:
$KALDI_TEDLIUM/utils/build_const_arpa_lm.sh \
  $KALDI_DATA_LOCATION/local/tmp/lm.arpa.gz \
  $KALDI_DATA_LOCATION/lang \
  $KALDI_DATA_LOCATION/lang_rescore

# 1. make graph from FMLLR-aligned SAT triphones
$KALDI_TEDLIUM/utils/mkgraph.sh \
  $KALDI_DATA_LOCATION/lang \
  $KALDI_MODEL_LOCATION/tri4a_ali \
  $KALDI_MODEL_LOCATION/tri4a_ali/graph

for dset in dev test; do

  # 2.1 decode in dev & test
  $KALDI_TEDLIUM/steps/decode_fmllr.sh \
    --nj $NJ \
    --cmd run.pl \
    --num-threads $NJ \
    $KALDI_MODEL_LOCATION/tri4a_ali/graph \
    $KALDI_DATA_LOCATION/${dset} \
    $KALDI_MODEL_LOCATION/tri4a_ali/decode_${dset}

  # 2.2 rescore the lattice with the ConstArpaLm format language model
  $KALDI_TEDLIUM/steps/lmrescore_const_arpa.sh \
    --cmd run.pl \
    $KALDI_DATA_LOCATION/lang \
    $KALDI_DATA_LOCATION/lang_rescore \
    $KALDI_DATA_LOCATION/${dset} \
    $KALDI_MODEL_LOCATION/tri4a_ali/decode_${dset} \
    $KALDI_MODEL_LOCATION/tri4a_ali/decode_${dset}_rescore
done
