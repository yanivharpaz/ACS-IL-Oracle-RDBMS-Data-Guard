# ACS-IL-Oracle-RDBMS-Data-Guard
Oracle database data guard automation


## Use this guide / scripts only for testing and learning purpose

## Run the prep script
```
sudo ./misc/100_prep_dg_files.sh [ORACLE_SID] [primary_host] [standby_host]
```

---
## Prerequisites for the data guard creation

* Oracle RDBMS Instance up & running on the primary
* Open port between the servers (default 1521)
* Oracle RDBMS software installed on both primary and standby
* Copy the password file from the primary to the secondary ($ORACLE_HOME/dbs)

## Steps on the creation process

### On the primary

* enable archive log mode
* enable force logging
* create standby redo logs
* TNS - setup entries for primary and standby -> tnsnames.ora and listener.ora
* start the data guard broker

### On the standby

* TNS - setup entries for primary and standby -> tnsnames.ora and listener.ora
* create directories for the database restore
* prepare init.ora for the restore
* startup nomount with the init.ora
* run RMAN duplicate target
* start the data guard broker
* run the dgmgrl -    
  * create configuration
  * add database
  * enable configuration  

### Test with switchover between the primary and the standby (and back)  


### Usage example on YouTube: https://youtu.be/5xYJvy7Pvgc

---
Thank you for reading.  
  
You can contact me at http://www.twitter.com/w1025
  