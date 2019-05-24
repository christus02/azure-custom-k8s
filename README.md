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
