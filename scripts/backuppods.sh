#! /bin/bash

# Function to backup files only  type=directory
backup_directory (){
  getcontainername=$(kubectl get pods -lapp=$podname -n $namespace --output jsonpath='{.items[0].metadata.name}')
  #echo "getcontainername: $getcontainername"
  kubectl cp $getcontainername:$backupfrom $backupto/$podname/$current_time/ -n $namespace
  find $backupto/$podname/* -maxdepth 0  -type d -ctime +$daystokeep -exec echo {} \;  
  totalseconds=`echo $SECONDS`
  lastjobseconds=$((totalseconds-totaljobseconds))
  totaljobseconds=$((totaljobseconds+lastjobseconds))
  echo "Backup of $getcontainername took $lastjobseconds seconds"
  message+="Backup of $jobtype in container: $getcontainername took $lastjobseconds seconds\\n"
}

backup_influxdb2 (){
  getcontainername=$(kubectl get pods -lapp=$podname -n $namespace --output jsonpath='{.items[0].metadata.name}')
  kubectl exec --namespace=$namespace $getcontainername -- influx backup $backupto/$current_time -t $influxdbtoken
  find $backupto/$podname/* -maxdepth 0  -type d -ctime +$daystokeep -exec echo {} \;  
  totalseconds=`echo $SECONDS`
  lastjobseconds=$((totalseconds-totaljobseconds))
  totaljobseconds=$((totaljobseconds+lastjobseconds))
  echo "Backup of $getcontainername took $lastjobseconds seconds"
  message+="Backup of $jobtype in container: $getcontainername took $lastjobseconds seconds\\n"
}
backup_k3sconfig (){
  
  echo "Start k3 backup"
  rsync -rlptDvLcp $backupfrom/ $backupto/$current_time/
  echo "end k3 backup"
  find $backupto/* -maxdepth 0  -type d -ctime +$daystokeep -exec echo {} \;  
  totalseconds=`echo $SECONDS`
  lastjobseconds=$((totalseconds-totaljobseconds))
  totaljobseconds=$((totaljobseconds+lastjobseconds))
  echo "Backup of k3s cluster  took $lastjobseconds seconds"
  message+="Backup of k3s cluster config took $lastjobseconds seconds\\n"
}

current_time=$(date +"%Y%m%d-%H")
yqPath="/home/linuxbrew/.linuxbrew/bin"
# Cleanup file for csv
# Get URL from Secrets file
url=$($yqPath/yq .backuppods.discordUrlBackup .secret-scripts.yaml)
influxdbtoken=$($yqPath/yq .backuppods.influxdbtoken .secret-scripts.yaml)
filecontents=$(sed '1d;s/.$//' backuppods.csv)
lastjobseconds=0
totaljobseconds=0
message="Backup of k8s cluster containers started \\n"
while IFS="," read -r podname namespace backupto backupfrom daystokeep jobtype
do
  
  
  if [[ "$jobtype" == "directory" ]]; then
    backup_directory
  elif [[ "$jobtype" == "influxdb2" ]]; then
    backup_influxdb2
    echo "end influxdb"
  elif [[ "$jobtype" == "k3s_config" ]]; then
    backup_k3sconfig

  fi
done <<< "$filecontents"
echo "end all jobs"

totalseconds=`echo $SECONDS`
message+="Backup of k8s cluster complete and took $totalseconds seconds"
echo "Backup of k8s cluster complete and took $totalseconds seconds"
curl -H "Content-Type: application/json" -X POST -d '{"username": "k3s-c01", "content":"'"${message}"'"}'  $url

