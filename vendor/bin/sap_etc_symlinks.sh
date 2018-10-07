#!/vendor/bin/sh

LOG_TAG="laop_symlinks"

# This script is executed once only by FP.
FIXED_FIRST_SIM_OPERATOR=`getprop persist.sys.sim.operator.first NODEF`

if [[ "$FIXED_FIRST_SIM_OPERATOR" != "NODEF" ]]; then
    exit 0;
fi

# wait for ntocde_etc_symlinks done
time_count=1
while [[ $time_count -le 100 ]]
do
    LAST_BUILD_INCREMENTAL=`getprop persist.sys.laop.incremental 0`
    if [[ "$LAST_BUILD_INCREMENTAL" != "0" ]]; then
        break;
    fi
    sleep 1
    let time_count=$time_count+1
done
log -p w -t ${LOG_TAG} "[SBP] ntcode_etc_symlinks wait for ${time_count} before it starts"

DEFAULT_ICCID_PERSIST_VALUE=89000000000000000000
CURRENT_ICCID=`getprop persist.sys.iccid ${DEFAULT_ICCID_PERSIST_VALUE}`

if [[ "$CURRENT_ICCID" == "$DEFAULT_ICCID_PERSIST_VALUE" ]]; then
    log -p w -t ${LOG_TAG} "[SBP] sap_etc_symlinks exit - SIM is not loaded yet."
    exit 0;
fi

SIM_OPERATOR=`getprop persist.sys.sim.operator NODEF`
SUB_SIM_OPERATOR=`getprop persist.sys.sim.operator.sub NODEF`
CUPSS_ROOTDIR=`getprop ro.lge.capp_cupss.rootdir /OP`

if [[ "$SUB_SIM_OPERATOR" == "SKC" ]]; then
    SIM_OPERATOR=$SUB_SIM_OPERATOR
fi

SOURCE_ETC_PATH=${CUPSS_ROOTDIR}/etc/${SIM_OPERATOR}
TARGET_ETC_PATH=/data/local/etc

if [ ! -d ${TARGET_ETC_PATH} ]; then
    log -p e -t ${LOG_TAG} "[SBP] sap_etc_symlinks exit - ${TARGET_ETC_PATH} not exist"
    exit 0;
fi

log -p i -t ${LOG_TAG} "[SBP] sap_etc_symlinks - SOURCE_ETC_PATH = $SOURCE_ETC_PATH"

# copy 3rd-party app properties for the matched operator
if [ -d ${SOURCE_ETC_PATH} ]; then
    cp -rf ${SOURCE_ETC_PATH}/* ${TARGET_ETC_PATH}/
    chown -R system:system ${TARGET_ETC_PATH}
    chmod -R 644 ${TARGET_ETC_PATH}/*

    # Change directory permission to get read
    find ${TARGET_ETC_PATH} -type d -exec chmod 755 {} +
fi

#FIX FIRST_SIM_OPERATOR
setprop persist.sys.sim.operator.first ${SIM_OPERATOR}
exit 0
