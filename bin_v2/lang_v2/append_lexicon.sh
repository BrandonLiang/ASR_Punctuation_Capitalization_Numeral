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

K=10000 # threshold for numbers in numeral lexicon

python3 $PYTHON_DIR/append_lexicon_punct_tokenized.py \
  --default_lexicon_location $APP_HOME/tedlium_dict_data/local/dict/lexicon.txt \
  --numeral_lexicon_base_location $APP_HOME/nsc_dict_data/local/dict_v2/numeral_lexicon_base.bsv \
  --k $K \
  --numeral_lexicon_dumb_location $APP_HOME/nsc_dict_data/local/dict_v2/numeral_lexicon_dumb.tsv \
  --output_lexicon_location $APP_HOME/nsc_dict_data/local/dict_v2/lexicon.txt
