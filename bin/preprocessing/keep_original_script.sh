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

### Original script keeps two lines for each utterance: the 1st line is the original and the 2nd line is the normalized/trimmed version (without punctuations, capitalizations or numerals)
### We want to keep only the 1st line for each utterance

for CHANNEL in 0 1 2; do
  LOCATION=$RAW_DATA_LOCATION/CHANNEL${CHANNEL}/SCRIPT

  ## https://gist.github.com/szydan/b225749445b3602083ed
  ## remove <U+FEFF> BOM character in txt files
  #for txt in $LOCATION/*.TXT; do
  #  awk '{ gsub(/\xef\xbb\xbf/,""); print }' $txt > $LOCATION/tmp; mv $LOCATION/tmp $txt
  #done
  python "$PYTHON_DIR"/keep_original_script.py --data_location $LOCATION
done
