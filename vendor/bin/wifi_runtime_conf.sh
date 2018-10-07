#!/vendor/bin/sh

######## LGP_WIFI_RUNTIME_SHELL ##############

INPUT_PARAM=$1

# TAG NAME
LOG_TAG=PCAS
CR_CHAR=$'\r'

#================ BUILD TIME =====================
WLAN_CHIP_VENDOR=`getprop wlan.chip.vendor`
WLAN_CHIP_VERSION=`getprop wlan.chip.version`

#=============== RUN TIME Property ===============
# http://collab.lge.com/main/pages/viewpage.action?pageId=677917338
LAOP_SKU_CARRIER_PROP=`getprop ro.lge.sku_carrier`

# WIFI PERSIST PATH
PERSIST_ROOT=/vendor/persist-lg

function VERIFY_PERSIST_FOLDER
{
	if [[ ! -d /vendor/persist-lg ]] && [[ ! -d /persist-lg ]]; then
		PERSIST_ROOT=/persist
	else
		if [[ -d /vendor/persist-lg ]]; then
		PERSIST_ROOT=/vendor/persist-lg
		else
		PERSIST_ROOT=/persist-lg
		fi
	fi
}

VERIFY_PERSIST_FOLDER
WIFI_PERSIST_LG_ROOT=${PERSIST_ROOT}/wifi
log -p i -t $LOG_TAG "select persist path = \"${WIFI_PERSIST_LG_ROOT}\""

# MAKE FOLDER

if [[ ! -d ${WIFI_PERSIST_LG_ROOT} ]]; then
mkdir ${WIFI_PERSIST_LG_ROOT}
chmod -h 0775 ${WIFI_PERSIST_LG_ROOT}
fi

if [[ ! -d ${WIFI_PERSIST_LG_ROOT}/qcom ]]; then
mkdir ${WIFI_PERSIST_LG_ROOT}/qcom
chmod -h 0775 ${WIFI_PERSIST_LG_ROOT}/qcom
fi

if [[ ! -d ${WIFI_PERSIST_LG_ROOT}/brcm ]]; then
mkdir ${WIFI_PERSIST_LG_ROOT}/brcm
chmod -h 0775 ${WIFI_PERSIST_LG_ROOT}/brcm
fi

if [[ ! -d ${WIFI_PERSIST_LG_ROOT}/mtk ]]; then
mkdir ${WIFI_PERSIST_LG_ROOT}/mtk
chmod -h 0775 ${WIFI_PERSIST_LG_ROOT}/mtk
fi

# FOR PATH CHECK ================================
# WiFi NV PATH
VENDOR_ETC_WIFI_PATH=/vendor/etc/wifi
SYSTEM_VENDOR_ETC_WIFI_PATH=/system/vendor/etc/wifi
SYSTEM_ETC_WIFI_PATH=/system/etc/wifi
WIFI_PATH=/system/etc/wifi

