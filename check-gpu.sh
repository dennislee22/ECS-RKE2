#!/bin/bash

# This script checks for nodes with NVIDIA GPUs in a Kubernetes cluster
# and lists the pods that are requesting those GPU resources.

# Set colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- Checking for GPU Nodes and Pods ---${NC}"

# Get all nodes that have the nvidia.com/gpu.count label.
# This label is a reliable way to find nodes with GPUs managed by the NVIDIA device plugin.
GPU_NODES=$(kubectl get nodes -l nvidia.com/gpu.count --no-headers -o custom-columns=NAME:.metadata.name)

if [ -z "$GPU_NODES" ]; then
    echo "No nodes with NVIDIA GPUs found in the cluster."
    exit 0
fi

# Loop through each node that has GPUs.
for node in $GPU_NODES; do
    echo -e "\n${GREEN}Node: $node${NC}"

    # Get the total number of GPUs on the node.
    GPU_CAPACITY=$(kubectl get node "$node" -o=jsonpath='{.status.capacity.nvidia\.com/gpu}')
    echo "  GPU Capacity: $GPU_CAPACITY"

    echo "  Pods requesting GPUs on this node:"

    # Get all pods running on the current node.
    # We use --field-selector to filter pods by the node name.
    PODS_ON_NODE=$(kubectl get pods --all-namespaces --no-headers -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name --field-selector spec.nodeName="$node")

    # A flag to check if any GPU pods are found on the node.
    found_gpu_pod=false

    # Loop through each pod on the node.
    while IFS= read -r line; do
        NAMESPACE=$(echo "$line" | awk '{print $1}')
        POD_NAME=$(echo "$line" | awk '{print $2}')

        # For each pod, check if it requests GPU resources.
        # We query the resource limits for nvidia.com/gpu.
        GPU_REQUEST=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o=jsonpath='{.spec.containers[*].resources.limits.nvidia\.com/gpu}' 2>/dev/null)

        if [[ -n "$GPU_REQUEST" && "$GPU_REQUEST" -gt 0 ]]; then
            echo "    - Namespace: $NAMESPACE, Pod: $POD_NAME, GPU Request: $GPU_REQUEST"
            found_gpu_pod=true
        fi
    done <<< "$PODS_ON_NODE"

    if [ "$found_gpu_pod" = false ]; then
        echo "    No pods requesting GPUs found on this node."
    fi
done

echo -e "\n${CYAN}--- Check complete ---${NC}"
