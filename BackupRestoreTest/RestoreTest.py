#!/usr/bin/python

"""
Steps for Restore test 
---
Step 1:- stop the alfresco instance
Step 2:- Remove the previous alfresco installation dir 
Step 3:- Copy the files from DMbackupLocation to Restore server
Step 4:- Drop the DB, Create DB, Import the Tables
Step 5:- change the ownership of /opt/alfresco to alfresco user 
Step 6:- Check for alfresco running instance, shut down it and run the installed one 

"""


print "Step 2 , copy the files from DMdmbackupLocation to 20.69"
import os
import time
import MySQLdb as mdb
# Step 1  Stop the alfresco instance running v
os.system("/opt/alfresco/alfresco.sh stop")
# Step 2 rm the previous install dir 
os.system("rm -rf /opt/alfresco")
#Step 3 :- Copy the files from DMbackupLocation to Restore server
os.system("scp -r  [remoteuser]@[yourTestServerIP]:/backuplocation/alfresco  /opt/.")
os.system("scp -r  [remoteuser]@[yourTestServerIP]:/backuplocation/AlfDB  /opt/.")

# Step 4 dropping the DB, creating it and restoring it from the SQL 
print ("Step 2, dropping the DB, creating it and restoring it from the SQL")
# Finding the latest SQL backup file in 
os.chdir("/opt/AlfDB/")
# Check current working directory.
retval = os.getcwd()
#print "Current working directory %s" % retval
newest = max(os.listdir("."), key = os.path.getctime)
print newest

dblocation = "/opt/AlfDB/"+newest;
print dblocation
db = mdb.connect(host="localhost", user="yourMysqlUser", passwd="yourMySQLpass")
cursor = db.cursor() 
cursor.execute("SHOW DATABASES LIKE 'alfresco'")
results = cursor.fetchone()
print(results)
# Check if anything at all is returned
if results:
    print("Yes, and we are going to drop ")
    cursor.execute("DROP DATABASE alfresco")
    print("Going to create one")
    cursor.execute("CREATE DATABASE alfresco")
    print("create alfresco DB")
else:
    print("No, there is no database alfresco")
    print("Going to create one")
    cursor.execute("CREATE DATABASE alfresco")
    print("create alfresco DB")
               
print("Going to import the DB tables ")
tableimport = "mysql -uyourMysqlUser -pyourMySQLpass alfresco < " + dblocation 
print(tableimport)
os.system(tableimport)
os.system("mkdir -p /opt/alfresco/tomcat/logs/")
os.system("chown alfresco.alfresco -R /opt/alfresco")
# Step 3 change to alfresco users 
# here please give your alfresco user ID
os.setuid(505)
print "Current user running the script is", os.geteuid()
#os.system("/opt/alfresco/alfresco.sh start")
print "Step 4, grep for error files in the log files and send it by email"
print "Alfreco Started time : %s" % time.ctime()
time.sleep(360)
print "After 6 minutes checking the log files for error  : %s" % time.ctime()
os.system("cat /opt/alfresco/tomcat/logs/catalina.out | grep -i error >> /home/alfresco/dm-error.txt")

# mail -s "PORTAL  : - RSYNC  NOT DONE" [yourid]@[yourdomain].com < SSHNotHappend.txt ;
os.system("mail [yourid]@[yourdomain].com < /home/alfresco/dm-error.txt")

