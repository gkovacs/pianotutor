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
  if root.currentLineNum < root.corpus_lines.length
    root.currentLineNum += 1
  showLine()
  setTimeout playNotesInOrder, 300

cleanSubgoalName = (name) ->
  basename = name.split('.xml')[0..0][0]
  basenameNoDigits = basename.replace(/[0-9]/g, '');
  nameParts = name.split('.xml')
  nameParts[0] = basenameNoDigits
  name = nameParts.join('').split('_').join(' ').split('part0').join('').split('verse').join('verse ')
  return name

updateProgress = (lineNum) ->
  totalLines = root.corpus_lines.length
  #songname = window.location.pathname.split('/').join('').split('_').join(' ').split('.html').join('')
  songname = root.songname.split('_').join(' ')
  
  numExercisesFromPriorSubgoals = 0
  
  $('#progressIndicator').html('')
  for subgoal in root.curriculum
    progressInSubgoal = 0
    isCurrent = false
    isFuture = false
    isComplete = false
    if lineNum >= numExercisesFromPriorSubgoals + subgoal.exercises.length
      progressInSubgoal = subgoal.exercises.length
      isComplete = true
    else if lineNum >= numExercisesFromPriorSubgoals
      isCurrent = true
      progressInSubgoal = lineNum - numExercisesFromPriorSubgoals
    else
      isFuture = true
      progressInSubgoal = 0
    name = cleanSubgoalName subgoal.name
    namespan = $('<span>').text(' ' + name)
    if isCurrent
      namespan.css('font-weight', 'bold')
    else if isFuture
      namespan.css('color', 'grey')
    glyphspan = $('<span class="glyphicon">')
    if isCurrent
      glyphspan.addClass 'glyphicon-music'
    else if isComplete
      glyphspan.addClass 'glyphicon-ok'
    curdiv = $('<div class="btn-group" style="padding-left: 10px; padding-right: 10px">').append(glyphspan).append(namespan).append('<br>')
    #curdiv.append('<br>').append('Exercise ' + progressInSubgoal + ' / ' + subgoal.exercises.length)
    exerciseNum = progressInSubgoal
    if isCurrent
      exerciseNum += 1
    curbtn = $('<button type="button" class="btn dropdown-toggle" data-toggle="dropdown" ><span class="caret"></span> Exercise ' + exerciseNum + '/' + subgoal.exercises.length + '</button>')
    if isCurrent
      curbtn.addClass 'btn-primary'
    else
      curbtn.addClass 'btn-default'
    curdiv.append(curbtn)
    toex = $('<ul class="dropdown-menu" role="menu">')
    toex.empty()
    for i in [0...subgoal.exercises.length]
      curitem = $('<li>')
      curlink = $('<a>')
      curlink.attr 'href', '#'
      curlink.text 'Exercise ' + (i+1)
      #if i <= maxLineReached()
      curlink.attr('onclick', 'window.location.hash = "#' + (i + numExercisesFromPriorSubgoals) + '"; window.location.reload()')
      #else
      #  curitem.addClass 'disabled'
      curitem.append curlink
      toex.append curitem
    numExercisesFromPriorSubgoals += subgoal.exercises.length
    curdiv.append toex
    $('#progressIndicator').append curdiv

  '''
  $('#progressIndicator').css('font-size', '24px')
  $('#progressIndicator').html('Exercise <b>' + (lineNum+1) + '/' + (totalLines-1) + '</b> in <b>' + songname + '</b>')
  '''

setNotesFromText = (span, text, durationMap, startnum) ->
  if not startnum?
    startnum = 0
  notes = text.split(' ')
  span.empty()
  isFirst = true
  notenum = startnum
  for note in notes
    if note == ''
      continue
    notebase = note
    duration = 1.0
    if durationMap[notenum]?
      duration = durationMap[notenum]
    #durationspan = $('<span>').text(duration)
    notespan = $('<span>').text(notebase).attr('note', notebase).attr('duration', duration).attr('notenum', notenum).addClass('note_' + notenum).addClass('targetnotes')
    #curspan = $('<span>').append(durationspan).append(notespan)
    span.append notespan
    if isFirst
      isFirst = false
    else
    span.append ' '
    notenum += 1
  return notenum

