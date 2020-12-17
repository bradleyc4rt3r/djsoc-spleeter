#!/bin/bash
set -x
set -e
set -o pipefail
exec > /var/log/spleeter.log

ZIP_NAME=$1
ZIP_DIR=$2
RECIPIENT=$3

cd $ZIP_DIR || exit 0


cat <<EOF > destination.json
{
  "ToAddresses":  ["${RECIPIENT}"],
  "CcAddresses":  ["dj@swansea-societies.co.uk"],
  "BccAddresses": []
}
EOF
cat <<EOF > message.json
{
  "Subject": {
    "Data": "Swansea University DJ Society",
    "Charset": "UTF-8"
  },
  "Body": {
    "Text": {
      "Data": "Please check the attached zip file for the stems of the track that our current model has attempted to split. We understand some songs are easier to split currently than other, but bear with as we've got a shed load of future upgrades to come.",
      "Charset": "UTF-8"
    },
    "Html": {
      "Data": "<h1>Swansea Uni DJ Society - Track Splitter</h1><p>Please check the attached zip file for the stems of the track that our current model has attempted to split. We understand some songs are easier to split currently than other, but bear with as we've got a shed load of future upgrades to come. Please contact us if you have any queries. Email: dj@swansea-societies.co.uk</p>",
      "Charset": "UTF-8"
    }
  }
}
EOF
aws --region eu-west-2 ses send-email --from "Swansea University DJ Society <dj@swansea-societies.co.uk>" --destination file://destination.json --message file://message.json --attachment file://${ZIP_NAME}

rm -rf $ZIP_NAME
set +x
