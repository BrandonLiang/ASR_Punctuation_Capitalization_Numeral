#!/bin/bash

# Note: to use 'greadlink', you need to have coreutils installed on your MacOS ("brew install coreutils")
#       if you are on Linux, use 'readlink' instead

#SCRIPT=`greadlink -f "$0"`
SCRIPT=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT"`
APP_HOME="$SCRIPT_DIR"/../..

CONF=$APP_HOME/conf
PYTHON_DIR=$APP_HOME/python
ENV="$CONF"/env.sh # configuration file
source "$ENV"

mkdir -p $KALDI_MODEL_LOCATION

# Monophone Training & Alignment
# Following: https://www.eleanorchodroff.com/tutorial/kaldi/training-acoustic-models.html

## 1. take subset of data
#$KALDI_TEDLIUM/utils/subset_data_dir.sh \
#  --first $KALDI_DATA_LOCATION/train \
#  10000 \
#  $KALDI_DATA_LOCATION/train_10k

# 2. train monophone
$KALDI_TEDLIUM/steps/train_mono.sh \
  --boost-silence $BOOST_SILENCE \
  --nj $NJ \
  --cmd run.pl \
  $KALDI_DATA_LOCATION/train_10k \
  $KALDI_DATA_LOCATION/lang \
  $KALDI_MODEL_LOCATION/mono_10k

# 3. align monophones
$KALDI_TEDLIUM/steps/align_si.sh \
  --boost-silence $BOOST_SILENCE \
  --nj $NJ \
  --cmd run.pl \
  $KALDI_DATA_LOCATION/train \
  $KALDI_DATA_LOCATION/lang \
  $KALDI_MODEL_LOCATION/mono_10k \
  $KALDI_MODEL_LOCATION/mono_ali || exit 1;