showLine = () ->
  window.location.hash = '#' + root.currentLineNum
  console.log 'showLine for line' + currentLineNum
  targetTextWithDurations = root.corpus_lines[root.currentLineNum].toLowerCase()
  root.targetText = noDurations(targetTextWithDurations)
  root.targetDurations = toDurationMap(targetTextWithDurations)
  if root.targetText.indexOf('congratulations') != -1
    window.location = 'skilltree.html'
  $('#textDisplay_entered').text('')
  notenum = setNotesFromText $('#textDisplay_entered'), '', root.targetDurations, 0
  #$('#textDisplay_todo').text(root.targetText)
  setNotesFromText $('#textDisplay_todo'), root.targetText, root.targetDurations, notenum
  updateText(true)
  updateProgress(root.currentLineNum)
  if root.currentLineNum > maxLineReached()
    $.cookie 'maxreached_' + root.globaltaskname, root.currentLineNum, {expires: 365}
    $.cookie 'numparts_' + root.globaltaskname, root.corpus_lines.length-1, {expires: 365}
  toex = $('#goto_exercise')
  toex.empty()
  for i in [0...root.corpus_lines.length-1]
    curitem = $('<li>')
    curlink = $('<a>')
    curlink.attr 'href', '#'
    curlink.text 'Exercise ' + (i+1)
    if i <= maxLineReached()
      curlink.attr('onclick', 'window.location.hash = "#' + i + '"; window.location.reload()')
    else
      curitem.addClass 'disabled'
    curitem.append curlink
    toex.append curitem

root.formValueIncludesInputted = false
root.haveCheckedFormValueIncludesInputted = false

matchLength = (str1, str2) ->
  for i in [0...Math.min(str1.length, str2.length)]
    if str1[i].toLowerCase() != str2[i].toLowerCase()
      return i
  return i

root.currentLineStartTime = 0

root.lineFinishLogs = []

initLineLog = ->
  data = {}
  data.keyevents = []
  return data

root.lineLog = initLineLog()

addKeyEvent = root.addKeyEvent = (key_pressed, key_expected)->
  currentTime = new Date().getTime()
  keyevent = {
    pressed: key_pressed,
    expected: key_expected,
    position: root.numNotesEntered,
    time: currentTime
  }
  console.log keyevent
  root.lineLog.keyevents.push keyevent

sendLineLog = root.sendLineLog = ->
  root.lineLog['logtype'] = 'line'
  root.lineLog['lineNum'] = root.currentLineNum
  root.lineLog['targetText'] = root.targetText
  root.lineLog['user'] = root.workerId
  root.lineLog['taskname'] = root.taskname
  root.lineLog['posttime'] = new Date().getTime()
  root.lineLog['starttime'] = new Date(root.currentLineStartTime).getTime()
  postToServer root.lineLog
  root.lineLog = initLineLog()

sendStartLog = root.sendStartLog = ->
  data = {}
  data['user'] = root.workerId
  data['taskname'] = root.taskname
  data['posttime'] = new Date().getTime()
  data['logtype'] = 'start'
  postToServer(data)

root.postToServer = postToServer = (data) ->
  console.log data
  $.ajax {
    type: 'POST',
    url: '/postlog',
    data: JSON.stringify(data),
    contentType: 'application/json; charset=utf-8',
    dataType: 'json'
  }

root.sendLogs = ->
  startTime = root.lineFinishLogs[0].startedAt
  $.get('/varTable?varname=' + escape(startTime) + '&set=' + escape(JSON.stringify(root.lineFinishLogs)), (data) ->
    $('#logLink').attr('href', '/varTable?varname=' + escape(startTime))
    $('#logLink').show()
  )

root.nextNoteToHighlight = 0
root.highlightNoteSeries = -1

root.autoPlayback = false

root.playNotesInOrder = playNotesInOrder = ->
  #console.log 'clearing button highlights'
  highlightButtonClearAll()
  root.autoPlayback = true
  $('#textInput').prop 'disabled', true
  performOnNotesInOrder (noteSpan) ->
    if not highlightNote noteSpan
      root.autoPlayback = false
      updateText(true)
      $('#textInput').prop 'disabled', false
      $('#textInput').focus()
      return false
    note = noteSpan.attr 'note'
    playNote note
    return true

