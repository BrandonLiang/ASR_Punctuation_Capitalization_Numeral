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

stage=3

# Stage 1 - Preprocess data in to kaldi-required format
# Following http://kaldi-asr.org/doc/data_prep.html
if [ $stage -le 1 ]; then
  $BIN_DIR/preprocessing/keep_original_script.sh # take only the original transcript - includes punctuation, capitalization & numeral
  $BIN_DIR/preprocessing/data_prep.sh # modify utt_id in to kaldi requirement, create text, utt2spk & wav.scp
  $BIN_DIR/preprocessing/train_dev_test_split.sh # split text, utt2spk & wav.scp into train, dev, test (8:1:1), then create spk2utt, mfcc features and cmvn stats in each partition
fi

# Stage 2 - Prepare Language data in to kaldi-required format
if [ $stage -le 2]; then
  $BIN_DIR/lang/append_lexicon.sh # append capitalization, punctuation & numeral pronunciation information into lexicon for $KALDI_DATA_LOCATION/local/dict/lexicon.txt
  $BIN_DIR/lang/cp_dict_to_data.sh # copy the generated dictionary directory above into $KALDI_DATA_LOCATION/local/dict
  $BIN_DIR/lang/create_lang_dir.sh # create the "lang" directory using Kaldi's utils/prepare_lang.sh
fi
