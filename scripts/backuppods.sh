#! /bin/bash
current_time=$(date +"%Y%m%d-%H")
# Cleanup file for csv
# Get URL from Secrets file
url=$(sed '/discordUrlBackup/ s/[^:]*: *//; s/,.*//' .secret-scripts.yaml)

filecontents=$(sed '1d;s/.$//' backuppods.csv)
lastjobseconds=0
totaljobseconds=0
message="Backup of k8s cluster containers started \\n"
while IFS="," read -r podname namespace backupto backupfrom daystokeep
do
  getcontainername=$(kubectl get pods -lapp=$podname -n $namespace --output jsonpath='{.items[0].metadata.name}')
  #echo "getcontainername: $getcontainername"
  kubectl cp $getcontainername:$backupfrom $backupto/$podname/$current_time/ -n $namespace
  totalseconds=`echo $SECONDS`
  lastjobseconds=$((totalseconds-totaljobseconds))
  totaljobseconds=$((totaljobseconds+lastjobseconds))
  echo "Backup of $getcontainername took $lastjobseconds seconds"
  message+="Backup of $getcontainername took $lastjobseconds seconds\\n"
  find $backupto/$podname/* -maxdepth 0  -type d -ctime +$daystokeep -exec echo {} \;
done <<< "$filecontents"

totalseconds=`echo $SECONDS`
message+="Backup of k8s cluster complete and took $totalseconds seconds"

curl -H "Content-Type: application/json" -X POST -d '{"username": "k3s-c01", "content":"'"${message}"'"}'  $url