root.highlightNotesInOrder = highlightNotesInOrder = ->
  performOnNotesInOrder highlightNote

root.performOnNotesInOrder = performOnNotesInOrder = (fn, seriesid) ->
  if not seriesid?
    seriesid = Math.floor(Math.random()*10000)
    root.highlightNoteSeries = seriesid
    root.nextNoteToHighlight = 0
  if seriesid != highlightNoteSeries
    return
  nextnote = $('.note_' + root.nextNoteToHighlight)
  if not fn nextnote
    return
  nextnote_note_text = nextnote.attr('note')
  nextnote_note_duration = 1.0
  if nextnote.attr('duration')
    nextnote_note_duration = parseFloat(nextnote.attr('duration'))
  root.nextNoteToHighlight += 1
  setTimeout ->
    root.performOnNotesInOrder(fn, seriesid)
  , 500 * nextnote_note_duration

root.highlightNote = highlightNote = (note) ->
  $('.targetnotes').css 'background-color', 'white'
  if note.length == 0
    return false
  note.css 'background-color', 'yellow'
  return true

root.highlightNotesClearAll = highlightNotesClearAll = ->
  $('.targetnotes').css 'background-color', 'white'

root.highlightNoteRedNoClear = highlightNoteRedNoClear = (note) ->
  #$('.targetnotes').css 'background-color', 'white'
  if note.length == 0
    return false
  note.css 'background-color', '#F08080'
  return true

root.highlightNoteAtPosition = highlightNoteAtPosition = (position) ->
  note = $('.note_' + position)
  return highlightNote note

root.numTimesDeletePressed = 0

root.nextNote = ''
root.lastText = ''

root.numNotesEntered = 0

root.errorIndexes = []

updateText = (forced) ->
    if not forced?
      forced = false
    ntext = $('#textInput').val()
    if ntext == root.lastText and not forced
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

    numNotesEntered = 0
    for chunk in reftext_entered.split(' ')
      if chunk.trim() != ''
        numNotesEntered += 1
    root.numNotesEntered = numNotesEntered

    #$('#textDisplay_entered').text(reftext_entered)
    #$('#textDisplay_todo').text(reftext_todo)
    notenum = setNotesFromText $('#textDisplay_entered'), reftext_entered, root.targetDurations, 0
    setNotesFromText $('#textDisplay_todo'), reftext_todo, root.targetDurations, notenum

    highlightNotesClearAll()
    for errorIndex in root.errorIndexes
      highlightNoteRedNoClear $('.note_' + errorIndex)

    if root.isMusic
      console.log reftext_todo
      nextNote = reftext_todo.trim().split(' ')[0]
      if nextNote? and nextNote.length?
        nextNote = nextNote.trim()
        if nextNote.trim().length > 0
          console.log 'next note is:' + nextNote
          root.nextNote = nextNote
          $('.targetButton').css('background-color', 'white').removeClass('targetButton')
          highlightButtonTarget nextNote


    if numMatched == root.targetText.length
      $('#textInput').val('')
      sendLineLog()
      root.lineFinishLogs.push {'targetText': root.targetText, 'startedAt': new Date(root.currentLineStartTime).toString(), 'completedAt': new Date().toString()}
      root.currentLineStartTime = 0
      if root.targetText == 'you are now done typing'
        root.sendLogs()
      if root.errorIndexes.length >= 1
        root.numTimesDeletePressed = 0
        root.errorIndexes = []
        showLine()
        #setTimeout (-> updateText(true)), 100
      #else if root.numTimesDeletePressed > 1
      #  root.numTimesDeletePressed = 0
      #  root.currentLineNum = Math.max(0, root.currentLineNum - 1)
      #  showLine()
      else
        nextLine()

root.hashname_to_index = {}

#corpus_lines = root.corpus_lines = root.corpus.split('\n')
do () ->
  for idx in [0...corpus_lines.length]
    line = corpus_lines[idx]
    hashidx = line.indexOf(' # ')
    if hashidx != -1
      hashname = line[hashidx+2..].trim()
      root.hashname_to_index[hashname] = idx
      corpus_lines[idx] = line[...hashidx].trim()
    #console.log x
  #break

