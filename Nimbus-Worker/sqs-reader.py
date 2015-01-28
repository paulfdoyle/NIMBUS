import boto.sqs
import argparse
import urllib
import os
import sys
import signal 
import time
import datetime
import socket
import fcntl
import struct
from boto.sqs.message import Message
from subprocess import call
import boto.s3.connection
from boto.s3.connection import S3Connection
from boto.s3.connection import Location
from boto.s3.key import Key
import os

current_folder_path, current_folder_name = os.path.split(os.getcwd())
str2=current_folder_path.split('/')
workername=str2[2]

filesprocessed = 0
ipadd=""
VERSIONNUM="Version 4.0.14"
timer_running=False
start_time = time.time()
listenforcmd = False

# AWS IDs to use to connect to the SQS Queue
ACCESSKEYID = 'AKIAINWVSI3MIXIB5N3Q'
SECRETKEYID = 'p5YZH9h2x6Ua+5D2qC+p4HFUHQZRVo94J9zrOE+c'
REGIONID = "us-east-1"

conn = S3Connection('AKIAINWVSI3MIXIB5N3Q', 'p5YZH9h2x6Ua+5D2qC+p4HFUHQZRVo94J9zrOE+c')
bucket=conn.get_bucket('nimbus-results1')
k = Key(bucket)



def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])


# Function that removes all files from a directory
def cleanDirectory ( str ):
	#print "clearing out ", str
	dirPath = str
	fileList = os.listdir(dirPath)
	for fileName in fileList:
 		os.remove(dirPath+"/"+fileName)
	return


# Function to print messages to the logile/queue
def sqsprint ( msg , printout):

	global ipadd
	global logfile_queue
	if printout:
		print msg
        m = Message()
	msg = workername + "," + ipadd + ", TIMESTAMP," + datetime.datetime.now().strftime("%Y-%m-%d,%H:%M:%S") + ",MSG,"+msg
        m.set_body(msg)
        try:
		logfile_queue.write(m)
	except:
		print ("failed to write to logfile queue")

# Function that removes all files from a directory
def deleteMsgs ( sqsQueue, msgList, resQueue):
        for msgscount in range (len(msgList)):
                msg = msgList.pop()
                msgstr = str(msg.get_body())
                filename = msgstr.split('/') [-1]
                resultfilename = ipadd +","+filename[:-1] + ".result"
                outputfilename = filename[:-3] + "result"
		k.key = resultfilename
		k.set_contents_from_filename('./Results/'+outputfilename)
	        m = Message()
       		resultmsg =  workername + "," + ipadd + ", TIMESTAMP," + datetime.datetime.now().strftime("%Y-%m-%d,%H:%M:%S") + ",MSG,"+resultfilename
        	m.set_body(resultmsg)
        	try:
                	resQueue.write(m)
        	except:
                	print ("failed to write to Results queue")
                
		sqsprint ("Result Filename = " + resultfilename,True)   
                sqsQueue.delete_message(msg)
        return

#    	for msgscount in range (len(msgList)):
#    		sqsQueue.delete_message(msgList.pop())
#	return

# Function that downloads a file take from the SQS message
def downloadMsgs ( sqsQueue, msgList, numfiles ):
	global filesprocessed,timer_running, start_time
	for batchnum in range (0,numfiles):
		msg = sqsQueue.read(600)
    		if msg <> None:
        		msgstr = str(msg.get_body())
       	 		msgList.append(msg)
       	 		newfilename = msgstr.split('/') [-1]
       	 		filesource = msgstr.split('/') [2]
			fname = newfilename[:-1]
			filesprocessed = filesprocessed+1
			#sys.stdout.write("\r files processed  %d%%%   " + fname)  
			#sys.stdout.write("\rFiles processed  %s   " %  filesprocessed)  
			#sys.stdout.write("\nFiles processed  %s   " %  filesprocessed)  
			#sys.stdout.flush()
        		downloadfile = "./Datafiles/"+ newfilename[:-1]
        		timea=(time.time())
			urllib.urlretrieve(msg.get_body(), filename=downloadfile)
        		timeb=(time.time())
			downloadtime = timeb -timea 
			sqsprint("Files processed, " + filesource + "," +newfilename[:-1] + ", download time," + str(downloadtime),False)  
    		else:
        		sqsprint ("Queue empty so sleeping for 10 seconds",True)
        		time.sleep(10)
       	return msgList

def registerWorker( msg, myqueue ):
	m = Message()
	m.set_body(msg)
	try:
		myqueue.write(m)
	except:
		sqsprint ("failed to write to register queue")

