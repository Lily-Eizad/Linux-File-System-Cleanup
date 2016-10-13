#Pegah Eizadkhah
#Bash file system clean up project

#This Bash script clears space on the disk by removing trace and media files older than 1 day, 
#removing listener log.xml files older than a day and gziping large listener logs located 
#in the trace directory. It also gzips audit files and puts them in separate directory 
#and cleans up files older than 30 days in that directory.

# This code is owned by Pegah Eizadkhah and is not meant for redistribution.

echo ' '
echo '**** Cleaning .trc and .trm files ****'
for database in $(ps -ef | grep [o]ra_pmon | awk '{ print $8 }' | sed 's/ora_pmon_//' | grep -v sed | sort);
do

#take the current database name and make it lowercase and store in y.
y=${database,,}
#strip the last char from the end of y, store in x, this is our database name.
x=${y%?}
#append base_path with database name stored in x, and the rest of the trace file path.
full_path_trace=/u01/app/oracle/diag/rdbms/$x/$database/trace/

#if .trc or .trm files older than 1 day are found in the directory full_path_trace, remove them, other wise, print nothing to do.
if find "$full_path_trace" -name '*.trc' -mtime +1 -print -quit | grep -q '^' || find "$full_path_trace" -name '*.trm' -mtime +1 -print -quit |
   grep -q '^'; then
  find "$full_path_trace"/*.trc -mtime +1 -exec rm {} \;
  find "$full_path_trace"/*.trm -mtime +1 -exec rm {} \;
  echo ${database}': Trace and media files Successfully cleaned up.'
else
  echo ${database}': Nothing to do for this DB.'
fi

done

echo ' '

host=$(hostname -s)
listener_log_path=/u01/app/oracle/diag/tnslsnr/${host}
cd ${listener_log_path}

echo '**** Cleaning listener files ****'
# this loop finds log.xml files older than a day and removes them
for listener_loc in $(ls -l |awk '{print $9}');
do

if find "${listener_loc}/alert" -name 'log_*.xml' -mtime +1 -print -quit |
   grep -q '^'; then
   find "${listener_loc}/alert"/log_*.xml -mtime +1 -exec rm {} \;
   echo ${listener_loc}': Old log.xml files successfully removed'
else
   echo ${listener_loc}': No log.xml files to delete for this location.'
fi

# remove the current old.gz file
find ${listener_loc}/trace/${listener_loc}.old.gz -exec rm {} \;
# copy the current log file into a .old file
find ${listener_loc}/trace/${listener_loc}.log -exec cp {} ${listener_loc}/trace/${listener_loc}.old \;
# gzip the .old file
find ${listener_loc}/trace/${listener_loc}.old -exec gzip {} \;
# truncate the .log file
find ${listener_loc}/trace/${listener_loc}.log -exec sh -c '> {}' \;
echo ${listener_loc}': Listener logs successfully cleaned up.'

done

echo ' '
echo '**** Cleaning up audit files ****'
#get the date
now=$(date +'%m-%d-%Y-%H-%M-%S')
audit_files=/u01/app/oracle/product/11.2.0.3/dbhome_1/rdbms/audit
cd "$audit_files"
#find all in audit files and tar and zip them
find . -type f -name "*.aud" | xargs tar -zcf "$now".tar.gz
#move the gzip file to the /old directory
mv "$now".tar.gz "$audit_files"/old
#remove the audit files from the audit files directory
find . -type f -name "*.aud" | xargs rm
#go in the /old directory and remove gziped audit files older than a month
if find "$audit_files"/old -name '*.tar.gz' -mtime +30 -print -quit | grep -q '^'; then
 find "$audit_files"/old/*.tar.gz -mtime +30 -exec rm {} \;
fi

echo ' '
echo '**** Done with the clean up!... ****'

echo ' '
