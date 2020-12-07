import argparse
import os
import pandas as pd
import sys
import logging
import numpy as np
import random
import csv

np.random.seed(10)
random.seed(10)

# given a list of indices (sorted), split into train, dev, test with the given ratio, where the indices in each partition is also SORTED!
# for simplicity, we now use a 8:1:1 ratio
def split_indices(indices):
  train = []
  dev = []
  test = []
  index = 0
  size = len(indices)
  while index < size:
    dev_key = random.randint(0, 9)
    test_key = random.randint(0, 9)
    while dev_key == test_key:
      test_key = random.randint(0, 9)

    dev_index = index + dev_key
    test_index = index + test_key
    train_indices = list(range(index, index + 10))
    train_indices = list(filter(lambda x: x != dev_index and x != test_index, train_indices))

    train.extend(train_indices)
    dev.append(dev_index)
    test.append(test_index)

    index += 10 # increment by 10

    leftover = size - index
    if leftover < 10:
      train.extend(list(range(index, index + leftover)))
      break

  return np.array(train), np.array(dev), np.array(test)

def split(data_location, target_parent_dir, delimiter = '\t', train_percent = 0.8, dev_percent = 0.1):
  test_percent = 1 - train_percent - dev_percent

  target_dirs = {}
  for d in ["train", "dev", "test"]:
    target_dirs[d] = os.path.join(target_parent_dir, d)
    os.system("mkdir -p {}".format(target_dirs[d]))

  text_tsv = os.path.join(data_location, "text.tsv")
  utt2spk_bsv = os.path.join(data_location, "utt2spk.bsv")
  wav_scp_bsv = os.path.join(data_location, "wav.scp.bsv")

  for f in [text_tsv, utt2spk_bsv, wav_scp_bsv]:
    if not os.path.isfile(f):
      raise Exception("{} not found".format(f))

  df_text = pd.read_csv(text_tsv, delimiter = '\t', header = None, names = ["utt_id", "transcript"], dtype = str)
  df_utt2spk = pd.read_csv(utt2spk_bsv, delimiter = '|', header = None, names = ["utt_id", "spk_id"], dtype = str)
  df_wav_scp = pd.read_csv(wav_scp_bsv, delimiter = '|', header = None, names = ["utt_id", "wav_path"], dtype = str)

  df = pd.merge(df_text, df_utt2spk, how = 'inner', on = "utt_id")
  df = pd.merge(df, df_wav_scp, how = 'left', on = "utt_id")

  print(df.head())
  print(df.shape[0])

  # split
  # need to keep the sorted order - kaldi requirement
  size = df.shape[0]
  train_indices, dev_indices, test_indices = split_indices(df.index)
  assert size == len(train_indices) + len(dev_indices) + len(test_indices), (size, len(train_indices), len(dev_indices), len(test_indices))

  train_df = df.iloc[train_indices]
  dev_df = df.iloc[dev_indices]
  test_df = df.iloc[test_indices]

  logger.info(f'Train Size: {train_df.shape[0]}, Dev Size: {dev_df.shape[0]}, Test Size: {test_df.shape[0]}')

  # save
  train_df[["utt_id", "transcript"]].to_csv(os.path.join(target_dirs["train"], "text"), header = False, index = False, sep = ' ')
  train_df[["utt_id", "spk_id"]].to_csv(os.path.join(target_dirs["train"], "utt2spk"), header = False, index = False, sep = ' ')
  train_df[["utt_id", "wav_path"]].to_csv(os.path.join(target_dirs["train"], "wav.scp"), header = False, index = False, sep = ' ')
  dev_df[["utt_id", "transcript"]].to_csv(os.path.join(target_dirs["dev"], "text"), header = False, index = False, sep = ' ')
  dev_df[["utt_id", "spk_id"]].to_csv(os.path.join(target_dirs["dev"], "utt2spk"), header = False, index = False, sep = ' ')
  dev_df[["utt_id", "wav_path"]].to_csv(os.path.join(target_dirs["dev"], "wav.scp"), header = False, index = False, sep = ' ')
  test_df[["utt_id", "transcript"]].to_csv(os.path.join(target_dirs["test"], "text"), header = False, index = False, sep = ' ')
  test_df[["utt_id", "spk_id"]].to_csv(os.path.join(target_dirs["test"], "utt2spk"), header = False, index = False, sep = ' ')
  test_df[["utt_id", "wav_path"]].to_csv(os.path.join(target_dirs["test"], "wav.scp"), header = False, index = False, sep = ' ')

  return


if __name__ == "__main__":
  logging.basicConfig(level = logging.INFO) # set INFO as the default logging level
  logger = logging.getLogger(__name__)

  parser = argparse.ArgumentParser()
  parser.add_argument("--data_location", default = None, type = str, help = "NSC SCRIPT Location to preprocess")
  parser.add_argument("--target_parent_dir", default = None, type = str, help = "target parent directory where train, dev, test sit")
  args = parser.parse_args()

  split(args.data_location, args.target_parent_dir)
