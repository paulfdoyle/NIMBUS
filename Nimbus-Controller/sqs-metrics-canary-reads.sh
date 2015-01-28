#!/bin/bash


# This generates a pair of values - epoch time and webserver 

FILELIST=$(ls SQS*)
SERVERLIST=$(cat SQS* | awk -F "," '{print $5 }' | grep http |  awk -F "http://" '{print $2 }' |  awk -F "/" '{print $1 }' | sort | uniq)

for servers in $SERVERLIST
do
	echo -n $servers ","
done
echo


#for files in $FILELIST
#do
	#echo $files " processed -> " $(cat $files | wc -l)
        #cat $files | grep http | awk -F "," '{print $5 }' | awk -F "http://" '{print $2 }' |  awk -F "/" '{print $1 }'| awk -F "." -v r=$files '{print r " "$1 }'
	x=1
	y=$(($x+100))
        filelen=$(cat SQS-canary9-* | wc -l)
        echo $filelen
	loops=$(($filelen/100))
	echo $loops

	for (( loopcount=1; loopcount<=$loops; loopcount++ )) 
	do
	        for servers in $SERVERLIST
        	do
			counter=0
			for files in $FILELIST
			do
               			counter1=$(cat $files | sed -n "$x,$y p"  | grep $servers | wc -l)
               			counter=$(($counter+counter1))
			done
			echo -n $counter ","
        	done
        	echo
		x=$(($x+100))
                y=$(($x+100))
	done
#done




# Time is rounded to nearest second
#TIMELIST=$(cat SQS*  | grep SentTime | awk -F "," '{print $1 $5}' | awk -F "http://" '{print $1 "," $2 }' | awk -F "/" '{print $1}' | sed s/\{u\'SentTimestamp\'\:[[:space:]]u\'// |  awk -F "\'\}," '{print $1}' | sed 's/\(^.\{10\}\).\{3\}\(.*\)/\1\2/' | sort -n -k 1 | uniq)

#echo UTC ","
#for times in $TIMELIST
#do
#	echo -n $times ","
#	for servers in $SERVERLIST
#	do
#		counter1=$(cat SQS*  | grep $times | grep $servers | wc -l)
#		echo -n $counter1 ","
#	done
#	echo
#done

