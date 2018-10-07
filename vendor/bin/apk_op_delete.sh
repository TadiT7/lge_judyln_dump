#!/vendor/bin/sh
TARGET_OPERATOR=`getprop persist.sys.target_operator`
TARGET_COUNTRY=`getprop persist.sys.target_country`
CUST_NEXT_ROOT=`getprop persist.sys.cupss.next-root`
CUST_NEXT_ROOT=${CUST_NEXT_ROOT##*/}
OP_INFO=`getprop persist.sys.op_info`
DELEGATE_BUYERCODE=`getprop sbp.lge.opname`
DELEGATE_NTCODE=`getprop persist.sys.ntcode`
MCCMNC_LIST=`getprop persist.sys.mccmnc-list`
SUBSET_LIST=`getprop persist.sys.subset-list`
IS_MULTISIM=`getprop ro.lge.sim_num`
DELAPK=`getprop ro.lge.capp_del_country_apk`
UI_BASE_CA=`getprop ro.build.ui_base_ca`
IS_CROSS_DOWNLOAD=`getprop ro.cross.download`
OP_ROOT_PATH=`getprop ro.lge.capp_cupss.op.dir`
PERSIST_LG_PATH="/persist-lg"

if [ "${OP_ROOT_PATH}" == "" ] || [ ! -d "${OP_ROOT_PATH}" ]; then
    OP_ROOT_PATH="/OP"
fi
OP_PRIV_APP_DIR="${OP_ROOT_PATH}/priv-app"
OP_APP_DIR="${OP_ROOT_PATH}/app"

echo "[SBP] CUST_NEXT_ROOT: ${CUST_NEXT_ROOT}"
echo "[SBP] persist.sys.target_operator : ${TARGET_OPERATOR}"
echo "[SBP] persist.sys.target_country : ${TARGET_COUNTRY}"
echo "[SBP] persist.sys.op_info: ${OP_INFO}"
echo "[SBP] persist.sys.ntcode: ${DELEGATE_NTCODE}"
echo "[SBP] persist.sys.mccmnc-list: ${MCCMNC_LIST}"
echo "[SBP] persist.sys.subset-list: ${SUBSET_LIST}"
echo "[SBP] ro.lge.sim_num: ${IS_MULTISIM}"
echo "[SBP] ro.lge.capp_del_country_apk: ${DELAPK}"
echo "[SBP] ro.build.ui_base_ca: ${UI_BASE_CA}"
echo "[SBP] ro.cross.download: ${IS_CROSS_DOWNLOAD}"

if [  "${DELEGATE_BUYERCODE}" != "" ]; then
    echo "[SBP] Excute Delte dummy resources by buyer code!"
    ITEM=${DELEGATE_BUYERCODE};
elif [ $CUST_NEXT_ROOT != "SUPERSET" ] && [ "${DELEGATE_NTCODE}" != "" ]; then
    echo "[SBP] Excute Delete dummy resources by ntcode!"
    ITEM=${OP_INFO}
fi

if [ $ITEM != "" ]; then
    if [ "${IS_CROSS_DOWNLOAD}" == "1" ]; then
        if [ $IS_MULTISIM == "1" ]; then
                if [ -d ${OP_ROOT_PATH}/${ITEM}_DS ]; then
                ITEM=${ITEM}_DS
                fi
        elif [ $IS_MULTISIM == "2" ]; then
                if [ -d ${OP_ROOT_PATH}/${ITEM} ]; then
                ITEM=${ITEM}
                fi
        fi
    else
        if [ $IS_MULTISIM == "2" ]; then
            if [ -d ${OP_ROOT_PATH}/${ITEM}_DS ]; then
                ITEM=${ITEM}_DS
            fi
        elif [ $IS_MULTISIM == "3" ]; then
            if [ -d ${OP_ROOT_PATH}/${ITEM}_TS ]; then
                ITEM=${ITEM}_TS
            fi
        fi
    fi

    setprop sbp.lge.opname $ITEM

    # Delete other operator dir
    DEL_ENTRY=`ls -F ${OP_ROOT_PATH} | grep / | tr -d /`
    for del_item in $DEL_ENTRY
    do
        if [ "$del_item" != "$ITEM" ] && [ "$del_item" != "lost+found" ] && [ "$del_item" != "_COMMON" ] && [ "$del_item" != "priv-app" ] && [ "$del_item" != "app" ]; then
            if [ -z $UI_BASE_CA ] || [ $del_item != $UI_BASE_CA ]; then
                rm -rf ${OP_ROOT_PATH}/$del_item
                echo "[SBP] rm -rf : OP/${del_item}"
                if [ -d "${OP_PRIV_APP_DIR}/$del_item" ]; then
                    rm -rf ${OP_PRIV_APP_DIR}/$del_item
                fi
                if [ -d "${OP_APP_DIR}/$del_item" ]; then
                    rm -rf ${OP_APP_DIR}/$del_item
                fi
            fi
        elif [ $del_item = $ITEM ] && [ "${DELAPK}" == "true" ]; then
            IS_SUPERSET_NTCODE=false
            # Check More than 1 NTcode status
            if [ "${#MCCMNC_LIST}" -gt 5 -a "${#SUBSET_LIST}" -gt 2 ]; then
                LAST_MCCMNC=${MCCMNC_LIST##*,}
                LAST_SUBSET=${SUBSET_LIST##*,}

                # Check Last NTCODE is SUPERSET
                if [ "${LAST_MCCMNC}" == 999999 -a "${LAST_SUBSET}" == 99 ]; then
                    IS_SUPERSET_NTCODE=true
                fi
            fi
            if [ "${IS_SUPERSET_NTCODE}" == false ]; then
                NTCODE_FILE_LIST_PATH=${PERSIST_LG_PATH}/tmo/file_list
                for del_apk_item in `ls ${OP_ROOT_PATH}/${ITEM}/apps`
                do
                    if [ "`grep -c $del_apk_item $NTCODE_FILE_LIST_PATH`" -eq "0" ]; then
                        rm -f ${OP_ROOT_PATH}/${ITEM}/apps/$del_apk_item
                        echo "[SBP] rm -rf : ${OP_ROOT_PATH}/${ITEM}/apps/${del_item}"
                    fi
                done
            fi
        fi
    done
fi

setprop persist.data.opdeletion 1

exit 0
