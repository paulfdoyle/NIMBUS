#!/bin/bash

cat *logfile* > MasterLogfile.csv


FILESUPLOADED=$( grep "Result Filename" *MasterLogfile* | wc -l )
FILESPROCESSED=$( grep "Files processed" *MasterLogfile* | wc -l )
FTPNODE1=$( grep "ftp.heanet" *MasterLogfile* | wc -l )
S3NODE1=$( grep "s3.amazonaws" *MasterLogfile* | wc -l )
WEBNODE1=$( grep "webnode1" *MasterLogfile* | wc -l )
WEBNODE2=$( grep "webnode2" *MasterLogfile* | wc -l )
WEBNODE3=$( grep "webnode3" *MasterLogfile* | wc -l )
WEBNODE4=$( grep "webnode4" *MasterLogfile* | wc -l )
WEBNODE5=$( grep "webnode5" *MasterLogfile* | wc -l )
WEBNODE6=$( grep "webnode6" *MasterLogfile* | wc -l )
INSTANCES=$( grep ACN *MasterLogfile* | sort | awk -F"," '{print $2}' | uniq | wc -l )
WORKERS=$( grep ACN *MasterLogfile* | sort | awk -F"," '{print $1}' | uniq | wc -l )
FIRSTWORKERSTARTTIME=$( grep "CmdQ START Time ON" *MasterLogfile* |sort| awk -F "," 'NR==1 {c=$5 } END { print "",c }' )
LASTWORKERSTARTTIME=$( grep "CmdQ START Time ON" *MasterLogfile* |sort| awk -F "," 'NR==1 {c=$5 } END { print "",$5 }' )
LASTDOWNLOADTIME=$( grep "Files Processed" *MasterLogfile* |sort| awk -F "," 'NR==1 {c=$5 } END { print "",$5 }' )
LASTUPLOADTIME=$( grep "Result Filename" *MasterLogfile* |sort| awk -F "," 'NR==1 {c=$5 } END { print "",$5 }' )
LINE=$( grep ACN *MasterLogfile* | wc -l )
DIFF=$(( $FILESPROCESSED - $FILESUPLOADED ))
NAME=$( ls *Monitor* | awk -F "-" 'NR==1 {print $1$2}' )

echo -n $NAME ","
echo -n $FILESUPLOADED ","
echo -n $FILESPROCESSED ","
echo -n $FTPNODE1 ","
echo -n $S3NODE1 ","
echo -n $WEBNODE1 ","
echo -n $WEBNODE2 ","
echo -n $WEBNODE3 ","
echo -n $WEBNODE4 ","
echo -n $WEBNODE5 ","
echo -n $WEBNODE6 ","
echo -n $INSTANCES ","
echo -n $WORKERS ","
echo -n $FIRSTWORKERSTARTTIME ","
echo -n $LASTWORKERSTARTTIME ","
echo -n $LASTDOWNLOADTIME ","
echo -n $LASTUPLOADTIME ","
echo -n $LINE ","

cat *resultq* > MasterRESULT.csv
RESULTS=$( grep "fz.result" *MasterRESULT* | wc -l )
worker1=$( grep "ubuntu," *MasterRESULT* | wc -l )
worker2=$( grep "ubuntu2," *MasterRESULT* | wc -l )
worker3=$( grep "ubuntu3," *MasterRESULT* | wc -l )
worker4=$( grep "ubuntu4," *MasterRESULT* | wc -l )
worker5=$( grep "ubuntu5," *MasterRESULT* | wc -l )
worker6=$( grep "ubuntu6," *MasterRESULT* | wc -l )
worker7=$( grep "ubuntu7," *MasterRESULT* | wc -l )
worker8=$( grep "ubuntu8," *MasterRESULT* | wc -l )
worker9=$( grep "ubuntu9," *MasterRESULT* | wc -l )
worker10=$( grep "ubuntu10," *MasterRESULT* | wc -l )
RESINSTANCES=$(grep ACN *MasterRESULT* | sort | awk -F"," '{print $2}' | uniq | wc -l)

