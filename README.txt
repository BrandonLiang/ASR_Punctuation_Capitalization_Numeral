UNI: xl2891
Name: Xudong Liang (Brandon)
Date: 12/17/2020
Project Title: Including Punctuation, Capitalization and Numeral in Automatic Speech Recognition

Project Summary
In traditional Automatic Speech Recognition (ASR) systems, the generated transcript output is typically unsegmented text that includes only the plain word tokens and excludes other sentence components, such as punctuations, capitalized phrases and numerals, due to text normalization in preprocessing. Although such transcripts containing word tokens alone can provide sufficient translation of the speech audio, the other sentence components are also crucial to understanding the message. In this work, I propose modification in the lexicon, acoustic model, and language model components to a tpyical ASR architecture to include punctuation, capitalization and numeral in the predicted transcript. Specifically, I propose two distinct ways to include punctuation and compare both results to the Kaldi Ted-Lium model.
# Results

Python Prerequisites
I use a few python packages (e.g.: NLTK, Pandas, etc.) in preprocessing. The detailed python packages are listed in ./requirements.txt and can be installed using:
  pip install -r requirements.txt

List of tools used
  CMU Pronouncing Dictionary (http://www.speech.cs.cmu.edu/cgi-bin/cmudict) - for ARPAbet-transcribed pronunciations of the basic number units
  CMU LOGIOS Lexicon Tool (http://www.speech.cs.cmu.edu/tools/lextool.html) - for ARPAbet-transcribed pronunciations of all possible numbers under 10,000
  Kaldi Documentaion (http://kaldi-asr.org/doc) - for data preparation and variou Kaldi documentaions
  Kaldi - for Ted-Lium recipe and various executables in utils/, steps/ and local/

List of Directories:
  ./python/ - python scripts (describe each)
  ./conf/ - stores environment variables for bash shell scripts (e.g.: ./conf/env.sh)
  ./bin/ - bash shell scripts/executables

List of Executables:
  ./bin/...

Main Executables:
# run-all script
run_train
run_test

one bin
data & model location switch in conf/env.sh
mention!

### data prep - following http://kaldi-asr.org/doc/data_prep.html

sample_data/train # kaldi style & requirement & convention
raw/{020010.TXT, 02001-0001.WAV} spk_id -> utt_id
kaldi: text, utt2spk,  wav.scp, spk2utt, feat.scp, cmvn.scp
data/local/dict/lexicon (default, numeral_base, numeral_dumb)

utt2num_frames, utt2dur, frame_shift

train/data/
cmvn_train.ark
cmvn_train.scp
make_mfcc_train.1.log
raw_mfcc_train.1.ark
raw_mfcc_train.1.scp

(see NLU DST README syntax & format!)

--draw result table here--
