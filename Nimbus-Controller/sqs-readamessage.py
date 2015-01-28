import boto.sqs
import argparse
from boto.sqs.attributes import Attributes
from boto.sqs.message import Message
from subprocess import call

parser = argparse.ArgumentParser()
parser.add_argument("echo")
args = parser.parse_args()

conn = boto.sqs.connect_to_region("us-east-1",aws_access_key_id='AKIAINWVSI3MIXIB5N3Q',aws_secret_access_key=
'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')
my_queue = conn.get_queue(args.echo)

m = Message()
m = my_queue.read(60)
m = my_queue.get_messages(num_messages=1,attributes='SentTimestamp')
counter = my_queue.count()
print counter
print "This is the message->",m[0].attributes,m[0].get_body()
