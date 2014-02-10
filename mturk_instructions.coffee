root = exports ? this

root.taskname = '${taskname}'
if root.taskname.indexOf('taskname') != -1
  root.taskname = 'foobarrr' # 92293

getUrlParameters = root.getUrlParameters = ->
  map = {}
  parts = window.location.href.replace /[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    map[key] = decodeURI(value)
  return map

getWorkerId = root.getWorkerId = ->
  params = getUrlParameters()
  if params.workerId?
    return params.workerId
  return ''

insertScript = root.insertScript = (url) ->
  scriptTag = document.createElement('script')
  scriptTag.type = 'text/javascript'
  scriptTag.src = url
  document.documentElement.appendChild(scriptTag)

nextYearDateString = ->
  nextyear = new Date()
  nextyear.setFullYear(nextyear.getFullYear() + 1)
  return nextyear.toGMTString()

taskAcceptedByWorker = root.taskAcceptedByWorker = (accepted_taskname) ->
  if accepted_taskname == '' or accepted_taskname == root.taskname
    console.log 'taskname matches: ' + accepted_taskname 
    setCookieValueIfNotSet 'taskname', root.taskname
    setCookieValueIfNotSet 'expires', nextYearDateString()
  else
    console.log 'taskname mismatch: ' + accepted_taskname + ' vs ' + root.taskname
    document.getElementById('returnwarning').style.display = ''
    #submitButton = document.getElementById('submitButton')
    #if submitButton?
    #  submitButton.disabled = true

acceptHIT = root.acceptHIT = ->
  console.log 'hit accepted'
  insertScript '//pianotutor.herokuapp.com/taskAcceptedByWorker.js?callback=taskAcceptedByWorker&workerid=' + encodeURI(getWorkerId()) + '&taskname=' + encodeURI(root.taskname)

#toHitCode = (taskname) ->
#  output = 0
#  for x in taskname
#    output += x.charCodeAt(0)
#  return output

toHitCode = root.toHitCode = (taskname) ->
  hash = 0
  if taskname.length == 0
    return hash
  for i in [0...taskname.length]
    char = taskname.charCodeAt(i)
    hash = ((hash<<5)-hash)+char
    hash |= 0 # Convert to 32bit integer
  if hash < 0
    return Math.floor(-hash/4096)
  return Math.floor(hash/4096)

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

setCookieValue = root.setCookieValue = (targetKey, targetValue) ->
  existing_keys = []
  haveSetKey = false
  if document.cookie?
    for keyval in document.cookie.split(';')
      parts = keyval.split('=')
      if parts[0] and parts[0] == targetKey
        existing_keys.push targetKey + '=' + targetValue
        haveSetKey = true
      else
        existing_keys.push keyval
  if not haveSetKey
    existing_keys.push(targetKey + '=' + targetValue)
  document.cookie = existing_keys.join(';')

setCookieValueIfNotSet = root.setCookieValueIfNotSet = (targetKey, targetValue) ->
  existingCookieVal = getCookieValue targetKey
  if not existingCookieVal?
    setCookieValue targetKey, targetValue

getCookieValue = root.getCookieValue = (targetKey) ->
  if document.cookie?
    parts = document.cookie.split(';')
    for part in parts
      keyval = part.split('=')
      key = keyval[0]
      if key? and key.trim() == targetKey
        val = keyval[1]
        if val?
          return val
  return null

previewHIT = root.previewHIT = ->
  acceptedTask = getCookieValue 'taskname'
  if acceptedTask? and acceptedTask != '' and acceptedTask != root.taskname
    document.getElementById('dontacceptwarning').style.display = ''

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
  else
    startTask = document.getElementById('startTask')
    startTask.href = '//pianotutor.herokuapp.com/mturk_index_' + root.taskname + '.html'
    workerid = getWorkerId()
    if workerid != ''
      startTask.href = '//pianotutor.herokuapp.com/mturk_index_' + root.taskname + '.html?workerId=' + encodeURI(workerid)
      acceptHIT()
    else # hit is being previewed
      previewHIT()

document.onreadystatechange = ->
  if document.readyState == 'complete'
    documentReady()

