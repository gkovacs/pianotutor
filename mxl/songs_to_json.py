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

def pitchToStr(p):
  np = pitch.Pitch(p.nameWithOctave)
  if not np.octave:
    np.octave = 1
  else:
    np.octave -= 3
  origmidi = np.midi
  if np.accidental and np.accidental.name == 'flat':
    np.accidental = pitch.Accidental('sharp')
    np = np.transpose(-2)
  newmidi = np.midi
  return np.nameWithOctave

def streamToNotes(measure, withDuration=False):
  output = []
  for noteOrRest in measure.notesAndRests:
    duration = noteOrRest.duration.quarterLength
    durationStr = ''
    if withDuration:
      durationStr = '_' + str(duration)
    if noteOrRest.isRest:
      output.append('R' + durationStr)
    else:
      output.append(':'.join([pitchToStr(x) + durationStr for x in noteOrRest.pitches]))
  return output

def isEndMeasure(measure):
    for noteOrRest in measure.notesAndRests:
        lyrics = ''.join([x.text for x in noteOrRest.lyrics])
        if ';' in lyrics or '.' in lyrics:
            return True
    return False
        
def getEndMeasures(part):
    endmeasures = []
    for idx,measure in enumerate(part.getElementsByClass(stream.Measure)):
        if isEndMeasure(measure):
            endmeasures.append(idx)
    return endmeasures

songs_db = {}

abcfiles = glob.glob('hymnsandcarols/*.xml')
#abcfiles = ['lotro-abc/marund.abc']
#abcfiles = ['lotro-abc/brave.abc']
ngram_size = 8
ngram_dictionary = [{} for n in range(ngram_size+1)]
for abcfile in abcfiles:
  abcfilebase = abcfile.split('/')[-1:][0]
  print 'parsing:', abcfile
  try:
    song = converter.parse(abcfile)
  except Exception as e:
    print 'exception:', e
    continue
  parts = song.getElementsByClass(stream.Part)
  #if len(parts) > 1:
  #  print 'more than one part'
  #  continue
  for partidx,part in enumerate(parts):
    if not part.hasMeasures:
      print 'no measures!'
      continue
    if not part.isWellFormedNotation():
      print 'notation not well formed!'
      continue
    sid = abcfilebase + '_part' + str(partidx)
    print 'processing:', abcfile
    measures = part.getElementsByClass(stream.Measure)
    endmeasures = getEndMeasures(part)

    allNotes = []
    for measure in measures:
      allNotes.extend(streamToNotes(measure, True))
      allNotes.append('|')
    if allNotes[-1:] == ['|']:
      allNotes = allNotes[:-1]
    allNotesString = ' '.join(allNotes)
    if 'R' in allNotesString:
      print 'have rest, skipping'
      continue
    if ':' in allNotesString:
      print 'have chord, skipping'
      continue
    if '-' in allNotesString:
      print 'have flat, skipping'
      continue
    if '| |' in allNotesString:
      print 'have empty measure, skipping'
      continue
    songs_db[sid + '_full'] = allNotesString

    startmeasure = 0
    for verseidx,endmeasure in enumerate(endmeasures):
      notes = []
      for measureidx in range(startmeasure, endmeasure+1):
        measure = measures[measureidx]
        notes.extend(streamToNotes(measure, True))
        notes.append('|')
      startmeasure = endmeasure + 1
      if notes[-1:] == ['|']:
        notes = notes[:-1]
      songs_db[sid + '_verse' + str(verseidx)] = ' '.join(notes)
      print ' '.join(notes)
    
    print ' '.join(allNotes)

json.dump(songs_db, open('song_db.json', 'w'))
#json.dump(ngram_dictionary, open('song_db.json', 'w'))
