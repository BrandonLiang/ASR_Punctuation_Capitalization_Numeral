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
source $SCRIPT_DIR/path.sh
source $SCRIPT_DIR/cmd.sh

# train RNNLM
$SCRIPT_DIR/local/rnnlm/tuning/run_lstm_tdnn_a.sh
$SCRIPT_DIR/local/rnnlm/average_rnnlm.sh
