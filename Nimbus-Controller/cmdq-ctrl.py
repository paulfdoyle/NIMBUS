# This script adds a new message to a specific SQS queue
#
# Author - Paul Doyle Aug 2013
#
#
import sys
import boto.sqs
import argparse
from boto.sqs.connection import SQSConnection
from boto.exception import SQSError
from boto.sqs.message import Message

parser = argparse.ArgumentParser()
#parser.add_argument('queuearg',help='name of the sqs queue to use')
parser.add_argument("echo")
parser.add_argument('workercommand',help='Instruction for all Workers to read')
args = parser.parse_args()
# AWS IDs to use to connect to the SQS Queue
ACCESSKEYID = 'AKIAINWVSI3MIXIB5N3Q'
SECRETKEYID = 'p5YZH9h2x6Ua+5D2qC+p4HFUHQZRVo94J9zrOE+c'
REGIONID = "us-east-1"
m = Message()

# Set up the connection to the SQS queue	
conn = boto.sqs.connect_to_region(REGIONID,aws_access_key_id=ACCESSKEYID,aws_secret_access_key=SECRETKEYID)

try:
        q=conn.create_queue(args.echo)
except:
        print "Could not create queue. possible too soon since deletion, wait 60 seconds"
	sys.exit()

sqs_queue = conn.get_queue(args.echo)

print "Flushing command queue..."

# flush the command msg queue

for i in range (100):

	# Here we try to clear all 10 messages from the superqueue
	try:
		msg= sqs_queue.read(60)
	except:
		pass
	try: 
		sqs_queue.delete_message(msg)
	except:
		pass

#
# Push Messages on the command msg queue
#
print "Setting command message to ", args.workercommand
m.set_body(args.workercommand)
for i in range (100):
	sqs_queue.write(m)
