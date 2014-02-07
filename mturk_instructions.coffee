root = exports ? this

root.taskname = '${taskname}'
if root.taskname.indexOf('taskname') != -1
  root.taskname = 'foobarrr'

toHitCode = (taskname) ->
  output = 0
  for x in taskname
    output += x.charCodeAt(0)
  return output

root.validateform = validateform = ->
  alert document.getElementById('hitcode').value
  alert toHitCode(document.getElementById('hitcode').value)
  #if [x.charCodeAt(0) root.taskname
  alert 'form did not validate'
  return false

###
documentready = ->
  alert 'foo'

document.onreadystatechange = ->
  if document.readyState === 'complete'
    documentready()
###
