ASR_DIR=$HOME/external/asr_data
NSC_DIR=$ASR_DIR/NSC/PART2
RAW_DATA_LOCATION=$NSC_DIR/DATA
KALDI_DATA_LOCATION=$NSC_DIR/kaldi

KALDI_ROOT=$HOME/src/kaldi
KALDI_TEDLIUM=$KALDI_ROOT/egs/tedlium/s5_r3

# kaldi cmd.sh
# Run locally:
export train_cmd=run.pl
export decode_cmd=run.pl
