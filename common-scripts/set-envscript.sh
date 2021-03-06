#!/usr/bin/env bash

DATAFILE='/Users/fsadykov/Projects/fuchicorp-projects/variable.tfvars'

ENVIRONMENT=$(sed -nr 's/^environment\s*=\s*"([^"]*)".*$/\1/p' "$DATAFILE")
BUCKET=$(sed -nr 's/^bucket_name\s*=\s*"([^"]*)".*$/\1/p' "$DATAFILE")
DEPLOYMENT=$(sed -nr 's/^deployment_name\s*=\s*"([^"]*)".*$/\1/p' "$DATAFILE")


DIR=$(pwd)
DATAFILE="$DIR/$1"

if [ ! -f "$DATAFILE" ]; then
    echo "setenv: Configuration file not found: $DATAFILE"
    return 1
fi

if [ -z "$ENVIRONMENT" ]
then
    echo "setenv: 'environment' variable not set in configuration file."
    return 1
fi

if [ -z "$BUCKET" ]
then
    echo "setenv: 'bucket_name' variable not set in configuration file."
    return 1
fi

if [ -z "$DEPLOYMENT" ]
then
    echo "setenv: 'deployment_name' variable not set in configuration file."
    return 1
fi

cat << EOF > "$DIR/backend.tf"
terraform {
  backend "s3" {
    bucket = "${BUCKET}"
    prefix = "${ENVIRONMENT}/${DEPLOYMENT}"
  }
}
EOF


echo "setenv: Initializing terraform"
terraform init > /dev/null
