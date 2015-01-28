# This script deletes all messages in a queue
#
# Author - Paul Doyle Sept 2013
#
#
import sys
import Queue
import boto.sqs
import argparse
import socket

datasource = '/data/compressed/'

parser = argparse.ArgumentParser()
parser.add_argument('queuearg',help='name of the sqs queue to use',metavar="myQueueName")
args = parser.parse_args()

from boto.sqs.message import Message
import threading

try:
	conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')
except:
	print "issue within conn"

try:
	sqs_queue = conn.get_queue(args.queuearg)
except:
	print "issue with queue"


class Sender(threading.Thread):
	def __init__(self):
		threading.Thread.__init__(self)

	def run(self):
		global sqs_queue,queue
		print "Thread active"
		while True:
                	try:
				m = Message()
                       		m = sqs_queue.read(60)
                       		sqs_queue.delete_message(m)
				print "deleted :",m
                	except:
                       		print "Logfile empty"
                		sys.exit(0)

			
threads = []
for n in xrange(40):
	t = Sender()
	t.start()
	threads.append(t)

for t in threads:
	t.join()