sharpToFlat = (basenote) ->
  return {
    'g#': 'Ab',
    'a#': 'Bb',
    'c#': 'Db',
    'd#': 'Eb',
    'f#': 'Gb'
  }[basenote.toLowerCase()]

addNotes = () ->
  for notenode in $('.key')
    note = $(notenode).text()
    noteFile = getMusicFileForNote note
    noteAlpha = note.split('#').join('s')
    $('#notes').append $('<audio>').attr('src', noteFile).attr('id', 'note_' + noteAlpha).css('display', 'none')

getNoteAlpha = (note) ->
  return note.split('#').join('s')

playNote = root.playNote = (note) ->
  highlightButton note.split('_')[0..0][0]
  noteAlpha = getNoteAlpha note.split('_')[0..0][0]
  audioTagJquery = $('#note_' + noteAlpha)
  currentTime = (new Date).getTime()
  audioTagJquery.attr('playEnd', currentTime + 500)
  audioTagJquery.attr('highlightEnd', currentTime + 200)
  audioTag = audioTagJquery[0]
  audioTag.pause()
  audioTag.currentTime = 0.0
  #audioTag.playbackRate = 1.5
  audioTag.play()
  #setTimeout () ->
  #  playEnd = parseInt(audioTagJquery.attr('playEnd'))
  #  if (new Date).getTime() >= playEnd
  #    audioTagJquery[0].pause()
  #, 501
  setTimeout () ->
    highlightEnd = parseInt(audioTagJquery.attr('highlightEnd'))
    if (new Date).getTime() >= highlightEnd
      unhighlightButton note.split('_')[0..0][0]
  , 201

unhighlightButton = root.unhighlightButton = (note) ->
  note = note.split('_')[0..0][0]
  button = $('#button_' + getNoteAlpha(note))
  button.attr 'highlighted', false
  if note == root.nextNote and !root.autoPlayback
    button.css 'background-color', 'yellow'
  else
    button.css 'background-color', 'white'
    button.removeClass 'targetButton'

highlightButtonClearAll = root.highlightButtonClearAll = ->
  $('.targetButton').css('background-color', 'white').removeClass('targetButton').attr('highlighted', false).attr('isTarget', false)

highlightButton = root.highlightButton = (note) ->
  note = note.split('_')[0..0][0]
  button = $('#button_' + getNoteAlpha(note))
  button.attr 'highlighted', true
  button.attr 'isTarget', false
  button.css 'background-color', 'lightblue'

highlightButtonTarget = root.highlightButtonTarget = (note) ->
  console.log 'highlighted:' + note
  note = note.split('_')[0..0][0]
  button = $('#button_' + getNoteAlpha(note))
  if root.autoPlayback
    return
  button.addClass 'targetButton'
  button.css 'background-color', 'yellow'

getMusicFileForNote = root.getMusicFileForNote = (note) ->
  octave = parseInt(note[-1..]) + 3
  basenote = note[...-1]
  if basenote[-1..] == '#'
    basenote = sharpToFlat basenote
  else
    basenote = basenote.toUpperCase()
  return 'piano/Piano.ff.' + basenote + octave + '.m4a'

makeButton = (name) ->
  button = $('<div>').text(name).addClass('keybase')
  button.attr 'id', 'button_' + getNoteAlpha(name)
  if name in ['tab', 'caps', 'shift', 'delete', 'return']
    button.addClass name
  else
    button.addClass 'key'
  return button

displayKeyboard = ->
  for letter in ['`'].concat '1234567890'.split('').concat '-='.split('').concat ['delete']
    $('#keyboard').append makeButton(transformTypedChar letter)
  $('#keyboard').append $('<div>').css('clear', 'both')
  for letter in ['tab'].concat 'QWERTYUIOP'.split('').concat '[]\\'.split('')
    $('#keyboard').append makeButton(transformTypedChar letter)
  $('#keyboard').append $('<div>').css('clear', 'both')
  for letter in ['caps'].concat 'ASDFGHJKL'.split('').concat ";'".split('').concat ['return']
    $('#keyboard').append makeButton(transformTypedChar letter)
  $('#keyboard').append $('<div>').css('clear', 'both')
  for letter in ['shift'].concat 'ZXCVBNM'.split('').concat ',./'.split('').concat ['shift']
    $('#keyboard').append makeButton(transformTypedChar letter)
  console.log 'keyboard displayed'

