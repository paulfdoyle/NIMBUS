import sys
from sys import stdout
import time
import datetime
import boto.ec2
import argparse
import Queue

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
CANARY1 =  'i-ae93e6e1'
CANARY1str =  'Instance:i-ae93e6e1'
CANARY2 =  'i-9e13abd2'
CANARY2str =  'Instance:i-9e13abd2'
def stopall (res):
	print "Stopping any running Instances"
	for rescounter in range (len(res)):
		try:
			res[rescounter-1].stop_all()
		except:
			print "Error trying to stop instances"
	return

def startcanary (connection,canarytype):
	if canarytype == 't1.micro':
		CANARY=CANARY1
		try:
			print "starting the small canary instances now "
			instance = connection.get_all_instances(instance_ids=[CANARY])
			instance[0].instances[0].start()
		except:
			print "failed to start the micro canary"
	else:
		CANARY=CANARY2
		try:
			print "starting the large canary instances now "
			instance = connection.get_all_instances(instance_ids=[CANARY])
			instance[0].instances[0].start()
		except:
			print "failed to start the large canary"

	return

def startworkers ( connection, count, insttype):

	queue = Queue.Queue(0)
        if insttype == 't1.micro':
                CANARY=CANARY1str
	else:
		CANARY=CANARY2str

	res = connection.get_all_instances()
	for rescounter in range (len(res)):
        	try:
                	instances = res[rescounter-1].instances
			for instnum in range (len(instances)):
                       	 	instance_ids=instances[instnum-1]
                        	if (str(instance_ids.instance_type) == insttype):
					print str(instance_ids) + CANARY
                                	if str(instance_ids) <> CANARY:
						queue.put(instance_ids)
					else:
						print "This is the canary", instance_ids
					
        	except:
                	print "Error trying to find instances"

	print "count", count, queue.qsize()
	newinstrequired = count-queue.qsize()
	print "New insts requried = ",newinstrequired	
	if newinstrequired > 0:
		newres=connection.run_instances('ami-5636d121',min_count=newinstrequired, max_count=newinstrequired,key_name='nimbus-eu', instance_type=insttype, security_groups=['nimbus-security'])
		for counter in range (len(newres.instances)):
			timeout = 0
			mystr = ""
			print "lenght = ",len(newres.instances)
        		while (not newres.instances[counter-1].update() == 'running') and (timeout < 10):
               		 	mystr = mystr+ "."
               		 	stdout.write("\r%s" % mystr)
               		 	stdout.flush()
               		 	timeout = timeout+1
               		 	time.sleep(5)
	else:
		newinstrequired = 0
	

	print "Number of instances starting = ",count-newinstrequired
	for instcounter in range (count-newinstrequired):
       	 	try:
			myinst=queue.get()
			myinst.start()
			print myinst.update()
		except:
			print "Cannot start waiting and retyring"
			time.sleep (10)
			myinst.start()

	if (count-newinstrequired) > 0:
		# This assumes there is at least 1 instance in the queue....
        	timeout = 0	
		mystr = ""
        	while (not myinst.update() == 'running') and (timeout < 10):
            		mystr = mystr+ "."
               		stdout.write("\r%s" % mystr)
               		stdout.flush()
               		timeout = timeout+1
               		time.sleep(5)

	return

def runtimer ( mytimer ):
	print "\n Instances now running starting timer"
	
	start_time = time.time()
	while (time.time() - start_time) < mytimer:
	        stdout.write("\r%d    " % (mytimer - (time.time() - start_time)))
	        stdout.flush()
	        time.sleep(1)

	print "Timer stopped." 

	return


def stopfinal (connection):
	reservations = connection.get_all_reservations()
	print "Shutting down all instances"
	for rescounter in range (len(reservations)):
		try:
			reservations[rescounter-1].stop_all()
		except:
			print "Error trying to stop instances"
	return

print "Instances requested: " , BATCHSIZE
print "Time to run experiments in seconds = : " , EXPTIME
print "Instance Type = : " , INSTTYPE

# Set up the connection to the SQS queue	
conn = boto.ec2.connect_to_region(REGIONID,aws_access_key_id=ACCESSKEYID,aws_secret_access_key=SECRETKEYID)
try:
	reservations = conn.get_all_reservations()
except:
	print "Count not get all reservations"

#stopall (reservations)
startcanary(conn, INSTTYPE)
startworkers(conn, BATCHSIZE-1,INSTTYPE)
runtimer(EXPTIME)
stopfinal (conn)
