#!/vendor/bin/sh
if [ -d /system/OP ]; then
    # If it is using bootanim at system partition, then we can skip all.
    setprop persist.sys.ntcode_list 1
    exit 0;
fi

OPERATOR=`getprop ro.build.target_operator`
COUNTRY=`getprop ro.build.target_country`
BUILD_TYPE=`getprop ro.build.type`
DCOUNTRY=`getprop ro.build.default_country`
UI_BASE_CA=`getprop ro.build.ui_base_ca`
MCC=`getprop persist.sys.ntcode`
FIRSTPOWERON=`getprop persist.radio.first-mccmnc`
LGBOOTANIM=`getprop ro.lge.firstboot.openani`
CUPSS_ROOT_DIR=`getprop ro.lge.capp_cupss.rootdir`
CUPSS_PROP_FILE=`getprop persist.sys.cupss.subca-prop`
CUPSS_CHANGED=`getprop persist.sys.cupss.changed`
IS_COTA_CHANGED=`getprop persist.sys.cota.changed`
IS_MULTISIM=`getprop ro.lge.sim_num`
SBP_VERSION=`getprop ro.build.sbp.version`
OP_PRELOAD_TYPE=`getprop ro.lge.sbp.op_preloadtype`
OP_INTEGRATION=`getprop ro.lge.op.integration`
OP_ROOT_PATH=`getprop ro.lge.capp_cupss.op.dir`
IS_LIVE_DEMO_UNIT=`getprop persist.LiveDemoUnit`


if [ "$OP_INTEGRATION" == "1" ]; then
    CUPSS_DEFAULT_PATH=$OP_ROOT_PATH
    RES_PATH=_SMARTCA_RES
    if [ "$OP_ROOT_PATH" == "/OP" ]; then
        COTA_RES_ROOT_PATH=$CUPSS_DEFAULT_PATH
    else
        COTA_RES_ROOT_PATH=/vendor/carrier
    fi
else
    OP_ROOT_PATH=/OP
    CUPSS_DEFAULT_PATH=/cust
    RES_PATH=_COTA_RES
fi

