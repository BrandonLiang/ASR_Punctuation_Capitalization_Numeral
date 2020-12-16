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
INFERENCE=$APP_HOME/inference
ENV="$CONF"/env.sh # configuration file
source "$ENV"
source $SCRIPT_DIR/path.sh
source $SCRIPT_DIR/cmd.sh

# Use trained model (on NSC) to make predictions on test data
# Following https://medium.com/@nithinraok_/decoding-an-audio-file-using-a-pre-trained-model-with-kaldi-c1d7d2fe3dc5

# model directory in exp/ for testing (decoding)
# CHANGE THIS !
MODEL_DIR=tri4a_ali

# decode the lattices
mkdir -p $INFERENCE
$KALDI_ROOT/src/latbin/lattice-best-path ark:'gunzip -c $KALDI_MODEL_LOCATION_TOKENIZED/$MODEL_DIR/decode_test/lat.*.gz |' 'ark,t:|int2sym.pl -f 2- $KALDI_MODEL_LOCATION_TOKENIZED/$MODEL_DIR/graph/words.txt > $INFERENCE/decoded_text_$MODEL_DIR.txt'
