# This script created a queue
#
# Author - Paul Doyle Aug 2013
#
#
import boto.sqs
import boto.sqs.queue
import argparse
from boto.sqs.message import Message
from boto.sqs.connection import SQSConnection
from boto.exception import SQSError

parser = argparse.ArgumentParser()
parser.add_argument("echo")
parser.add_argument('-c', action='store',nargs=1,type=int,dest='sqstimeout',help='set message timetout')
args = parser.parse_args()
conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')

if args.sqstimeout is None:
	msgtimeout = 120
else:
	msgtimeout = args.sqstimeout

try:
	q=conn.create_queue(args.echo)
	print args.echo, " queue has been created or already exists"
except:
	print "Could not create queue. possible too soon since deletion, wait 60 seconds"

