#!/bin/bash

# Note: to use 'greadlink', you need to have coreutils installed on your MacOS ("brew install coreutils")
#       if you are on Linux, use 'readlink' instead

SCRIPT=`greadlink -f "$0"`
#SCRIPT=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT"`
APP_HOME="$SCRIPT_DIR"/../..

CONF=$APP_HOME/conf
PYTHON_DIR=$APP_HOME/python
BIN_DIR=$APP_HOME/bin
ENV="$CONF"/env.sh # configuration file
source "$ENV"

stage=2

# Stage 1 - Preprocess data in to kaldi-required format
if [ $stage -le 1 ]; then
  $BIN_DIR/preprocessing/keep_original_script.sh
  $BIN_DIR/preprocessing/data_prep.sh
  $BIN_DIR/preprocessing/train_dev_test_split.sh
fi

# Stage 2 - Prepare Language data in to kaldi-required format
if [ $stage -le 2]; then
  $BIN_DIR/lang/append_lexicon.sh
