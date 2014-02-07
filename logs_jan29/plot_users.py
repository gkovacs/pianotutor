import matplotlib.pyplot as plt
import json
import time
import datetime
from dateutil.parser import parse as parsedate
import sys
from scipy.stats.stats import pearsonr
from collections import Counter
from math import sqrt

def groupByTask(loglines):
  prevTarget = ''
  currentGroup = []
  for line in loglines:
    if line['targetText'] != prevTarget and len(currentGroup) > 0:
      yield currentGroup
      currentGroup = [line]
    else:
      currentGroup.append(line)
    prevTarget = line['targetText']
  if len(currentGroup) > 0:
    yield currentGroup

def totimestamp(dt):
  return time.mktime(dt.timetuple())

def timeSpent(logline):
  return totimestamp(parsedate(logline['completedAt'])) - totimestamp(parsedate(logline['startedAt']))

def numNotes(logline):
  return len(logline['targetText'].split(' '))

def numUniqueNotes(logline):
  return len(frozenset(logline['targetText'].split(' ')))

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

class LearnerModel:
  def __init__(self):
    self.substrings_practiced = Counter()
  def get_word_difficulty(self, word):
    num_substrings = 0.0
    substrings_learned = 0.0
    for substring in generate_substrings_music(word):
      num_substrings += (1.0 / len(substring.split(' ')))
      if substring in self.substrings_practiced:
        substrings_learned += (1.0 / len(substring.split(' ')))
    return sqrt(num_substrings - substrings_learned)
  def practice_word(self, word):
    for substring in generate_substrings_music(word):
      self.substrings_practiced[substring] += 1

for user in ['msb', 'chinmay', 'onkur', 'sanjay', 'meo']:
  print user
  userlog = json.load(open(user + '.json'))
  learner_model = LearnerModel()
  points_num_tries = []
  points_total_time_spent = []
  points_avg_time_spent = []
  points_num_notes = []
  points_num_unique_notes = []
  points_difficulty_score = []
  for loglineGroup in groupByTask(userlog):
    if loglineGroup[0]['targetText'].strip() == '':
      continue
    total_time_spent = sum(timeSpent(line) for line in loglineGroup)
    num_tries = len(loglineGroup)
    avg_time_spent = float(total_time_spent) / num_tries
    num_notes = numNotes(loglineGroup[0])
    num_unique_notes = numUniqueNotes(loglineGroup[0])
    difficulty_score = learner_model.get_word_difficulty(loglineGroup[0]['targetText'])
    #print difficulty_score, len(learner_model.substrings_practiced.keys())
    points_total_time_spent.append(total_time_spent)
    points_num_tries.append(num_tries)
    points_avg_time_spent.append(avg_time_spent)
    points_num_notes.append(num_notes)
    points_num_unique_notes.append(num_unique_notes)
    points_difficulty_score.append(difficulty_score)

    learner_model.practice_word(loglineGroup[0]['targetText'])
    #points.append(len(loglineGroup))
    #print len(loglineGroup), loglineGroup[0]['targetText']

  #corr,pval = pearsonr(points_num_tries, points_difficulty_score)
  #print corr, pval

  p1, = plt.plot(points_total_time_spent, 'go')
  p2, = plt.plot(points_num_tries, 'b.')
  p3, = plt.plot(points_num_notes, 'rx')
  p4, = plt.plot(points_num_unique_notes, 'k*')
  p5, = plt.plot(points_difficulty_score, 'p-')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p1,p2,p3,p4,p5], ['total time spent', 'num tries', 'num notes', 'num unique notes', 'difficulty score'])
  #plt.show()
  plt.savefig(user + '.png')
  plt.clf()

  p1, = plt.plot(points_total_time_spent, 'go')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p1], ['total time spent'])
  #plt.show()
  plt.savefig(user + '-timespent.png')
  plt.clf()

  p2, = plt.plot(points_num_tries, 'b.')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p2], ['num tries'])
  #plt.show()
  plt.savefig(user + '-numtries.png')
  plt.clf()

  p3, = plt.plot(points_num_notes, 'rx')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p3], ['num notes'])
  #plt.show()
  plt.savefig(user + '-numnotes.png')
  plt.clf()

  p1, = plt.plot(points_total_time_spent, 'go')
  p2, = plt.plot(points_num_tries, 'b.')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p1,p2], ['total time spent', 'num tries'])
  #plt.show()
  plt.savefig(user + '-timespent_numtries.png')
  plt.clf()

  p2, = plt.plot(points_num_tries, 'b.')
  p3, = plt.plot(points_num_notes, 'rx')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p2,p3], ['num tries', 'num notes'])
  #plt.show()
  plt.savefig(user + '-numtries_numnotes.png')
  plt.clf()

  p1, = plt.plot(points_total_time_spent, 'go')
  p3, = plt.plot(points_num_notes, 'rx')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p1,p3], ['total time spent', 'num notes'])
  #plt.show()
  plt.savefig(user + '-timespent_numnotes.png')
  plt.clf()

  p1, = plt.plot(points_num_tries, 'go')
  p5, = plt.plot(points_difficulty_score, 'rx')
  #plt.ylabel('number of tries until entered correctly')
  plt.legend([p1,p5], ['num tries', 'difficulty_score'])
  #plt.show()
  plt.savefig(user + '-numtries_difficulty.png')
  plt.clf()

