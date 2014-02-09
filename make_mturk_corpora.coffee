root = exports ? this

fs = require 'fs'

blockify = (lines, blocksize) ->
  blocks = []
  current_block = []
  for line in lines
    current_block.push line
    if current_block.length >= blocksize
      blocks.push current_block
      current_block = []
  if current_block.length > 0
    blocks.push current_block
  return blocks

shuffle = (array) ->
  counter = array.length
  # While there are elements in the array
  while counter > 0
    #Pick a random index
    index = Math.floor(Math.random() * counter)
    # Decrease counter by 1
    counter -= 1
    # And swap the last element with it
    temp = array[counter]
    array[counter] = array[index]
    array[index] = temp
  return array

lines_to_corpus = (lines) ->
  output = []
  output.push 'root = exports ? this'
  output.push ''
  output.push 'corpus = root.corpus = """'
  for line in lines
    output.push line
  output.push '"""'
  return output.join('\n')

randstr = (length) ->
  output = []
  possible = 'abcdefghijklmnopqrstuvwxyz'
  for i in [0...length]
    output.push possible.charAt(Math.floor(Math.random() * possible.length))
  return output.join('')

toHitCode = require('./make_hitcode').toHitCode
corpus = require('./corpus').corpus

main = ->
  htmlfile = fs.readFileSync 'index.html', 'utf-8'
  htmlfile_lines = htmlfile.split('\n')
  corpus_lines = corpus.split('\n')
  finishing_line = corpus_lines[-1..-1][0].split(':')[0] + ': '
  corpus_lines = corpus_lines[...-1]
  #console.log corpus_lines
  #console.log corpus_lines.length
  tasknames = []
  for scramble_size in [1,2,4,8,16,32,64]
    for iteration in [0...10]
      blocks = blockify corpus_lines, scramble_size
      lines = []
      for block in blocks
        for line in shuffle(block)
          lines.push line
      taskname = scramble_size + '_' + iteration + '_' + randstr(4)
      tasknames.push taskname
      lines.push finishing_line + toHitCode(taskname)
      corpus = lines_to_corpus lines
      corpus_filename = 'mturk_corpus_' + taskname + '.coffee'
      corpus_filename_js = 'mturk_corpus_' + taskname + '.js'
      fs.writeFileSync(corpus_filename, corpus, 'utf-8')
      new_htmlfile_lines = []
      for line in htmlfile_lines
        if line == '<script src="corpus.js"></script>'
          new_htmlfile_lines.push '<script src="' + corpus_filename_js + '"></script>'
        else
          new_htmlfile_lines.push line
      new_htmlfile = new_htmlfile_lines.join('\n')
      new_htmlfile_filename = 'mturk_index_' + taskname + '.html'
      fs.writeFileSync new_htmlfile_filename, new_htmlfile, 'utf-8'
  csvfile = []
  csvfile.push 'taskname'
  for taskname in tasknames
    csvfile.push taskname
  csvfile = csvfile.join('\n')
  fs.writeFileSync = fs.writeFileSync 'mturk_items.csv', csvfile, 'utf-8'
main() if require.main is module
