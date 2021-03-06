express = require 'express'
http = require 'http'

app = express()
server = http.createServer(app)

app.use(express.static(__dirname + '/'))
app.use(express.json())
app.set('view engine', 'ejs')

vartable = {}

app.get '/varTable', (req, res) ->
  varname = req.query['varname']
  if !varname?
    res.send(JSON.stringify(vartable))
    return
  if req.query['set']?
    vartable[varname] = req.query['set']
  res.send(vartable[varname])

logs = {}

app.get '/', (req, res) ->
  res.redirect('/skilltree.html')

app.get '/practice', (req, res) ->
  songname = req.query.songname
  if not songname?
    res.send 'need songname'
    return
  res.render('practice', {songname: songname})

app.get '/listusers', (req, res) ->
  res.json Object.keys(logs)

app.get '/getlogs', (req, res) ->
  user = req.query.user
  if not user?
    res.send logs
    return
  res.json logs[user]

workerid_to_taskname = {}

app.get '/getWorkerIdToTasknames', (req, res) ->
  res.json workerid_to_taskname

app.get '/releaseWorker', (req, res) ->
  workerid = req.query.workerid
  if workerid_to_taskname[workerid]?
    delete workerid_to_taskname[workerid]
  res.send ''

app.get '/taskAcceptedByWorker.js', (req, res) ->
  workerid = req.query.workerid
  taskname = req.query.taskname
  if not workerid? or workerid == ''
    res.jsonp ''
    return
  if not workerid_to_taskname[workerid]
    workerid_to_taskname[workerid] = taskname
  res.jsonp workerid_to_taskname[workerid]

app.get '/getTaskNamePreviouslyAcceptedByWorker.js', (req, res) ->
  workerid = req.query.workerid
  taskname = ''
  if workerid? and workerid_to_taskname[workerid]?
    taskname = workerid_to_taskname[workerid]
  res.jsonp taskname

app.post '/postlog', (req, res) ->
  data = req.body
  console.log data
  if not data.user?
    return
  user = data.user
  if not logs[user]?
    logs[user] = []
  logs[user].push data

port = Number(process.env.PORT || 8080)
server.listen(port)
console.log("Server running on port #{server.address().port}")

