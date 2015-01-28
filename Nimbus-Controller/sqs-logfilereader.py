import boto.sqs
import argparse
import sys
import signal
import time
from boto.sqs.message import Message
from subprocess import call

parser = argparse.ArgumentParser()
parser.add_argument("echo")
args = parser.parse_args()

conn = boto.sqs.connect_to_region("us-east-1",aws_access_key_id='AKIAINWVSI3MIXIB5N3Q',aws_secret_access_key=
'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')
my_queue = conn.get_queue(args.echo)
m = Message()

print "Reading Queue " + args.echo + " Messages read are deleted"

while True:
    	try:

		try:
			m = my_queue.read(60)
			print m.get_body()
			my_queue.delete_message(m)
		except:
			if my_queue.count() < 1:
				print args.echo + " is empty"
				sys.exit(0)
			time.sleep (5)
    	except KeyboardInterrupt:
		sys.exit(0)
