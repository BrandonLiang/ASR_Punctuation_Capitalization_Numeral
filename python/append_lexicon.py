import copy
import argparse
import pandas as pd

#punctuations = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
punctuations = '!"$%&\'()+,-./:;=?@`'
#SILENCE_PHONES = ["SIL", "NSN", "oov"]
SILENCE_PHONES = ["NSN"]

def is_alphabet_lowercase(c):
  if 97 <= ord(c) <= 122:
    return True
  else:
    return False

def is_alphabet(c):
  if 65 <= ord(c) <= 90 or is_alphabet_lowercase(c):
    return True
  else:
    return False

def add_capitalize(s):
  if is_alphabet_lowercase(s[0]):
    return [copy.deepcopy(s), s[0].upper() + s[1:]]
  else:
    return [copy.deepcopy(s)]

# add silence phones as pronunciation for the incoming tokens
def silence_phones(tokens):
  lex = []
  for token in tokens:
    for silence_phone in SILENCE_PHONES:
      lex.append("{} {}\n".format(token, silence_phone))
  return lex

# attach punctuations to the end of all possible tokens
def attach_punctuations(lexicons):
  updated_lexicons = copy.deepcopy(lexicons)
  for mapping in lexicons:
    space_index = mapping.index(" ")
    for punct in punctuations:
      updated_lexicons.append(mapping[:space_index] + punct + mapping[space_index:])
  return updated_lexicons

def attach_dumb_numeral_lexicons(numeral_lexicon_dumb):
  addition = []
  df = pd.read_csv(numeral_lexicon_dumb, delimiter = '\t', header = None, names = ["number", "pronunciation"], dtype = str)
  for index, row in df.iterrows():
    addition.append("{} {}\n".format(row.number, row.pronunciation))
  return addition

def infer_numeral_lexicons(numeral_lexicon_base, k = 10000):
  addition = []
  mapping = {}
  # for non-numeric words that are crucial in number spelling
  extra_words = ["a", "and", "hundred", "thousand", "million"]
  extra_word_mapping = {}
  df = pd.read_csv(numeral_lexicon_base, delimiter = '|', header = None, names = ["word", "pronunciation"], dtype = str)

  df_number = df[~df.word.isin(extra_words)]
  df_word = df[df.word.isin(extra_words)]

  # store words
  for index, row in df_word.iterrows():
    extra_word_mapping[row.word] = row.pronunciation

  # store numbers
  for index, row in df_number.iterrows():
    num = row.word
    pronun = row.pronunciation
    if num in mapping:
      tmp = mapping[num]
      tmp.append(pronun)
    else:
      mapping[num] = [pronun]
    addition.append("{} {}\n".format(num, pronun))

  print(extra_word_mapping)

  number = 21
  while number < k:
    #print(number)
    number_string = str(number)
    if number < 100:
      if number % 10 != 0: # already have 20, 30, 40, ..., 90
        mapping[number_string] = combine2(mapping[number_string[0] + "0"], mapping[number_string[-1]])
    elif number < 1000:
      first_digit = number_string[0]
      if number % 100 != 0:
        if int(number_string[1:]) < 10:
          key = number_string[-1]
        else:
          key = number_string[1:]
        tmp = combine2(mapping[first_digit], mapping[key], sep = " " + extra_word_mapping["hundred"] + " " + extra_word_mapping["and"] + " ")

        if first_digit == "1":
          tmp.extend(combine2([extra_word_mapping["a"]], mapping[key], sep = " " + extra_word_mapping["hundred"] + " " + extra_word_mapping["and"] + " "))
      else: # hundreds
        tmp = combine2(mapping[first_digit], [extra_word_mapping["hundred"]])

        if first_digit == "1":
          tmp.extend(combine2([extra_word_mapping["a"]], [extra_word_mapping["hundred"]]))
      mapping[number_string] = tmp

    elif number < 10000:
      pass

    # append to return
    for pronun in mapping[number_string]:
      addition.append("{} {}\n".format(number_string, pronun))

    number += 1

  print(mapping)

  return addition

# given two lists, return all possible combination (in order)
def combine2(list1, list2, sep = " "):
  result = []
  for e1 in list1:
    for e2 in list2:
      result.append("{}{}{}".format(e1, sep, e2))
  return result


def main(default_lexicon, numeral_lexicon_base, k, numeral_lexicon_dumb, output_lexicon):
  lexicons = []
  f = open(default_lexicon, 'r')
  for line in f.readlines():
    # 1. capitalize 1st letter - duplicate
    lexicons.extend(add_capitalize(line))
  f.close()

  # 2.1 add inferred numeral lexicons from base numeral lexicons
  lexicons.extend(infer_numeral_lexicons(numeral_lexicon_base, k))

  # 2.2 add dumb numeral lexicons
  lexicons.extend(attach_dumb_numeral_lexicons(numeral_lexicon_dumb))

  # 3.1 attach punctuations to the end of all possible tokens
  lexicons = attach_punctuations(lexicons)

  # 3.2 add punctuations as standalone tokens with silence phones
  lexicons.extend(silence_phones(punctuations))

  with open(output_lexicon, 'w') as f:
    for line in lexicons:
      f.write("%s" % line)

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--default_lexicon_location", default = None, type = str, help = "default lexicon location")
  parser.add_argument("--numeral_lexicon_base_location", default = None, type = str, help = "base numeral lexicon location")
  parser.add_argument("--k", default = 10000, type = int, help = "numerical threshold in numeral lexicon")
  parser.add_argument("--numeral_lexicon_dumb_location", default = None, type = str, help = "dumb numeral lexicon location")
  parser.add_argument("--output_lexicon_location", default = None, type = str, help = "output lexicon location")
  args = parser.parse_args()

  main(args.default_lexicon_location, args.numeral_lexicon_base_location, args.k, args.numeral_lexicon_dumb_location, args.output_lexicon_location)
