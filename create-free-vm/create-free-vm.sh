#!/bin/bash
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
  echo "please specify all three arguments: username password rpd_location"
  exit 1
fi

RG=rg-win-free
LOCATION=centralus
VMNAME=win-free-vm
USERNAME=$1
PASSWORD=$2
IMAGE=MicrosoftWindowsServer:WindowsServer:2019-datacenter-smalldisk-g2:latest
VNET=win-free-vnet
VNET_PREFIX=192.168.0.0/24
SUBNET=win-free-subnet
SUBNET_PREFIX=192.168.0.0/28
NSG=win-free-nsg
ASG=win-free-asg
RDP_LOCATION=$3
ODSG=64
SIZE=Standard_B1s
TAG="pjt=win-free"

# create resource group
az group create -g $RG -l $LOCATION --tags $TAG

# create nsg
az network nsg create -n $NSG -g $RG -l $LOCATION --tags $TAG 

# create asg
az network asg create -n $ASG -g $RG -l $LOCATION --tags $TAG

# create nsg rule
az network nsg rule create -n RDP --nsg-name $NSG --priority 3000 -g $RG --access Allow \
  --destination-asg $ASG --destination-port-ranges 3389 --direction InBound \
  --source-address-prefixes $RDP_LOCATION

# create vm with vnet, subnet
az vm create -g $RG -n $VMNAME --admin-username $USERNAME --admin-password $PASSWORD \
  --asgs $ASG --image $IMAGE -l $LOCATION --nsg $NSG --os-disk-size-gb $ODSG \
  --public-ip-address-allocation dynamic --size $SIZE --subnet $SUBNET --subnet-address-prefix $SUBNET_PREFIX \
  --tags $TAG --vnet-address-prefix $VNET_PREFIX --vnet-name $VNET
