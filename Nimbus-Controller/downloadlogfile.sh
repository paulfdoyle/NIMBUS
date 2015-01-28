#!/bin/bash
#
# Author:       Paul Doyle
# Date:         Oct 2013
#
# NAME
#       downloadlogfile
#
#
# SYNOPSIS
#       downloadlogfile <experiment> <date-time><sqsqueue>
#
# DESCRIPTION:  
#	The purpose of this script is to download logfile entries which are sitting in an Amazon SQS queue using a
#	multithreaded python script.
#	
#	The directory for storing the experiments is required which are also data stamped
# OPTIONS
# 
usage(){
        echo ""
        echo "downloadlogfile: download logfile entries which are sitting in an Amazon SQS queue"
        echo ""
        echo "Usage: `basename $0` <experiment> <date-time> <queuename>"
        echo ""
        echo " Options:"
        echo "        h - provides help messages"
        echo "        v - script version"
        echo "        m - generate metrics"
        echo "        n - do not generate metrics"

        echo " Parameters"
        echo "        experiment: name of the experiment so it can be recongised later"
        echo "        date-time: this is used to seperate different experimental runs"
        echo "        queuename: this is the name of the queue which needs to be downloaded"
        echo ""
}

COMMAND=0
while getopts hvmn OPT; do
        case "$OPT" in
                h) #  Help
                        usage
                        exit 0
                        ;;
                v) #  Show Version
                        echo "`basename $0` version 0.1"
                        exit 0
			;;

                m) #  calcmetrisc
                        COMMAND=1;;
                \?)
                        usage
                        exit 1
                        ;;
        esac
done

shift `expr $OPTIND - 1`

if [ $# -eq 3 ]; then
        EXPNAME=$1
        EXPTIME=$2
        QUENAME=$3
else
        usage
        echo "Invalid number of parameters"
        exit 1
fi

mkdir -p /home/ubuntu/nimbus-client/ExperimentalResults/$EXPNAME/$EXPTIME
cd /home/ubuntu/nimbus-client/ExperimentalResults/$EXPNAME/$EXPTIME
python ../../../sqs-fastreader.py $QUENAME $EXPNAME
if [ $COMMAND -eq 1 ]; then
	echo "calculating metrics"
	../../../metrics.sh > Metrics-$QUENAME-$EXPNAME.output
fi
