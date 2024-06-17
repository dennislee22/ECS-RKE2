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
fi

res_cpu=$(kubectl -n $1 get pods -o=jsonpath='{.items[*]..resources.requests.cpu}')
let tot=0
res_mem=$(kubectl -n $1 get pods -o=jsonpath='{.items[*]..resources.requests.memory}')
let tot_mem=0
res_pvc=$(kubectl -n $1 get pvc -o=jsonpath='{.items[*].spec.resources.requests.storage}')
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
echo "Total CPU requests in $1 ns: $tot m"

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
echo "Total Memory requests in $1 ns: $tot_mem MiB"

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

echo "Sum of PVC requests in $1 ns: $tot_pvc GiB"
