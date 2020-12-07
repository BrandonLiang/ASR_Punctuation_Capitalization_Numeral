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

### data prep - following http://kaldi-asr.org/doc/data_prep.html

# 1. unzip
# 2. update utt_id (format: spk_utt) in scripts and rename wav file to match spk_utt
# 2.1 also accumulate utt_id -> wav file path for wav.scp & utt2spk
# 3. create text file to use spk_utt (sorted)
# they are tab- or bar-delimited, easier for train, dev, test splitting

mkdir -p $KALDI_DATA_LOCATION/all
KALDI_TEXT_FILE_TSV=$KALDI_DATA_LOCATION/all/text.tsv
KALDI_WAV_SCP_BSV=$KALDI_DATA_LOCATION/all/wav.scp.bsv
KALDI_UTT2SPK_BSV=$KALDI_DATA_LOCATION/all/utt2spk.bsv
# these 3 files need to be sorted
touch $KALDI_TEXT_FILE_TSV
touch $KALDI_WAV_SCP_BSV
touch $KALDI_UTT2SPK_BSV

UPDATED_WAV_LOCATION=$RAW_DATA_LOCATION/wav
mkdir -p $UPDATED_WAV_LOCATION

# Be careful when you sort that you have the shell variable LC_ALL defined as "C"
export LC_ALL=C

CUR_DIR=`pwd`

for CHANNEL in 0 1 2; do
  LOCATION=$RAW_DATA_LOCATION/CHANNEL${CHANNEL}
  ## 1. unzip
  #cd $LOCATION
  #for zip_file in $LOCATION/WAVE/*.zip; do
  #  unzip $zip_file
  #done
  #cd $CUR_DIR

  echo "2. Modifying Utt Id in SCRIPTs"
  # 2. update utt_id in SCRIPT to match kaldi convention
  python "$PYTHON_DIR"/data_prep.py --data_location $LOCATION --channel $CHANNEL

  echo "2. Modifying WAVE file names"
  # modify each wave file name to match the utt id's in each script according to kaldi convention
  for wave_file in $LOCATION/WAVE/*/*/*.WAV; 
    NSC_UTT=`basename $wave_file`
    SPK=${NSC_UTT:0:5} # first 5 char
    UTT=${NSC_UTT:5:4} # last 4 char
    mv $wave_file $UPDATED_WAV_LOCATION/${SPK}-${UTT}.wav
    # in the process, also accumulate utt_id -> wav file path for wav.scp
    echo "${SPK}-${UTT}|$UPDATED_WAV_LOCATION/${SPK}-${UTT}.wav">> $KALDI_WAV_SCP_BSV
    # also accumulate utt2spk file
    echo "${SPK}-${UTT}|${SPK}" >> $KALDI_UTT2SPK_BSV

  # make sure wav.scp & utt2spk are sorted
  # should already be sorted - double check!

  echo "3. Creating Kaldi Text file"
  # 3. create one text file that contains the transcriptions of each utterance
  # the first element on each line is the utt_id
  # the second element on each line is the transcription of each utterance
  for text_file in $LOCATION/SCRIPT/*.TXT; do
    cat $text_file >> $KALDI_TEXT_FILE_TSV
  done

  # make sure text is sorted
  # should already be sorted - double check!
done
