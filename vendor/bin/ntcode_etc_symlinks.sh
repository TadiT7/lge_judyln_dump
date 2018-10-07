#!/vendor/bin/sh
LOG_TAG="laop_symlinks"
LAST_BUILD_INCREMENTAL=`getprop persist.sys.laop.incremental 0`
CURRENT_BUILD_INCREMENTAL=`getprop ro.build.version.incremental NODEF`
if [[ "$LAST_BUILD_INCREMENTAL" == "$CURRENT_BUILD_INCREMENTAL" ]]; then
    exit 0;
fi

SOURCE_PATH=`getprop ro.lge.capp_cupss.rootdir /cust`   #/cust/VDF_COM

# TODO: Remove below lines from Q-OS - START
OP_PATH=`getprop persist.sys.op_info NODEF`
if [[ "$OP_PATH" == "NODEF" ]]; then
    IS_MULTISIM=`getprop ro.lge.sim_num 1`
    OPERATOR=`getprop ro.build.target_operator GLOBAL`
    COUNTRY=`getprop ro.build.target_country COM`

    if [ $IS_MULTISIM == "2" ]; then
        OP_PATH=${OPERATOR}_${COUNTRY}_DS
    elif [ $IS_MULTISIM == "3" ]; then
        OP_PATH=${OPERATOR}_${COUNTRY}_TS
    else
        OP_PATH=${OPERATOR}_${COUNTRY}
    fi
fi
LEGACY_OP_PATH=/OP/${OP_PATH}
# TODO: Remove below lines from Q-OS - END

SOURCE_ETC_PATH=${SOURCE_PATH}/etc
TARGET_ETC_PATH=/data/local/etc

