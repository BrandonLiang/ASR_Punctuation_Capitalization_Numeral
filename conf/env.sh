ASR_DIR=$HOME/external/asr_data
NSC_DIR=$ASR_DIR/NSC/PART2
RAW_DATA_LOCATION=$NSC_DIR/DATA
KALDI_DATA_LOCATION=$NSC_DIR/kaldi
KALDI_MODEL_LOCATION=$KALDI_DATA_LOCATION/exp

KALDI_DATA_LOCATION_TOKENIZED=$NSC_DIR/kaldi_v2
KALDI_MODEL_LOCATION_TOKENIZED=$KALDI_DATA_LOCATION_TOKENIZED/exp

KALDI_ROOT=$HOME/src/kaldi
KALDI_TEDLIUM=$KALDI_ROOT/egs/tedlium/s5_r3

PRETRAINED_TEDLIUM=$HOME/src/pretrained_tedlium_s5_r3/exp/rnnlm_lstm_tdnn_a_averaged/final.raw

# number of jobs in parallel
NJ=8

# want bigram for LM
LM_ORDER=4

BOOST_SILENCE=1.25

# kaldi cmd.sh
# Run locally:
export train_cmd=run.pl
export decode_cmd=run.pl

# Be careful when you sort that you have the shell variable LC_ALL defined as "C"
export LC_ALL=C
