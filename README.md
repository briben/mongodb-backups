# mongodb-backups
Backup mongoDB databases from Replica Set and sync to AWS S3.

This script will do the following:
1. Check the status of the node and only run backups if it is NOT a primary node.
2. Run mongodump and dump the databases to /data/backup/
3. Log the details to /data/backup_logs/backup.log
4. Compress the dump to a bzip (.bz2) file and sync to AWS S3 bucket.
5. Sends an email notification whether the backup process has been successful or has failed.

N.B.
* The script keeps 5 local versions of backups.
* Backup logs are logrotated every x days.
* S3 Lifecycle rules _may_ be needed to limit the number of backups on S3 from growing too large.
