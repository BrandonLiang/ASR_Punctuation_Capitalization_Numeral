import argparse

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--k", default = 10000, type = int, help = "threshold")
  parser.add_argument("--output_location", default = None, type = str, help = "output location")
  args = parser.parse_args()

  with open(args.output_location, 'w') as f:
    i = 0
    while i < args.k:
      f.write("%d\n" % i)
      i += 1
