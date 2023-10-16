## CML on ECS Useful Tools

<p align="left"><img src="https://github.com/dennislee22/ECS/blob/main/cldrlogo.png" alt="c" width="20" height="20"/>check_cmluser_mapping.sh </p>
* Objective: Run this script in the ECS/OCP master node to check the mapping between CML username and the Kubernetes (OCP/ECS) namespace name provisioned for that particular username of interest. This script can also generate all CML usernames mapping.

````diff
# ./check_cmluser_mapping.sh 
Enter the CML workspace name: cmlws1
Enter a username or 'all' for all users: illegitimate_user
The user illegitimate_user is not found in the CML workspace cmlws1.
```
