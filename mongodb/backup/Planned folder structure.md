# Planned folder structure
├── /var/scripts/
   └── backup/
       ├── mongo-backup.sh
       └── email/
           ├── failure-notification.html
           ├── failure-template.html
           ├── success-notification.html
           └── success-template.html
 
├── /data/
    ├── backup/
    |   ├── 2017-11-17-08:11:57.bz2
    |   ├── 2017-11-17-12:11:57.bz2
    |   └── 2017-11-17-16:11:57.bz2
    └── backup_logs/
    |   ├── backup.log
    |   ├── removed.log
    |   ├── backup.log-2017-12-11-14:52:34
    |   └── backup.log-2017-12-11-15:51:34
    └── failed-backup/
        ├── zz_FAILED_BACKUP_2017-11-14-11:04:01
        ├── zz_FAILED_BACKUP_2017-11-15-12:04:01
        └── zz_FAILED_BACKUP_2017-11-16-13:04:01



====================
└── mongodb/
    ├── backups/
    │   ├── delete-oldest-folder.sh
    │   ├── delete-oldest.sh
    │   ├── html-email.sh
    │   ├── mongo-backup.sh
    │   └── mongo-backup.sh.bak
    ├── email/
    │   ├── failure-notification.html
    │   ├── failure-template.html
    │   ├── success-notification.html
    │   ├── success-template.html