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
cull = 0

if my_queue.count() > 120000:
	if my_queue.count() > 300000:
		cull=2
	elif my_queue.count() > 250000:
		cull=3
	elif my_queue.count() > 220000:
		cull=4
	elif my_queue.count() > 170000:
		cull=5
	elif my_queue.count() > 140000:
		cull=6
	else:
		cull=7

while True:
    	try:
		try:
			rs=my_queue.get_messages(num_messages=10,visibility_timeout=12000,wait_time_seconds=5)
			if (len(rs) == 0):
			        print args.echo + " len = 0 now empty"
				sys.exit(0)
			for msgcounter in range (len(rs)):
				m = rs[msgcounter-1]
				print m.get_body()
				if cull != 0:
					if (msgcounter > cull):
						my_queue.delete_message(m)
		except:
			if my_queue.count() < 1:
				print args.echo + " is now empty"
				sys.exit(0)
			time.sleep (3)
    	except KeyboardInterrupt:
		sys.exit(0)
