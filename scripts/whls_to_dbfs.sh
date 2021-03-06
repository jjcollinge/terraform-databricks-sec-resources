#!/bin/bash

# This script downloads any custom Python package whls using links in 
# variables.cluster_default_packages, and re-uploads them to DBFS for cluster installation.

# NOTE: this assumes network connectivity to the provided URIs

set -e

echo "Downloading custom whls for clusters..."

mkdir -p defaultpackages && cd defaultpackages

# First argument should be a comma-separated string of remote URIs
IFS=', '
read -ra ADDR <<< "$2"
for uri in "${ADDR[@]}"; 
do
    # Download whl
    curl --remote-name $uri

    # Checksum validation
    sha256sum $(basename $uri) > shasum.txt
    sha256sum -c shasum.txt
    rm shasum.txt
done

cd ..

echo "Downloaded. Uploading to dbfs..."

# dbfs auth
export DATABRICKS_HOST=$3 # host
export DATABRICKS_TOKEN=$4 # PAT

# Upload ./defaultpackages wheelhouse to dbfs
zip -r defaultpackages.wheelhouse.zip defaultpackages
dbfs cp -r --overwrite defaultpackages.wheelhouse.zip dbfs:/mnt/libraries/defaultpackages.wheelhouse.zip

echo "Uploaded!"

rm -rf defaultpackages
rm -rf defaultpackages.wheelhouse.zip