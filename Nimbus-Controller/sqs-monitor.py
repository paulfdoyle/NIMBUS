# This script returns the message count of a specific queue
#
# Author - Paul Doyle Aug 2013
#
#
import boto.sqs
import boto.sqs.queue
import argparse
import datetime
import sys
import time
from sys import stdout
from time import sleep
from boto.sqs.message import Message


parser = argparse.ArgumentParser()
parser.add_argument("echo")
parser.add_argument("exptime",type=int)
args = parser.parse_args()
print "Connecting to queue..."
conn = boto.sqs.connect_to_region("us-east-1", aws_access_key_id='AKIAINWVSI3MIXIB5N3Q', aws_secret_access_key='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')
sqs_queue = conn.get_queue(args.echo)

# Start the experimental timer
exptimerstart=time.time()

timer_running=False
msgcountstarting =  sqs_queue.count()
stdout.write("Messages to process %d\n" % msgcountstarting)
stdout.flush()


while (time.time() - exptimerstart) < args.exptime:
	try:
		msgcount =  sqs_queue.count()
		# Start the timer when processing starts
		if msgcount < msgcountstarting:
			if timer_running:
				timer=time.time() - start_time
				rate=(msgcountstarting-msgcount)/timer
				#stdout.write("\rMessages to process %d" % msgcount + " Timer in Seconds = %d " % timer + "Files per second = %f " % rate )
				#print "START TIME,", start_time, ",TIME,",time.time(),", QueueSIZE, ", msgcount , ",Timer," ,timer , "Files per second = ,", rate 
				print "START TIME,", start_time_formatted, ",TIME,"+datetime.datetime.now().strftime("%Y-%m-%d,%H:%M:%S")+", QueueSIZE, ", msgcount , ",Elapsed Time," ,timer , ",Files per second,", rate 
				stdout.flush()
			else:
				start_time = time.time()
				start_time_formatted = datetime.datetime.now().strftime("%Y-%m-%d, %H:%M:%S")
				timer_running = True

		else:
			start_time = time.time()
			start_time_formatted = datetime.datetime.now().strftime("%Y-%m-%d, %H:%M:%S")
			msgcountstarting = msgcount # This allows the monitor to start earlier and catch up on a queue that is growing
		sleep(1)

		if msgcount == 0:
			stdout.write("\n")
                	print ("Msg Queue empty sleeping for 10 seconds")
			if timer_running:
				print time.time() - start_time, "seconds elapsed"
                	time.sleep(10)
			
	except KeyboardInterrupt:
		stdout.write("\n")
		print ("Exiting")
		print time.time() - start_time, "seconds elapsed"
		sys.exit(0)

print "Finished Monitoring WorkerQ"
