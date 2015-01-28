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
parser.add_argument("insttype")
args = parser.parse_args()
INSTTYPE = args.insttype


# Set up the connection to the SQS queue	
conn = boto.ec2.connect_to_region(REGIONID,aws_access_key_id=ACCESSKEYID,aws_secret_access_key=SECRETKEYID)

if INSTTYPE == 't1.micro':
	try:
		print "rebooting the small canary instances now "
		instance = conn.get_all_instances(instance_ids=['i-ae93e6e1'])
		instance[0].instances[0].reboot()
	except:
		print "failed to reboot the micro canary"
else:
	try:
		print "rebooting the large canary instances now "
		instance = conn.get_all_instances(instance_ids=['i-9e13abd2'])
		instance[0].instances[0].start()
	except:
		print "failed to start the large canary"
