root = exports ? this

root.targetText = 'hi guys where are you all going'

STRING_MATCH = 1
STRING_SUBSTITUTION = 2
STRING_MISSED = 3
STRING_INSERTED = 4
STRING_SPACE = 5
#STRING_LINESEPARATOR = 6
STRING_INVERSIONFIRST = 7
STRING_INVERSIONSECOND = 8

alphabet = 'abcdefghijklmnopqrstuvwxyz'

root.stringToIndex = {}
do () ->
  for letter,idx in alphabet
    root.stringToIndex[letter] = idx

getSubstitutionScore = (letterA, letterB) ->
  indexA = root.stringToIndex[letterA.toLowerCase()]
  indexB = root.stringToIndex[letterB.toLowerCase()]
  return root.substitutionMatrix[indexA][indexB]

blast_text = (typedText, referenceText) ->
  scores = []
  operationTypes = []
  for i in [0...typedText.length+1]
    scores[i] = (-1000 for j in [0...referenceText.length+1])
    operationTypes[i] = (0 for j in [0...referenceText.length+1])
  scores[0][0] = 0
  
  maxscore = 0
  maxscore_i = 0
  maxscore_j = 0
  
  for i in [0...typedText.length]
    typedChar = typedText[i]
    for j in [0...referenceText.length]
      referenceChar = referenceText[j]
      if referenceChar == ' '
        scores[i+1][j+1] = scores[i+1][j]
        operationTypes[i+1][j+1] = STRING_SPACE
      else if typedChar == referenceChar # text matches!
        scores[i+1][j+1] = scores[i][j] + 1
        operationTypes[i+1][j+1] = STRING_MATCH
      else
        substitutionScore = getSubstitutionScore(referenceChar, typedChar) - .1
        scores[i+1][j+1] = scores[i][j] + substitutionScore
        operationTypes[i+1][j+1] = STRING_SUBSTITUTION
        if i > 0 and j > 0 and operationTypes[i][j] == STRING_SUBSTITUTION
          prevTypedChar = typedText[i-1]
          prevReferenceChar = referenceText[j-1]
          if typedChar == prevReferenceChar and referenceChar == prevTypedChar
            scores[i+1][j+1] += .8
            operationTypes[i+1][j+1] = STRING_INVERSIONSECOND
            operationTypes[i][j] = STRING_INVERSIONFIRST
        if scores[i][j+1] - .4 > scores[i+1][j+1]
          scores[i+1][j+1] = scores[i][j+1] - .4
          operationTypes[i+1][j+1] = STRING_INSERTED
        if scores[i+1][j] - .7 > scores[i+1][j+1]
          scores[i+1][j+1] = scores[i+1][j] - .7
          operationTypes[i+1][j+1] = STRING_MISSED
      if scores[i+1][j+1] > maxscore
        maxscore = scores[i+1][j+1]
        maxscore_i = i+1
        maxscore_j = j+1
  console.log 'maxscore_i: ' + maxscore_i
  console.log 'maxscore_j: ' + maxscore_j
  console.log 'maxscore: ' + maxscore
  output = []
  x = typedText.length #maxscore_i #typedText.length
  y = maxscore_j #referenceText.length
  while x != 0 and y != 0
    op = operationTypes[x][y]
    if op == STRING_MATCH or op == STRING_SUBSTITUTION or op == STRING_INVERSIONFIRST or op == STRING_INVERSIONSECOND
      x -= 1
      y -= 1
      output.push typedText[x]
    if op == STRING_MISSED
      y -= 1
    if op == STRING_INSERTED
      x -= 1
      output.push typedText[x]
    if op == STRING_SPACE
      y -= 1
      output.push ' '
  return [output.reverse().join(''), maxscore_j]
        

removeWhitespace = (text) ->
  output = []
  for c in text
    output.push c.trim()
  return output.join('')

removeNonAlpha = (text) ->
  output = []
  for c in text
    c = c.toLowerCase()
    if alphabet.indexOf(c) != -1
      output.push c
  return output.join('')

root.currentLineNum = 0

nextLine = () ->
  root.currentLineNum += 1
  showLine()

showLine = () ->
  window.location.hash = '#' + root.currentLineNum
  console.log 'showLine for line' + currentLineNum
  root.targetText = root.corpus_lines[root.currentLineNum].toLowerCase()
  $('#textDisplay_entered').text('')
  $('#textDisplay_todo').text(root.targetText)

root.formValueIncludesInputted = false
root.haveCheckedFormValueIncludesInputted = false

matchLength = (str1, str2) ->
  for i in [0...Math.min(str1.length, str2.length)]
    if str1[i].toLowerCase() != str2[i].toLowerCase()
      return i
  return i

