#!/usr/bin/env python3

import sys
import numpy as np
from PIL import Image, ImageOps

def main(argv):
  if len(sys.argv) < 2:
    print("Usage: {0} <text file>".format(sys.argv[0]))
    sys.exit(1)
  path = sys.argv[1]
  with open(path, "r") as f:
    text = f.read()
  raw_lines = text.split('\n')
  new_cnt = 0
  W = 400
  H = 300
  pixels = [[0 for _ in range(W)] for _ in range(H)]
  for line in raw_lines:
    elems = line.split()
    if elems[0] != "CMD":
      continue
    if elems[1] == "SAVE":
      if elems[2] != "x":
        h, v, color = map(int, (elems[2], elems[3], elems[4]))
        pixels[H-1-v][h] = color*16
    elif elems[1] == "NEW":
      new_cnt += 1
      if new_cnt == 2:
        break
  pixels = np.array(pixels).astype(dtype=np.uint8)
  img = Image.fromarray(pixels)
  img.show()

if __name__ == "__main__":
  main(sys.argv)