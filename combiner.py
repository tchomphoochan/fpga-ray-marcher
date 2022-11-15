#!/usr/bin/env python3

from functools import cmp_to_key
import os

def cmp_path(a, b):
  if "types" in a and "types" in b:
    return 0
  if "types" in a:
    return -1
  if "types" in b:
    return 1
  return a < b

def get_file_paths():
  paths = []
  for root, directories, file in os.walk("./src"):
    for file in file:
      paths.append(os.path.join(root,file))
  paths.sort(key=cmp_to_key(cmp_path))
  return paths

def combine_files(paths):
  contents = []
  for path in paths:
    with open(path, "r") as f:
      contents.append(f.read())
  return "\n\n".join(contents)

def main():
  paths = get_file_paths()
  content = combine_files(paths)
  out_path = os.path.join(".", "for-lab-bc", "src", "top_level.sv")
  with open(out_path, "w") as f:
    f.write(content)


if __name__ == "__main__":
  main()