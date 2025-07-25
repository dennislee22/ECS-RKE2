#!/bin/bash

# This script reports on the vCPU and RAM resources of a Kubernetes node.
# It details the total allocatable resources, the resources requested by pods,
# and the remaining balance that can be requested.

# Get the node name from the first argument, or get the first node if not specified
NODE_NAME=${1:-$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" | head -n 1)}

if [ -z "$NODE_NAME" ]; then
  echo "Error: No nodes found in the cluster."
  exit 1
fi

echo "Generating resource report for node: $NODE_NAME"
echo "--------------------------------------------------"

# Get the node description, which contains all the necessary information
NODE_DESCRIPTION=$(kubectl describe node "$NODE_NAME")

# --- TOTAL ALLOCATABLE RESOURCES ---

# Extract the total allocatable CPU in millicores (m) and Memory in KiB
ALLOCATABLE_CPU=$(echo "$NODE_DESCRIPTION" | grep -A5 "Allocatable" | grep "cpu" | awk '{print $2}')
ALLOCATABLE_MEM=$(echo "$NODE_DESCRIPTION" | grep -A5 "Allocatable" | grep "memory" | awk '{print $2}')

# Convert CPU to millicores for consistent calculations
if [[ $ALLOCATABLE_CPU == *"m"* ]]; then
  ALLOCATABLE_CPU_MILLICORES=${ALLOCATABLE_CPU//m/}
else
  ALLOCATABLE_CPU_MILLICORES=$(echo "$ALLOCATABLE_CPU * 1000" | bc)
fi

# Convert Memory to KiB for consistent calculations
if [[ $ALLOCATABLE_MEM == *"Ki"* ]]; then
  ALLOCATABLE_MEM_KIBIBYTES=${ALLOCATABLE_MEM//Ki/}
elif [[ $ALLOCATABLE_MEM == *"Mi"* ]]; then
  ALLOCATABLE_MEM_KIBIBYTES=$(echo "${ALLOCATABLE_MEM//Mi/} * 1024" | bc)
elif [[ $ALLOCATABLE_MEM == *"Gi"* ]]; then
  ALLOCATABLE_MEM_KIBIBYTES=$(echo "${ALLOCATABLE_MEM//Gi/} * 1024 * 1024" | bc)
else
  ALLOCATABLE_MEM_KIBIBYTES=${ALLOCATABLE_MEM}
fi


# --- REQUESTED RESOURCES ---

# Extract and sum the requested CPU and Memory for all pods on the node
REQUESTED_RESOURCES=$(echo "$NODE_DESCRIPTION" | awk '/Non-terminated Pods/,/Allocated resources/' | grep -v "Non-terminated Pods" | grep -v "Allocated resources" | tail -n +2 | awk '{print $3, $5}')

REQUESTED_CPU_MILLICORES=0
REQUESTED_MEM_KIBIBYTES=0

while read -r CPU_REQ MEM_REQ; do
  # Process CPU requests
  if [[ $CPU_REQ == *"m"* ]]; then
    REQUESTED_CPU_MILLICORES=$((REQUESTED_CPU_MILLICORES + ${CPU_REQ//m/}))
  fi

  # Process Memory requests
  if [[ $MEM_REQ == *"Ki"* ]]; then
    REQUESTED_MEM_KIBIBYTES=$((REQUESTED_MEM_KIBIBYTES + ${MEM_REQ//Ki/}))
  elif [[ $MEM_REQ == *"Mi"* ]]; then
    REQUESTED_MEM_KIBIBYTES=$((REQUESTED_MEM_KIBIBYTES + $(echo "${MEM_REQ//Mi/} * 1024" | bc)))
  elif [[ $MEM_REQ == *"Gi"* ]]; then
    REQUESTED_MEM_KIBIBYTES=$((REQUESTED_MEM_KIBIBYTES + $(echo "${MEM_REQ//Gi/} * 1024 * 1024" | bc)))
  fi
done <<< "$REQUESTED_RESOURCES"


# --- REMAINING RESOURCES ---

# Calculate the remaining resources
REMAINING_CPU_MILLICORES=$((ALLOCATABLE_CPU_MILLICORES - REQUESTED_CPU_MILLICORES))
REMAINING_MEM_KIBIBYTES=$((ALLOCATABLE_MEM_KIBIBYTES - REQUESTED_MEM_KIBIBYTES))

# --- CONVERT MEMORY TO GB FOR DISPLAY ---
# Using bc for floating point arithmetic to convert KiB to GB (1 GB = 1024 * 1024 KiB)
# scale=2 sets the precision to two decimal places.
ALLOCATABLE_MEM_GB=$(echo "scale=2; $ALLOCATABLE_MEM_KIBIBYTES / (1024*1024)" | bc)
REQUESTED_MEM_GB=$(echo "scale=2; $REQUESTED_MEM_KIBIBYTES / (1024*1024)" | bc)
REMAINING_MEM_GB=$(echo "scale=2; $REMAINING_MEM_KIBIBYTES / (1024*1024)" | bc)


# --- DISPLAY REPORT ---

echo "Total Allocatable Resources:"
echo "  vCPU: $ALLOCATABLE_CPU_MILLICORES m"
echo "  RAM:  $ALLOCATABLE_MEM_GB GB"
echo

echo "Total Requested Resources by Pods:"
echo "  vCPU: $REQUESTED_CPU_MILLICORES m"
echo "  RAM:  $REQUESTED_MEM_GB GB"
echo

echo "Remaining Available Resources:"
echo "  vCPU: $REMAINING_CPU_MILLICORES m"
echo "  RAM:  $REMAINING_MEM_GB GB"
echo

