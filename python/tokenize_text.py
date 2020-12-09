import copy
import argparse
import pandas as pd
from nltk.tokenize import WordPunctTokenizer

#punctuations = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
punctuations = '!"$%&\'()+,-./:;=?@`'
#SILENCE_PHONES = ["SIL", "NSN", "oov"]
SILENCE_PHONES = ["NSN"]

def separate_punct(tokenizer, text):
  return " ".join(tokenizer.tokenize(text))

def main(text_location, output_location):
  tokenizer = WordPunctTokenizer()
  df = pd.read_csv(text_location, delimiter = '\t', header = None, names = ["utt", "transcript"], dtype = str)
  df.transcript = df.transcript.apply(lambda x: separate_punct(tokenizer, x))
  df.to_csv(output_location, sep = '\t', header = False, index = False)

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--text_location", default = None, type = str, help = "text location")
  parser.add_argument("--output_location", default = None, type = str, help = "output location")
  args = parser.parse_args()

  main(args.text_location)
