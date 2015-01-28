#!/bin/bash

INSTANCESLIST=$(grep ip-10 *MasterRESULT* | sort | awk -F"," '{print $2}' | sort | uniq)
 # WORKERLIST=$(grep ip-10 *MasterRESULT* | sort | awk -F"," '{print $1}' | sort | uniq )
echo $(grep ip-10  *MasterRESULT* | awk -F"," '{print $5}' | sort | uniq | awk -F " " '{print $1;exit}')

echo
echo
echo
echo
for instance in $INSTANCESLIST
do

	echo -n $instance ","
	echo $(grep $instance *MasterRESULT* | awk -F"," '{print $5}' | sort | uniq | awk -F " " '{print $1;exit}')
done
exit 0

