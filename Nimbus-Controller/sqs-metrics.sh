#!/bin/bash


# This generates a pair of values - epoch time and webserver 

SERVERLIST=$(cat SQS* | awk -F "," '{print $5 }' | grep http |  awk -F "http://" '{print $2 }' |  awk -F "/" '{print $1 }' | sort | uniq)

# Time is rounded to nearest second
TIMELIST=$(cat SQS*  | grep SentTime | awk -F "," '{print $1 $5}' | awk -F "http://" '{print $1 "," $2 }' | awk -F "/" '{print $1}' | sed s/\{u\'SentTimestamp\'\:[[:space:]]u\'// |  awk -F "\'\}," '{print $1}' | sed 's/\(^.\{10\}\).\{3\}\(.*\)/\1\2/' | sort -n -k 1 | uniq)

echo UTC ","
for servers in $SERVERLIST
do
	echo -n $servers ","
done
echo
for times in $TIMELIST
do
	echo -n $times ","
	for servers in $SERVERLIST
	do
		counter1=$(cat SQS*  | grep $times | grep $servers | wc -l)
		echo -n $counter1 ","
	done
	echo
done

