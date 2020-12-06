import os
import argparse
import sys
import glob
import logging
import pandas as pd

def keep_original_script(txtfile, delimiter = '\t'):
  df = pd.read_csv(txtfile, delimiter = delimiter, header = None, names = ["utt", "text"], dtype = str)
  original_row_count = df.shape[0]
  # filter out utt_id that are "nan" - want to keep original scripts only
  df = df[df.utt.notnull()]
  new_row_count = df.shape[0]
  # assert same number of utterance id's is the same as before
  assert original_row_count == 2 * new_row_count
  df.to_csv(txtfile, sep = delimiter, index = False, header = False)
  return

if __name__ == "__main__":
  logging.basicConfig(level = logging.INFO) # set INFO as the default logging level
  logger = logging.getLogger(__name__)

  parser = argparse.ArgumentParser()
  parser.add_argument("--data_location", default = None, type = str, help = "NSC SCRIPT Location to preprocess")
  args = parser.parse_args()
  for txtfile in glob.glob(os.path.join(args.data_location, "*.TXT")):
    keep_original_script(txtfile)
    logger.info(txtfile)
