#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <pvc_name> <namespace>"
  exit 1
fi

PVC_NAME=$1
NAMESPACE=$2

# Get the pod names associated with the PVC
POD_NAMES=$(kubectl get pods --namespace=${NAMESPACE} -o json | jq -r ".items[] | select(.spec.volumes[]?.persistentVolumeClaim.claimName == \"${PVC_NAME}\").
metadata.name")

if [ -z "${POD_NAMES}" ]; then
  echo "No pods found for PVC '${PVC_NAME}' in namespace '${NAMESPACE}'."
else
  echo -e  "Pods currently attached to PVC '${PVC_NAME}' in namespace '${NAMESPACE}':\n"
  echo "${POD_NAMES}" | tr ' ' '\n'
fi
