#!/system/bin/sh
#
# Copyright (C) 2016 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Helper function to copy files
function do_copy_file() {
  source_file=$1
  dest_name=$2
  folder_name=$3

  # Move to a temporary file so we can do a rename and have the preopted file
  # appear atomically in the filesystem.
  temp_dest_name=${dest_name}.tmp
  if ! cp -f ${source_file} ${temp_dest_name} ; then
    log -p w -t cppreloads "Unable to copy file ${source_file} to ${temp_dest_name}!"
  else
    log -p i -t cppreloads "Copied file from ${source_file} to ${temp_dest_name}"
    sync
    if ! mv -f ${temp_dest_name} ${dest_name} ; then
      log -p w -t cppreloads "Unable to rename temporary file from ${temp_dest_name} to ${dest_name}"
    else
      log -p i -t cppreloads "Renamed temporary file from ${temp_dest_name} to ${dest_name}"
      if [ ${folder_name} == "preload" ] ; then
        chown system:system ${dest_name}
        chmod 644 ${dest_name}
      elif [ ${folder_name} == "media" ] ; then
        chown media_rw:media_rw ${dest_name}
        chmod 664 ${dest_name}
      else
        log -p w -t cppreloads "do_copy_file, Unable to find folder name ${folder_name}, dest_name: ${dest_name}"
      fi
    fi
  fi
}

# Helper function to copy folder
function do_copy_folder() {
  source_folder=$1
  dest_folder=$2
  folder_name=$3

  for file in $(find ${source_folder} -type f -name "*.*"); do
    real_name=${file/${source_folder}/}
    dest_name=${dest_folder}${real_name}

    mkfolder=$(dirname $dest_name)
    mkdir -p ${mkfolder}

    if [ ${folder_name} == "preload" ] ; then
      chown system:system ${mkfolder}
      chmod 755 ${mkfolder}
    elif [ ${folder_name} == "media" ] ; then
      chown media_rw:media_rw ${mkfolder}
      chmod 775 ${mkfolder}
    else
      log -p w -t cppreloads "do_copy_folder, Unable to find folder name ${folder_name}"
    fi

    # Copy files in background to speed things up
    do_copy_file ${file} ${dest_name} ${folder_name} &
  done
}

OP_PATH=`getprop ro.lge.capp_cupss.op.dir`/
OP_ROOT=`getprop ro.lge.capp_cupss.rootdir`
OP_NAME=${OP_ROOT/${OP_PATH}/}

if [ $# -eq 1 ]; then
  # Where the system_b is mounted that contains the preopt'd files
  mountpoint=$1

  log -p i -t cppreloads "cppreloads from ${mountpoint}"
  # All preload contents do the copy task
  # NOTE: this implementation will break in any path with spaces to favor
  # background copy tasks

  # create base directory
  DATA_PRELOAD_DIR="/data/preload"
  mkdir -p ${DATA_PRELOAD_DIR}
  chown system:system ${DATA_PRELOAD_DIR}
  chmod 755 ${DATA_PRELOAD_DIR}

  DATA_MEDIA_DIR="/data/media"
  mkdir -p ${DATA_MEDIA_DIR}
  chown media_rw:media_rw ${DATA_MEDIA_DIR}
  chmod 775 ${DATA_MEDIA_DIR}

  if [ ${mountpoint} == "/cache/data/preload" ] ; then
    log -p i -t cppreloads "do copy preload cache"
    do_copy_folder ${mountpoint}/ /data/preload/ "preload" &
    wait
    rm -rf ${mountpoint}/
    exit 0
  else
    # /data/preload
    if [[ "$OP_ROOT" == *"SUPERSET"* ]] ; then
      ENTRY=`ls -F ${mountpoint}/data/preload/`
      for item in $ENTRY
      do
        if [[ "$item" == */* ]] ; then
          do_copy_folder ${mountpoint}/data/preload/${item} /data/preload/ "preload" &
        fi
      done
    else
      do_copy_folder ${mountpoint}/data/preload/_COMMON/ /data/preload/ "preload" &
      do_copy_folder ${mountpoint}/data/preload/${OP_NAME}/ /data/preload/ "preload" &
    fi

    # Wait for jobs to finish
    wait

    # /data/media
    do_copy_folder ${mountpoint}/data/media/ /data/media/ "media"

    wait
    exit 0
  fi
else
  log -p e -t cppreloads "Usage: cppreloads <preloads-mount-point>"
  exit 1
fi
