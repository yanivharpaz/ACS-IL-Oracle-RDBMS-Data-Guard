#!/bin/bash
#
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1

# General exports and vars
export PATH=$ORACLE_HOME/bin:$PATH
LSNR=$ORACLE_HOME/bin/lsnrctl
SQLPLUS=$ORACLE_HOME/bin/sqlplus
DBCA=$ORACLE_HOME/bin/dbca
NETCA=$ORACLE_HOME/bin/netca
ORACLE_OWNER=oracle
RETVAL=0
#CONFIG_NAME="oracledb_$ORACLE_SID-$ORACLE_VERSION.conf"
#CONFIGURATION="/etc/sysconfig/$CONFIG_NAME"

NEW_CONFIG_NAME="oracle_rdbms_config_sample.conf"
NEW_CONFIGURATION="/tmp/$NEW_CONFIG_NAME"

. "$NEW_CONFIGURATION"

# Commands
if [ -z "$SU" ];then SU=/bin/su; fi
if [ -z "$GREP" ]; then GREP=/usr/bin/grep; fi
if [ ! -f "$GREP" ]; then GREP=/bin/grep; fi



# To start the DB
prep_dg_01()
{
    check_for_configuration
    RETVAL=$?
    if [ $RETVAL -eq 1 ]
    then
        echo "The Oracle Database is not configured. You must run '/etc/init.d/oracledb_$ORACLE_SID-$ORACLE_VERSION configure' as the root user to configure the database."
        exit
    fi
    # Check if the DB is already started
    pmon=`ps -ef | egrep pmon_$ORACLE_SID'\>' | $GREP -v grep`
    if [ "$pmon" != "" ];
    then

        # Unset the proxy env vars before calling sqlplus
        # unset_proxy_vars

        echo "Putting Oracle instance in archivelog $ORACLE_SID."
        $SU -s /bin/bash  $ORACLE_OWNER -c "$SQLPLUS -s /nolog << EOF
            connect / as sysdba
            spool /tmp/prep_dg.log
            set echo on
            SELECT log_mode FROM v\\\$database;
            select member from v\\\$logfile;
            alter system set db_recovery_file_dest_size=10G scope=both sid='*';
            alter system set db_recovery_file_dest='$ORACLE_BASE/oradata' scope=both sid='*';
            SHUTDOWN IMMEDIATE;
            STARTUP MOUNT;
            ALTER DATABASE ARCHIVELOG;
            ALTER DATABASE OPEN;
            ALTER DATABASE FORCE LOGGING;
            ALTER SYSTEM SWITCH LOGFILE;
            select 'Oracle SID: $ORACLE_SID' AS SID FROM DUAL;

            ALTER DATABASE ADD STANDBY LOGFILE ('$ORACLE_REDO_LOCATION/standby_redo01.log') SIZE 200M;
            ALTER DATABASE ADD STANDBY LOGFILE ('$ORACLE_REDO_LOCATION/standby_redo02.log') SIZE 200M;
            ALTER DATABASE ADD STANDBY LOGFILE ('$ORACLE_REDO_LOCATION/standby_redo03.log') SIZE 200M;
            ALTER DATABASE ADD STANDBY LOGFILE ('$ORACLE_REDO_LOCATION/standby_redo04.log') SIZE 200M;

            ALTER DATABASE FLASHBACK ON;
            ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;

            SELECT log_mode FROM v\\\$database;
            select member from v\\\$logfile;
            spool off
            exit;
            EOF" 
        RETVAL1=$?
        if [ $RETVAL1 -eq 0 ]
        then
            echo "Oracle Database instance $ORACLE_SID started."
        fi
    else
        echo "Oracle instance not running $ORACLE_SID."
        exit 0
    fi

    echo
    if [ $RETVAL -eq 0 ] && [ $RETVAL1 -eq 0 ]
    then
        return 0
     else
        echo "Failed to prepare database instance for data guard."
        exit 1
    fi
}

run_scripts_primary() {
    # /tmp/080_prep_dg.sh
    /bin/bash -c "sudo /tmp/setup_cdb1.sh configure"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/210_change_sys_password.sh"
    /bin/bash -c "/tmp/080_prep_dg.sh"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/310_copy_tns_files_primary.sh"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/120_dg_broker_start.sh"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/110_restart_listener.sh"

}
#prep_dg_01
#cat /tmp/prep_dg.log

run_scripts_primary

exit 0
