# Creating a Custom Kubernetes in Azure Cloud

This repository talks about creating a custom / unmanaged Kubernetes in Azure cloud.
For creating a custom Kubernetes in any Cloud, we generally use KOPS. Since KOPS is currently not supporting Azure,
let's create a cluster ourselves.

## Using `az` to create the Kubernetes nodes

### Login to your Azure Subscription

This lists your available Azure Subscriptions
`az account list`

Then login using:

`az login --subscription <subscription ID>`

Set this subscription as default to avoid providing subscription in every command. This can be changed later

`az account set -s <subscription ID>`

### Create a Resource Group

To list all the available locations for your subscriptions, use the below command

`az account list-locations`

Now create a resource group

`az group create --location southindia --name custom-k8s`

### Create VNET and Subnets

Create a VNET and one Subnet for the nodes
```
az network vnet create --resource-group custom-k8s --name vnet --address-prefix 10.0.0.0/16 \
    --subnet-name subnet1 --subnet-prefix 10.0.0.0/24
```

Create another subnet for VPX - Front Facing

```
az network vnet subnet create --resource-group custom-k8s --vnet-name vnet --name subnet2 \
                            --address-prefixes 10.0.1.0/24
```

### Create Network Security Groups for the Subnets

**For Subnet 1:**

Create a Network Security Group

`az network nsg create --resource-group custom-k8s --name nsg-subnet1`

Create a NSG rule to allow HTTP Traffic from Internet

```
az network nsg rule create --resource-group custom-k8s --nsg-name nsg-subnet1 \
    --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound \
    --priority 100 --source-address-prefix Internet \
    --source-port-range "*" --destination-address-prefix "*" \
    --destination-port-range 80
```

Create a NSG rule to allow SSL Traffic from Internet

```
az network nsg rule create --resource-group custom-k8s --nsg-name nsg-subnet1 \
    --name Allow-HTTPS-All --access Allow --protocol Tcp --direction Inbound \
    --priority 200 --source-address-prefix Internet \
    --source-port-range "*" --destination-address-prefix "*" \
    --destination-port-range 443
```

Create a NSG rule to allow SSH Traffic from Internet

```
az network nsg rule create --resource-group custom-k8s --nsg-name nsg-subnet1 \
    --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound \
    --priority 300 --source-address-prefix Internet \
    --source-port-range "*" --destination-address-prefix "*" \
    --destination-port-range 22
```

Associate the NSG to the Subnet

```
az network vnet subnet update --vnet-name vnet --name subnet1 --resource-group custom-k8s \
    --network-security-group nsg-subnet1
```

**For Subnet 2:**

Create a Network Security Group

`az network nsg create --resource-group custom-k8s --name nsg-subnet2`

Create a NSG rule to allow HTTP Traffic from Internet

```
az network nsg rule create --resource-group custom-k8s --nsg-name nsg-subnet2 \
    --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound \
    --priority 100 --source-address-prefix Internet \
    --source-port-range "*" --destination-address-prefix "*" \
    --destination-port-range 80
```

Create a NSG rule to allow SSL Traffic from Internet

```
az network nsg rule create --resource-group custom-k8s --nsg-name nsg-subnet2 \
    --name Allow-HTTPS-All --access Allow --protocol Tcp --direction Inbound \
    --priority 200 --source-address-prefix Internet \
    --source-port-range "*" --destination-address-prefix "*" \
    --destination-port-range 443
```

Associate the NSG to the Subnet

```
az network vnet subnet update --vnet-name vnet --name subnet2 --resource-group custom-k8s \
    --network-security-group nsg-subnet2
```

### Create Ubuntu VMs

Create a Master node

```
az vm create --name master --resource-group custom-k8s --image UbuntuLTS \
    --public-ip-address master-pip --public-ip-address-allocation static \
    --vnet-name vnet --subnet subnet1 \
    --admin-username cicuser --admin-password '$CIC-user-password$'
```

Create a worker node 

```
az vm create --name worker1 --resource-group custom-k8s --image UbuntuLTS \
    --public-ip-address worker1-pip --public-ip-address-allocation static \
    --vnet-name vnet --subnet subnet1 \
    --admin-username cicuser --admin-password '$CIC-user-password$'
```

Create another worker node 

```
az vm create --name worker2 --resource-group custom-k8s --image UbuntuLTS \
    --public-ip-address worker2-pip --public-ip-address-allocation static \
    --vnet-name vnet --subnet subnet1 \
    --admin-username cicuser --admin-password '$CIC-user-password$'
```



## Delete the created Kubernetes Cluster

### Delete the VNET

`az network vnet delete --resource-group custom-k8s --name vnet`