# /data/local/etc MUST be updated in MR or OSU.
log -p i -t ${LOG_TAG} "[SBP] clean-up /data/local/etc for MR or OSU"
rm -rf ${TARGET_ETC_PATH}/*

if [ ! -d ${TARGET_ETC_PATH} ]; then
    log -p i -t ${LOG_TAG} "[SBP] mkdir ${TARGET_ETC_PATH}"
    mkdir -p -m 771 ${TARGET_ETC_PATH}
    restorecon ${TARGET_ETC_PATH}
fi

if [ ! -d ${TARGET_ETC_PATH} ]; then
    log -p e -t ${LOG_TAG} "[SBP] exit - cannot mkdir ${TARGET_ETC_PATH}"
    exit 0;
fi

# copy 3rd party app properties for LGE to /data
LGE_3RD_PARTY_KEY_PATH=/system/vendor/etc/LGE
if [ -d ${LGE_3RD_PARTY_KEY_PATH} ]; then
    cp -rf ${LGE_3RD_PARTY_KEY_PATH}/* ${TARGET_ETC_PATH}/
fi

# Read NT-Code MCC
NTCODE=`getprop ro.lge.ntcode_mcc XXX`
if [[ "$NTCODE" == "XXX" ]]; then
    #Nothing to do - fail to read ntcode
    log -p e -t ${LOG_TAG} "[SBP] exit - fail to read ntcode"
    exit 0;
fi

# For dedicatie operator with speical NT-code, eg., VDF: "2","FFF,FFF,FFFFFFFF,FFFFFFFF,11","999,01F,FFFFFFFF,FFFFFFFF,FF"
MCCMNC_LIST=`getprop persist.sys.mccmnc-list "FFFFF"`
DEDICATE_OPERATOR_MCCMNC="XXXXXX"
if [[ "$MCCMNC_LIST" == *"999"* ]]; then
    DEDICATE_OPERATOR_MCCMNC=${MCCMNC_LIST%%999*}
    DEDICATE_MCCMNC_INDEX=${#DEDICATE_OPERATOR_MCCMNC}
    DEDICATE_OPERATOR_MCCMNC=${MCCMNC_LIST:$DEDICATE_MCCMNC_INDEX:6}
    DEDICATE_OPERATOR_MCCMNC=${DEDICATE_OPERATOR_MCCMNC%,}
fi

if [ -d ${SOURCE_ETC_PATH}/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rf ${SOURCE_ETC_PATH}/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_ETC_PATH}/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_ETC_PATH}/${NTCODE} ]; then
    cp -rf ${SOURCE_ETC_PATH}/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_ETC_PATH}/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_ETC_PATH}/FFF ]; then
    cp -rf ${SOURCE_ETC_PATH}/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_ETC_PATH}/FFF/* ${TARGET_ETC_PATH}/"

# TODO: Remove below lines from Q-OS - START
# Support Legacy locations
elif [ -d ${SOURCE_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rf ${SOURCE_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rf ${SOURCE_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] ${SOURCE_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rf ${LEGACY_OP_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${LEGACY_OP_PATH}/prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC} ]; then
    cp -rf ${LEGACY_OP_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${LEGACY_OP_PATH}/config/apps_prop/${DEDICATE_OPERATOR_MCCMNC}/* ${TARGET_ETC_PATH}/"

elif [ -d ${SOURCE_PATH}/prop/${NTCODE} ]; then
    cp -rf ${SOURCE_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_PATH}/config/apps_prop/${NTCODE} ]; then
    cp -rf ${SOURCE_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/prop/${NTCODE} ]; then
    cp -rf ${LEGACY_OP_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${LEGACY_OP_PATH}/prop/${NTCODE}/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/config/apps_prop/${NTCODE} ]; then
    cp -rf ${LEGACY_OP_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${LEGACY_OP_PATH}/config/apps_prop/${NTCODE}/* ${TARGET_ETC_PATH}/"

elif [ -d ${SOURCE_PATH}/prop/FFF ]; then
    cp -rf ${SOURCE_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/"
elif [ -d ${SOURCE_PATH}/config/apps_prop/FFF ]; then
    cp -rf ${SOURCE_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/prop/FFF ]; then
    cp -rf ${LEGACY_OP_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${LEGACY_OP_PATH}/prop/FFF/* ${TARGET_ETC_PATH}/"
elif [ -d ${LEGACY_OP_PATH}/config/apps_prop/FFF ]; then
    cp -rf ${LEGACY_OP_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${LEGACY_OP_PATH}/config/apps_prop/FFF/* ${TARGET_ETC_PATH}/"
# TODO: Remove below lines from Q-OS - END

fi

# Restore sap_etc_symlink in MR
FIXED_FIRST_SIM_OPERATOR=`getprop persist.sys.sim.operator.first NODEF`
if [[ "$FIXED_FIRST_SIM_OPERATOR" != "NODEF" ]]; then
    if [ -d ${SOURCE_ETC_PATH}/${FIXED_FIRST_SIM_OPERATOR} ]; then
        cp -rf ${SOURCE_ETC_PATH}/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/
        log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_ETC_PATH}/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/"
# TODO: Remove below lines from Q-OS - START
    elif [ -d ${SOURCE_PATH}/prop/${FIXED_FIRST_SIM_OPERATOR} ]; then
        cp -rf ${SOURCE_PATH}/prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/
        log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/"
    elif [ -d ${SOURCE_PATH}/config/apps_prop/${FIXED_FIRST_SIM_OPERATOR} ]; then
        cp -rf ${SOURCE_PATH}/config/apps_prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/
        log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SOURCE_PATH}/config/apps_prop/${FIXED_FIRST_SIM_OPERATOR}/* ${TARGET_ETC_PATH}/"
# TODO: Remove below lines from Q-OS - END
    fi
fi

# Smart-CA configuration is top prioirty.
SMARTCA_ETC_PATH="/data/shared/cust/etc"
if [ -d ${SMARTCA_ETC_PATH} ];then
    cp -rf ${SMARTCA_ETC_PATH}/* ${TARGET_ETC_PATH}/
    log -p i -t ${LOG_TAG} "[SBP] cp -rf ${SMARTCA_ETC_PATH}/* ${TARGET_ETC_PATH}/"
fi

chown -R system:system ${TARGET_ETC_PATH}
chmod -R 644 ${TARGET_ETC_PATH}/*

# Change directory permission to get read
find ${TARGET_ETC_PATH} -type d -exec chmod 755 {} +

setprop persist.sys.laop.incremental ${CURRENT_BUILD_INCREMENTAL}

exit 0
