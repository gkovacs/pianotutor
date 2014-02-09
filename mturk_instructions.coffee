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

root.codeKeypress = codeKeypress = (event) ->
  if event.keyCode == 13 # enter
    checkCode()
  else
    document.getElementById('codeCorrect').style.display = 'none'
    document.getElementById('codeIncorrect').style.display = 'none'

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

documentReady = ->
  isChrome = /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)
  if not isChrome
    alert 'you need to '

  submitButton = document.getElementById('submitButton')
  if submitButton?
    submitButton.onclick = 'return validateForm()'
    submitButton.style.display = 'none'

document.onreadystatechange = ->
  if document.readyState == 'complete'
    documentReady()

