root = exports ? this

root.taskname = '${taskname}'
if root.taskname.indexOf('taskname') != -1
  root.taskname = 'foobarrr'

toHitCode = (taskname) ->
  output = 0
  for x in taskname
    output += x.charCodeAt(0)
  return output

root.validateForm = validateForm = ->
  expected_hitcode = toHitCode(root.taskname).toString()
  hitcode = document.getElementById('hitcode').value.trim()
  if hitcode != expected_hitcode
    alert 'the hitcode you input: "' + hitcode + '" is not correct'
    return false
  return true

documentReady = ->
  submitButton = document.getElementById('submitButton')
  submitButton.onclick = 'return validateForm()'

document.onreadystatechange = ->
  if document.readyState == 'complete'
    documentReady()

