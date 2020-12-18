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

### data prep - following http://kaldi-asr.org/doc/data_prep.html

# 1. unzip
# 2. update utt_id (format: spk_utt) in scripts and rename wav file to match spk_utt
# 2.1 also accumulate utt_id -> wav file path for wav.scp & utt2spk
# 3. create text file to use spk_utt (sorted)
# they are tab- or bar-delimited, easier for train, dev, test splitting

mkdir -p $KALDI_DATA_LOCATION/all
KALDI_TEXT_FILE_TSV=$KALDI_DATA_LOCATION/all/text.tsv
KALDI_TEXT_FILE_TOKENIZED_TSV=$KALDI_DATA_LOCATION/all/text.tsv
mkdir -p $KALDI_DATA_LOCATION/all

# tokenize punctuation in the transcript so that punctuations act as standalone tokens
python3 $PYTHON_DIR/tokenize_text.py \
  --text_location $KALDI_TEXT_FILE_TSV \
  --output_location $KALDI_TEXT_FILE_TOKENIZED_TSV

# cp wav.scp and utt2spk from v1 to v2
cp $KALDI_DATA_LOCATION_V1/all/wav.scp.bsv $KALDI_DATA_LOCATION_V2/all
cp $KALDI_DATA_LOCATION_V1/all/utt2spk.bsv $KALDI_DATA_LOCATION_V2/all
