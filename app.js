// Generated by CoffeeScript 1.6.3
var app, express, http, logs, port, server, vartable, workerid_to_taskname;

express = require('express');

http = require('http');

app = express();

server = http.createServer(app);

app.use(express["static"](__dirname + '/'));

app.use(express.json());

vartable = {};

app.get('/varTable', function(req, res) {
  var varname;
  varname = req.query['varname'];
  if (varname == null) {
    res.send(JSON.stringify(vartable));
    return;
  }
  if (req.query['set'] != null) {
    vartable[varname] = req.query['set'];
  }
  return res.send(vartable[varname]);
});

logs = [];

app.get('/getlogs', function(req, res) {
  var user;
  user = req.query.user;
  if (user == null) {
    res.send('need user parameter');
    return;
  }
  return res.send(logs[user]);
});

workerid_to_taskname = {};

app.get('/getWorkerIdToTasknames', function(req, res) {
  return res.json(workerid_to_taskname);
});

app.get('/releaseWorker', function(req, res) {
  var workerid;
  workerid = req.query.workerid;
  if (workerid_to_taskname[workerid] != null) {
    return delete workerid_to_taskname[workerid];
  }
});

app.get('/taskAcceptedByWorker.js', function(req, res) {
  var taskname, workerid;
  workerid = req.query.workerid;
  taskname = req.query.taskname;
  if ((workerid == null) || workerid === '') {
    res.jsonp('');
    return;
  }
  if (!workerid_to_taskname[workerid]) {
    workerid_to_taskname[workerid] = taskname;
  }
  return res.jsonp(workerid_to_taskname[workerid]);
});

app.get('/getTaskNamePreviouslyAcceptedByWorker.js', function(req, res) {
  var taskname, workerid;
  workerid = req.query.workerid;
  taskname = '';
  if ((workerid != null) && (workerid_to_taskname[workerid] != null)) {
    taskname = workerid_to_taskname[workerid];
  }
  return res.jsonp(taskname);
});

app.post('/postlog', function(req, res) {
  var data, user;
  data = req.body;
  console.log(data);
  if (data.user == null) {
    return;
  }
  user = data.user;
  if (logs[user] == null) {
    logs[user] = [];
  }
  return logs[user].push(data);
});

port = Number(process.env.PORT || 8080);

server.listen(port);

console.log("Server running on port " + (server.address().port));
