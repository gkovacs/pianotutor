root = exports ? this

fs = require 'fs'

# learned: a dictionary of all words that have been learned
difficulty_of_learning = (word, words_learned) ->
  num_substrings = 0
  substrings_learned = 0
  for substring in generate_substrings(word):
    num_substrings += 1
    if words_learned[substring]?
      substrings_learned += 1
  return num_substrings - substrings_learned

generate_substrings = (string) ->
  for start in [0 til string.length]
    for end in [start+1 til string.length+1]
      yield string[start til end]

main() if require.main is module