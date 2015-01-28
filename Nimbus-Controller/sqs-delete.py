# This script deletes a queue
#
# Author - Paul Doyle Aug 2013
#
#
import boto.sqs
import boto.sqs.queue
import argparse
from boto.sqs.message import Message
from boto.sqs.connection import SQSConnection
parser = argparse.ArgumentParser()
parser.add_argument("echo")
args = parser.parse_args()
conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')
try:
	sqs_queue = conn.get_queue(args.echo)
except:
	print "Failed to find queue ", args.echo
try:
	conn.delete_queue(sqs_queue,True)
	print args.echo, " queue has been deleted"
except: 
	print "Could not delete queue or it does not exist"
