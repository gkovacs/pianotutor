root = exports ? this

#process = require 'process'

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

main = ->
  console.log process.argv[2]
  console.log toHitCode process.argv[2]

main() if require.main is module