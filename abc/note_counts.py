#!/usr/bin/env python

import glob
import itertools
import sys
import json
from music21 import *

def take_n(input, n):
  prevList = []
  for x in input:
    prevList.append(x)
    if len(prevList) == n:
      yield prevList[:]
      prevList.pop(0)

def add_ngrams(pitches, n, output):
  for ngram in take_n(pitches, n):
    key = ' '.join(ngram)
    if key not in output[n]:
      output[n][key] = 1
    else:
      output[n][key] += 1


abcfiles = glob.glob('lotro-abc/*.abc')
#abcfiles = ['lotro-abc/marund.abc']
#abcfiles = ['lotro-abc/brave.abc']
ngram_size = 8
ngram_dictionary = [{} for n in range(ngram_size+1)]
for abcfile in abcfiles:
  print 'parsing:', abcfile
  try:
    song = converter.parse(abcfile)
  except Exception as e:
    print 'exception:', e
    continue
  if not song.hasMeasures:
    print 'no measures!'
    continue
  if not song.isWellFormedNotation():
    print 'notation not well formed!'
    continue
  print 'processing:', abcfile
  for measurenum in itertools.count():
    print abcfile, measurenum
    try:
      measure = song.measures(measurenum, measurenum+1, collect=[], gatherSpanners=False, searchContext=False)[0]
    except Exception as e2:
      print 'exception:', e2
      continue
    if measure.measureNumber != measurenum:
      break
    pitches = [str(pitch).lower() for pitch in measure.pitches]
    for n in range(1, ngram_size+1):
      add_ngrams(pitches, n, ngram_dictionary)

json.dump(ngram_dictionary, open('pitch_ngrams.json', 'w'))