maxLineReached = root.maxLineReached = ->
  maxreached = $.cookie 'maxreached_' + root.globaltaskname
  if maxreached?
    return parseInt maxreached
  return 0

setSelectionRange = root.setSelectionRange = (input, selectionStart, selectionEnd) ->
  if input.setSelectionRange
    input.focus()
    input.setSelectionRange(selectionStart, selectionEnd)
  else if input.createTextRange
    range = input.createTextRange()
    range.collapse(true)
    range.moveEnd('character', selectionEnd)
    range.moveStart('character', selectionStart)
    range.select()

setCaretToPos = root.setCaretToPos = (input, pos) ->
  setSelectionRange(input, pos, pos)

getUrlParameters = root.getUrlParameters = ->
  map = {}
  parts = window.location.href.replace /[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    map[key] = decodeURI(value)
  return map

noDurations = (musicstring) ->
  output = []
  for x in musicstring.split(' ')
    x = x.split('_')[0]
    output.push(x)
  return output.join(' ')

toDurationMap = (musicstring) ->
  output = {}
  for x,idx in musicstring.split(' ')
    duration = 1.0
    if x.indexOf('_') != -1
      duration = parseFloat(x.split('_')[-1..-1][0])
    output[idx] = duration
  return output

root.workerId = 'foobar'
root.taskname = 'sometask'
root.songname = 'practice'

$(document).ready ->
  urlparams = getUrlParameters()
  if urlparams['workerId']?
    root.workerId = urlparams['workerId']
  else
    if not $.cookie('username')?
      $.cookie('username', (Math.floor(Math.random()*10) for i in [0...10]).join(''))
    root.workerId = $.cookie('username')
  if urlparams['taskname']?
    root.taskname = urlparams['taskname']
  if urlparams.songname?
    root.songname = urlparams.songname
    if root.songname.indexOf('#') != -1
      root.songname = root.songname[...root.songname.indexOf('#')]
    if root.taskname == 'sometask'
      root.taskname = root.songname
  maxlinereached = maxLineReached()
  if window.location.hash? and window.location.hash.trim() != ''
    console.log 'hash is:' + window.location.hash
    hashstring = window.location.hash.split('#').join('')
    if root.hashname_to_index[hashstring]?
      root.currentLineNum = root.hashname_to_index[hashstring]
    else
      hashstringAsInt = parseInt(hashstring)
      if not isNaN(hashstringAsInt)
        root.currentLineNum = hashstringAsInt
    if root.currentLineNum > maxlinereached
      root.currentLineNum = maxlinereached
  else
    root.currentLineNum = maxlinereached

  showLine()

  $('#textInput').focus()
  $('#textInput').bind 'blur', (event) ->
    $('#textInput').focus()
    setCaretToPos(document.getElementById('textInput'), $('#textInput').val().length)
    event.preventDefault()
    return false
  $('#textInput').bind 'cut copy paste drop', (event) ->
    event.preventDefault()
    return false
  $('#textInput').bind 'propertychange keyup input', (event) ->
    updateText()
    return false
  $("#textInput").bind 'keydown', (evt) ->
    $('#textInput').focus()
    setCaretToPos(document.getElementById('textInput'), $('#textInput').val().length)
    if evt.which?
        console.log evt.which
        #if evt.ctrlKey? and evt.ctrlKey
        #  return true
        #if evt.altKey? and evt.altKey
        #  return true
        if evt.which == 8 # delete button
          #return false
          root.numTimesDeletePressed += 1
          if root.isMusic
            start = this.selectionStart
            end = this.selectionEnd
            val = this.value
            lastSpace = start-2
            while lastSpace > 0
              if val[lastSpace] == ' '
                break
              lastSpace -= 1
            this.value = val.slice(0, lastSpace) + ' ' + val.slice(end)
            if this.value == ' '
              this.value = ''
            return false
        origChar = root.mapKeyPressToActualCharacter(evt.shiftKey, evt.which)
        console.log origChar
        transformedChar = transformTypedChar(origChar)
        #console.log transformedChar

        if transformedChar != origChar
            if root.isMusic
              playNote transformedChar
              addKeyEvent(transformedChar, root.nextNote)
              transformedChar = transformedChar + ' '
            start = this.selectionStart
            end = this.selectionEnd
            val = this.value
            newvalue = val.slice(0, start) + transformedChar + val.slice(end)
            #targetTextNoDurations = noDurations(targetText)
            if root.targetText.indexOf(newvalue.trim()) != 0 and root.targetText != 'freestyle' and root.targetText.indexOf('you have finished the task. enter this code on the hit page:') != 0 and root.targetText.indexOf('congratulations') != 0
              numTimesDeletePressed += 1
              errorIndex = parseInt $($('#textDisplay_todo').find('.targetnotes')[0]).attr('notenum')
              root.errorIndexes.push errorIndex
              highlightNoteRedNoClear $('.note_' + errorIndex)
              return false
            #transformedChar = targetText.slice(start).split(' ')[0] + ' '
            newvalue = val.slice(0, start) + transformedChar + val.slice(end)
            #console.log 'targetText:' + targetText
            this.value = newvalue
            # Move the caret
            this.selectionStart = this.selectionEnd = start + transformedChar.length
            return false
  displayKeyboard()
  if root.isMusic
    addNotes()
    updateText(true)
  sendStartLog()
  setTimeout playNotesInOrder, 1000

make_key_mapping = (qwerty_rows, dvorak_rows) ->
  output = {}
  for i in [0...qwerty_rows.length]
    qwerty_row = qwerty_rows[i]
    if not qwerty_row?
      continue
    dvorak_row = dvorak_rows[i]
    if not dvorak_row?
      continue
    for j in [0...qwerty_row.length]
      qwerty_key = qwerty_row[j]
      if not qwerty_key?
        continue
      dvorak_key = dvorak_row[j]
      if not dvorak_key?
        continue
      output[qwerty_key] = dvorak_key
  console.log output
  return output

q_rows = [
  '`1234567890-='.split(''),
  'qwertyuiop[]\\'.split(''),
  "asdfghjkl;'".split(''),
  'zxcvbnm,./'.split(''),
  '~!@#$%^&*()_+'.split(''),
  'QWERTYUIOP{}'.split(''),
  'ASDFGHJKL:"'.split(''),
  'ZXCVBNM<>?'.split('')
]
m_rows = [
  ['c3', 'c#3', 'd3', 'd#3', 'e3', 'f3', 'f#3', 'g3', 'g#3', 'a3', 'a#3', 'b3', 'c4'],
  ['b1', 'c2', 'c#2', 'd2', 'd#2', 'e2', 'f2', 'f#2', 'g2', 'g#2', 'a2', 'a#2', 'b2'],
  ['c1', 'c#1', 'd1', 'd#1', 'e1', 'f1', 'f#1', 'g1', 'g#1', 'a1', 'a#1'],
  ['d0', 'd#0', 'e0', 'f0', 'f#0', 'g0', 'g#0', 'a0', 'a#0', 'b0'],
  ['c3', 'c#3', 'd3', 'd#3', 'e3', 'f3', 'f#3', 'g3', 'g#3', 'a3', 'a#3', 'b3', 'c4'],
  ['b1', 'c2', 'c#2', 'd2', 'd#2', 'e2', 'f2', 'f#2', 'g2', 'g#2', 'a2', 'a#2', 'b2'],
  ['c1', 'c#1', 'd1', 'd#1', 'e1', 'f1', 'f#1', 'g1', 'g#1', 'a1', 'a#1'],
  ['d0', 'd#0', 'e0', 'f0', 'f#0', 'g0', 'g#0', 'a0', 'a#0', 'b0']
]
d_rows = [
  '`1234567890[]'.split(''),
  "',.pyfgcrl/=\\".split(''),
  'aoeuidhtns-'.split(''),
  ';qjkxbmwvz'.split(''),
  '~!@#$%^&*(){}'.split(''),
  '"<>PYFGCRL?+'.split(''),
  'AOEUIDHTNS_'.split(''),
  ':QJKXBMWVZ'.split('')
]
to_dvorak = make_key_mapping(q_rows, d_rows)
to_piano = make_key_mapping(q_rows, m_rows)
substitution_table = to_piano

root.isMusic = true

transformTypedChar = (origChar) ->
  #return origChar
  if substitution_table[origChar]?
    return substitution_table[origChar]
  return origChar