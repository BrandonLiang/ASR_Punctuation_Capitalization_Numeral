UNI: xl2891
Name: Xudong Liang (Brandon)


--Python Package Prerequisites
pip install -r requirements.txt
--

python/ - python scripts (describe each)
conf/env.sh - stores environment variables for bash shell scripts
bin/ - bash shell scripts (describe each)

bin/run.sh - run-all script (bash shell)

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
