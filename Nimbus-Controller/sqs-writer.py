# This script adds a new message to a specific SQS queue
#
# Author - Paul Doyle Aug 2013
#
#
import sys
import Queue
import boto.sqs
import argparse
import socket
import time
import datetime

datasource = '/data/compressed/'


parser = argparse.ArgumentParser()
parser.add_argument('queuearg',help='name of the sqs queue to use',metavar="myQueueName")
parser.add_argument('-i','--ipaddr', action='store',nargs=1,dest='ipAddr',help='Insert ip address')
args = parser.parse_args()

if args.ipAddr is None:
        ipadd='http://' + socket.gethostbyname(socket.gethostname()) + datasource
else:
        ipadd="".join(args.ipAddr)
        ipadd='http://' + ipadd 
#+ datasource

from boto.sqs.message import Message
import threading

conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')
sqs_queue = conn.get_queue(args.queuearg)
canary_queue = conn.get_queue("canaryq")

class Sender(threading.Thread):
	def __init__(self):
		threading.Thread.__init__(self)

	def run(self):
		global sqs_queue,canary_queue,queue
		while True:
			try: 
				msg = queue.get(True,3)
				m = Message()
				m.set_body(msg)
				status = sqs_queue.write(m)
			#	msg = "TIMESTAMP," + datetime.datetime.now().strftime("%Y-%m-%d,%H:%M:%S")+"," + msg
		#		m.set_body(msg)
		#		status = canary_queue.write(m)
			except Queue.Empty:
				return
			except:
				return
			


queue = Queue.Queue(0)

for file in sys.stdin:
	file = ipadd+file
	queue.put(file)

threads = []
for n in xrange(40):
	t = Sender()
	t.start()
	threads.append(t)

for t in threads:
	t.join()

