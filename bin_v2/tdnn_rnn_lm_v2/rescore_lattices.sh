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

# rescore the lattices from tdnn using lstm rnnlm
RNNLM_DIR=$KALDI_MODEL_LOCATION_TOKENIZED/rnnlm_lstm_tdnn_a_averaged
LANG_DIR=$KALDI_DATA_LOCATION_TOKENIZED/lang_chain

for dset in dev test; do
  DATA_DIR=$KALDI_DATA_LOCATION_TOKENIZED/${dset}_hires
  DECODING_DIR=$KALDI_MODEL_LOCATION_TOKENIZED/chain_cleaned/tdnnf_1a/decode_${dset}
  SUFFIX=$(basename $RNNLM_DIR)
  OUTPUT_DIR=${DECODING_DIR}_$SUFFIX

  $SCRIPT_DIR/rnnlm/lmrescore_pruned.sh \
    --cmd "run.pl --mem 4G" \
    --weight 0.5 \
    --max-ngram-order $LM_ORDER \
    $LANG_DIR \
    $RNNLM_DIR \
    $DATA_DIR \
    $DECODING_DIR \
    $OUTPUT_DIR
done
