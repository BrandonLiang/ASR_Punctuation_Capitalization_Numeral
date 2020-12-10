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

#for FILE in nonsilence_phones.txt silence_phones.txt optional_silence.txt; do
#  dos2unix $APP_HOME/nsc_dict_data/local/dict_v2/$FILE
#done

rm -fr $KALDI_DATA_LOCATION_TOKENIZED/local/*
mkdir -p $KALDI_DATA_LOCATION_TOKENIZED/local/
cp -r $APP_HOME/nsc_dict_data/local/dict_v2 $KALDI_DATA_LOCATION_TOKENIZED/local/dict
