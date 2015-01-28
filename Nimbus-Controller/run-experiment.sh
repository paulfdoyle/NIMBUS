#!/bin/bash
#
# Author: 	Paul Doyle
# Date:		Oct 2013
#
# NAME
#	prepare-experiment which sets up all systems so they are ready to process data
#
#
# SYNOPSIS
#	prepare-experiment [-hvdnax ] <instances to run> <time to run experiment> <number of webnodes to use> <inst type>
#
# DESCRIPTION:	
#
# OPTIONS
# 
usage(){
        echo ""
        echo "prepare-experiment: Set up and run an experiment. You must specify the"
	echo "			  number of Ec2 instances to run and time for experiment to run for"
        echo ""
        echo "Usage: `basename $0` <number of Instances> <time in seconds> <expName> <num of webnodes> <inst type>"
        echo ""
        echo " Options:"
        echo "        h - provides help messages"
        echo "        v - script version"
        echo "        d - Use DIT webnodes"
        echo "        n - Use HEANT webnodes"
        echo "        a - Use Amazon webnodes"
        echo "        x - Use all of the webnodes"
        echo "        t - Use all of the webnodes write msg from single source"
        echo ""
        echo " Parameters"
        echo "        Number of Instances: This is the number of Ec2 instances to run"
        echo "        Time in seconds: This is the numebr of seconds for the experiment to run"
        echo "        ExpName: Name of the experiment for use in logfile monitoring"
        echo "        Number of Nodes: Number of webnodes to start up. value 1-2 or 6 for all nodes"
        echo "        Type of Instance: t1.micro m1.medium m1.large ibm326"
        echo ""
}

while getopts hvdnaftx OPT; do
        case "$OPT" in
                h) #  Help
                        usage
                        exit 0
                        ;;
                v) #  Show Version
                        echo "`basename $0` version 0.1"
                        exit 0
                        ;;
                d) #  use the DIT webservers
                        COMMAND=1;;
                n) #  use the heanet webservers
                        COMMAND=2;;
                a) #  use the amazon webservers
                        COMMAND=3;;
                x) #  use all webservers
                        COMMAND=4;;
                f) #  use all FTP
                        COMMAND=5;;
                t) #  test using all webserver but ensure even distribution of filenames
                        COMMAND=6;;
                \?)
                        usage
                        exit 1
                        ;;
        esac
done

shift `expr $OPTIND - 1`

