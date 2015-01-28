#!/bin/bash
#
# Author: 	Paul Doyle
# Date:		Sept 2013
#
# NAME
#	resetqueue delete and recreate a queue to ensure everything is empty
#
#
# SYNOPSIS
#	resetqueue <sqsqueuname>
#
# DESCRIPTION:	
#
# OPTIONS
# 

COMMAND=0
usage(){
	echo ""
	echo "resetqueue - control the sqs queues"
	echo ""
	echo "Usage: `basename $0` [-hvdxwcnl] [SQS-QUEUE-NAME] [sourcedir] [IP Address] "
	echo ""
	echo " OPTIONS"
	echo "        h - provides help messages"
	echo "        v - script version"
	echo "        d - delete the queue"
	echo "        x - dump the contents of the queue to a text file"
	echo "        w - write messages to the queue using files in sourcedir"
	echo "        c - create a queue using SQS-QUEUE-NAME"
	echo "        n - show the number of elements in a queue"
	echo "        l - list avaialble queues"
	echo "SQS-QUEUE-NAME"
	echo "        the name of the sqs queue to operate on (not use with -l option)."
	echo ""
	echo "sourcedir"
	echo "        default source directories can be over overridden for option '-w'"
	echo ""
	echo "IP Address"
	echo "        IP Address can be over overridden for option '-w' but include a sourcedir"
	echo ""
}

	QUEUENAME=$1
	python sqs-delete.py $QUEUENAME
	echo "Waiting 60 seconds so queue can be recreated"
	sleep 60
	python sqs-create.py $QUEUENAME
	python cmdq-ctrl.py $QUEUENAME $2
