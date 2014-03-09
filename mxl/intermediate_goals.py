import json
import sys
from collections import Counter
from heapq import nlargest

song_db = json.load(open('song_db.json'))

def noDurations(musicstring):
  output = []
  for x in musicstring.split(' '):
    x = x.split('_')[0]
    output.append(x)
  return ' '.join(output)

def generate_substrings_music(musicstring):
  bars = [bar.strip() for bar in musicstring.split('|')]
  for bar in bars:
    string = bar.split(' ')
    for start in range(0, len(string)):
      for end in range(start+1, len(string)+1):
        yield ' '.join(string[start:end])
  for start in range(0, len(bars)):
    for end in range(start+1, len(bars)+1):
      yield ' '.join(bars[start:end])

class IntermediateGoalGenerator:
  def __init__(self, target_song):
    self.learned_substrings = Counter()
    self.available_songs = []
    self.available_songs_to_names = {}
    self.target_song_substrings = Counter()
    self.target_song = target_song
    for substring in generate_substrings_music(noDurations(target_song)):
      self.target_song_substrings[substring] += 1
  def addAvailableSong(self, song, songname):
    self.available_songs.append(song)
    self.available_songs_to_names[song] = songname
  def getDifficultySeq(self, songs):
    return sum(self.getStepDifficultiesExcludingTarget(songs))
  def getDifficulty(self, song):
    return self.getDifficultySeq([song])
  def getNoveltySeq(self, songs):
    novelty = 0
    for song in songs:
      novelty += len(''.join(noDurations(song).split('|')).split(' '))
    return novelty
  def getNovelty(self, song):
    return self.getNoveltySeq([song])
  def getUsefulnessSeq(self, songs):
    usefulness = 0
    learnedNow = Counter()
    for song in songs:
      for substring in generate_substrings_music(noDurations(song)):
        if substring in self.target_song_substrings and substring not in learnedNow:
          usefulness += 1
          learnedNow[substring] += 1
    return usefulness
  def getUsefulness(self, song):
    return self.getUsefulnessSeq([song])
  def getMaxStepDifficulty(self, songs):
    return max(self.getStepDifficultiesIncludingTarget(songs))
  def getStepDifficultiesExcludingTarget(self, songs):
    return self.getStepDifficultiesIncludingTarget(songs)[:-1]
  def getStepDifficultiesIncludingTarget(self, songs):
    stepDifficulties = []
    learnedNow = Counter()
    for song in songs + [target_song]:
      stepDifficulty = 0
      for substring in generate_substrings_music(noDurations(song)):
        if substring not in self.learned_substrings and substring not in learnedNow:
          stepDifficulty += 1
          learnedNow[substring] += 1
      stepDifficulties.append(stepDifficulty)
    return stepDifficulties
  def scoreSongSeq(self, songs):
    return self.getUsefulnessSeq(songs)*3 - self.getDifficultySeq(songs) - 2*self.getMaxStepDifficulty(songs) + self.getNoveltySeq(songs)
  def scoreSong(self, song):
    return self.scoreSongSeq([song])
  def learnSong(self, song):
    for substring in generate_substrings_music(song):
      self.learned_substrings[substring] += 1
  def getNBestSongs(self, n):
    scores_and_songs = [(self.scoreSong(song),song) for song in self.available_songs]
    return [song for score,song in nlargest(n, scores_and_songs)]
  def getBestSong(self):
    return self.getNBestSongs(1)[0]

#print song_db.keys()

target_song_name = 'As_I_Went_To_Bethlehem_2.xml_part0_full'

target_song = song_db[target_song_name]

goal_generator = IntermediateGoalGenerator(target_song)

for songname,song in song_db.iteritems():
  if 'As_I_Went_To_Bethlehem' in songname:
    continue
  goal_generator.addAvailableSong(song, songname)

candidates = goal_generator.getNBestSongs(100)

candidate_seqs = []
for song1 in candidates:
  candidate_seqs.append([song1])
  for song2 in candidates:
    if song1 == song2:
      continue
    candidate_seqs.append([song1, song2])

bestscore = -sys.maxint
bestseq = []

for curseq in candidate_seqs:
  curscore = goal_generator.scoreSongSeq(curseq)
  if curscore > bestscore:
    bestscore = curscore
    bestseq = curseq

output = []

#print 'bestscore:', bestscore
for song in bestseq:
  #if song == target_song:
  #  continue
  #print goal_generator.available_songs_to_names[song]
  output.append({'name': goal_generator.available_songs_to_names[song], 'song': song})
  print >> sys.stderr, song

output.append({'name': target_song_name, 'song': target_song})

print json.dumps(output)

#print goal_generator.getStepDifficultiesIncludingTarget(bestseq)

'''
for songname,song in song_db.iteritems():
  if 30 < len(song.split(' ')) < 50 and '#' not in song:
    print songname
'''
