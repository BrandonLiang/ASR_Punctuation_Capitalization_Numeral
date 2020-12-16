export ASR_DIR=$HOME/external/asr_data
export NSC_DIR=$ASR_DIR/NSC/PART2
export RAW_DATA_LOCATION=$NSC_DIR/DATA
export KALDI_DATA_LOCATION=$NSC_DIR/kaldi
export KALDI_MODEL_LOCATION=$KALDI_DATA_LOCATION/exp

export KALDI_DATA_LOCATION_TOKENIZED=$NSC_DIR/kaldi_v2
export KALDI_MODEL_LOCATION_TOKENIZED=$KALDI_DATA_LOCATION_TOKENIZED/exp

export KALDI_ROOT=$HOME/src/kaldi
export KALDI_TEDLIUM=$KALDI_ROOT/egs/tedlium/s5_r3

export PRETRAINED_TEDLIUM=$HOME/src/pretrained_tedlium_s5_r3/exp/rnnlm_lstm_tdnn_a_averaged/final.raw

# number of jobs in parallel
export NJ=16

# want bigram for LM
export LM_ORDER=4

export BOOST_SILENCE=1.25

# kaldi cmd.sh
# Run locally:
export train_cmd=run.pl
export decode_cmd=run.pl

# Be careful when you sort that you have the shell variable LC_ALL defined as "C"
export LC_ALL=C
