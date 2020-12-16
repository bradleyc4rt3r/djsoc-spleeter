#!/bin/bash
REGION=eu-west-2
BUCKET_ROLE=split-tmp-download-bucket

echo `date`

get_latest_bucket_name(){
        echo "Searching S3 for latest bucket integer"
        bucket_list=$(aws s3api list-buckets --query "Buckets[].Name" --region $REGION | grep ${BUCKET_ROLE} | sort -nr | sed 's/"//g' | sed 's/,//g' )
        export latest_bucket=$(echo $bucket_list | awk '{print $1}')
        COUNTER=$(echo $latest_bucket | sed 's/split-tmp-download-bucket-//g')
}

create_temp_bucket(){
        export COUNTER=$((COUNTER+1))
        echo "Creating users temporary bucket"
        aws s3 mb s3://${BUCKET_ROLE}-$COUNTER --region $REGION
        echo "Random bucket created, ready for end user"
}

sync_bucket_contents(){
        echo "Syncing from temporary bucket"
	mkdir -p /mnt/download_bucket/download-${COUNTER}
        aws s3 sync s3://$BUCKET_ROLE-$COUNTER /mnt/download_bucket/download-$COUNTER
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

        elif    [ -v $COUNTER ]; then
                echo "Latest bucket found, downloading contents to server..."
                create_temp_bucket
                sync_bucket_contents
                sleep 120
                remove_temp_bucket
        fi
}