function VERIFY_WIFI_NV_QCOM_399X
{
	if [[ -f ${VENDOR_ETC_WIFI_PATH}/bdwlan.bin ]]; then
		WIFI_PATH=${VENDOR_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to vendor image"
	elif [[ -f ${SYSTEM_VENDOR_ETC_WIFI_PATH}/bdwlan.bin ]]; then
		WIFI_PATH=${SYSTEM_VENDOR_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to system/vendor image"
	else
		WIFI_PATH=${SYSTEM_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to system/bin image"
	fi
}

function VERIFY_WIFI_NV_QCOM_WCNSS
{
	if [[ -f ${VENDOR_ETC_WIFI_PATH}/WCNSS_qcom_wlan_nv.bin ]]; then
		WIFI_PATH=${VENDOR_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to vendor image"
	elif [[ -f ${SYSTEM_VENDOR_ETC_WIFI_PATH}/WCNSS_qcom_wlan_nv.bin ]]; then
		WIFI_PATH=${SYSTEM_VENDOR_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to system/vendor image"
	else
		WIFI_PATH=${SYSTEM_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to system/bin image"
	fi
}

function VERIFY_WIFI_NV_BRCM
{
	if [[ -f ${VENDOR_ETC_WIFI_PATH}/bcmdhd_runtime.cal ]]; then
		WIFI_PATH=${VENDOR_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to vendor image"
	elif [[ -f ${SYSTEM_VENDOR_ETC_WIFI_PATH}/bcmdhd_runtime.cal ]]; then
		WIFI_PATH=${SYSTEM_VENDOR_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to system/vendor image"
	else
		WIFI_PATH=${SYSTEM_ETC_WIFI_PATH}
		log -p i -t $LOG_TAG "Path change to system/bin image"
	fi
}

function VERIFY_WIFI_NV_MTK
{
}

function VERIFY_WIFI_NV_FOLDER
{
	if [[ ${WLAN_CHIP_VENDOR} == "qcom" ]]; then
		if [[ ${WLAN_CHIP_VERSION} == "wcn399x" ]]; then
			VERIFY_WIFI_NV_QCOM_399X
		else
			VERIFY_WIFI_NV_QCOM_WCNSS
		fi
	elif [[ ${WLAN_CHIP_VENDOR} == "brcm" ]]; then
		VERIFY_WIFI_NV_BRCM
	elif [[ ${WLAN_CHIP_VENDOR} == "mtk" ]]; then
		VERIFY_WIFI_NV_MTK
	else
		return
	fi
}

# FUNCTION
VERIFY_WIFI_NV_FOLDER
log -p i -t $LOG_TAG "WIFI SYSTEM PATH = \"${WIFI_PATH}\""

#=========== Symbolic Folder path ==========================================
WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE=${WIFI_PERSIST_LG_ROOT}/wpa_supplicant_runtime.conf
WIFI_SKU_PATH=${WIFI_PATH}/${LAOP_SKU_CARRIER_PROP}

#============ RUNTIME PROPERTY conf file ===================================
WIFI_RUNTIME_PROPERTY_FILE=${WIFI_PATH}/wifi_runtime_prop.conf

# ======================= Qualcomm WLAN =================================
# WCN
WIFI_QCT_FOLDER_PATH=${WIFI_PERSIST_LG_ROOT}/qcom
WIFI_QCT_CACHE_BOOT_CAL_FILE=${WIFI_QCT_FOLDER_PATH}/WCNSS_qcom_wlan_cache_nv_boot.bin
WIFI_QCT_CACHE_INI_FILE=${WIFI_QCT_FOLDER_PATH}/WCNSS_qcom_cache_cfg.ini

# QCT WCN399X
WIFI_QCT_399X_CACHE_BD_WLAN=${WIFI_QCT_FOLDER_PATH}/bdwlan_cache.bin
WIFI_QCT_399X_CACHE_BD_CH0_WLAN=${WIFI_QCT_FOLDER_PATH}/bdwlan_ch0_cache.bin
WIFI_QCT_399X_CACHE_BD_CH1_WLAN=${WIFI_QCT_FOLDER_PATH}/bdwlan_ch1_cache.bin
WIFI_QCT_399X_CACHE_MAC_WLAN=${WIFI_QCT_FOLDER_PATH}/wlan_mac_cache.bin

# ======================= Broadcom WLAN ===================================
WIFI_BRCM_FOLDER_PATH=${WIFI_PERSIST_LG_ROOT}/brcm
WIFI_BRCM_CACHE_BOOT_CAL_FILE=${WIFI_BRCM_FOLDER_PATH}/bcmdhd_cache.cal

# ======================= Mediatek WLAN ==========================
WIFI_MTK_FOLDER_PATH=${WIFI_PERSIST_LG_ROOT}/mtk
WIFI_MTK_CACHE_BOOT_CAL_FILE=${WIFI_MTK_FOLDER_PATH}/WIFI_cache
WIFI_MTK_FW_PATH=/system/vendor/firmware


# ======================= FUNCTION ==============================

function QCOM_INI_SET() {
	log -p i -t $LOG_TAG "QCOM INI"
	# default ini
	ln -sf ${WIFI_PATH}/WCNSS_qcom_cfg.ini ${WIFI_QCT_FOLDER_PATH}/WCNSS_qcom_cache_cfg.ini

	if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
		if [[ -f ${WIFI_SKU_PATH}/WCNSS_qcom_cfg.ini ]]; then
			ln -sf ${WIFI_SKU_PATH}/WCNSS_qcom_cfg.ini ${WIFI_QCT_CACHE_INI_FILE}
			log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
		fi
	fi
}

function QCOM_NV_SET() {
	log -p i -t $LOG_TAG "QCOM WCN NV"
	# nv.bin
	ln -sf ${WIFI_PATH}/WCNSS_qcom_wlan_nv.bin ${WIFI_QCT_CACHE_BOOT_CAL_FILE}

	if [[ -f ${WIFI_QCT_CACHE_BOOT_CAL_FILE} ]]; then
		log -p i -t $LOG_TAG "Default NV Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SKU_PATH}/WCNSS_qcom_wlan_nv.bin ]]; then
				ln -sf ${WIFI_SKU_PATH}/WCNSS_qcom_wlan_nv.bin ${WIFI_QCT_CACHE_BOOT_CAL_FILE}
				log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
			fi
		fi
	else
		log -p i -t $LOG_TAG "Don't have write permission to change Link"
	fi

	# INI
	QCOM_INI_SET
}

function QCOM_WCN399X_NV_SET() {
	log -p i -t $LOG_TAG "QCOM WCN399X NV"
	# bdwlan.bin
	ln -sf ${WIFI_PATH}/bdwlan.bin ${WIFI_QCT_399X_CACHE_BD_WLAN}

	if [[ -f ${WIFI_QCT_399X_CACHE_BD_WLAN} ]]; then
		log -p i -t $LOG_TAG "Default bdwlan Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SKU_PATH}/bdwlan.bin ]]; then
				ln -sf ${WIFI_SKU_PATH}/bdwlan.bin ${WIFI_QCT_399X_CACHE_BD_WLAN}
				log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
			fi
		fi
	else
		log -p i -t $LOG_TAG "Don't have write permission to change Link"
	fi

	# bdwlan_ch0.bin
	ln -sf ${WIFI_PATH}/bdwlan_ch0.bin ${WIFI_QCT_399X_CACHE_BD_CH0_WLAN}
	if [[ -f ${WIFI_QCT_399X_CACHE_BD_CH0_WLAN} ]]; then
		log -p i -t $LOG_TAG "Default bdwlan_ch0 Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SKU_PATH}/bdwlan_ch0.bin ]]; then
				ln -sf ${WIFI_SKU_PATH}/bdwlan_ch0.bin ${WIFI_QCT_399X_CACHE_BD_CH0_WLAN}
				log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
			fi
		fi
	else
		log -p i -t $LOG_TAG "Don't have write permission to change Link"
	fi

	# bdwlan_ch1.bin
	ln -sf ${WIFI_PATH}/bdwlan_ch1.bin ${WIFI_QCT_399X_CACHE_BD_CH1_WLAN}
	if [[ -f ${WIFI_QCT_399X_CACHE_BD_CH1_WLAN} ]]; then
		log -p i -t $LOG_TAG "Default bdwlan_ch1 Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SKU_PATH}/bdwlan_ch1.bin ]]; then
				ln -sf ${WIFI_SKU_PATH}/bdwlan_ch1.bin ${WIFI_QCT_399X_CACHE_BD_CH1_WLAN}
				log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
			fi
		fi
	else
		log -p i -t $LOG_TAG "Don't have write permission to change Link"
	fi

	# INI
	QCOM_INI_SET
}

function BRCM_NV_SET() {
	log -p i -t $LOG_TAG "BRCM"
	# on first booting.
	ln -sf ${WIFI_PATH}/bcmdhd_runtime.cal ${WIFI_BRCM_CACHE_BOOT_CAL_FILE}

	if [[ -f ${WIFI_BRCM_CACHE_BOOT_CAL_FILE} ]]; then
		log -p i -t $LOG_TAG "Default bcmdhd.cal Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SKU_PATH}/bcmdhd.cal ]]; then
				ln -sf ${WIFI_SKU_PATH}/bcmdhd.cal ${WIFI_BRCM_CACHE_BOOT_CAL_FILE}
				log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
			fi
		fi
	else
		log -p i -t $LOG_TAG "Don't have write permission to change Link"
	fi
}

function MTK_NV_SET() {
	log -p i -t $LOG_TAG "MTK"
	# on first booting.
	ln -sf ${WIFI_MTK_FW_PATH}/WIFI ${WIFI_MTK_CACHE_BOOT_CAL_FILE}

	if [[ -f ${WIFI_MTK_CACHE_BOOT_CAL_FILE} ]]; then
		log -p i -t $LOG_TAG "Default WIFI Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SKU_PATH}/WIFI ]]; then
				ln -sf ${WIFI_SKU_PATH}/WIFI ${WIFI_MTK_CACHE_BOOT_CAL_FILE}
				log -p i -t $LOG_TAG "Change symbolic link sku = \"${WIFI_SKU_PATH}\""
			fi
		fi
	else
		log -p i -t $LOG_TAG "Don't have write permission to change Link"
	fi
}

function READ_FILE_SET_PROPERTY() {
if [[ -f ${WIFI_RUNTIME_PROPERTY_FILE} ]]; then
	while read -r SKU PROP NAME VALUE
	do
		str_chk=`echo "${SKU}" | grep "#" | wc -l`
		if [[ ! $str_chk -ge 1 ]]; then
			if [[ -n ${LAOP_SKU_CARRIER_PROP} ]] && [[ ${LAOP_SKU_CARRIER_PROP} = ${SKU} ]]; then
				if [[ ${PROP} = "setprop" ]]; then
					# remove CR/LF
					if [[ -n ${NAME} ]] && [[ -n ${VALUE} ]]; then
					NEW_VALUE=$(echo $VALUE | sed -e 's/\r//g' | sed -e 's/\n//g')
					`setprop ${NAME} ${NEW_VALUE}`
					log -p i -t $LOG_TAG "${SKU} ${PROP} ${NAME} ${NEW_VALUE}"
					fi
				else
					log -p i -t $LOG_TAG "Please check wifi_runtime_prop.conf format"
				fi
			fi
		fi
	done < ${WIFI_RUNTIME_PROPERTY_FILE}
	## CHECK END OF LINE IF NO CR which skip from read.
	TAIL_DATA=`tail ${WIFI_RUNTIME_PROPERTY_FILE} -n 1`
	if [[ $TAIL_CHECK == *$CR_CHAR* ]];then
		log -p i -t $LOG_TAG "CR at tail of file"
	else
		log -p i -t $LOG_TAG "No CR at tail of file"
		TAIL_VALUE=($TAIL_DATA)
		SKU=${TAIL_VALUE[0]} PROP=${TAIL_VALUE[1]}
		NAME=${TAIL_VALUE[2]} VALUE=${TAIL_VALUE[3]}
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]] && [[ ${LAOP_SKU_CARRIER_PROP} = ${SKU} ]]; then
			if [[ ${PROP} = "setprop" ]]; then
				# remove CR/LF
				if [[ -n ${NAME} ]] && [[ -n ${VALUE} ]]; then
				NEW_VALUE=$(echo $VALUE | sed -e 's/\r//g' | sed -e 's/\n//g')
				`setprop ${NAME} ${NEW_VALUE}`
				log -p i -t $LOG_TAG "${SKU} ${PROP} ${NAME} ${NEW_VALUE}"
				fi
			else
				log -p i -t $LOG_TAG "Please check wifi_runtime_prop.conf format"
			fi
		fi
	fi
else
	log -p i -t $LOG_TAG "Please check wifi_runtime_prop.conf"
fi
}

function SAVE_LAOP_PARAMS_FOR_CONF() {
  log -p i -t $LOG_TAG "SAVE_LAOP_PARAMS_FOR_CONF()"

  LAOP_ENABLED_PROP=`getprop ro.lge.laop`
  WLAN_DIABLE_PCAS=`getprop wifi.lge.disable_pcas`
  LAOP_TARGET_OPERATOR_PROP=`getprop ro.build.target_operator`
  LAOP_TARGET_COUNTRY_PROP=`getprop ro.build.target_country`
  LAOP_TARGET_REGION_PROP=`getprop ro.build.target_region`
  LAOP_DEFAULT_COUNTRY_PROP=`getprop ro.build.default_country`
  TREBLE_ENABLED=`getprop ro.treble.enabled`

  echo WLAN_CHIP_VENDOR=\"${WLAN_CHIP_VENDOR}\" > ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  echo WLAN_CHIP_VERSION=\"${WLAN_CHIP_VERSION}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  echo RO_BUILD_TARGET_OPERATOR=\"${LAOP_TARGET_OPERATOR_PROP}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  echo RO_BUILD_TARGET_COUNTRY=\"${LAOP_TARGET_COUNTRY_PROP}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  echo RO_BUILD_TARGET_REGION=\"${LAOP_TARGET_REGION_PROP}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  echo WLAN_TREBLE_ENABLED=\"${TREBLE_ENABLED}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  echo WLAN_DIABLE_PCAS=\"${WLAN_DIABLE_PCAS}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}

  if [[ -d /system/OP ]]; then
   log -p i -t $LOG_TAG "NT CODE BASED SET!"
   echo NT_CODE=\"true\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  else
   echo NT_CODE=\"false\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  fi

  if [[ ${LAOP_ENABLED_PROP} == 1 ]]; then
    echo LAOP_ENABLED=\"${LAOP_ENABLED_PROP}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
    echo LAOP_SKU_CARRIER=\"${LAOP_SKU_CARRIER_PROP}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
    echo LAOP_RO_BUILD_DEFAULT_COUNTRY=\"${LAOP_DEFAULT_COUNTRY_PROP}\" >> ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  fi

  chown -h system:wifi ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
  chmod -h 0775 ${WIFI_PERSIST_LG_WPA_LAOP_CONF_FILE}
}

function QCT_PROPERTY() {
	if [[ ${WLAN_CHIP_VERSION} == "wcn399x" ]]; then
		TX_POWER=`getprop wlan.lge.txpower`
		if [[ ${TX_POWER} == "" ]]; then
			log -p i -t $LOG_TAG "wlan.lge.txpower is null!! and set default value"
##                       `setprop wlan.lge.txpower 2`
		else
			log -p i -t $LOG_TAG "wlan.lge.txpower is ${TX_POWER}"
		fi
	fi
}

function BRCM_PROPERTY() {
}

function MTK_PROPERTY() {
}

function VERIFICATION_PROPERTY() {
	log -p i -t $LOG_TAG "VERIFICATION_PROPERTY()"
	if [[ ${WLAN_CHIP_VENDOR} == "qcom" ]]; then
		QCT_PROPERTY
	elif [[ ${WLAN_CHIP_VENDOR} == "brcm" ]]; then
		BRCM_PROPERTY
	elif [[ ${WLAN_CHIP_VENDOR} == "mtk" ]]; then
		MTK_PROPERTY
	else
		return
	fi
}

function MAIN_FUNCTION() {

	if [[ ${INPUT_PARAM} == "--sku" ]] || [[ ${INPUT_PARAM} == "--runtimeprop" ]]; then
		# LGP_WIFI_RUNTIME_SHELL_NV
		if [[ ${WLAN_CHIP_VENDOR} == "qcom" ]]; then
			if [[ ${WLAN_CHIP_VERSION} == "wcn399x" ]]; then
				QCOM_WCN399X_NV_SET
			else
				QCOM_NV_SET
			fi
		elif [[ ${WLAN_CHIP_VENDOR} == "brcm" ]]; then
			BRCM_NV_SET
		elif [[ ${WLAN_CHIP_VENDOR} == "mtk" ]]; then
			MTK_NV_SET
		else
			log -p i -t $LOG_TAG "What Wlan Chip is ?????????"
			return
		fi
		log -p i -t $LOG_TAG "Link changed : Vendor \"${WLAN_CHIP_VENDOR}\", Input Param \"${INPUT_PARAM}\""
		return;
	else
		log -p i -t $LOG_TAG "Write Data : Vendor \"${WLAN_CHIP_VENDOR}\", Input Param \"${INPUT_PARAM}\""
	fi


    # LGP_WIFI_RUNTIME_SUPPLICANT
	SAVE_LAOP_PARAMS_FOR_CONF

    # LGP_WIFI_RUNTIME_SHELL_PROPERTY
	READ_FILE_SET_PROPERTY

    # LGP_WIFI_RUNTIME_SHELL_PROPERTY
    # VERIFICATION_PROPERTY
}

### MAIN FUNCTION ###
MAIN_FUNCTION

