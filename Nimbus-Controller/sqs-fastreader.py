# This script adds a new message to a specific SQS queue
#
# Author - Paul Doyle Aug 2013
#
#
#from __future__ import print_function
import sys
import Queue
import boto.sqs
import argparse
import socket
import datetime
import sys
import time
from boto.sqs.attributes import Attributes

parser = argparse.ArgumentParser()
parser.add_argument('queuearg',help='name of the sqs queue to use',metavar="myQueueName")
parser.add_argument('experiment',help='name of the experiment queue to use')
args = parser.parse_args()

from boto.sqs.message import Message
import threading

conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')
sqs_queue = conn.get_queue(args.queuearg)

class Sender(threading.Thread):
	def __init__(self):
		threading.Thread.__init__(self)

	def run(self):
		global sqs_queue,queue
		name = args.experiment+str(queue.get())+"-"+args.queuearg+".csv"
		f = open(name,'w')
		
		while True:
			try:
				m = sqs_queue.get_messages(num_messages=1,attributes='SentTimestamp')
				f.write(str(m[0].attributes)+","+str(m[0].get_body())+"\n")
				sqs_queue.delete_message(m[0])
			except:
				if sqs_queue.count() < 1:
					f.write(args.queuearg + " is empty\n")
					return
queue = Queue.Queue(0)

threads = []
for n in xrange(40):
	queue.put(n)
	t = Sender()
	t.start()
	threads.append(t)

for t in threads:
	t.join()

