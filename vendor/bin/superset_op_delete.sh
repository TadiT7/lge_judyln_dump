#!/vendor/bin/sh

DELEGATE_NTCODE=`getprop persist.sys.ntcode`
SBP_VERSION=`getprop ro.build.sbp.version`
DEVICE_FINGERPRINT=`getprop ro.lge.fingerprint_sensor`
DEVICE_GYRO=`getprop ro.lge.gyro`
DEVICE_NFC=`getprop lge.nfc.vendor`

echo "[SBP] SUPERSET OP DELETE"
echo "[SBP] persist.sys.ntcode: ${DELEGATE_NTCODE}"
echo "[SBP] ro.build.sbp.version : ${SBP_VERSION}"
echo "[SBP] ro.lge.fingerprint_sensor : ${DEVICE_FINGERPRINT}"
echo "[SBP] ro.lge.gyro : ${DEVICE_GYRO}"
echo "[SBP] lge.nfc.vendor : ${DEVICE_NFC}"

#Change IT
OP_DIR=`getprop ro.lge.capp_cupss.op.dir`
if [ "${OP_DIR}" == "" ] || [ ! -d "${OP_DIR}" ]; then
    OP_DIR="/OP"
fi
OP_PRIV_APP_DIR=${OP_DIR}/priv-app/
OP_APP_DIR=${OP_DIR}/app/
SUPERSET_INFO_FILE=${OP_DIR}/_COMMON/SUPERSET_INFO.cfg
SUPERSET_NTCODE="\"1\",\"999,999,FFFFFFFF,FFFFFFFF,99\""

#Check SUPERSET Version by NTCODE
if [ "$DELEGATE_NTCODE" != "$SUPERSET_NTCODE" ]; then
    echo "[SBP]FINISH! This is not a SUPERSET version."
    exit 0
fi

#Get HW vari info
list=()
device_vari=""

enable=1
if [ "$DEVICE_FINGERPRINT" != 1 ]; then
    enable=0
fi
device_vari+="F"${enable}

enable=1
if [ "$DEVICE_GYRO" != 1 ]; then
    enable=0
fi
device_vari+="G"${enable}

enable=1
if [ "$DEVICE_NFC" == "none" ]; then
    enable=0
fi
device_vari+="N"${enable}

echo "[SBP] Device variation from properties : $device_vari"

# READ SUPERSET_INFO.cfg
while read line
do
    IFS='='
    first=($line)

    IFS=:
    second=(${first[1]})

    hwvari=${second[0]}

    if [ "$hwvari" == "$device_vari" ] ; then
        echo "[SBP] HW vari match! => $hwvari"
        IFS=,
        list=(${second[1]})
    fi
    unset IFS
#    echo $line
done < $SUPERSET_INFO_FILE

cupss_list_orig=($(ls -F $OP_DIR | grep / | tr -d /))
cupss_delete_list=()

# Set Removable Cupss list
for op in "${cupss_list_orig[@]}" ; do
    match=0

    if [ "SUPERSET" == "$op" ] || [ "_COMMON" == "$op" ] || [ "lost+found" == "$op" ] || [ "priv-app" == "$op" ] || [ "app" == "$op" ]; then
        match=1
        continue
    else
        for item in "${list[@]}" ; do
            if [ "$op" == "$item" ] ; then
                match=1
            fi
        done
    fi

    if [ "$match" != 1 ] ; then
        cupss_delete_list+=(${op})
    fi
done

#Must delete OPEN_RU in SUPERSET Version
cupss_delete_list+=("OPEN_RU")
cupss_delete_list+=("OPEN_RU_DS")

#dump
echo "[SBP] CUPSS list in SUPERSET_INFO.cfg : ${list[*]}"
echo "[SBP] Current CUPSS list in OP Partition :  ${cupss_list_orig[*]}"
echo "[SBP] Delete CUPSS list :  ${cupss_delete_list[*]}"

#Exceptional Case
# OPEN_RU

# Remove
for del_item in "${cupss_delete_list[@]}" ; do
    rm -rf $OP_DIR/$del_item
    echo "[SBP] rm -rf : OP/${del_item}"
    rm -rf $OP_PRIV_APP_DIR$del_item
    echo "[SBP] rm -rf : OP/priv-app/${del_item}"
    rm -rf $OP_APP_DIR$del_item
    echo "[SBP] rm -rf : OP/app/${del_item}"
done

exit 0
