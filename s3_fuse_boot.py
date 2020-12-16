#!/usr/bin/python3

import time
import os
import logging

# Setting up logging
logging.getLogger().setLevel(logging.INFO)

def mount_cloud_storage():
        print('Executing s3fs mount now')
        os.system('s3fs spleeter-splitting /mnt/spleeter-splitter -o allow_other -o passwd_file=${HOME}/.passwd-s3fs -o url=https://s3.console.aws.amazon.com/s3/buckets/spleeter-splitting/?region=eu-west-2 -o use_path_request_style')
   
        #time.sleep(5)
        #if os.system('df -h | grep spleeter | wc -l ') > 0:
            #os.system('echo The number of active sessions are:' + str(os.system('df -h | grep spleeter | wc -l')))
        #else:
            #os.system('echo no Spleeter sessions found.')

mount_cloud_storage()