root.currentLineStartTime = 0

root.lineFinishLogs = []

root.sendLogs = () ->
  startTime = root.lineFinishLogs[0].startedAt
  $.get('/varTable?varname=' + escape(startTime) + '&set=' + escape(JSON.stringify(root.lineFinishLogs)), (data) ->
    $('#logLink').attr('href', '/varTable?varname=' + escape(startTime))
    $('#logLink').show()
  )

root.numTimesDeletePressed = 0

root.lastText = ''
updateText = () ->
    ntext = $('#textInput').val()
    if ntext == root.lastText
      return
    root.lastText = ntext
    
    if root.currentLineStartTime == 0 and ntext.trim().length > 0
      root.currentLineStartTime = new Date().getTime()
    
    if root.startTime == 0 and ntext.trim().length > 0
      root.startTime = new Date().getTime()
      $('#startTime').text(new Date(root.startTime).toString())
    
    numMatched = matchLength(ntext.trim(), root.targetText)
    reftext_entered = root.targetText[0...numMatched]
    reftext_todo = root.targetText[numMatched..]
    
    $('#textDisplay_entered').text(reftext_entered)
    $('#textDisplay_todo').text(reftext_todo)
    
    if numMatched == root.targetText.length
      $('#textInput').val('')
      root.lineFinishLogs.push {'targetText': root.targetText, 'startedAt': new Date(root.currentLineStartTime).toString(), 'completedAt': new Date().toString()}
      root.currentLineStartTime = 0
      if root.targetText == 'you are now done typing'
        root.sendLogs()
      if root.numTimesDeletePressed >= 1
        root.numTimesDeletePressed = 0
        showLine()
      #else if root.numTimesDeletePressed > 1
      #  root.numTimesDeletePressed = 0
      #  root.currentLineNum = Math.max(0, root.currentLineNum - 1)
      #  showLine()
      else
        nextLine()

root.hashname_to_index = {}

corpus_lines = root.corpus_lines = root.corpus.split('\n')
do () ->
  for idx in [0...corpus_lines.length]
    line = corpus_lines[idx]
    hashidx = line.indexOf('#')
    if hashidx != -1
      hashname = line[hashidx+1..].trim()
      root.hashname_to_index[hashname] = idx
      corpus_lines[idx] = line[...hashidx].trim()
    #console.log x
  #break

$(document).ready ->
  if window.location.hash?
    hashstring = window.location.hash.split('#').join('')
    if root.hashname_to_index[hashstring]?
      root.currentLineNum = root.hashname_to_index[hashstring]
    else
      hashstringAsInt = parseInt(hashstring)
      if not isNaN(hashstringAsInt)
        root.currentLineNum = hashstringAsInt
  
  showLine()
  
  $('#textInput').focus()
  $('#textInput').bind 'propertychange keyup input paste', (event) ->
    updateText()
    return false
  $("#textInput").bind 'keydown', (evt) ->
    if evt.which?
        console.log evt.which
        if evt.which == 8
          root.numTimesDeletePressed += 1
        origChar = root.mapKeyPressToActualCharacter(evt.shiftKey, evt.which)
        console.log origChar
        transformedChar = transformTypedChar(origChar)
        #console.log transformedChar
        if transformedChar != origChar
            start = this.selectionStart
            end = this.selectionEnd
            val = this.value
            this.value = val.slice(0, start) + transformedChar + val.slice(end)
            # Move the caret
            this.selectionStart = this.selectionEnd = start + 1
            return false

make_key_mapping = (qwerty_rows, dvorak_rows) ->
  output = {}
  for i in [0...qwerty_rows.length]
    qwerty_row = qwerty_rows[i]
    dvorak_row = dvorak_rows[i]
    for j in [0...qwerty_row.length]
      qwerty_key = qwerty_row[j]
      dvorak_key = dvorak_row[j]
      output[qwerty_key] = dvorak_key
  console.log output
  return output

q_rows = [
  'qwertyuiop[]',
  "asdfghjkl;'",
  'zxcvbnm,./'
  'QWERTYUIOP{}',
  'ASDFGHJKL:"',
  'ZXCVBNM<>?'
]
d_rows = [
  "',.pyfgcrl/=",
  'aoeuidhtns-',
  ';qjkxbmwvz',
  '"<>PYFGCRL?+',
  'AOEUIDHTNS_',
  ':QJKXBMWVZ'
]
to_dvorak = make_key_mapping(q_rows, d_rows)
substitution_table = to_dvorak

transformTypedChar = (origChar) ->
  #return origChar
  if substitution_table[origChar]?
    return substitution_table[origChar]
  return origChar