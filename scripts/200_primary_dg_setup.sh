#!/bin/bash
#

if [ $# -ne 1 ]
then
    echo "Usage: sudo $0 [ ORACLE_SID ] "
    exit 1
fi

echo "Reading configuration"
NEW_CONFIG_NAME="oracle_rdbms_config_sample.conf"
NEW_CONFIGURATION="/tmp/$NEW_CONFIG_NAME"

. "$NEW_CONFIGURATION" $ORACLE_SID

echo "ORACLE_HOME       : $ORACLE_HOME"

# export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1

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


# Commands
if [ -z "$SU" ];then SU=/bin/su; fi
if [ -z "$GREP" ]; then GREP=/usr/bin/grep; fi
if [ ! -f "$GREP" ]; then GREP=/bin/grep; fi


run_scripts_primary() {
    # /tmp/080_prep_dg.sh
    /bin/bash -c "sudo /tmp/setup_cdb1.sh configure"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/210_change_sys_password.sh"
    /bin/bash -c "/tmp/190_update_db_config.sh $ORACLE_SID"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/310_copy_tns_files_primary.sh"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/120_dg_broker_start.sh"
    $SU -s /bin/bash  $ORACLE_OWNER -c "/tmp/110_restart_listener.sh"

}
#prep_dg_01
#cat /tmp/prep_dg.log

run_scripts_primary

exit 0
