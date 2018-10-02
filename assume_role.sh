#!/usr/bin/env bash

if [[ ( "$#" < 2 ) || ( "$#" > 3 ) ]]
then
  echo "Usage: source assume_role.sh account_id role [profile]"
  exit 1
fi

ACCOUNT="$1"
ROLE="$2"
PROFILE="${3:-default}"

role_session_name=`uuidgen || date | cksum | cut -d " " -f 1`
aws_creds="$(aws --profile "${PROFILE}" sts assume-role \
            --role-arn "arn:aws:iam::${ACCOUNT}:role/${ROLE}" \
            --role-session-name "${role_session_name}" \
            --duration-seconds 3600 \
            --output json)"

if [ "$?" -ne 0 ]
then
  exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "${aws_creds}" | grep AccessKeyId | awk -F'"' '{print $4}' )
export AWS_SECRET_ACCESS_KEY=$(echo "${aws_creds}" | grep SecretAccessKey | awk -F'"' '{print $4}' )
export AWS_SESSION_TOKEN=$(echo "${aws_creds}" | grep SessionToken | awk -F'"' '{print $4}' )
export AWS_SECURITY_TOKEN=$(echo "${aws_creds}" | grep SessionToken | awk -F'"' '{print $4}' )
echo "session '$role_session_name' valid for 60 minutes"
