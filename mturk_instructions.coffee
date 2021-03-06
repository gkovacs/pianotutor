root = exports ? this

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
    if not $.cookie('taskname')?
      $.cookie 'taskname', root.taskname, {expires: 365}
    #setCookieValueIfNotSet 'taskname', root.taskname
    #setCookieValueIfNotSet 'expires', nextYearDateString()
  else
    console.log 'taskname mismatch: ' + accepted_taskname + ' vs ' + root.taskname
    document.getElementById('returnwarning').style.display = ''
    if not $.cookie('taskname')?
      $.cookie 'taskname', accepted_taskname, {expires: 365}
    #setCookieValueIfNotSet 'taskname', accepted_taskname
    #setCookieValueIfNotSet 'expires', nextYearDateString()
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
  return false

root.isHitCodeCorrect = isHitCodeCorrect = ->
  expected_hitcode = toHitCode(root.taskname).toString()
  hitcode = document.getElementById('hitcode').value.trim()
  return expected_hitcode == hitcode

root.codeKeypress = codeKeypress = (event) ->
  if event.keyCode == 13 # enter
    checkCode()
    event.preventDefault()
    return false
  else
    document.getElementById('codeCorrect').style.display = 'none'
    document.getElementById('codeIncorrect').style.display = 'none'
    return true

root.codeKeyup = codeKeyup = (event) ->
  if isHitCodeCorrect()
    checkCode()
  return true

root.checkCode = checkCode = ->
  if not isHitCodeCorrect()
    document.getElementById('codeCorrect').style.display = 'none'
    document.getElementById('codeIncorrect').style.display = ''
  else
    document.getElementById('codeCorrect').style.display = ''
    document.getElementById('codeIncorrect').style.display = 'none'
    document.getElementById('checkCodeButton').disabled = true
    #document.getElementById('hitcode').disabled = true
    document.getElementById('survey').style.display = ''
    submitButton = document.getElementById('submitButton')
    if submitButton?
      submitButton.style.display = ''
  return false

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
  return /chrom(e|ium)/.test(navigator.userAgent.toLowerCase())

previewHIT = root.previewHIT = ->
  acceptedTask = $.cookie 'taskname'
  if acceptedTask? and acceptedTask != '' and acceptedTask != root.taskname
    $('#dontacceptwarning').show()
    $('#taskBody').hide()
    $('#submitButton').hide()

checkIfHITDoneCookies = root.checkIfHITDoneCookies = ->
  acceptedTask = $.cookie 'taskname'
  if acceptedTask? and acceptedTask != '' and acceptedTask != root.taskname
    $('#returnwarning').show()
    $('#taskBody').hide()
    $('#submitButton').hide()

documentReady = ->
  $('#submitButton').click ->
    return validateForm()
  if $.browser.mobile
    $('#mobilewarning').show()
    $('#taskBody').hide()
    $('#submitButton').hide()
    $('#submitButton').attr 'disabled', 'disabled'
    $('#startTask').text 'You must use a desktop computer or laptop to do this task. Open this HIT on a desktop computer or laptop to do the task.'
    $('#startTask').attr 'href', 'http://www.google.com/chrome'
    $('#checkCodeButton').attr 'disabled', 'disabled'
    $('#hitcode').attr 'disabled', 'disabled'
  if not isChrome()
    $('#chromewarning').show()
    $('#taskBody').hide()
    $('#submitButton').hide()
    $('#submitButton').attr 'disabled', 'disabled'
    $('#startTask').text 'You must use Google Chrome to do this task. Open this HIT in Google Chrome to do the task.'
    $('#startTask').attr 'href', 'http://www.google.com/chrome'
    $('#checkCodeButton').attr 'disabled', 'disabled'
    $('#hitcode').attr 'disabled', 'disabled'
    return
  $('#useragent').val(navigator.userAgent.toString())
  workerid = getWorkerId()
  if workerid != ''
    $('#startTask').text 'Start the task to get a code (will open a new window)'
    $('#startTask').attr 'href', '//pianotutor.herokuapp.com/mturk_index_' + root.taskname + '.html?workerId=' + encodeURI(workerid) + '&taskname=' + encodeURI(root.taskname)
    checkIfHITDoneCookies()
    acceptHIT()
  else # hit is being previewed
    previewHIT()

document.onreadystatechange = ->
  if document.readyState == 'complete'
    documentReady()

