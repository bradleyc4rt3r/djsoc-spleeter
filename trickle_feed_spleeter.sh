#!/bin/bash
SLEEP=100 #seconds
set -x

source ~/miniconda3/etc/profile.d/conda.sh
conda activate spleeter-cpu
wait

cd /mnt/spleeter-readable

for file in *; do spleeter separate -i $file -o /home/spleeter/spleeter/audio_output -p spleeter:2stems; wait; done
	echo 'Please check /home/spleeter/spleeter/audio_output for many outputs'

set +x
