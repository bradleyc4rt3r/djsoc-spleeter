#!/bin/bash


SLEEP=100 #seconds
set -x

#MUST run via bash -i interactive shell to work
conda activate spleeter


cd /mnt/spleeter-readable

for file in *; do spleeter separate -i $file -o /data/complete/audio_output -p spleeter:2stems; done
	echo 'Please check /home/spleeter/spleeter/audio_output for many outputs'

set +x
