#!/bin/bash

set -x
#set -e
set -o pipefail
exec > /var/log/spleeter.log

FILE_NAME=$1

conda activate spleeter &&
cd /data/envs/$FILE_NAME

cleanup(){
    rm -rf $@
}

{
    for FILE in *
    do 
        spleeter separate -i $FILE -o /data/complete -p spleeter:2stems
        if [ -d "/data/complete/${FILE%.*}/" ]
        then
            echo "SUCCESS! Check /data/complete/${FILE%.*}/ for output"
            cleanup "/data/envs/${FILE}" "/data/uploads/${FILE}"
        else
            echo "ERROR: Split unsuccessful - ${FILE}"
        fi
    done
    conda deactivate
} || {
    echo "ERROR: Split unsuccessful - ${FILE_NAME}"
}
