# poc-aws-env

This is a POC aimed at creating an environment for a devops team to work on the aws cloud
 
The layout of this environment is as follows:
 
* A single parent VPC within which all other resources are placed
* Two subnets within the parent VPC:
   - Subnet 1
      * All developers workstations are located here. DevOps engineers have full control over their own individual resources
      * Developers have also some rights over some of the shared resources.
   - Subnet 2
      * All server-based resources are located here. The SysOps role is the only one granted management rights over the resources in subnet 2.
* The roles needed are as follows:
   - Client - Anyone that accesses to the services deployed in the aws VPC
   - Support - Anyone who can configure all the resources within the VPC, including both subnet 1 and subnet 2
   - DevOps - Anyone who exploits the resources in the subnet 1 and, indirectly, the shared resources in the subnet 2.
