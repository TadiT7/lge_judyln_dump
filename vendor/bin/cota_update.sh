#!/vendor/bin/sh

OPERATOR=`getprop ro.build.target_operator`
COTA_FLAG=`getprop persist.sys.cota.changed`
SMARTCA_FLAG=`getprop persist.sys.smartca.changed`
OP_INTEGRATION=`getprop ro.lge.op.integration`
OP_ROOT_PATH=`getprop ro.lge.capp_cupss.op.dir`

if [ "$OP_INTEGRATION" == "1" ]; then
    if [ "$OP_ROOT_PATH" == "/OP" ]; then
        CUPSS_DEFAULT_PATH=/OP
    else
        CUPSS_DEFAULT_PATH=/vendor/carrier
    fi
    RES_PATH=_SMARTCA_RES
else
    CUPSS_DEFAULT_PATH=/cust
    RES_PATH=_COTA_RES
fi

if [ "$COTA_FLAG" == "2" ]; then
    # set 3 to distinguish cota task done
    setprop persist.sys.cota.changed 3
    exit 0
fi

if [ "$SMARTCA_FLAG" == "2" ]; then
    # set 3 to distinguish cota task done
    setprop persist.sys.smartca.changed 3
    exit 0
fi

if [ $OPERATOR == "GLOBAL" -a "$COTA_FLAG" == "1" ]; then
    # In case of SUPERSET in MID process,
    # prevent copying cota bootanimation, in ResourcePackageManagmer, to cust.
    setprop persist.sys.cota.changed 2
    exit 0
fi

if [ $OPERATOR == "GLOBAL" -a "$SMARTCA_FLAG" == "1" ]; then
    # In case of SUPERSET in MID process,
    # prevent copying smartca bootanimation, in ResourcePackageManagmer, to OP.
    setprop persist.sys.smartca.changed 2
    exit 0
fi

chown -R system:system /data/shared/cust
chmod 775 /data/shared/cust
chmod 775 /data/shared/cust/*

chown -R system:system ${CUPSS_DEFAULT_PATH}/${RES_PATH}
chmod 775 ${CUPSS_DEFAULT_PATH}/${RES_PATH}
chmod 775 ${CUPSS_DEFAULT_PATH}/${RES_PATH}/*

if [ $(ls /data/shared/cust/PowerOn.ogg) ]; then
    cp -pf /data/shared/cust/PowerOn.ogg ${CUPSS_DEFAULT_PATH}/${RES_PATH}
fi

if [ $(ls /data/shared/cust/bootanimation.zip) ]; then
    cp -pf /data/shared/cust/bootanimation.zip ${CUPSS_DEFAULT_PATH}/${RES_PATH}

fi

if [ "$COTA_FLAG" == "1" ]; then
    # Trigger For cust partition rw remount
    setprop persist.sys.cota.changed 2
fi

if [ "$SMARTCA_FLAG" == "1" ]; then
    # Trigger For OP partition rw remount
    setprop persist.sys.smartca.changed 2
fi

exit 0