if [ $# -eq 5 ]; then
	INSTNUM=$1
	EXPTIME=$2
	EXPNAME=$3
	NUMNODE=$4
	INSTTYPE=$5
else
	usage
	echo "Invalid number of parameters"
	exit 1
fi

echo " "
echo " "
echo " "
echo " "
echo " "
echo "Start Experiment " $3
echo " "
echo " "
echo " "

SMALLDIR="/var/www/nginx-default/data/compressed-small"
BIGDIR="/var/www/nginx-default/data/compressed"
FTPDIR="/ftpsite"
DATADIR=$BIGDIR
AWSUSER="ubuntu"
DITUSER="paul"
USER=""

if [ $INSTNUM -le 0 ]; then
        echo "No instances requested to run. We will just run a timer"
elif [ $INSTNUM -gt 2 ]; then
	DATADIR=$BIGDIR		
else
	DATADIR=$SMALLDIR
fi 

if [ $EXPTIME -le 10 ]; then
        echo "need to enter a time for experiment > 60"
        usage
        exit 1
fi 
if [ $NUMNODE -le 0 ]; then
        echo "need to enter > 0 nodes"
        usage
        exit 1
fi 

WEBNODE1=""
WEBNODE2=""
DITNODE1="webnode1.dit.ie"
DITNODE2="webnode2.dit.ie"
AWSNODE1="webnode3.nightsky.ie"
AWSNODE2="webnode4.nightsky.ie"
HEANODE1="webnode5.nightsky.ie"
HEANODE2="webnode6.nightsky.ie"
HEANODE3="ftp.heanet.ie/mirrors/phdtest/"
AWSNODE3="webnode7.nightsky.ie"
AWSNODE4="webnode8.nightsky.ie"

if [ $COMMAND -eq 1 ]; then
        if [ $NUMNODE -le 0 ]  ||  [ $NUMNODE -ge 3 ] ; then
		echo "Valid nodes are 1-2 for DIT webservers"
        	usage
        	exit 1
	else
		WEBNODE1=$DITNODE1
		USER=$DITUSER
		if [ $NUMNODE -eq 2 ]; then
			WEBNODE2=$DITNODE2
		fi
	fi
fi 
if [ $COMMAND -eq 2 ]; then
        if [ $NUMNODE -le 0 ] || [ $NUMNODE -ge 3 ] ; then
		echo "Valid nodes are 1-2 for HEANET webservers"
        	usage
        	exit 1
	else
		WEBNODE1=$HEANODE1
		USER=$DITUSER
		if [ $NUMNODE -eq 2 ]; then
			WEBNODE2=$HEANODE2
		fi

	fi
fi 
if [ $COMMAND -eq 3 ]; then
        if [ $NUMNODE -le 0 ] || [ $NUMNODE -ge 5 ] ; then
		echo "Valid nodes are 1-4 for AMAZON webservers"
        	usage
        	exit 1
	else
		WEBNODE1=$AWSNODE1
		USER=$AWSUSER
		if [ $NUMNODE -eq 2 ]; then
			WEBNODE2=$AWSNODE2
		fi
		if [ $NUMNODE -eq 3 ]; then
			WEBNODE2=$AWSNODE2
			WEBNODE3=$AWSNODE3
		fi
		if [ $NUMNODE -eq 4 ]; then
			WEBNODE2=$AWSNODE2
			WEBNODE3=$AWSNODE3
			WEBNODE4=$AWSNODE4
		fi

	fi
fi 

# Initialise timers and required variables
START=$(date +%s)
NOW=$(date +"%Y%m%d%H%M%S")

# Stop any instances running in the Ireland Region

echo "Step 1.1: terminating any running Ec2 Instances"
python Ec2-terminateallinstances
python Ec2-stopcanary.py t1.micro
python Ec2-stopcanary.py m1.large

echo "Step 2. Deleting all queues"
python sqs-delete.py workerq
python sqs-delete.py canaryq
python sqs-delete.py cmdq
python sqs-delete.py supervisor
python sqs-delete.py workerregister
python sqs-delete.py logfile
python sqs-delete.py resultq

echo "Step 3. Removing files from the bucket"
python s3-fastdelete.py 

echo "Step 4. Waiting 60 seconds so queue can be recreated"
sleep 60

python sqs-create.py cmdq 
python sqs-create.py supervisor 
python sqs-create.py workerregister 
python sqs-create.py logfile 
python sqs-create.py resultq 
python sqs-create.py workerq 
python sqs-create.py canaryq

echo "Writing START to cmdq"
python cmdq-ctrl.py cmdq START
echo "Writing WORK to supervisor"
python cmdq-ctrl.py supervisor WORK

echo "Populating the queues as required"
#
# We are using the DIT Servers
#
if [ $COMMAND -eq 1 ]; then
	SMALLDIR="/var/www/nginx-default/data/compressed-small"
	if [ $NUMNODE -eq 2 ] ; then 
		echo "Populating queue from " $WEBNODE2
		ssh $USER@$WEBNODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE2/data/compressed/ &
	fi
	echo "Populating queue from " $WEBNODE1
	ssh $USER@$WEBNODE1 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE1/data/compressed/
fi

#
# We are using the HEANET Servers
#
if [ $COMMAND -eq 2 ]; then
		if [ $NUMNODE -eq 2 ] ; then
			echo "Populating queue from " $WEBNODE2
			ssh $USER@$WEBNODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE2/data/compressed/ &
		fi
	echo "Populating queue from " $WEBNODE1
	echo "ssh " $USER $WEBNODE1 "/home/paul/nimbus-client/sqs-qm -w workerq " $DATADIR  $WEBNODE1
	ssh $USER@$WEBNODE1 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE1/data/compressed/
elif [ $COMMAND -eq 3 ]; then 

	if [ $NUMNODE -ge 2 ] ; then 
		echo "Populating queue from " $WEBNODE2
		echo "ssh " $USER $WEBNODE2 "/home/ubuntu/nimbus-client/sqs-qm -w workerq " $DATADIR  $WEBNODE2
		ssh -i ./keys/nimbuskey.pem $USER@$WEBNODE2 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE2/data/compressed/ &
	fi
	if [ $NUMNODE -ge 3 ] ; then 
		echo "Populating queue from " $WEBNODE3
		echo "ssh " $USER $WEBNODE3 "/home/ubuntu/nimbus-client/sqs-qm -w workerq " $DATADIR  $WEBNODE3
		ssh -i ./keys/nimbus-oregon.pem $USER@$WEBNODE3 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE3/data/compressed/ &
	fi
	if [ $NUMNODE -ge 4 ] ; then 
		echo "Populating queue from " $WEBNODE4
		echo "ssh " $USER $WEBNODE4 "/home/ubuntu/nimbus-client/sqs-qm -w workerq " $DATADIR  $WEBNODE4
		ssh -i ./keys/nimbus-oregon.pem $USER@$WEBNODE4 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE4/data/compressed/ &
	fi
	
	echo "Populating queue from " $WEBNODE1
	ssh -i ./keys/nimbuskey.pem $USER@$WEBNODE1 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $WEBNODE1/data/compressed/


elif [ $COMMAND -eq 4 ]; then 
	echo "Populating all 9 webnodes...this will take a while...."
	ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $FTPDIR  $HEANODE3  &
	ssh paul@$DITNODE1 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $DITNODE1/data/compressed/ &
	ssh paul@$DITNODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $DITNODE2/data/compressed/ &
	ssh paul@$HEANODE1 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE1/data/compressed/ &
	ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE2/data/compressed/ &
	ssh -i ./keys/nimbuskey.pem ubuntu@$AWSNODE1 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $AWSNODE1/data/compressed/ &
	ssh -i ./keys/nimbus-oregon.pem ubuntu@$AWSNODE3 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $AWSNODE3/data/compressed/ &
	ssh -i ./keys/nimbus-oregon.pem ubuntu@$AWSNODE4 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $AWSNODE4/data/compressed/ &
	ssh -i ./keys/nimbuskey.pem ubuntu@$AWSNODE2 /home/ubuntu/nimbus-client/sqs-qm -w workerq $DATADIR  $AWSNODE2/data/compressed/

elif [ $COMMAND -eq 5 ]; then 
	echo "Populating ftp webnodes...this will take a while...."
	DATADIR=$FTPDIR
	if [ $INSTNUM -ge 0 ]; then
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
	fi
	if [ $INSTNUM -ge  10 ]; then
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
	fi 
	if [ $INSTNUM -ge  20 ]; then
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
	fi 
	if [ $INSTNUM -ge  49 ]; then
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
		ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-qm -w workerq $DATADIR  $HEANODE3 
	fi 
elif [ $COMMAND -eq 6 ]; then 
	echo "Populating all 9 webnodes from one location take a while...."
	ssh paul@$HEANODE2 /home/paul/nimbus-client/sqs-loader 
fi

#read -p "When you have a queue fully populated and ready to work press any key to continue to start instances..."
echo  "Sleeping for about 4 minutes to let the sqs queue finish before we start any workers"
sleep 240
NOW=$(date +"%Y-%m-%d-%H:%M:%S")
MONITORINGFILE="$3-Monitor-Workerq.csv"
LOGFILE="$3-logfile.csv"
WORKERREGFILE="$3-WorkerReg.csv"
RESULTFILE="$3-ResultQ.csv"

EXPTIMEMON=$(( $EXPTIME + 150 ))

if [ ! -d ./ExperimentalResults/$3 ]; then
	mkdir ./ExperimentalResults/$3 
fi
mkdir ./ExperimentalResults/$3/$NOW
echo "Start monitoring the workerq for length of the experiment"

#ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie /home/ubuntu/nimbus-client/startmonitoring.sh $3 $NOW workerq $EXPTIMEMON &
ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185 /home/ubuntu/nimbus-client/startmonitoring.sh $3 $NOW workerq $EXPTIMEMON &
#python sqs-monitor.py workerq $EXPTIMEMON > ./ExperimentalResults/$3/$NOW/$MONITORINGFILE &

UTCDATE=$(date )
echo "Start time is " $UTCDATE 

if [[ $INSTTYPE == "ibm326" ]]; then
	read -p "start the IBM server manually and hit return"
elif [[ $INSTTYPE == "x4150" ]]; then
	read -p "start the x4150 server manually and hit return"
#elif [[ $INSTTYPE == "m3.2xlarge" ]]; then
#	read -p "start the m3.2xlarges servers in other regions manually and hit return"
else
	echo "AMI instances to start = " $1
  #	echo "Starting the canary"
	#
	# A canary instance runs with the rest of the experiment and is used to see how each of its clones also runs.
	# With the exception of the 1 instance test the canary is counted as part of the run.
	#
	#
  #	python Ec2-startcanary.py $INSTTYPE &
fi

#
#
#
# This creates and stops the instances after the set amount of time has concluded
#
# A canary instance runs with the rest of the experiment and is used to see how each of its clones also runs. 
# With the exception of the 1 instance test the canary is counted as part of the run. 
#
#
#if [ $INSTTYPE == "t1.micro" ]; then
#	python Ec2-startcanary.py t1.micro
#else
#	python Ec2-startcanary.py M1.large
#fi

if [ $INSTNUM -le 0 ]; then
	python timer.py $EXPTIME 
	# After the instances have finished, read the logfiles and write then out"
	echo "killing the monitor" 
	UTCDATE=$(date)
	echo "TIME ENDED: time is " $UTCDATE
#	ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie kill $(ps aux | grep '[p]ython sqs-monitor.py' | awk '{print $2}') > /dev/null 2>&1
	ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185  kill $(ps aux | grep '[p]ython sqs-monitor.py' | awk '{print $2}') > /dev/null 2>&1
	python cmdq-ctrl.py cmdq STOP
else
	python Ec2-createinstancefromAMI.py $INSTNUM $EXPTIME $INSTTYPE
	# After the instances have finished, read the logfiles and write then out"
	echo "killing the monitor" 
	UTCDATE=$(date)
	echo "TIME ENDED: time is " $UTCDATE
#	ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie kill $(ps aux | grep '[p]ython sqs-monitor.py' | awk '{print $2}') > /dev/null 2>&1
	ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185 kill $(ps aux | grep '[p]ython sqs-monitor.py' | awk '{print $2}') > /dev/null 2>&1
	python cmdq-ctrl.py cmdq STOP
	python Ec2-terminateallinstances
fi

#
#
#python Ec2-stopallinstances
#
#
#
#

echo "Reading logfiles from the queue"
#ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie /home/ubuntu/nimbus-client/downloadlogfile.sh $3 $NOW workerregister
#ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie /home/ubuntu/nimbus-client/downloadlogfile.sh $3 $NOW resultq &
#ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie /home/ubuntu/nimbus-client/downloadlogfile.sh $3 $NOW logfile &
ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185 /home/ubuntu/nimbus-client/downloadlogfile.sh $3 $NOW workerregister
ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185 /home/ubuntu/nimbus-client/downloadlogfile.sh $3 $NOW resultq &
ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185 /home/ubuntu/nimbus-client/downloadlogfile.sh $3 $NOW logfile &

#
#
# Check that the logfile is empty before removing it
#
python sqs-count.py logfile
status=$?
echo " checking logfile" 
while [ $status -gt 0 ]; 
    do
	python sqs-count.py logfile
    	status=$?
    	sleep 5
    done;
echo DONE

echo cleaning up processes which may still be running
echo "Running Metrics"
#ssh -i ./keys/nimbuskey.pem ubuntu@munin.nightsky.ie /home/ubuntu/nimbus-client/downloadlogfile.sh -m $3 $NOW supervisor &
ssh -i ./keys/nimbus-oregon.pem ubuntu@54.244.93.185  /home/ubuntu/nimbus-client/downloadlogfile.sh -m $3 $NOW supervisor &
UTCDATE=$(date)
echo "End time is " $UTCDATE
echo ""
echo ""
echo "---------------------"
