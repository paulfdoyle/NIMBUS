#!/bin/bash

INSTANCESLIST=$(grep ip-10 *MasterRESULT* | sort | awk -F"," '{print $2}' | sort| uniq)

#for instances in $INSTANCESLIST
#do
#	FIRSTWORKERSTARTTIME=$( grep $instances *MasterRESULT* |sort| awk -F "," 'NR==1 {c=$5 } END { print "",c }' )
#	echo "Instances = " $instances "start time = " $FIRSTWORKERSTARTTIME
#done
#
for instances in $INSTANCESLIST
do
	lastWORKERSTARTTIME=$( grep $instances *MasterRESULT* |sort| awk -F "," 'NR==1 {c=$5 } END { print "",$5 }' )
#	echo "Instances = " $instances "stop time = " $lastWORKERSTARTTIME
	echo $lastWORKERSTARTTIME
done
