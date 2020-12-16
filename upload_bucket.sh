#!/bin/bash
set -x
DATE==$(echo `date`)
REGION=eu-west-2
BUCKET_ROLE=split-tmp-upload-bucket


#create a temporary bucket on upload with custom id and tell user it has a ttl of 30 mins.
#handle error if bucket created has the same random id generated.
#inside upload_bucket.php delete bucket after 30mins

get_latest_bucket_name(){
	echo "Searching S3 for latest bucket integer"
	bucket_list=$(aws s3api list-buckets --query "Buckets[].Name" --region eu-west-2 | grep ${BUCKET_ROLE} | sort -nr | sed 's/"//g' | sed 's/,//g' )
	export latest_bucket=$(echo $bucket_list | awk '{print $1}')
	COUNTER=$(echo $latest_bucket | sed 's/split-tmp-upload-bucket-//g')
}

create_temp_bucket(){
        export COUNTER=$((COUNTER+1))
        echo "Creating users temporary bucket"
        aws s3 mb s3://${BUCKET_ROLE}-$COUNTER --region $REGION
        echo "Random bucket created, ready for end user"
}

sync_bucket_contents(){
        echo "Syncing to temporary bucket"
	mkdir -p /mnt/upload_bucket/upload-${COUNTER}
        aws s3 sync /mnt/upload_bucket/upload-${COUNTER} s3://${BUCKET_ROLE}-$COUNTER
	echo "Sync complete"
}

remove_temp_bucket(){
	echo "Removing temp bucket: ${BUCKET_ROLE}-${COUNTER}"
	aws s3 rb s3://$BUCKET_ROLE-$COUNTER --region $REGION
	echo "Bucket ${BUCKET_ROLE}-${COUNTER} removed"
}

main(){
	get_latest_bucket_name
	if [ -v $latest_bucket ]; then
		echo "CRITICAL: Latest bucket not found."
	
	elif	[ -v $COUNTER ]; then
		echo "Latest bucket found, generating temp bucket and uploading contents..."
		create_temp_bucket
		sync_bucket_contents
		sleep 1800
		remove_temp_bucket
	fi
}

main
set +x
