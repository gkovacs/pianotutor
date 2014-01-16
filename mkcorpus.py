from heapq import nlargest
import sys
import json
import os

# learned: a dictionary of all words that have been learned
def difficulty_of_learning(word, words_learned):
  num_substrings = 0
  substrings_learned = 0
  for substring in generate_substrings(word):
    num_substrings += 1
    if substring in words_learned:
      substrings_learned += 1
  return num_substrings - substrings_learned

def generate_substrings(string):
  for start in range(0, len(string)):
    for end in range(start+1, len(string)+1):
      yield string[start:end]

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