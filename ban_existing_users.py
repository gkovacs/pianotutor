import urllib2
import csv
for csvfile in ['run0_aborted_Batch_1413108_batch_results.csv', 'run1_14_Batch_1413932_batch_results.csv', 'run2_70_Batch_1414012_batch_results.csv', 'run3_14_Batch_1415736_batch_results.csv', 'run4_70_Batch_1416255_batch_results.csv']:
  for line in csv.DictReader(open(csvfile)):
    workerid = line['WorkerId']
    taskname = line['Input.taskname']
    url = 'http://pianotutor.herokuapp.com/taskAcceptedByWorker.js?workerid=' + workerid + '&taskname=' + taskname
    response = urllib2.urlopen(url)
    print response.read()