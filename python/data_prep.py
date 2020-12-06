import os
import argparse
import sys
import glob
import logging
import pandas as pd

# kaldi data convention: http://kaldi-asr.org/doc/data_prep.html

# kaldi id needs to be {spk_id}-{recording_id} - with dash over underscore
# in NSC PART2, the NSC utt id is {CHANNEL}{SPK_ID}{RECORDING_ID}, where the number of digits are {1}{4}{4}. i.e.: 122061811: CHANNEL1, Speaker 2206, Recording 1811
# We want to keep {CHANNEL}{SPK_ID} as spk_id, so the final utt id is {CHANNEL}{SPK_ID}-{RECORDING_ID}
def nsc_uttid_to_kaldi_uttid(uttid):
  assert len(uttid) == 9
  spk_id = uttid[:5]
  recording_id = uttid[5:]
  assert len(spk_id) == 5
  assert len(recording_id) == 4
  return "{}-{}".format(spk_id, recording_id)

# modify the utt id's in each script into kaldi convention
def modify_script(txtfile, delimiter = '\t'):
  df = pd.read_csv(txtfile, delimiter = delimiter, header = None, names = ["utt", "text"], dtype = str)
  original_row_count = df.shape[0]

  df.utt = df.utt.apply(lambda x: nsc_uttid_to_kaldi_uttid(x))

  new_row_count = df.shape[0]
  # assert same number of utterance id's is the same as before
  assert original_row_count == new_row_count
  df.to_csv(txtfile, sep = delimiter, index = False, header = False)
  return

# create one text file that contains the transcriptions of each utterance
# the first element on each line is the utt_id
# the second element on each line is the transcription of each utterance

if __name__ == "__main__":
  logging.basicConfig(level = logging.INFO) # set INFO as the default logging level
  logger = logging.getLogger(__name__)

  parser = argparse.ArgumentParser()
  parser.add_argument("--data_location", default = None, type = str, help = "NSC SCRIPT Location to preprocess")
  parser.add_argument("--channel", default = "0", type = str, help = "CHANNEL number in NSC PART2 WAVE")
  args = parser.parse_args()
  for txtfile in glob.glob(os.path.join(args.data_location, "SCRIPT/*.TXT")):
    modify_script(txtfile)
    logger.info(txtfile)
