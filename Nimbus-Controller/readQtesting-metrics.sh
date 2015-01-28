#!/bin/bash

# List of unique times in the .csv file
TIMELIST=$(cat SQS* | awk -F "{" '{print $1 }' | awk -F "," '{print $3}' | awk 'NF > 0' | sort | uniq)

for times in $TIMELIST
do
	echo -n $times ","
	counter1=$(cat SQS*  | grep $times | wc -l)
	echo $counter1
done





