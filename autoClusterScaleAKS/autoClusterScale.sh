#!/bin/bash
SUBSCRIPTION_ID=$(az account show --query id -o json | tr -d '"' | base64)
TENANT_ID=$(az account show --query tenantId -o json | tr -d '"' | base64)

read -p "What's your cluster name? " cluster_name
read -p "Resource group name? " resource_group

CLUSTER_NAME=$(echo $cluster_name | base64)
RESOURCE_GROUP=$(echo $resource_group | base64)

CLIENT_ID=$(echo $client_id | base64)
CLIENT_SECRET=$(echo $client_secret | base64)

NODE_RESOURCE_GROUP=$(az aks show --name $cluster_name  --resource-group $resource_group -o tsv --query 'nodeResourceGroup' | base64)

echo "---
apiVersion: v1
kind: Secret
metadata:
    name: cluster-autoscaler-azure
    namespace: kube-system
data:
    ClientID: $CLIENT_ID
    ClientSecret: $CLIENT_SECRET
    ResourceGroup: $RESOURCE_GROUP
    SubscriptionID: $SUBSCRIPTION_ID
    TenantID: $TENANT_ID
    VMType: QUtTCg==
    ClusterName: $CLUSTER_NAME
    NodeResourceGroup: $NODE_RESOURCE_GROUP
---"