MCC=${MCC#*,}
MCC=${MCC:1:3}

USER_BOOTANIMATION_FILE=/data/local/bootanimation.zip
USER_BOOTANIMATION_SOUND_FILE=/data/local/PowerOn.ogg
USER_SHUTDOWNANIMATION_FILE=/data/local/shutdownanimation.zip
USER_SHUTDOWNANIMATION_SOUND_FILE=/data/local/PowerOff.ogg
USER_APP_MANAGER_INSTALLATION_FILE=/data/local/app-ntcode-conf.json

COTA_BOOTANIMATION_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/bootanimation.zip
COTA_BOOTANIMATION_SOUND_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/PowerOn.ogg
COTA_SHUTDOWNANIMATION_FILE=/data/shared/cust/shutdownanimation.zip
COTA_SHUTDOWNANIMATION_SOUND_FILE=/data/shared/cust/PowerOff.ogg

if [ "${DCOUNTRY}" != "" ]; then
    if [ "${UI_BASE_CA}" != "" ]; then
        SUBCA_FILE=${UI_BASE_CA}/${DCOUNTRY}
    else
        if [ $IS_MULTISIM == "2" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS/${DCOUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}/${DCOUNTRY}
            fi
        elif [ $IS_MULTISIM == "3" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_TS/${DCOUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}/${DCOUNTRY}
            fi
        else
            SUBCA_FILE=${OPERATOR}_${COUNTRY}/${DCOUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                if [ -d ${CUPSS_DEFAULT_PATH}/${OPERATOR}_${COUNTRY}_DS/${DCOUNTRY} ]; then
                    SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS/${DCOUNTRY}
                fi
            fi
        fi
    fi
else
    if [ "${UI_BASE_CA}" != "" ]; then
        SUBCA_FILE=${UI_BASE_CA}
    else
        if [ $IS_MULTISIM == "2" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}
            fi
        elif [ $IS_MULTISIM == "3" ]; then
            SUBCA_FILE=${OPERATOR}_${COUNTRY}_TS
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                SUBCA_FILE=${OPERATOR}_${COUNTRY}
            fi
        else
            SUBCA_FILE=${OPERATOR}_${COUNTRY}
            SUBCA_FILE=${OPERATOR}_${COUNTRY}
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                if [ -d ${CUPSS_DEFAULT_PATH}/${OPERATOR}_${COUNTRY}_DS ]; then
                    SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS
                fi
            fi
        fi
    fi
fi

if [ ! -d ${COTA_RES_ROOT_PATH}/${RES_PATH} ]; then
    if [ $(ls /data/shared/cust/bootanimation.zip) ]; then
        if [ "$OP_INTEGRATION" == "1" ]; then
            setprop persist.sys.smartca.changed 1
        else
            setprop persist.sys.cota.changed 1
        fi
    fi
fi

if [ -d $OP_ROOT_PATH ]; then
    ANI_ROOT_PATH=$OP_ROOT_PATH
    DOWNCA_APP_MANAGER_INSTALLATION_FILE=$OP_ROOT_PATH/_COMMON/app-enabled-conf.json
else
    ANI_ROOT_PATH=data/.OP
    chown -R system:system /data/.OP
    chmod -R 0771 /data/.OP
    chmod -R 0644 /data/.OP/$SUBCA_FILE/power*/*
    chmod -R 0755 /data/.OP/apps/*
    chmod -R 0755 /data/.OP/*/apps/*
    chmod -R 0644 /data/.OP/*/prop
    chmod 0644 /data/.OP/app-enabled-conf.json
    DOWNCA_APP_MANAGER_INSTALLATION_FILE=/data/.OP/app-enabled-conf.json
fi

if [ -d /data/preload ]; then
chown -R system:system /data/preload
chmod 775 /data/preload/*
chmod 755 /data/preload/*/*
fi
if [ -d /data/media/0/Preload ]; then
chown -R media_rw:media_rw /data/media/0/Preload
chmod 775 /data/media/0/Preload
chmod 775 /data/media/0/Preload/LG
fi
chmod 755 /data/shared
chmod 755 /data/local/cust

if [ $CUPSS_ROOT_DIR == "/data/local/cust" ]; then
    if [ ! -d ${CUPSS_ROOT_DIR} ]; then
        mkdir ${CUPSS_ROOT_DIR}
        chmod 755 ${CUPSS_ROOT_DIR}
    fi

    if [ ${CUPSS_CHANGED} == "1" ]; then
        if [ ! -d ${CUPSS_ROOT_DIR}/prev ]; then
            mkdir ${CUPSS_ROOT_DIR}/prev
            chmod 755 ${CUPSS_ROOT_DIR}/prev
        fi
        mv -f ${CUPSS_ROOT_DIR}/* ${CUPSS_ROOT_DIR}/prev
    fi

    if [[ $CUPSS_PROP_FILE == *"/OPEN_COM_DS/"* ]]; then
        OPEN_PATH=${CUPSS_DEFAULT_PATH}/OPEN_COM_DS
    elif [[ $CUPSS_PROP_FILE == *"/OPEN_COM_TS/"* ]]; then
        OPEN_PATH=${CUPSS_DEFAULT_PATH}t/OPEN_COM_TS
    else
        OPEN_PATH=${CUPSS_DEFAULT_PATH}/OPEN_COM
    fi

    CUPSS_SUBCA=${CUPSS_PROP_FILE##*cust_}
    CUPSS_SUBCA=${CUPSS_SUBCA%.prop}
    CUPSS_CA=${CUPSS_SUBCA%_*}

    DIRLIST=$(ls ${OPEN_PATH})
    for DIR in ${DIRLIST}; do
        if [ -d ${OPEN_PATH}/${DIR} ]; then
            DIRNAME=${DIR#_}
            if [ -h ${CUPSS_ROOT_DIR}/${DIRNAME} ] || [ ! -d ${CUPSS_ROOT_DIR}/${DIRNAME} ]; then
                if [ -d ${OPEN_PATH}/${DIR}/${DIRNAME}_${CUPSS_SUBCA} ]; then
                    ln -sfn ${OPEN_PATH}/${DIR}/${DIRNAME}_${CUPSS_SUBCA} ${CUPSS_ROOT_DIR}/${DIRNAME}
                else
                    ln -sfn ${OPEN_PATH}/${DIR}/${DIRNAME}_${CUPSS_CA} ${CUPSS_ROOT_DIR}/${DIRNAME}
                fi
            fi
        fi
    done
fi

HYDRA_PROP=`getprop ro.lge.hydra NONE`
HYDRA_PROP_LOWERCASE=`echo $HYDRA_PROP | tr [:upper:] [:lower:]`
BOOTANIM_SRC_DIR="${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron"
DOWNCA_BOOTANIMATION_FILE=${BOOTANIM_SRC_DIR}/bootanimation.zip

for BOOTANIM_FILE in $(ls $BOOTANIM_SRC_DIR | grep bootanimation); do
    HYDRA_BOOTANIMATION_FILE=`echo $BOOTANIM_FILE | grep ${HYDRA_PROP}.zip`
    HYDRA_BOOTANIMATION_FILE_LOWERCASE=`echo $BOOTANIM_FILE | grep ${HYDRA_PROP_LOWERCASE}.zip`
    if [ "$HYDRA_BOOTANIMATION_FILE" == "$BOOTANIM_FILE" ] || [ "$HYDRA_BOOTANIMATION_FILE_LOWERCASE" == "$BOOTANIM_FILE" ]; then
        DOWNCA_BOOTANIMATION_FILE=${BOOTANIM_SRC_DIR}/$BOOTANIM_FILE
    fi
done

DOWNCA_BOOTANIMATION_MCC_FILE=$BOOTANIM_SRC_DIR/bootanimation_${MCC}.zip
for BOOTANIM_MCC_FILE in $(ls $BOOTANIM_SRC_DIR | grep bootanimation | grep ${MCC}); do
    HYDRA_BOOTANIMATION_MCC_FILE=`echo $BOOTANIM_MCC_FILE | grep $HYDRA_PROP`
    HYDRA_BOOTANIMATION_MCC_FILE_LOWERCASE=`echo $BOOTANIM_MCC_FILE | grep $HYDRA_PROP_LOWERCASE`
    if [ "$HYDRA_BOOTANIMATION_MCC_FILE" == "$BOOTANIM_MCC_FILE" ] || [ "$HYDRA_BOOTANIMATION_MCC_FILE_LOWERCASE" == "$BOOTANIM_MCC_FILE" ]; then
        DOWNCA_BOOTANIMATION_MCC_FILE=${BOOTANIM_SRC_DIR}/$BOOTANIM_MCC_FILE
    fi
done

if [ -f $DOWNCA_BOOTANIMATION_MCC_FILE ]; then
    DOWNCA_BOOTANIMATION_FILE=$DOWNCA_BOOTANIMATION_MCC_FILE
fi

if [ "$LGBOOTANIM" == "true" -a "$FIRSTPOWERON" == "" ]; then
    DOWNCA_BOOTANIMATION_FILE=""
fi

log -p i -t runtime_boot_res "DOWNCA_BOOTANIMATION_FILE = $DOWNCA_BOOTANIMATION_FILE"

if [ $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn_${MCC}.ogg | grep PowerOn_${MCC}.ogg) ]; then
    if [ $LGBOOTANIM != "" ] && [ $LGBOOTANIM == "true" ]; then
        if [ $FIRSTPOWERON != "" ]; then
            DOWNCA_BOOTANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn_${MCC}.ogg
        fi
    else
        DOWNCA_BOOTANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn_${MCC}.ogg
    fi

else
    DOWNCA_BOOTANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn.ogg
fi

if [ $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/shutdownanimation_${MCC}.zip | grep shutdownanimation_${MCC}.zip) ]; then
    if [ $LGBOOTANIM != "" ] && [ $LGBOOTANIM == "true" ]; then
        if [ $FIRSTPOWERON != "" ]; then
            DOWNCA_SHUTDOWNANIMATION_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/shutdownanimation_${MCC}.zip
        fi
    else
        DOWNCA_SHUTDOWNANIMATION_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/shutdownanimation_${MCC}.zip
    fi

else
    DOWNCA_SHUTDOWNANIMATION_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/shutdownanimation.zip
fi

if [ $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/PowerOff_${MCC}.ogg | grep PowerOff_${MCC}.ogg) ]; then
    if [ $LGBOOTANIM != "" ] && [ $LGBOOTANIM == "true" ]; then
        if [ $FIRSTPOWERON != "" ]; then
            DOWNCA_SHUTDOWNANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/PowerOff_${MCC}.ogg
        fi
    else
        DOWNCA_SHUTDOWNANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/PowerOff_${MCC}.ogg
    fi

else
    DOWNCA_SHUTDOWNANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/PowerOff.ogg
fi

if [ $OPERATOR != "GLOBAL" -a $OPERATOR != "LAO" ]; then

    rm $USER_BOOTANIMATION_FILE
    rm $USER_BOOTANIMATION_SOUND_FILE
    rm $USER_SHUTDOWNANIMATION_FILE
    rm $USER_SHUTDOWNANIMATION_SOUND_FILE

    if [ -f $DOWNCA_BOOTANIMATION_FILE ]; then
        if [ ! $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/nobootani_${MCC}.open) ]; then
            ln -s $DOWNCA_BOOTANIMATION_FILE $USER_BOOTANIMATION_FILE
        fi
    fi

    if [ -f $DOWNCA_BOOTANIMATION_SOUND_FILE ]; then
        if [ ! $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/nobootani_sound_${MCC}.open) ]; then
            ln -s $DOWNCA_BOOTANIMATION_SOUND_FILE $USER_BOOTANIMATION_SOUND_FILE
        fi
    fi

    if [ -f $DOWNCA_SHUTDOWNANIMATION_FILE ]; then
        if [ ! $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/noshutdownani_${MCC}.open) ]; then
            ln -s $DOWNCA_SHUTDOWNANIMATION_FILE $USER_SHUTDOWNANIMATION_FILE
        fi
    fi

    if [ -f $DOWNCA_SHUTDOWNANIMATION_SOUND_FILE ]; then
        if [ ! $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweroff/noshutdownani_sound_${MCC}.open) ]; then
            ln -s $DOWNCA_SHUTDOWNANIMATION_SOUND_FILE $USER_SHUTDOWNANIMATION_SOUND_FILE
        fi
    fi

    if [ -f $COTA_BOOTANIMATION_FILE ]; then
        ln -sf $COTA_BOOTANIMATION_FILE $USER_BOOTANIMATION_FILE
    fi

    if [ -f $COTA_BOOTANIMATION_SOUND_FILE ]; then
        ln -sf $COTA_BOOTANIMATION_SOUND_FILE $USER_BOOTANIMATION_SOUND_FILE
    fi

    if [ -f $COTA_SHUTDOWNANIMATION_FILE ]; then
        ln -sf $COTA_SHUTDOWNANIMATION_FILE $USER_SHUTDOWNANIMATION_FILE
    fi

    if [ -f $COTA_SHUTDOWNANIMATION_SOUND_FILE ]; then
        ln -sf $COTA_SHUTDOWNANIMATION_SOUND_FILE $USER_SHUTDOWNANIMATION_SOUND_FILE
    fi

else
    rm $USER_APP_MANAGER_INSTALLATION_FILE
    if [ -f $DOWNCA_APP_MANAGER_INSTALLATION_FILE ]; then
        ln -sf $DOWNCA_APP_MANAGER_INSTALLATION_FILE $USER_APP_MANAGER_INSTALLATION_FILE
    fi
fi

#Single CA Google submission
if [ $OPERATOR != "GLOBAL" -a $OPERATOR != "LAO" ]; then
    rm -f $USER_APP_MANAGER_INSTALLATION_FILE

    SINGLECA_ENABLE=`getprop ro.lge.singleca.enable`
    SINGLECA_SUBMIT=`getprop ro.lge.singleca.submit`
    if [ "${SINGLECA_ENABLE}" == "1" -a "${SINGLECA_SUBMIT}" == "1" ]; then
        if [ -f $DOWNCA_APP_MANAGER_INSTALLATION_FILE ]; then
            ln -sf $DOWNCA_APP_MANAGER_INSTALLATION_FILE $USER_APP_MANAGER_INSTALLATION_FILE
        fi
    fi
fi

CUST_AUDIO_PATH=${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/media/audio
CUST_RINGTONE_PATH=${CUST_AUDIO_PATH}/ringtones
CUST_NOTIFICATION_PATH=${CUST_AUDIO_PATH}/notifications
CUST_ALARM_ALERT_PATH=${CUST_AUDIO_PATH}/alarms

USER_MEDIA_PATH=/data/local/media
USER_AUDIO_PATH=/${USER_MEDIA_PATH}/audio
USER_RINGTONE_PATH=${USER_AUDIO_PATH}/ringtones
USER_NOTIFICATION_PATH=${USER_AUDIO_PATH}/notifications
USER_ALARM_ALERT_PATH=${USER_AUDIO_PATH}/alarms

rm -rf $USER_MEDIA_PATH

IS_SUBCA_EXIST=$(ls -R ${CUST_AUDIO_PATH} | grep "\_[0-9]\{3\}\.")
if [ $? -eq 0 ]; then
    mkdir -p $USER_AUDIO_PATH
    mkdir $USER_RINGTONE_PATH
    mkdir $USER_NOTIFICATION_PATH
    mkdir $USER_ALARM_ALERT_PATH
    chmod 755 $USER_MEDIA_PATH
    chmod 755 -R $USER_MEDIA_PATH/*
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    if [ -d ${CUST_RINGTONE_PATH} ]; then
        if [ ! $(ls ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/config/noringtone.open) ]; then
        CUST_RINGTONE_FILES=$(ls ${CUST_RINGTONE_PATH} | grep ${MCC})
        if [ $? -eq 0 ]; then
            for CUST_RINGTONE_FILE in ${CUST_RINGTONE_FILES}; do
                    RINGTONE_EXTENTION=${CUST_RINGTONE_FILE##*.}
                    RINGTONE_FILE_NAME=${CUST_RINGTONE_FILE%%_${MCC}*}
                    cp -p ${CUST_RINGTONE_PATH}/${CUST_RINGTONE_FILE} ${USER_RINGTONE_PATH}/${RINGTONE_FILE_NAME}.${RINGTONE_EXTENTION}
            done
        else
            RINGTONE_FILES=$(ls ${CUST_RINGTONE_PATH} | grep -v "\_[0-9]\{3\}\.")
            if [ $? -eq 0 ]; then
                for RINGTONE_FILE in ${RINGTONE_FILES}; do
                    cp -p ${CUST_RINGTONE_PATH}/${RINGTONE_FILE} ${USER_RINGTONE_PATH}/${RINGTONE_FILE}
                done
            fi
        fi
    fi
    fi
    if [ -d ${CUST_NOTIFICATION_PATH} ]; then
        if [ ! $(ls ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/config/nonotification.open) ]; then
        CUST_NOTIFICATION_FILES=$(ls ${CUST_NOTIFICATION_PATH} | grep ${MCC})
        if [ $? -eq 0 ]; then
            for CUST_NOTIFICATION_FILE in ${CUST_NOTIFICATION_FILES}; do
                    NOTIFICATION_EXTENTION=${CUST_NOTIFICATION_FILE##*.}
                    NOTIFICATION_FILE_NAME=${CUST_NOTIFICATION_FILE%%_${MCC}*}
                    cp -p ${CUST_NOTIFICATION_PATH}/${CUST_NOTIFICATION_FILE} ${USER_NOTIFICATION_PATH}/${NOTIFICATION_FILE_NAME}.${NOTIFICATION_EXTENTION}
            done
        else
            NOTIFICATION_FILES=$(ls ${CUST_NOTIFICATION_PATH} | grep -v "\_[0-9]\{3\}\.")
            if [ $? -eq 0 ]; then
                for NOTIFICATION_FILE in ${NOTIFICATION_FILES}; do
                    cp -p ${CUST_NOTIFICATION_PATH}/${NOTIFICATION_FILE} ${USER_NOTIFICATION_PATH}/${NOTIFICATION_FILE}
                done
            fi
        fi
        fi
    fi
    if [ -d ${CUST_ALARM_ALERT_PATH} ]; then
        if [ ! $(ls ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE}/config/noalarm.open) ]; then
        CUST_ALARM_ALERT_FILES=$(ls ${CUST_ALARM_ALERT_PATH} | grep ${MCC})
        if [ $? -eq 0 ]; then
            for CUST_ALARM_ALERT_FILE in ${CUST_ALARM_ALERT_FILES}; do
                    ALARM_ALERT_EXTENTION=${CUST_ALARM_ALERT_FILE##*.}
                    ALARM_ALERT_FILE_NAME=${CUST_ALARM_ALERT_FILE%%_${MCC}*}
                    cp -p ${CUST_ALARM_ALERT_PATH}/${CUST_ALARM_ALERT_FILE} ${USER_ALARM_ALERT_PATH}/${ALARM_ALERT_FILE_NAME}.${ALARM_ALERT_EXTENTION}
            done
        else
            ALARM_ALERT_FILES=$(ls ${CUST_ALARM_ALERT_PATH} | grep -v "\_[0-9]\{3\}\.")
            if [ $? -eq 0 ]; then
                for ALARM_ALERT_FILE in ${ALARM_ALERT_FILES}; do
                    cp -p ${CUST_ALARM_ALERT_PATH}/${ALARM_ALERT_FILE} ${USER_ALARM_ALERT_PATH}/${ALARM_ALERT_FILE}
                done
            fi
        fi
        fi
    fi
    IFS=$SAVEIFS
fi

# Preload Contents (Loaded and removable)
OP_PRELOAD_DIR=("$OP_ROOT_PATH/_COMMON/media/Preload"
                "$OP_ROOT_PATH/_COMMON/media/Preload/LG"
                "$CUPSS_ROOT_DIR/media/Preload"
                "$CUPSS_ROOT_DIR/media/Preload/LG")
OP_PRELOAD_DONE="/data/system/op_preload_done.ini"
PRELOAD_LINK_LOCATION_DIR="/data/media/0/Preload"
if [ ${SBP_VERSION} -gt "30" ]; then
    if [ ! -f ${OP_PRELOAD_DONE} ]; then
        mkdir -p ${PRELOAD_LINK_LOCATION_DIR}
        for PRELOAD_SUB_DIR in ${OP_PRELOAD_DIR[@]}; do
            if [ -d ${PRELOAD_SUB_DIR} ]; then
                PRELOAD_LIST=$(ls ${PRELOAD_SUB_DIR})
                for PRELOAD_ITEM in ${PRELOAD_LIST}; do
                    if [ -f ${PRELOAD_SUB_DIR}/${PRELOAD_ITEM} ]; then
                        if [ "${OP_PRELOAD_TYPE}" == "copy" ]; then
                            cp -rf ${PRELOAD_SUB_DIR}/${PRELOAD_ITEM} ${PRELOAD_LINK_LOCATION_DIR}/${PRELOAD_ITEM}
                        else
                            ln -sfn ${PRELOAD_SUB_DIR}/${PRELOAD_ITEM} ${PRELOAD_LINK_LOCATION_DIR}/${PRELOAD_ITEM}
                        fi
                    fi
                done
            fi
        done

        chown -R media_rw:media_rw ${PRELOAD_LINK_LOCATION_DIR}
        chmod -R 0775 ${PRELOAD_LINK_LOCATION_DIR}
        echo "op_preload_done" > ${OP_PRELOAD_DONE}
    fi
fi

if [ "${IS_LIVE_DEMO_UNIT}" == "1" ]; then
    # Common, Custom Retail Contents (Loaded and resetting when rebooting)
    IS_BY_LDU_RES=`getprop sys.lge.runtime_ldu_res`

    # 1. Create Preload Directory
    PRELOAD_LINK_LOCATION_DIR="/data/media/0/Preload"
    mkdir -p ${PRELOAD_LINK_LOCATION_DIR}
    chown -R media_rw:media_rw ${PRELOAD_LINK_LOCATION_DIR}
    chmod -R 0775 ${PRELOAD_LINK_LOCATION_DIR}

    RETAIL_CONTENTS_OP_DIR=$OP_ROOT_PATH/_COMMON/media/Preload/RetailContents
    RETAIL_CONTENTS_CUST_DIR=${CUPSS_ROOT_DIR}/media/RetailContents
    RETAIL_CONTENTS_LN_DIR="/data/media/0/Preload/RetailContents"
    RETAIL_CONTENTS_LIST=("audio" "image" "movie" "product")
    RETAIL_CONTENTS_HIDELIST=("screensaver")
    #2. Create RetailContents Directory
    mkdir -p ${RETAIL_CONTENTS_LN_DIR}

    #3. Remove Old RetailContents Files (only when booting)
    if [ "${IS_BY_LDU_RES}" == "1" ]; then
        echo "only restore removed contents"
    else
        rm -rf ${RETAIL_CONTENTS_LN_DIR}/*
        rm -rf ${RETAIL_CONTENTS_LN_DIR}/.*
    fi

    #4. Symlink RetailContents
    if [ -d ${RETAIL_CONTENTS_OP_DIR} ]; then
        for ITEM_DIR in ${RETAIL_CONTENTS_LIST[@]}; do
            if [ ! -d ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR} ]; then
                mkdir -p ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR}
            fi
            ITEMLIST=$(ls ${RETAIL_CONTENTS_OP_DIR}/${ITEM_DIR})
            for ITEM in ${ITEMLIST}; do
                if [ ! -f  ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR}/${ITEM} ]; then
                    ln -sfn ${RETAIL_CONTENTS_OP_DIR}/${ITEM_DIR}/${ITEM} ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR}/${ITEM}
                fi
            done
        done
        for ITEM_DIR in ${RETAIL_CONTENTS_HIDELIST[@]}; do
            if [ ! -d ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR} ]; then
                mkdir -p ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR}
            fi
            ITEMLIST=$(ls ${RETAIL_CONTENTS_OP_DIR}/${ITEM_DIR})
            for ITEM in ${ITEMLIST}; do
                if [ ! -f  ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR}/${ITEM} ]; then
                    ln -sfn ${RETAIL_CONTENTS_OP_DIR}/${ITEM_DIR}/${ITEM} ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR}/${ITEM}
                fi
            done
        done
    fi
    if [ -d ${RETAIL_CONTENTS_CUST_DIR} ]; then
        for ITEM_DIR in ${RETAIL_CONTENTS_LIST[@]}; do
            if [ ! -d ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR} ]; then
                mkdir -p ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR}
            fi
            ITEMLIST=$(ls ${RETAIL_CONTENTS_CUST_DIR}/${ITEM_DIR})
            for ITEM in ${ITEMLIST}; do
                if [ ! -f  ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR}/${ITEM} ]; then
                    ln -sfn ${RETAIL_CONTENTS_CUST_DIR}/${ITEM_DIR}/${ITEM} ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR}/${ITEM}
                fi
            done
        done
        for ITEM_DIR in ${RETAIL_CONTENTS_HIDELIST[@]}; do
            if [ ! -d ${RETAIL_CONTENTS_LN_DIR}/${ITEM_DIR} ]; then
                mkdir -p ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR}
            fi
            ITEMLIST=$(ls ${RETAIL_CONTENTS_CUST_DIR}/${ITEM_DIR})
            for ITEM in ${ITEMLIST}; do
                if [ ! -f  ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR}/${ITEM} ]; then
                    ln -sfn ${RETAIL_CONTENTS_CUST_DIR}/${ITEM_DIR}/${ITEM} ${RETAIL_CONTENTS_LN_DIR}/.${ITEM_DIR}/${ITEM}
                fi
            done
        done
    fi

    #5. Permisison Setting
    if [ -d ${RETAIL_CONTENTS_LN_DIR} ]; then
        chown -R media_rw:media_rw ${RETAIL_CONTENTS_LN_DIR}
        chmod -R 0775 ${RETAIL_CONTENTS_LN_DIR}
    fi
    setprop sys.lge.runtime_ldu_res 0
fi


setprop persist.sys.ntcode_list 1

exit 0
