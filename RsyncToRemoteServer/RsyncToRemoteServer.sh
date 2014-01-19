#!/bin/sh
DAYS=`date +%Y%m%d-%H%M`;
ALFRESCO_ROOT="/opt/alfresco";
MYSQL_USER="urmysqlusr";
MYSQL_PASS="urmysqlpass";
MYSQL_DB="urdb";
ALF_SRC="/opt/alfresco";
ALF_DES="[remoteuser]@[UR-BackupServer-IP]:/opt3/[remoteuser]/ho-dm/.";
MYSQL_DES="[remoteuser]@[UR-BackupServer-IP]:/opt3/[remoteuser]/ho-dm/AlfDB/.";
DATE="/bin/date";
ECHO="/bin/echo";
EXCLUDE="alfresco/tomcat/logs";
RM="/bin/rm";

$ECHO "######################################  START #################################################### ";
$ECHO "START  TIME: "`$DATE`
echo "Stop Alf Servive";
$ALFRESCO_ROOT/alfresco.sh stop


echo "Starting RSYNC process";

#rsync -r -a    /opt/alfresco -e ssh [remoteuser]@[UR-BackupServer-IP]:/opt3/[remoteuser]/ho-dm/.;

if rsync -r -a -z -v  --delete  --exclude $EXCLUDE   $ALFRESCO_ROOT  -e ssh $ALF_DES;
 then 
 echo "RSYNC File transfering for [DM.yourdomain] is  ........On..." >> SSHSucess.txt;
 $DATE >> SSHSucess.txt;
 mail -s "RSYNC for [DM.yourdomain]  has been done" [youremailid]@yourdomain.com < SSHSucess.txt;
else 
 $DATE >> SSHNotHappend.txt;
 echo "Sorry Connection lost ...!" >> SSHNotHappend.txt;
 mail -s "Attention : - RSYNC  NOT DONE done for [DM.yourdomain]" [youremailid]@yourdomain.com < SSHNotHappend.txt ;
fi

$RM *.sql;

echo "=== Make Mysql Backup ==="
if mysqldump --user=$MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB > $MYSQL_DB$DAYS.sql;
 then
 echo "MySQL Dump success" >> MySQLDumpSucess.txt;
 $DATE >> MySQLDumpSucess.txt;
else
 $DATE >> MySQLDumpFailure.txt;
 echo "MySQL Dump did not WORK";
 mail -s "ATTENTION :- MySQL Dump Not working for [DM.yourdomain]" [youremailid]@yourdomain.com < MySQLDumpFailure.txt;
fi






scp $MYSQL_DB$DAYS.sql $MYSQL_DES;


$ECHO "END TIME: "`$DATE`;

echo "Start Alf Servive";
$ALFRESCO_ROOT/alfresco.sh start;
$ECHO "######################################  END  ##################################################### ";

