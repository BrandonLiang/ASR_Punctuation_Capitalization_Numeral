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

# Create the "lang" directory
# http://kaldi-asr.org/doc/data_prep.html
# this creates L.fst & L_disambig.fst
$KALDI_TEDLIUM/utils/prepare_lang.sh \
  $KALDI_DATA_LOCATION/local/dict \
  "<UNK>" \
  $KALDI_DATA_LOCATION/local/lang \
  $KALDI_DATA_LOCATION/lang
