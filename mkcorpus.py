from heapq import nlargest
from collections import Counter
from math import sqrt, log
import sys
import json
import os

'''
# learned: a dictionary of all words that have been learned
def difficulty_of_learning(word, words_learned):
  num_substrings = 0
  substrings_learned = 0
  for substring in generate_substrings(word):
    num_substrings += 1
    if substring in words_learned:
      substrings_learned += 1
  return num_substrings - substrings_learned
'''

def generate_substrings(string):
  for start in range(0, len(string)):
    for end in range(start+1, len(string)+1):
      yield string[start:end]

class LanguageModel:
  word_freqs = Counter()
  substring_freqs = Counter()
  common_words = []
  def __init__(self):
    if not os.path.exists('brownfreqs.json'):
      import nltk
      from nltk.corpus import brown
      fdist = nltk.FreqDist([w.lower() for w in brown.words()])
      json.dump(fdist, open('brownfreqs.json', 'w'))
    else:
      fdist = json.load(open('brownfreqs.json'))
    for word,count in fdist.iteritems():
      self.word_freqs[word] += count
      for substring in generate_substrings(word):
        self.substring_freqs[substring] += count
    self.common_words = nlargest(10000, fdist.keys(), key=lambda w: fdist[w])
  def add_word(self, word, count=1):
    self.common_words.append(word)
    self.word_freqs[word] += count
    for substring in generate_substrings(word):
      self.substring_freqs[substring] += count

class LearnerModel:
  words_practiced = Counter()
  substrings_practiced = Counter()
  def get_word_difficulty(self, word):
    num_substrings = 0
    substrings_learned = 0
    for substring in generate_substrings(word):
      num_substrings += 1
      if substring in self.substrings_practiced:
        substrings_learned += 1
    return sqrt(num_substrings - substrings_learned)
  def practice_word(self, word):
    self.words_practiced[word] += 1
    for substring in generate_substrings(word):
      self.substrings_practiced[substring] += 1

class CurriculumGenerator:
  target_word = ''
  target_substrings = frozenset()
  learner_model = None
  language_model = None
  def __init__(self, target_word, learner_model, language_model):
    self.target_word = target_word
    self.learner_model = learner_model
    self.language_model = language_model
    self.target_substrings = frozenset(generate_substrings(target_word))
  def is_target_reached(self):
    return self.target_word in self.learner_model.words_practiced
  def get_word_usefulness_overall(self, word):
    return 0 # todo
  def get_word_usefulness_target(self, word):
    usefulness = 0
    for substring in generate_substrings(word):
      if substring in self.target_substrings:
        if substring in self.learner_model.substrings_practiced:
          usefulness += max(0, 1.0 - 0.3*self.learner_model.substrings_practiced[substring])
        else:
          usefulness += 1.0
    return sqrt(usefulness)
  def get_next_word_to_practice(self):
    return max(self.language_model.common_words, key=self.get_word_score_for_practice)
  def practice_word(self, word):
    self.learner_model.practice_word(word)

class CurriculumGeneratorThreshold(CurriculumGenerator):
  difficulty_threshold = 1.3 
  def get_word_score_for_practice(self, word):
    if word in self.learner_model.substrings_practiced:
      return -sys.maxint
    usefulness = self.get_word_usefulness_target(word)
    difficulty = self.learner_model.get_word_difficulty(word)
    if usefulness <= 0:
      return -sys.maxint
    if log(difficulty) > self.difficulty_threshold:
      return -sys.maxint
    return log(usefulness)

class CurriculumGeneratorRatio(CurriculumGenerator):
  difficulty_ratio = 1.3 # amount that is dedicated to keeping the sequence easy. increase to make easier. should be at least 1
  def get_word_score_for_practice(self, word):
    if word in self.learner_model.substrings_practiced:
      return -sys.maxint
    usefulness = self.get_word_usefulness_target(word)
    difficulty = self.learner_model.get_word_difficulty(word)
    if usefulness <= 0:
      return -sys.maxint
    return log(usefulness) - self.difficulty_ratio * log(difficulty)

'''
import random

class ErrorModelLength:
  def makes_error(self, word):
    return random.random() < min(float(len(word)) / 10.0, .5)
'''

def main():
  target_word = 'stanford'
  language_model = LanguageModel()
  language_model.add_word(target_word)
  for letter in 'abcdefghijklmnopqrstuvwxyz':
    language_model.add_word(letter)
  learner_model = LearnerModel()
  curriculum_generator = CurriculumGeneratorRatio(target_word, learner_model, language_model)
  while not curriculum_generator.is_target_reached():
    newword = curriculum_generator.get_next_word_to_practice()
    print newword
    curriculum_generator.practice_word(newword)
    #print target_model.learner_model.substrings_practiced

if __name__ == '__main__':
  main()

'''
if not os.path.exists('brownfreqs.json'):
  import nltk
  from nltk.corpus import brown
  fdist = nltk.FreqDist([w.lower() for w in brown.words()])
  json.dump(fdist, open('brownfreqs.json', 'w'))
else:
  fdist = json.load(open('brownfreqs.json'))
uniquewords = fdist.keys()
wordlist = nlargest(10000, uniquewords, key=lambda w: fdist[w])
for letter in 'abcdefghijklmnopqrstuvwxyz':
  wordlist.append(letter)
#print fdist['the']

#wordlist = ['them', 't', 'h', 'e', 'he', 'the', 'm', 'o', 'ore', 'more']
target = 'troublesome'
target_substrings = frozenset(generate_substrings(target))
wordlist.append(target)

#print list(generate_substrings('more'))
words_learned = set()

while target not in words_learned:
  word_scores = {}
  for word in wordlist:
    if word in words_learned:
      word_scores[word] = -sys.maxint
      continue
    wordscore = -difficulty_of_learning(word, words_learned)
    for word_substring in generate_substrings(word):
      if word_substring in target_substrings:
        wordscore += 0.9
    word_scores[word] = wordscore
  #print word_scores
  new_word = max(wordlist, key=lambda w: word_scores[w])
  print new_word
  words_learned.add(new_word)
'''