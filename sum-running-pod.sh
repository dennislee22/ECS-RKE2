#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

namespace="$1"

# Check if the namespace exists
if kubectl get namespace "$namespace" > /dev/null 2>&1; then
    echo "Namespace '$namespace' exists."
else
    echo "Warning: Namespace '$namespace' does not exist!"
    exit 1 # Exit if the namespace doesn't exist
fi

# Get CPU requests for running pods
echo "---"
echo "Calculating CPU requests for running pods in namespace: $namespace"

# Using field-selector to only get running pods
res_cpu=$(kubectl -n "$namespace" get pods --field-selector=status.phase=Running -o=jsonpath='{.items[*]..resources.requests.cpu}')
let tot=0

if [ -z "$res_cpu" ]; then
    echo "No running pods with CPU requests found in namespace '$namespace'."
else
    for i in $res_cpu
    do
        if [[ $i =~ "m" ]]; then
            # Remove 'm' and add to total
            i=$(echo "$i" | sed 's/m//g')
            tot=$(( tot + i ))
        else
            # Assume units are full cores if no 'm' is present, convert to milli-cores
            tot=$(( tot + i*1000 ))
        fi
    done
    echo "Total CPU requests for running pods in $namespace ns: $tot m"
fi

# Get Memory requests for all pods
echo "---"
echo "Calculating Memory requests for all pods in namespace: $namespace"
res_mem=$(kubectl -n "$namespace" get pods -o=jsonpath='{.items[*]..resources.requests.memory}')
let tot_mem=0

if [ -z "$res_mem" ]; then
    echo "No pods with memory requests found in namespace '$namespace'."
else
    for i in $res_mem
    do
        # Handling common Kubernetes memory units
        if [[ $i =~ "Gi" ]]; then
            i=$(echo "$i" | sed 's/Gi//g')
            tot_mem=$(( tot_mem + i*1024 )) # Convert GiB to MiB
        elif [[ $i =~ "Mi" ]]; then
            i=$(echo "$i" | sed 's/Mi//g')
            tot_mem=$(( tot_mem + i ))
        elif [[ $i =~ "G" ]] || [[ $i =~ "g" ]]; then
            # Assuming G or g without 'i' means Gigabytes, convert to MiB (1000 MB)
            i=$(echo "$i" | sed 's/[Gg]//g')
            tot_mem=$(( tot_mem + i*1000 ))
        elif [[ $i =~ "M" ]] || [[ $i =~ "m" ]]; then
            # Assuming M or m without 'i' means Megabytes, convert to MiB (1000 KB)
            i=$(echo "$i" | sed 's/[Mm]//g')
            tot_mem=$(( tot_mem + i )) # For simplicity, treating M as MiB here
        else # Assume bytes if no unit, convert to MiB
            i=$(echo "$i" | sed 's/[^0-9]*//g')
            tot_mem=$(( tot_mem + i/1048576 )) # 1024*1024 bytes in 1 MiB
        fi
    done
    echo "Total Memory requests for all pods in $namespace ns: $tot_mem MiB"
fi


# Get PVC requests
echo "---"
echo "Calculating PVC requests in namespace: $namespace"
res_pvc=$(kubectl -n "$namespace" get pvc -o=jsonpath='{.items[*].spec.resources.requests.storage}')
let tot_pvc=0

if [ -z "$res_pvc" ]; then
    echo "No PVCs with storage requests found in namespace '$namespace'."
else
    for i in $res_pvc
    do
        # Handling common Kubernetes storage units
        if [[ $i =~ "Ti" ]]; then
            i=$(echo "$i" | sed 's/Ti//g')
            tot_pvc=$(( tot_pvc + i*1024 )) # Convert TiB to GiB
        elif [[ $i =~ "Gi" ]]; then
            i=$(echo "$i" | sed 's/Gi//g')
            tot_pvc=$(( tot_pvc + i ))
        elif [[ $i =~ "Mi" ]]; then
            i=$(echo "$i" | sed 's/Mi//g')
            tot_pvc=$(( tot_pvc + i/1024 )) # Convert MiB to GiB
        elif [[ $i =~ "Ki" ]]; then
            i=$(echo "$i" | sed 's/Ki//g')
            tot_pvc=$(( tot_pvc + i/1048576 )) # Convert KiB to GiB (1024*1024)
        elif [[ $i =~ "T" ]] || [[ $i =~ "t" ]]; then
            # Assuming T or t without 'i' means Terabytes, convert to GiB (1000 GB)
            i=$(echo "$i" | sed 's/[Tt]//g')
            tot_pvc=$(( tot_pvc + i*1000 ))
        elif [[ $i =~ "G" ]] || [[ $i =~ "g" ]]; then
            # Assuming G or g without 'i' means Gigabytes, convert to GiB (1000 MB)
            i=$(echo "$i" | sed 's/[Gg]//g')
            tot_pvc=$(( tot_pvc + i )) # For simplicity, treating G as GiB here
        elif [[ $i =~ "M" ]] || [[ $i =~ "m" ]]; then
            # Assuming M or m without 'i' means Megabytes, convert to GiB
            i=$(echo "$i" | sed 's/[Mm]//g')
            tot_pvc=$(( tot_pvc + i/1000 )) # For simplicity, treating M as MB then to GB (1000MB per GB)
        else # Assume bytes if no unit, convert to GiB
            i=$(echo "$i" | sed 's/[^0-9]*//g')
            tot_pvc=$(( tot_pvc + i/1073741824 )) # 1024*1024*1024 bytes in 1 GiB
        fi
    done
    echo "Sum of PVC requests in $namespace ns: $tot_pvc GiB"
fi
