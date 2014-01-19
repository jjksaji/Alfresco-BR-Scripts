#!/bin/sh                                                                                                                     
                                                                                                                              
DATE="/bin/date";                                                                                                             
ECHO="/bin/echo";                                                                                                             
SRCPATH="alfdailybackup";                                                                                                     
SOURCE=/mnt/bkp                                                                                                               
EXCLUDE="alfresco/tomcat/logs";

DAYS=`date +%Y%m%d-%H%M`                                                                                                      
                                                                                                                              
RSYNC=/usr/bin/rsync                                                                                                          
MOUNT=/bin/mount                                                                                                              
UMOUNT=/bin/umount                                                                                                            
GREP=/bin/grep                                                                                                                
ECHO=/bin/echo                                                                                                                
FIND=/usr/bin/find                                                                                                            
RM=/bin/rm                                                                                                                    
CP=/bin/cp
KILL=/bin/kill
CAT=/bin/cat



# This is my alfresco installation dir, please do change it as your enviornment
ALFRESCO_ROOT=/opt/alfresco
#I have mounted my USB device on /mnt/bkp, please change it for your enviornment 
ALF_DES=/mnt/bkp/alfdailybackup/

# This are mysql parameter, please change it to reflect your enviornment
MYSQL_USER=urmysqluser
MYSQL_PASS=mysqlusername
MYSQL_DB=mysqldb
MYSQL_DES=/mnt/bkp/alfdailybackup/AlfDB

$ECHO "Going to check if NAS  is mounted"

# I am taking backup as alfresco user, I have added the alresco user as sudo user with NOPASSWORD option

#check if NAS  is mounted
$ECHO $SOURCE/$SRCPATH

if [ -d $SOURCE/$SRCPATH ] 
then
        $ECHO "SOURCE mounted  OK"
else
        $ECHO "SOURCE not mounted"
        $ECHO "Trying to mount SOURCE"
        echo $MOUNT $SOURCE
        sudo $MOUNT /dev/sdc1  $SOURCE
        if [ -d $SOURCE/$SRCPATH ]
        then
                $ECHO "SOURCE mounted  OK"
        else
                $ECHO "unable to mount SOURCE"
                $ECHO "ERROR exiting"
                $ECHO
                #No point in copying log file to source
                exit 1
        fi

fi

echo "Stop Alf Servive";
$ALFRESCO_ROOT/alfresco.sh stop
#echo $ALFRESCO_ROOT/alfresco.sh stop


echo "Starting RSYNC process";

#rsync -r -a    /opt/alfresco /opt1/BackUp/DM/.;
#  Taking backup on the Storage device connected to the system
# 

#rsync -r -a     $ALFRESCO_ROOT   $ALF_DES
# You can later remove -v option (verfiy) after testing the script
# I have exluded the log files, if you need to add log files also for backup, please remove "--exclude $EXCLUDE" 
echo "rsync -r -a -z -v "      $ALFRESCO_ROOT   $ALF_DES
rsync -r -a -z -v  --delete  --exclude $EXCLUDE    $ALFRESCO_ROOT   $ALF_DES

echo "=== Make Mysql Backup ==="
#mysqldump --user=$MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB > $MYSQL_DB$DAYS.sql;
mysqldump --user="$MYSQL_USER "--password="$MYSQL_PASS $MYSQL_DB ">"$MYSQL_DB$DAYS".sql ;

echo $MYSQL_DES/.
cp /home/alfresco/$MYSQL_DB$DAYS.sql $MYSQL_DES/.


$ECHO "END TIME: "`$DATE`;

echo "Start Alf Servive";
$ALFRESCO_ROOT/alfresco.sh start;
$ECHO "######################################  END  ##################################################### ";

