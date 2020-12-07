#!/bin/bash

# Note: to use 'greadlink', you need to have coreutils installed on your MacOS ("brew install coreutils")
#       if you are on Linux, use 'readlink' instead

SCRIPT=`greadlink -f "$0"`
#SCRIPT=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT"`
APP_HOME="$SCRIPT_DIR"/../..

CONF=$APP_HOME/conf
PYTHON_DIR=$APP_HOME/python
ENV="$CONF"/env.sh # configuration file
source "$ENV"

# number of jobs in parallel
NJ=2

#echo "splitting"
## split the created text, wav.scp, utt2spk from all to train, dev, test, using utt-id in all files
## 80-10-10 split
## ! make sure $dir/{text, utt2spk, wav.scp} are all sorted
#python $PYTHON_DIR/train_dev_test_split.py --data_location $KALDI_DATA_LOCATION/all --target_parent_dir $KALDI_DATA_LOCATION

#echo "removing escaped double quote in \$dir/text"
#for dir in train dev test; do
#  sed 's/\ \"/\ /g' $KALDI_DATA_LOCATION/$dir/text | sed 's/\"$//g' > $KALDI_DATA_LOCATION/$dir/tmp; mv $KALDI_DATA_LOCATION/$dir/tmp $KALDI_DATA_LOCATION/$dir/text
#done

cd $KALDI_TEDLIUM

# then, create spk2utt, feats.scp & cmvn.scp in all 3 partitions
for dir in train dev test; do
  echo "Working on $dir"
  CUR_DATA_DIR=$KALDI_DATA_LOCATION/$dir
  mkdir -p $CUR_DATA_DIR

  # created using kaldi utils
  CUR_KALDI_UTT2SPK=$KALDI_DATA_LOCATION/$dir/utt2spk # already created from data_prep.sh & above
  CUR_KALDI_SPK2UTT=$KALDI_DATA_LOCATION/$dir/spk2utt
  # http://www.inf.ed.ac.uk/teaching/courses/asr/2019-20/lab6.pdf
  CUR_KALDI_MFCC_DIR=$KALDI_DATA_LOCATION/$dir/data
  CUR_KALDI_MFCC_LOG_DIR=$KALDI_DATA_LOCATION/$dir/log
  mkdir -p $CUR_KALDI_MFCC_DIR
  mkdir -p $CUR_KALDI_MFCC_LOG_DIR

  # create spk2utt, feats.scp & cmvn.scp after train,dev,test split, since cmvn.scp is indexed by speaker-id, not utt-id
  #echo "creating spk2utt"
  #$KALDI_TEDLIUM/utils/utt2spk_to_spk2utt.pl $CUR_KALDI_UTT2SPK > $CUR_KALDI_SPK2UTT
  # http://www.inf.ed.ac.uk/teaching/courses/asr/2019-20/lab6.pdf
  echo "creating feats.scp"
  $KALDI_TEDLIUM/steps/make_mfcc.sh -nj $NJ --cmd $KALDI_TEDLIUM/"$train_cmd" $CUR_DATA_DIR $CUR_KALDI_MFCC_LOG_DIR $CUR_KALDI_MFCC_DIR
  echo "creating cmvn.scp"
  $KALDI_TEDLIUM/steps/compute_cmvn_stats.sh $CUR_DATA_DIR $CUR_KALDI_MFCC_LOG_DIR $CUR_KALDI_MFCC_DIR
done

## validate prepped data directory
#for dir in train dev test; do
#  echo "Validating $KALDI_DATA_LOCATION/$dir"
#  $KALDI_TEDLIUM/utils/validate_data_dir.sh $KALDI_DATA_LOCATION/$dir
#  # fix
#  # $KALDI_TEDLIUM/utils/fix_data_dir.sh $KALDI_DATA_LOCATION/$dir
#done
