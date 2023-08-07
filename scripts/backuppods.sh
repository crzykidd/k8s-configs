#/bin/bash
# script backups directory from pod.  Runs once per week and stores the copy in a backup dir based on the date and hour
# You can set the number of DAYS_TO_KEEP below.   If you run it more than once an hour it will overwrite.
CURRENT_TIME=$(date +"%Y%m%d-%H")
DAYS_TO_KEEP=31

# Settings for each job
SONARR_GETPOD=$(kubectl get pods -lapp=sonarr-ui -n dnloads --output jsonpath='{.items[0].metadata.name}')
SONARR_BACKUPPATH=/mnt/k8s-configs/backups/dnloads/sonarr
SONARR_BACKUPDIR=/config
RADARR_GETPOD=$(kubectl get pods -lapp=radarr-ui -n dnloads --output jsonpath='{.items[0].metadata.name}')
RADARR_BACKUPPATH=/mnt/k8s-configs/backups/dnloads/radarr
RADARR_BACKUPDIR=/config


#Backup Sonarr
kubectl cp $SONARR_GETPOD:$SONARR_BACKUPDIR $SONARR_BACKUPPATH/$CURRENT_TIME/ -n dnloads
#Remove old backups from Sonarr
find $SONARR_BACKUPPATH/* -maxdepth 0  -type d -ctime +$DAYS_TO_KEEP -exec rm -rf {} \;

#Backup Radarr
kubectl cp $RADARR_GETPOD:$RADARR_BACKUPDIR $RADARR_BACKUPPATH/$CURRENT_TIME/ -n dnloads
#Remove old backups from Radarr
find $RADARR_BACKUPPATH/* -maxdepth 0  -type d -ctime +$DAYS_TO_KEEP -exec rm -rf {} \;
