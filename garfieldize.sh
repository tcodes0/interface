#!/usr/bin/env python

import sys
import copy
def garfieldize(utterance):
    print("".join([f":garfield_{e}:" if e.isalpha() else f"  {e}  " for e in " ".join(utterance)]))
    # print("copied")

if __name__ == "__main__":
    input_stream = None
    if not sys.stdin.isatty():
        input_stream = sys.stdin
    else:
        input_stream = sys.argv[1:]
    garfieldize(input_stream)