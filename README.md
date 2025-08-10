## Data Services on ECS/RKE2 Tools

<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>check_cmluser_mapping.sh</b></p>

- Run this script in the ECS master node to check the mapping between CML username and the Kubernetes (ECS) namespace name provisioned for that particular username of interest. This script can also generate all CML usernames' mapping.

```diff
# ./check_cmluser_mapping.sh 
Enter the CML workspace name: cmlws1
Enter a username or 'all' for all users: dennislee
 username  |   namespace   
-----------+---------------
 dennislee | cmlws1-user-1
```
```
# ./check_cmluser_mapping.sh 
Enter the CML workspace name: cmlws1
Enter a username or 'all' for all users: illegitimate_user
The user illegitimate_user is not found in the CML workspace cmlws1.
```

<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>remove_ecs.sh</b></p>

- Run this script in each ECS node to remove/uninstall the ECS software. Subsequently, reboot the node.


<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>pvc_check.sh</b></p>

- Run this script at the node (with kubectl command) to identify which pod(s) is/are currently attached to the specific PVC in the particular namespace.


<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>check-node.sh</b></p>

 - Run this script to report the total allocatable resources, the resources requested by pods, and the remaining balance that can be requested.

<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>check-gpu.sh</b></p>

 - Run this script to check for nodes with `nvidia.com/gpu` in a Kubernetes cluster and lists the pods that are requesting those GPU resources.
