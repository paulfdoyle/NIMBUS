import sys
from sys import stdout
import time
import datetime
import boto.ec2
import argparse

# AWS IDs to use to connect to the SQS Queue
ACCESSKEYID = 'AKIAINWVSI3MIXIB5N3Q'
SECRETKEYID = 'p5YZH9h2x6Ua+5D2qC+p4HFUHQZRVo94J9zrOE+c'
REGIONID = "eu-west-1"

parser = argparse.ArgumentParser()
parser.add_argument("batch",type=int)
parser.add_argument("timer",type=int)
parser.add_argument("insttype")
args = parser.parse_args()
BATCHSIZE = args.batch
EXPTIME = args.timer
INSTTYPE = args.insttype
print "starting the instances now: " , BATCHSIZE
print "time to run experiments in seconds = : " , EXPTIME
# Set up the connection to the SQS queue	
conn = boto.ec2.connect_to_region(REGIONID,aws_access_key_id=ACCESSKEYID,aws_secret_access_key=SECRETKEYID)
res=conn.run_instances('ami-5636d121',min_count=BATCHSIZE, max_count=BATCHSIZE,key_name='nimbus-eu', instance_type=INSTTYPE, security_groups=['nimbus-security'])
print "Number of instances Starting = ",len(res.instances)

mystr = ""


for counter in range (len(res.instances)):
	timeout = 0
	while (not res.instances[counter-1].update() == 'running') and (timeout < 10):
		mystr = mystr+ "."
    		stdout.write("\r%s" % mystr)
		stdout.flush()
    		timeout = timeout+1
		time.sleep(5)

print "\n Instances now running starting timer"

start_time = time.time()
while (time.time() - start_time) < EXPTIME:
	stdout.write("\r%d    " % (EXPTIME - (time.time() - start_time)))		
	stdout.flush()
    	time.sleep(1)

print "Timer stopped. Shutting down the EC2 instances"
try:
	res.stop_all()
except:
	print "error trying to stop all instances. Trying again"
try:	
	res.stop_all()
except:
	print "Error trying to stop all instances second time."
	
print "All Instances stopped"
