# Azure Red Hat OpenShift creation script

This script creates an Azure Red Hat OpenShift cluster. This script assumes your target resource group, virtual network, and subnet all exist. Your execution user must also have access to create and assign roles to service principals in AAD.

# Evironment Variables Required:

```
SUBSCRIPTIONID=                 # Id of the target Azure Subscription
LOCATION=                       # Azure region location of your cluster
RESOURCEGROUP=                  # Name of the resource group where you want to create your cluster object
CLUSTEROBJECTSRESOURCEGROUP=    # Resource group which will contain all the supporting Azure resources
CLUSTERNAME=                    # Name of your cluster
VIRTUALNETWORKNAME=             # Name of the target virtual network
VIRTUALNETWORKRESOURCEGROUP=    # Name of the virtual network resouce group
MASTERSUBNETNAME=               # Subnet where the the cluster master will be deployed to
WORKERSUBNETNAME=               # Subnet where there cluster worker nodes will be deployed to
CLUSTERSPNAME=                  # Cluster service principal client/application/object id
CLUSTERSPCLIENTSECRET=          # Cluster service principal client secret
SSOAPPREGNAME=                  # Name of the SSO application registration
SSOCLIENTSECRET=                # SSO Azure AD application client secret
CUSTOMCLUSTERDOMAIN=            # Custom domain for the cluster
DNSZONERESOURCEGROUP=           # Resource froup name of the custom domain
INGRESSVISIBILITY=              # Configures ingress for the cluster, must be Public or Private
MASTERNODESIZE=                 # Master node size
WORKERNODESIZE=                 # Worker node size
WORKERNODECOUNT=                # Worker node count
WORKERNODEDISKSIZE=             # Worker node disk size
```

The above variables are expected to be in an .env file for script execution.

# OpenShift CLI for MacOS Installation:

```
cd ~
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-mac.tar.gz

mkdir openshift
tar -zxvf openshift-client-mac.tar.gz -C openshift
echo 'export PATH=$PATH:~/openshift' >> ~/.bashrc && source ~/.bashrc
```

# TODO:
 * Move permissions assigned to use Microsoft Graph OpenId Connect Scopes instead of Azure AD Graph.
