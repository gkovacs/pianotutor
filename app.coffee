express = require 'express'
http = require 'http'

app = express()
server = http.createServer(app)

app.use(express.static(__dirname + '/'))
app.use(express.json())

vartable = {}

app.get '/varTable', (req, res) ->
  varname = req.query['varname']
  if !varname?
    res.send(JSON.stringify(vartable))
    return
  if req.query['set']?
    vartable[varname] = req.query['set']
  res.send(vartable[varname])

app.post '/postlog', (req, res) ->
  data = req.body
  console.log data

port = Number(process.env.PORT || 5000)
server.listen(port)
console.log("Server running on port #{server.address().port}")

