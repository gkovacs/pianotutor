root = exports ? this

root.taskname = '${taskname}'
if root.taskname.indexOf('taskname') != -1
  root.taskname = 'foobarrr' # 861

toHitCode = (taskname) ->
  output = 0
  for x in taskname
    output += x.charCodeAt(0)
  return output

root.testPlayNote = testPlayNote = ->
  console.log 'note played!'
  audioTag = document.getElementById('testNote')
  audioTag.pause()
  audioTag.currentTime = 0.0
  audioTag.play()

root.codeKeypress = codeKeypress = (event) ->
  if event.keyCode == 13 # enter
    checkCode()
    event.preventDefault()
    return false
  else
    document.getElementById('codeCorrect').style.display = 'none'
    document.getElementById('codeIncorrect').style.display = 'none'
    return true

root.checkCode = checkCode = ->
  expected_hitcode = toHitCode(root.taskname).toString()
  hitcode = document.getElementById('hitcode').value.trim()
  if hitcode != expected_hitcode
    document.getElementById('codeCorrect').style.display = 'none'
    document.getElementById('codeIncorrect').style.display = ''
  else
    document.getElementById('codeCorrect').style.display = ''
    document.getElementById('codeIncorrect').style.display = 'none'
    document.getElementById('checkCodeButton').disabled = true
    document.getElementById('hitcode').disabled = true
    document.getElementById('survey').style.display = ''
    submitButton = document.getElementById('submitButton')
    if submitButton?
      submitButton.style.display = ''

isComboBoxZero = root.isComboBoxZero = (name) ->
  return document.getElementsByName(name)[0].value == '0'

isTextEmpty = root.isTextEmpty = (name) ->
  return document.getElementsByName(name)[0].value == ''

isRadioEmpty = root.isRadioEmpty = (name) ->
  checked = false
  for x in document.getElementsByName(name)
    if x.checked
      checked = true
  return !checked

pleaseAnswer = (name) ->
  alert 'please answer survey question ' + name

root.validateForm = validateForm = ->
  expected_hitcode = toHitCode(root.taskname).toString()
  hitcode = document.getElementById('hitcode').value.trim()
  if hitcode != expected_hitcode
    alert 'the code you input: "' + hitcode + '" is not correct'
    return false
  if not isChrome()
    alert 'You must use Google Chrome to do this task'
    return false
  if isComboBoxZero 'musicexperience'
    pleaseAnswer 3
    return false
  if isComboBoxZero 'musicrecency'
    pleaseAnswer 4
    return false
  if isComboBoxZero 'pianoexperience'
    pleaseAnswer 5
    return false
  if isComboBoxZero 'pianorecency'
    pleaseAnswer 6
    return false
  if isRadioEmpty 'piece1heard'
    pleaseAnswer 7
    return false
  if isRadioEmpty 'piece1played'
    pleaseAnswer 7
    return false
  if isRadioEmpty 'piece2heard'
    pleaseAnswer 7
    return false
  if isRadioEmpty 'piece2played'
    pleaseAnswer 7
    return false
  return true

isChrome = ->
  return /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)

documentReady = ->
  submitButton = document.getElementById('submitButton')
  if submitButton?
    submitButton.onclick = 'return validateForm()'
  if not isChrome()
    document.getElementById('chromewarning').style.display = ''
    if submitButton?
      submitButton.disabled = true
    startTask = document.getElementById('startTask')
    if startTask.text?
      startTask.text = 'You must use Google Chrome to do this task. Open this HIT in Google Chrome to do the task.'
    if startTask.textContent?
      startTask.textContent = 'You must use Google Chrome to do this task. Open this HIT in Google Chrome to do the task.'
    startTask.href = 'http://www.google.com/chrome'
    document.getElementById('checkCodeButton').disabled = true
    document.getElementById('hitcode').disabled = true

document.onreadystatechange = ->
  if document.readyState == 'complete'
    documentReady()

