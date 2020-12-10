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

mkdir -p $KALDI_MODEL_LOCATION_TOKENIZED

# Triphone Training & Alignment
# https://www.eleanorchodroff.com/tutorial/kaldi/training-acoustic-models.html

# 1. train delta-based triphones
$KALDI_TEDLIUM/steps/train_deltas.sh \
  --boost-silence $BOOST_SILENCE \
  --cmd run.pl \
  2000 10000 \
  $KALDI_DATA_LOCATION_TOKENIZED/train \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/mono_ali \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri1 || exit 1;

# 2. align delta-based triphones
$KALDI_TEDLIUM/steps/align_si.sh \
  --nj $NJ \
  --cmd run.pl \
  $KALDI_DATA_LOCATION_TOKENIZED/train \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri1 \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri1_ali || exit 1;

# 3. train delta + delta-delta triphones
$KALDI_TEDLIUM/steps/train_deltas.sh \
  --cmd run.pl \
  2500 15000 \
  $KALDI_DATA_LOCATION_TOKENIZED/train \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri1_ali \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri2a || exit 1;

# 4. align delta + delta-delta triphones
$KALDI_TEDLIUM/steps/align_si.sh \
  --nj $NJ \
  --cmd run.pl \
  --use-graphs true \
  $KALDI_DATA_LOCATION_TOKENIZED/train \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri2a \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri2a_ali || exit 1;

# 5. train LDA-MLLT triphones
$KALDI_TEDLIUM/steps/train_lda_mllt.sh \
  --cmd run.pl \
  3500 20000 \
  $KALDI_DATA_LOCATION_TOKENIZED/train \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri2a_ali \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri3a || exit 1;

# 6. clean up training data - remove bad portions of transcripts
$KALDI_TEDLIUM/steps/cleanup/clean_and_segment_data.sh \
  --nj $NJ \
  --cmd run.pl \
  $KALDI_DATA_LOCATION_TOKENIZED/train \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri3a \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri3a_cleaned_work \
  $KALDI_DATA_LOCATION_TOKENIZED/train_cleaned

# 7. align LDA-MLLT triphones with FMLLR
$KALDI_TEDLIUM/steps/align_fmllr.sh \
  --nj $NJ \
  --cmd run.pl \
  $KALDI_DATA_LOCATION_TOKENIZED/train_cleaned \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri3a \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri3a_ali || exit 1;

# 8. train SAT triphones
$KALDI_TEDLIUM/steps/train_sat.sh \
  --cmd run.pl \
  4200 40000 \
  $KALDI_DATA_LOCATION_TOKENIZED/train_cleaned \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri3a_ali \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri4a || exit 1;

# 9. align SAT triphones with FMLLR
$KALDI_TEDLIUM/steps/align_fmllr.sh \
  --cmd run.pl \
  $KALDI_DATA_LOCATION_TOKENIZED/train_cleaned \
  $KALDI_DATA_LOCATION_TOKENIZED/lang \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri4a \
  $KALDI_MODEL_LOCATION_TOKENIZED/tri4a_ali || exit 1;
