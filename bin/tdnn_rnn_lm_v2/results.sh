#!/bin/bash

# UNI: xl2891
# Name: Xudong Liang (Brandon)

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
source $SCRIPT_DIR/path.sh
source $SCRIPT_DIR/cmd.sh

# Get WER from the final model on dev and test

# The output of this script (after successfully running ./run.sh) can be found in the RESULTS file.

filter_regexp=.
[ $# -ge 1 ] && filter_regexp=$1

# kaldi scoring,
for x in $KALDI_MODEL_LOCATION_TOKENIZED/{mono,tri,sgmm,nnet,dnn,lstm}*/decode*; do
  [ -d $x ] && grep WER $x/wer_* | $KALDI_TEDLIUM/utils/best_wer.sh;
done 2>/dev/null
for x in $KALDI_MODEL_LOCATION_TOKENIZED/chain*/*/decode*; do
  [ -d $x ] && grep WER $x/wer_* | $KALDI_TEDLIUM/utils/best_wer.sh;
done 2>/dev/null | grep $filter_regexp

# sclite scoring,
for x in $KALDI_MODEL_LOCATION_TOKENIZED/{mono,tri,sgmm,nnet,dnn,lstm}*/decode*; do
  [ -d $x ] && grep Sum $x/score_*/*.sys | $KALDI_TEDLIUM/utils/best_wer.sh;
done 2>/dev/null | grep $filter_regexp
for x in $KALDI_MODEL_LOCATION_TOKENIZED/chain*/*/decode*; do
  [ -d $x ] && grep Sum $x/score_*/*.sys | $KALDI_TEDLIUM/utils/best_wer.sh;
done 2>/dev/null | grep $filter_regexp

exit 0

