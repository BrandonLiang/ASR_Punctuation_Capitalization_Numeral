#!/bin/bash

# Note: to use 'greadlink', you need to have coreutils installed on your MacOS ("brew install coreutils")
#       if you are on Linux, use 'readlink' instead

#SCRIPT=`greadlink -f "$0"`
SCRIPT=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT"`
APP_HOME="$SCRIPT_DIR"

CONF=$APP_HOME/conf
PYTHON_DIR=$APP_HOME/python
BIN_DIR=$APP_HOME/bin
ENV="$CONF"/env.sh # configuration file
source "$ENV"

stage=3

# Stage 1 - Data Preparation: Preprocess data in to kaldi-required format & Feature Extraction (MFCC & CMVN stats)
# Following http://kaldi-asr.org/doc/data_prep.html
if [ $stage -le 1 ]; then

  # - take only the original transcript that includes punctuation, capitalization & numeral
  $BIN_DIR/preprocessing/keep_original_script.sh

  # - modify utt_id in text and wav file names into kaldi requirement
  # - concatenate all transcripts together into text
  # - create utt2spk & wav.scp
  $BIN_DIR/preprocessing/data_prep.sh

  # - split text, utt2spk & wav.scp into train, dev, test (8:1:1 ratio)
  # - create spk2utt
  # - feature extraction: extract mfcc features and cmvn stats in each split
  $BIN_DIR/preprocessing/train_dev_test_split.sh

fi

# Stage 2 - Prepare Language data in to kaldi-required format
# Following http://kaldi-asr.org/doc/data_prep.html
if [ $stage -le 2 ]; then

  # - append capitalization, punctuation & numeral pronunciation information into lexicon dictionary for $KALDI_DATA_LOCATION/local/dict/lexicon.txt
  $BIN_DIR/lang/append_lexicon.sh

  # - copy the generated dictionary directory above into $KALDI_DATA_LOCATION/local/dict
  $BIN_DIR/lang/cp_dict_to_data.sh

  # - create the "lang" directory using Kaldi's utils/prepare_lang.sh
  # - creates L.fst & L_disambig.fst
  $BIN_DIR/lang/create_lang_dir_L_fst.sh

  # - creates G.fst using ngram model (n = 2) & lm.arpa
  $BIN_DIR/lang/train_lm_arpa_G_fst.sh

fi

# Stage 3 - Monophone & Triphone Training & Alignment
# Following https://www.eleanorchodroff.com/tutorial/kaldi/training-acoustic-models.html
if [ $stage -le 3 ]; then

  # Follwing https://www.eleanorchodroff.com/tutorial/kaldi/training-acoustic-models.html#monophone-training-and-alignment
  # - take subset (10k) of training data for monophone training
  # - train monophones
  # - alignment monophones
  $BIN_DIR/monophone_triphone_training_alignment/monophone_training_alignment.sh

  # Following https://www.eleanorchodroff.com/tutorial/kaldi/training-acoustic-models.html#triphone-training-and-alignment
  # - train delta-based triphones
  # - align delta-based triphones
  # - train delta + delta-delta triphones
  # - align delta + delta-delta triphones
  # - train LDA-MLLT triphones
  # - clean up training data
  # - align LDA-MLLT triphones with FMLLR
  # - train SAT triphones
  # - align SAT triphones with FMLLR
  $BIN_DIR/monophone_triphone_training_alignment/triphone_training_alignment.sh

  # - make graph from FMLLR-aligned SAT triphones
  # - decode
  # - rescore the lattices with ConstARPA format LM
  #$BIN_DIR/monophone_triphone_training_alignment/decode_sat_triphone.sh

fi
