#!/usr/bin/env bash

# Name of MongoDB Replica Set
#replset='vivo_01'
replset=`/var/lib/mongodb-mms-automation/mongodb-linux-x86_64-3.6.2/bin/mongo --host localhost:36035 --eval 'rs.conf()._id' --quiet`
#replset=`/usr/bin/mongo --host localhost:36035 --eval 'rs.conf()._id' --quiet`

# Assign variables & set-up files
WKDIR=/data/backup
DIR2=`date +%F-%T`
# Replace the ':' with '.' in the date string (':' causes problems when archiving)
DIR=$(echo $DIR2 | tr ':' '.')
DEST=/data/backup/$DIR
ERR='zz_FAILED_BACKUP_'$DIR
LOG=/data/backup_logs/backup.log
REMLOG=/data/backup_logs/removed.log

echo "MongoDB backup process started..."

# Make copies of the email templates for editing
cp /var/scripts/backup/email/success-template.html /var/scripts/backup/email/success-notification.html
cp /var/scripts/backup/email/failure-template.html /var/scripts/backup/email/failure-notification.html

# Create the backup folder
mkdir $DEST
# Run mongodump - backup all databases
/var/lib/mongodb-mms-automation/mongodb-linux-x86_64-3.6.2/bin/mongodump --host mgdb201.prod.lbh.newsonline.tc.nca.bbc.co.uk:36035,mgdb202.prod.lbh.newsonline.tc.nca.bbc.co.uk:36035,mgdb203.prod.lbh.newsonline.tc.nca.bbc.co.uk:36035 --username=mongo --password=mongo --authenticationDatabase=admin --oplog --out $DEST \
#/usr/bin/mongodump --host localhost --port 36035 --username=mongo --password=mongo --authenticationDatabase=admin --oplog --out $DEST \
>> $LOG 2>&1


# Error catching & notification
if [ $? -ne 0 ]; then
    # Move & rename the failed backup folder
    mv $DEST /data/failed_backup/$ERR

    # Capture the error message
    failmsg=$(tail -1 /data/backup_logs/backup.log)
    
    # Log the events
    echo "*** MongoDump failed! ***" | tee -a "$LOG"

    # Construct email notification of failure
    sed -i -e "s~%%FAILURE%%~${failmsg}~g" /var/scripts/backup/email/failure-notification.html
    
    # Send email - !! DO NOT indent Email headers & EOF below !!
    cat <<'EOF' - /var/scripts/backup/email/failure-notification.html | /usr/sbin/sendmail -i -t
To: brian.benton@bbc.co.uk
Subject: MongoDB Backup failed
Content-Type: text/html

EOF
    
    exit 1
else
    # Log the events
    echo "*** Backup complete - Added $DEST.bz2  ***"  | tee -a "$LOG"

    # Remove the oldest backup folder
    min_dirs=0
    [[ $(find "$WKDIR" -maxdepth 1 -type d | wc -l) -ge $min_dirs ]] &&
    IFS= read -r -d $'\0' line < <(find "$WKDIR" -maxdepth 1 -printf '%T@ %p\0' 2>/dev/null | sort -z -n)
    file="${line#* }"
    echo "REMOVED " $file &>> $REMLOG
    remdir=$file
    rm -rf "$file"
    
    # Construct email notification of success
    sed -i -e "s~%%RSET%%~${replset}.bz2~g" -e "s~%%ADDED%%~${DEST}.bz2~g" -e "s~%%REMOVED%%~${remdir}~g" /var/scripts/backup/email/success-notification.html
    
    # Send email - !! DO NOT indent Email headers & EOF below !!
    cat <<'EOF' - /var/scripts/backup/email/success-notification.html | /usr/sbin/sendmail -i -t -f "brian.benton@bbc.co.uk"
To: brian.benton@bbc.co.uk
From: mongodb <mongod@$hostname>
Subject: MongoDB Backup completed
Content-Type: text/html

EOF

fi

# Archive and compress (bzip) the backup
tar -cjf ${DEST}.bz2 ${DEST}

# Remove the raw backup files
rm -R ${DEST}

# Upload to AWS S3
aws s3 sync $WKDIR s3://vivo-test-dst/mongo-backups

# Make an archive copy of the backup.log file - <-- NOT NEEDED, NOW USES logrotate (/etc/logrotate.conf)
# cp /data/backup_logs/backup.log /data/backup_logs/${DIR}_backup.log