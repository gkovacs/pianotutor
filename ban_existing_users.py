import urllib2
import csv
for line in csv.DictReader(open('Batch_1413108_batch_results.csv')):
  workerid = line['WorkerId']
  taskname = line['Input.taskname']
  url = 'http://pianotutor.herokuapp.com/taskAcceptedByWorker.js?workerid=' + workerid + '&taskname=' + taskname
  response = urllib2.urlopen(url)
  print response.read()