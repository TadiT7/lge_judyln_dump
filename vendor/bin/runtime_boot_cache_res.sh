#!/vendor/bin/sh
if [ -d /system/OP ]; then
    # If it is using bootanim at system partition, then we can skip all.
    exit 0;
fi

OPERATOR=`getprop ro.build.target_operator`
COUNTRY=`getprop ro.build.target_country`
BUILD_TYPE=`getprop ro.build.type`
DCOUNTRY=`getprop ro.build.default_country`
UI_BASE_CA=`getprop ro.build.ui_base_ca`
MCC=`getprop ro.lge.ntcode_mcc`
LGBOOTANIM=`getprop ro.lge.firstboot.openani`
IS_MULTISIM=`getprop ro.lge.sim_num`
OP_INTEGRATION=`getprop ro.lge.op.integration`
OP_ROOT_PATH=`getprop ro.lge.capp_cupss.op.dir`
PERSIST_LG_PATH="/vendor/persist-lg"

if [ "${OP_ROOT_PATH}" == "" ] || [ ! -d "${OP_ROOT_PATH}" ]; then
    OP_ROOT_PATH="/OP"
fi
if [ ! -d "${PERSIST_LG_PATH}" ] || [ -L "${PERSIST_LG_PATH}" ]; then
    PERSIST_LG_PATH="/persist-lg"
fi

if [ "${OP_INTEGRATION}" == "1" ]; then
    CUPSS_DEFAULT_PATH=${OP_ROOT_PATH}
    RES_PATH=_SMARTCA_RES
    if [ "${OP_ROOT_PATH}" == "/OP" ]; then
        COTA_RES_ROOT_PATH=${CUPSS_DEFAULT_PATH}
    else
        COTA_RES_ROOT_PATH=/vendor/carrier
    fi
else
    CUPSS_DEFAULT_PATH=/cust
    COTA_RES_ROOT_PATH=${CUPSS_DEFAULT_PATH}
    RES_PATH=_COTA_RES
fi

SYSTEM_BOOTANIMATION_FILE=/system/media/bootanimation.zip
SYSTEM_BOOTANIMATION_SOUND_FILE=/system/media/audio/ui/PowerOn.ogg
CACHE_BOOTANIMATION_FILE=${PERSIST_LG_PATH}/poweron/bootanimation.zip
CACHE_BOOTANIMATION_SOUND_FILE=${PERSIST_LG_PATH}/poweron/PowerOn.ogg
COTA_BOOTANIMATION_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/bootanimation.zip
COTA_BOOTANIMATION_SOUND_FILE=${COTA_RES_ROOT_PATH}/${RES_PATH}/PowerOn.ogg

if [ -d ${OP_ROOT_PATH} ]; then
    ANI_ROOT_PATH=${OP_ROOT_PATH}
else
    ANI_ROOT_PATH="/cust"
fi

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
            if [ ! -d ${CUPSS_DEFAULT_PATH}/${SUBCA_FILE} ]; then
                if [ -d ${CUPSS_DEFAULT_PATH}/${OPERATOR}_${COUNTRY}_DS ]; then
                    SUBCA_FILE=${OPERATOR}_${COUNTRY}_DS
                fi
            fi
        fi
    fi
fi

#mkdir ${PERSIST_LG_PATH}/poweron 0771 system system
#chown -R system:sytem ${PERSIST_LG_PATH}/poweron
#chmod -R 0775 ${PERSIST_LG_PATH}poweron

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

log -p i -t runtime_boot_cache_res.sh "DOWNCA_BOOTANIMATION_FILE = $DOWNCA_BOOTANIMATION_FILE"

if [ $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn_${MCC}.ogg | grep PowerOn_${MCC}.ogg) ]; then
    if [ $LGBOOTANIM != "" ] && [ $LGBOOTANIM == "true" ]; then
        DOWNCA_BOOTANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn_${MCC}.ogg
    else
        DOWNCA_BOOTANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn_${MCC}.ogg
    fi

else
    DOWNCA_BOOTANIMATION_SOUND_FILE=${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/PowerOn.ogg
fi

if [ $OPERATOR != "GLOBAL" -a $OPERATOR != "LAO" ]; then
    if [ -f $COTA_BOOTANIMATION_FILE ]; then
        ln -sf $COTA_BOOTANIMATION_FILE $CACHE_BOOTANIMATION_FILE
    elif [ -f $DOWNCA_BOOTANIMATION_FILE ]; then
        if [ $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/nobootani_${MCC}.open) ]; then
            ln -sf $SYSTEM_BOOTANIMATION_FILE $CACHE_BOOTANIMATION_FILE
        else
            ln -sf $DOWNCA_BOOTANIMATION_FILE $CACHE_BOOTANIMATION_FILE
        fi
    else
        rm $CACHE_BOOTANIMATION_FILE
    fi

    if [ -f $COTA_BOOTANIMATION_SOUND_FILE ]; then
        ln -sf $COTA_BOOTANIMATION_SOUND_FILE $CACHE_BOOTANIMATION_SOUND_FILE
    elif [ -f $DOWNCA_BOOTANIMATION_SOUND_FILE ]; then
        if [ $(ls ${ANI_ROOT_PATH}/${SUBCA_FILE}/poweron/nobootani_sound_${MCC}.open) ]; then
            ln -sf $SYSTEM_BOOTANIMATION_SOUND_FILE $CACHE_BOOTANIMATION_SOUND_FILE
        else
            ln -sf $DOWNCA_BOOTANIMATION_SOUND_FILE $CACHE_BOOTANIMATION_SOUND_FILE
        fi
    else
        rm $CACHE_BOOTANIMATION_SOUND_FILE
    fi
else
    rm $CACHE_BOOTANIMATION_FILE
    rm $CACHE_BOOTANIMATION_SOUND_FILE
fi
exit 0
