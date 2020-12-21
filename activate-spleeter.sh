#!/bin/bash

set -m
#set -x
#set -e
set -o pipefail
#exec > /var/log/spleeter.log

FILE_NAME=$1

cleanup(){
    rm -rf $@
}

{
    #Set dependency matplotlib env vars&dirs
    mkdir -m 777 /tmp/NUMBA_CACHE_DIR /tmp/MPLCONFIGDIR &> /dev/null
    export NUMBA_CACHE_DIR="/tmp/NUMBA_CACHE_DIR"
    export MPLCONFIGDIR="/tmp/MPLCONFIGDIR"

    #System tweaks
    sync;

    cd "/data/envs/${FILE_NAME}" &&
    source activate spleeter && {
      /home/brad/miniconda3/envs/spleeter/bin/spleeter separate -i ${FILE_NAME} -o /data/complete -p spleeter:2stems
      wait
      if [ -d "/data/complete/${FILE_NAME%.*}/" ]
      then
          echo "SUCCESS! Check /data/complete/${FILE_NAME%.*}/ for output"
          cleanup "/data/envs/${FILE_NAME}" "/data/uploads/${FILE_NAME}"
      else
          echo "ERROR: Directory does not exist - /data/complete/${FILE_NAME%.*}"
      fi

      conda deactivate
    }
} || {
    echo "ERROR: Split unsuccessful - ${FILE_NAME}"
}
#set +x