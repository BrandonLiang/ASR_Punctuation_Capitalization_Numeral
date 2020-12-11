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
INFERENCE=$APP_HOME/inference_v2
ENV="$CONF"/env.sh # configuration file
source "$ENV"
source $SCRIPT_DIR/path.sh
source $SCRIPT_DIR/cmd.sh

# Use trained GMM-HMM TDNN RNN LM Model (on NSC) to make predictions on test data
# Following https://medium.com/@nithinraok_/decoding-an-audio-file-using-a-pre-trained-model-with-kaldi-c1d7d2fe3dc5

# 1. generate ivector files and respective configuration files as required for decoding
$SCRIPT_DIR/steps/online/nnet3/prepare_online_decoding.sh\
  --mfcc-config $SCRIPT_DIR/conf/mfcc_hires.conf \
  $KALDI_DATA_LOCATION_TOKENIZED/lang_chain \
  $KALDI_MODEL_LOCATION_TOKENIZED/nnet3/extractor \
  $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged \
  $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online

# 2. make HCLG.fst graph
$SCRIPT_DIR/utils/mkgraph.sh \
  --self-loop-scale 1.0 \
  $KALDI_DATA_LOCATION_TOKENIZED/test \
  $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online \
  $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online/graph

# 3. generate decoded lattices from the file based on mdl file and graph
$SCRIPT_DIR/steps/online/nnet3/decode.sh \
  --nj $NJ \
  --acwt 1.0 \
  --post-decode-acwt 10.0 \
  $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online/graph \
  $KALDI_DATA_LOCATION_TOKENIZED/test \
  $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online/decode_test

# 4. decode the lattices
mkdir -p $INFERENCE
$KALDI_ROOT/src/latbin/lattice-best-path ark:'gunzip -c $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online/decode_test/lat.*.gz |' 'ark,t:|int2sym.pl -f 2- $KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged_online/graph/words.txt > $INFERENCE/decoded_text.txt'
