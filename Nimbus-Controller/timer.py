import sys
from sys import stdout
import time
import datetime
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("timer",type=int)
args = parser.parse_args()
EXPTIME = args.timer
print "time to run experiments in seconds = : " , EXPTIME

mystr = ""

start_time = time.time()
while (time.time() - start_time) < EXPTIME:
	stdout.write("\r%d    " % (EXPTIME - (time.time() - start_time)))		
	stdout.flush()
    	time.sleep(1)

print "Timer stopped."
