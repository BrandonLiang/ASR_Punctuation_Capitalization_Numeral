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

# generate numbers under K to feed into CMU LOGIOS Lexicon Tool (http://www.speech.cs.cmu.edu/tools/lextool.html) for ARPAbet pronunciation mapping
# for appending numeral pronunciation to the lexicon
K=10000 # threshold

python $PYTHON_DIR/number_generator.py \
  --k $K \
  --output_location $APP_HOME/nsc_dict_data/local/dict_v2/numbers.txt
