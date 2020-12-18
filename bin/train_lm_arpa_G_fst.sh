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

# Train LM
# Following: https://kaldi-asr.org/doc/kaldi_for_dummies.html

# 0. generate corpus.txt for all transcriptions
KALDI_ALL_TEXT_TSV=$KALDI_DATA_LOCATION/all/text.tsv
KALDI_ALL_TEXT=$KALDI_DATA_LOCATION/all/corpus.txt

cut -f 2- $KALDI_ALL_TEXT_TSV > $KALDI_ALL_TEXT

# 1. ensure SRILM is installed
loc=`which ngram-count`;
if [ -z $loc ]; then
  if uname -a | grep 64 >/dev/null; then
    sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
  else
    sdir=$KALDI_ROOT/tools/srilm/bin/i686
  fi
  if [ -f $sdir/ngram-count ]; then
    echo "Using SRILM language modelling tool from $sdir"
    export PATH=$PATH:$sdir
  else
    echo "SRILM toolkit is probably not installed.
          Instructions: tools/install_srilm.sh"
    exit 1
  fi
fi

# 2. make lm.arpa
mkdir -p $KALDI_DATA_LOCATION/local/tmp
ngram-count \
  -order $LM_ORDER \
  -write-vocab $KALDI_DATA_LOCATION/local/tmp/vocab-full.txt \
  -wbdiscount \
  -text $KALDI_ALL_TEXT \
  -lm $KALDI_DATA_LOCATION/local/tmp/lm.arpa

# 3. make G.st (Finite-State Transducer, equivalent to HMM)
$KALDI_ROOT/src/lmbin/arpa2fst \
  --disambig-symbol=#0 \
  --read-symbol-table=$KALDI_DATA_LOCATION/lang/words.txt \
  $KALDI_DATA_LOCATION/local/tmp/lm.arpa \
  $KALDI_DATA_LOCATION/lang/G.fst
