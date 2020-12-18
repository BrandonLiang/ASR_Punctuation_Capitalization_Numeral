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
source $SCRIPT_DIR/path.sh
source $SCRIPT_DIR/cmd.sh

# This is where Neural-Network component begins
# Run TDNN on the GMM results from FMLLR-aligned SAT Triphones
# (Requires GPU/CUDA)

# import pre-trained TedLium model (exp/rnnlm_lstm_tdnn_a_averaged/final.raw) by setting "--trainer.input-model" param in steps/nnet3/chain/train.py

TRAIN_STAGE=18 # tdnn training stage
TDNN_STAGE=100 # finished all IVector training & extraction

$SCRIPT_DIR/local/chain/run_tdnn.sh \
  --nj $NJ \
  --nnet3-affix "" \
  --train_stage $TRAIN_STAGE \
  --stage $TDNN_STAGE
