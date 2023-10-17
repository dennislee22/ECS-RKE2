## Data Services on ECS/RKE2 Tools

<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>check_cmluser_mapping.sh</b></p>
* Objective: Run this script in the ECS master node to check the mapping between CML username and the Kubernetes (ECS) namespace name provisioned for that particular username of interest. This script can also generate all CML usernames' mapping.

```diff
# ./check_cmluser_mapping.sh 
Enter the CML namespace: cmlws1
Enter a username or 'all' for all users: dennislee
 username  |   namespace   
-----------+---------------
 dennislee | cmlws1-user-1

# ./check_cmluser_mapping.sh 
Enter the CML workspace name: cmlws1
Enter a username or 'all' for all users: illegitimate_user
The user illegitimate_user is not found in the CML workspace cmlws1.
```

<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/><b>remove_ecs.sh</b></p>
* Objective: Run this script in each ECS node to remove/uninstall the ECS software. Subsequently, reboot the node.
