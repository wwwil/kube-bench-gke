#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

gcloud auth activate-service-account --key-file=$1;
CLUSTER_NAME=$(curl http://metadata/computeMetadata/v1/instance/attributes/cluster-name -H "Metadata-Flavor: Google");
CLUSTER_LOCATION=$(curl http://metadata/computeMetadata/v1/instance/attributes/cluster-location -H "Metadata-Flavor: Google");
IFS='-' read -ra CLUSTER_REGION_ZONE <<< "$CLUSTER_LOCATION";
if [ "${CLUSTER_REGION_ZONE[2]}" != "" ]; then LOCATION_ARG="--zone"; else LOCATION_ARG="--region"; fi;
gcloud container clusters describe $CLUSTER_NAME $LOCATION_ARG $CLUSTER_LOCATION > $2;
