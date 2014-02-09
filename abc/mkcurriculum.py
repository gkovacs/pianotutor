#!/usr/bin/env python

import sys
import json
from math import sqrt
from collections import Counter
from math import log

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

def uniq(l):
  seen = set()
  for x in l:
    if x not in seen:
      seen.add(x)
      yield x

class LanguageModel:
  def __init__(self):
    self.substring_freqs = Counter()
    self.common_words = []
    self.most_frequent_count = 0
    for ngram_dict in json.load(open('pitch_8grams.json')):
      for ngram,count in ngram_dict.iteritems():
        self.substring_freqs[ngram] = count
    for word,count in self.substring_freqs.iteritems():
      if count > 10:
        self.common_words.append(word)
        if count > self.most_frequent_count:
          self.most_frequent_count = count
  def add_word(self, word, count=1):
    for substring in generate_substrings_music(word):
      self.substring_freqs[substring] += count
      self.common_words.append(substring)

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

class CurriculumGenerator:
  target_word = ''
  target_word_nobars = ''
  target_substrings = frozenset()
  learner_model = None
  language_model = None
  def __init__(self, target_word, learner_model, language_model):
    self.target_word = target_word
    self.target_word_nobars = ' '.join([bar.strip() for bar in target_word.split('|')])
    self.learner_model = learner_model
    self.language_model = language_model
    self.target_substrings = frozenset(generate_substrings_music(target_word))
  def is_target_reached(self):
    return self.target_word_nobars in self.learner_model.substrings_practiced
  def get_word_usefulness_overall(self, word):
    if word not in self.target_substrings:
      return 0
    else:
      return float(self.language_model.substring_freqs[word]) / self.language_model.most_frequent_count
  def get_word_usefulness_target(self, word):
    usefulness = 0
    for substring in generate_substrings_music(word):
      if substring in self.target_substrings:
        if substring in self.learner_model.substrings_practiced:
          usefulness += 0
          #usefulness += max(0, 1.0 - 0.3*self.learner_model.substrings_practiced[substring])
        else:
          usefulness += (1.0 / len(substring.split(' ')))
    return sqrt(usefulness)
  def get_next_word_to_practice(self):
    return max(self.language_model.common_words, key=self.get_word_score_for_practice)
  def practice_word(self, word):
    self.learner_model.practice_word(word)

class CurriculumGeneratorThreshold(CurriculumGenerator):
  #difficulty_threshold = 0.3
  difficulty_threshold = 0.3
  def get_word_score_for_practice(self, word):
    if word in self.learner_model.substrings_practiced:
      return -sys.maxint
    usefulness = self.get_word_usefulness_target(word) + self.get_word_usefulness_overall(word)
    difficulty = self.learner_model.get_word_difficulty(word)
    if usefulness <= 0:
      return -sys.maxint
    if log(difficulty) > self.difficulty_threshold:
      return -1000 + log(usefulness) - log(difficulty)
    return log(usefulness)

class CurriculumGeneratorRatio(CurriculumGenerator):
  difficulty_ratio = 1.1
  def get_word_score_for_practice(self, word):
    if word in self.learner_model.substrings_practiced:
      return -sys.maxint
    usefulness = self.get_word_usefulness_target(word) + self.get_word_usefulness_overall(word)
    difficulty = self.learner_model.get_word_difficulty(word)
    if usefulness <= 0:
      return -sys.maxint
    return log(usefulness) - self.difficulty_ratio * log(difficulty)

def main():
  targets = []
  target_word = 'e1 d1 c1 d1 | e1 e1 e1'
  targets.append(target_word)
  target_word = 'e1 d1 c1 d1 | e1 e1 e1 | d1 d1 d1 | e1 g1 g1'
  targets.append(target_word)
  target_word = 'e1 d1 c1 d1 | e1 e1 e1 | d1 d1 d1 | e1 g1 g1 | e1 d1 c1 d1 | e1 e1 e1 e1 | d1 d1 e1 d1 c1'
  targets.append(target_word)
  target_word = 'e2 d#2 | e2 d#2 e2 b1 d2 c2'
  targets.append(target_word)
  target_word = 'e2 d#2 | e2 d#2 e2 b1 d2 c2 | a1 c1 e1 a1 | b1 e1 g#1 b1'
  targets.append(target_word)
  target_word = 'e2 d#2 | e2 d#2 e2 b1 d2 c2 | a1 c1 e1 a1 | b1 e1 g#1 b1 | c2 e1 e2 d#2 | e2 d#2 e2 b1 d2 c2 | a1 c1 e1 a1'
  targets.append(target_word)
  language_model = LanguageModel()
  for target_word in targets:
    language_model.add_word(target_word)
  learner_model = LearnerModel()
  for target_word in targets:
    curriculum_generator = CurriculumGeneratorThreshold(target_word, learner_model, language_model)
    while not curriculum_generator.is_target_reached():
      newword = curriculum_generator.get_next_word_to_practice()
      print newword
      curriculum_generator.practice_word(newword)

if __name__ == '__main__':
  main()