INSTANCESLIST=$(grep ACN *MasterRESULT* | sort | awk -F"," '{print $2}' | uniq)
RESWORKERS=$(grep ACN *MasterRESULT* | sort | awk -F"," '{print $1}' | uniq | wc -l)

echo -n $RESULTS ","
echo -n $worker1 ","
echo -n $worker2 ","
echo -n $worker3 ","
echo -n $worker4 ","
echo -n $worker5 ","
echo -n $worker6 ","
echo -n $worker7 ","
echo -n $worker8 ","
echo -n $worker9 ","
echo -n $worker10 ","
echo -n $RESWORKERS ","

total=0
min=20000
max=0
avg=0
square=0
sumsquare=0
WORKERLIST=$(grep ACN *MasterRESULT* | sort | awk -F"," '{print $1}' | uniq)
for worker in $WORKERLIST
do
        count1=$( grep "$worker," *MasterRESULT* | wc -l )
        total=$(($total + $count1))
        if [ $count1 -gt $max ]; then
                max=$count1
        fi
        if [ $count1 -le $min ]; then
                min=$count1
        fi
done

avg=$(echo $total/$WORKERS | bc)
for worker in $WORKERLIST
do
        count1=$( grep $worker *MasterRESULT* | wc -l )
        sum=$(($count1 - $avg))
        square=$(($sum * $sum))
        sumsquare=$(($sumsquare + $square))
done
variance=$(echo $sumsquare/$WORKERS | bc)
stddeviation=$(echo "scale=3;sqrt ($variance)" | bc)
echo -n $min ","
echo -n $max ","
echo -n $avg ","
echo -n $stddeviation ","


echo -n $RESINSTANCES ","

total=0
min=20000
max=0
avg=0
square=0
sumsquare=0
for instances in $INSTANCESLIST
do
	count1=$( grep $instances *MasterRESULT* | wc -l )
	total=$(($total + $count1))
	if [ $count1 -gt $max ]; then
		max=$count1
	fi
	if [ $count1 -le $min ]; then
		min=$count1
	fi
done

avg=$(echo $total/$RESINSTANCES | bc)

for instances in $INSTANCESLIST
do
        count1=$( grep $instances *MasterRESULT* | wc -l )
	sum=$(($count1 - $avg))
	square=$(($sum * $sum))
	sumsquare=$(($sumsquare + $square))
done
variance=$(echo $sumsquare/$RESINSTANCES | bc)
stddeviation=$(echo "scale=3;sqrt ($variance)" | bc)
echo -n $min ","
echo -n $max ","
echo -n $avg ","
echo -n $stddeviation ","


cat *workerregister* > MasterReg.csv
REGINSTANCES=$(grep ACN *Reg.csv | sort | awk -F"," '{print $2}' | uniq | wc -l)
REGWORKERS=$(grep ACN *Reg.csv | sort | awk -F"," '{print $1}' | uniq | wc -l)

echo -n $REGINSTANCES ","
echo -n $REGWORKERS ","
REGSTARTWORKER=$(grep ACN *Reg.csv | sort | awk -F"," '{print $4}' | sort| uniq | awk -F " " 'NR==1 {c=$2 } END { print c }')
REGLASTWORKER=$(grep ACN *Reg.csv | sort | awk -F"," '{print $4}' | sort| uniq | awk -F " " 'END {print $2}')
echo -n $REGSTARTWORKER ","
echo -n $REGLASTWORKER ","

STARTTIME=$(grep -v "QueueSIZE,  0 ," *Mon*|grep QueueSIZE  |  awk -F"," 'END { print $3 }')
STOPTIME=$(grep -v "QueueSIZE,  0 ," *Mon*|grep QueueSIZE  |  awk -F"," 'END { print $6 }')
QUEUEMIN=$(grep -v "QueueSIZE,  0 ," *Mon*|grep QueueSIZE  |  awk -F"," 'END { print $8 }')
QUEUEMAX=$(grep -v "QueueSIZE,  0 ," *Mon*|grep $STARTTIME |  awk -F "," 'NR==1 {c=$8 } END { print c }')

echo -n $QUEUEMIN ","
echo -n $QUEUEMAX ","
echo -n $STARTTIME ","
echo $STOPTIME 


