#!/bin/bash

# Function to check if a Kubernetes namespace exists
namespace_exists() {
  local namespace="$namespace"
  kubectl get namespace "$namespace" &>/dev/null
  return $?
}

# Function to highlight text in red
highlight_red() {
  echo -e "\e[41;97m$namespace\e[0m"
}

# Prompt the input for namespace
read -p "Enter the namespace: " namespace

# Check if the specified namespace exists
if ! namespace_exists "$namespace"; then
  echo "Namespace '$namespace' does not exist."
  exit 1
fi

res_cpu=$(kubectl -n $namespace get pods -o=jsonpath='{.items[*]..resources.requests.cpu}')
let tot=0
res_mem=$(kubectl -n $namespace get pods -o=jsonpath='{.items[*]..resources.requests.memory}')
let tot_mem=0
res_pvc=$(kubectl -n $namespace get pvc -o=jsonpath='{.items[*].spec.resources.requests.storage}')
let tot_pvc=0

for i in $res_cpu
do
if [[ $i =~ "m" ]]; then
i=$(echo $i | sed 's/[^0-9]*//g')
tot=$(( tot + i ))
else
tot=$(( tot + i*1000 ))
fi
done
echo "Total CPU requests in $(highlight_red "$namespace") ns: $tot m"

for i in $res_mem
do
if [[ $i =~ "M" ]] || [[ $i =~ "m" ]]
then
i=$(echo $i | sed 's/[^0-9]*//g')
tot_mem=$(( tot_mem + i ))
else
i=$(echo $i | sed 's/[^0-9]*//g')
tot_mem=$(( tot_mem + i*1000 ))
fi
done
echo "Total Memory requests in $(highlight_red "$namespace") ns: $tot_mem MiB"

for i in $res_pvc
do
if [[ $i =~ "G" ]] || [[ $i =~ "g" ]]
then
i=$(echo $i | sed 's/[^0-9]*//g')
tot_pvc=$(( tot_pvc + i ))
elif [[ $i =~ "M" ]] || [[ $i =~ "m" ]]
then
i=$(echo $i | sed 's/[^0-9]*//g')
tot_pvc=$(( tot_pvc + i/1000 ))
else
i=$(echo $i | sed 's/[^0-9]*//g')
tot_pvc=$(( tot_pvc + i*1000 ))
fi
done

echo "Sum of PVC requests in $(highlight_red "$namespace") ns: $tot_pvc GiB"