def checkSupervisor( supervisor_queue, register_queue , ipadd):

	global listenforcmd 

	try:
		supervisor_m = supervisor_queue.read(1)
		supervisorstr = str(supervisor_m.get_body())
	except:
		#sqsprint ("could not read supervisor Queue.",True)
		supervisorstr = "WORK"

	if supervisorstr == "REGISTER" and listenforcmd == True:
		# We only want to write once in case we read the msg many times
                sqsprint("REGISTER Worker",True)
		listenforcmd = False
                registerWorker (workername + "," + ipadd + ", TIMESTAMP," + datetime.datetime.now().strftime("%Y-%m-%d,%H:%M:%S") , register_queue)
	if supervisorstr == "REBOOT" and listenforcmd == True:
		listenforcmd = False
                sqsprint("REBOOT",True)
		time.sleep(3)
                call(['reboot'])
	if supervisorstr == "LISTEN":
		if listenforcmd == False:
			sqsprint ("LISTEN",True)
		listenforcmd = True
	if supervisorstr == "UPGRADE" and listenforcmd == True:
		listenforcmd = False
               	sqsprint("UPGRADE",True)
		upgradeurl= "http://webnode1.dit.ie/worker/upgradeworker.sh"
               	urllib.urlretrieve(upgradeurl, "/home/ubuntu/upgrade.sh")
		call(['chmod','0755','/home/ubuntu/upgrade.sh'])
		call(['sudo','/home/ubuntu/upgrade.sh'])


# Set up the connection to the SQS queue	
parser = argparse.ArgumentParser()
parser.add_argument("qname")
parser.add_argument("commandqname")
parser.add_argument("batch",type=int)
args = parser.parse_args()
conn = boto.sqs.connect_to_region(REGIONID,aws_access_key_id=ACCESSKEYID,aws_secret_access_key=SECRETKEYID)



try:
	my_queue = conn.get_queue(args.qname)
	command_queue = conn.get_queue(args.commandqname)
	supervisor_queue = conn.get_queue("supervisor")
	register_queue = conn.get_queue("workerregister")
	logfile_queue = conn.get_queue("logfile")
	results_queue = conn.get_queue("resultq")
except:
	print "Failure to access a queue"
	sqsprint ("Failure to access a queue",False)

#ipadd=socket.gethostname()+","+str(get_ip_address('eth0'))
ipadd=socket.gethostname()
sqsprint ("Now Running "+VERSIONNUM,False)
BATCHSIZE = args.batch
m = Message()
simpleList = []
stopcheck = 1
startcheck = 1
registerWorker (workername + "," + ipadd + ", TIMESTAMP," + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") , register_queue)

while True:

    try:
	# Check the supervisor queue for instructions
	checkSupervisor(supervisor_queue, register_queue, ipadd)
	
	try:
		cmd_m = command_queue.read(1)
		cmdstr = str(cmd_m.get_body())
	except:
		#sqsprint ("could not read cmd queue",True)
		cmdstr = "NOQUEUE"
	
	if cmdstr == "START":
		stopcheck=1
		if startcheck == 1:
			sqsprint ("CmdQ START Time ON\n",True)
			startcheck=0
			start_time = time.time()
                        timer_running = True
			filecounter = 0

		cleanDirectory ("./Datafiles")
		#batchnum=0
    		downloadMsgs(my_queue, simpleList, BATCHSIZE)
		if len(simpleList) >0:
			return_code = call(['./scripts/do_work'])
			filecounter = filecounter + len(simpleList) # Get number of files processed
			rate = filecounter/(time.time() - start_time)
			sqsprint("Files Processed, " + str(filecounter) + ", Processing Rate = ,"+str(rate),True)
		else:
			sqsprint ("No files to process so sleeping for 60 seconds",True)
			time.sleep(60)
	
		if return_code > 0:
    			sqsprint ("message not deleted return code is = " + str(return_code),True)
		else:
    			deleteMsgs (my_queue, simpleList,results_queue)
	
		cleanDirectory ("./Datafiles")
	elif cmdstr == "QUIT":
		print "CmdQ QUIT"
		sys.exit(0)
	elif cmdstr == "SLEEP":
		startcheck=1
		sqsprint ("CmdQ SLEEP 60 seconds",True)
		time.sleep(60)
	elif cmdstr == "STOP":
		startcheck=1
		if stopcheck == 1:
			sqsprint("CMQ STOP Timer OFF",True)
			stopcheck = 0
			timer_running = False
		time.sleep(1)
	else:
		startcheck=1
		print "CmdQ string = ", cmdstr
    except KeyboardInterrupt:
	cleanDirectory ("./Datafiles")
	sqsprint("Exiting with Ctrl C",True)
	sys.exit(0)
