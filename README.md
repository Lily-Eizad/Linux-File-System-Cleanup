# File-System-Cleanup
Bash script to clean up the file system in a linux server for more space 

Pegah Eizadkhah
Bash file system clean up project

This Bash script clears space on the disk by removing trace and media files older than 1 day, 
removing listener log.xml files older than a day and gziping large listener logs located 
in the trace directory. It also gzips audit files and puts them in separate directory 
and cleans up files older than 30 days in that directory.

This code is owned by Pegah Eizadkhah and is not meant for redistribution.
