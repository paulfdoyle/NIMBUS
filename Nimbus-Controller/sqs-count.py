# This script returns the message count of a specific queue
#
# Author - Paul Doyle Aug 2013
#
#
import boto.sqs
import boto.sqs.queue
import argparse
import sys
from boto.sqs.message import Message
parser = argparse.ArgumentParser()
parser.add_argument("echo")
args = parser.parse_args()
conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')
sqs_queue = conn.get_queue(args.echo)
#print "number of messages in the queue is -> ", sqs_queue.count()
sys.exit(sqs_queue.count())
