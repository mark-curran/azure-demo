#!/bin/bash

echo "Executing Terraform remote state setup script."

RESOURCE_GROUP_CONFIG_FILE="resource_group.json"
STORAGE_ACCOUNT_FILE="storage_account.json"

# Azure resource group and location
echo "Reading config file: $RESOURCE_GROUP_CONFIG_FILE"
RESOURCE_GROUP_NAME=$(jq -r '.RESOURCE_GROUP_NAME' $RESOURCE_GROUP_CONFIG_FILE)
RESOURCE_GROUP_TAG_NAME=$(jq -r '.RESOURCE_GROUP_TAG_NAME' $RESOURCE_GROUP_CONFIG_FILE)


# Check if the storage_account.json file exists
echo "Checking if $STORAGE_ACCOUNT_FILE exists."
if [ -f "$STORAGE_ACCOUNT_FILE" ]; then
    echo "Storage account file exists. Reading STORAGE_ACCOUNT_NAME from it."
    
    # Read STORAGE_ACCOUNT_NAME from the file
    STORAGE_ACCOUNT_NAME=$(jq -r '.STORAGE_ACCOUNT_NAME' $STORAGE_ACCOUNT_FILE)
else

    echo "Store account file does not exist, checking for storage account name."

    # Fetch the current subscription from the configured cli.
    echo "Fetching current subscription id."
    SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
    echo "Current subscruption id: $SUBSCRIPTION_ID"

    # Check if the resource group exists
    echo "Checking if resource group $RESOURCE_GROUP_NAME exists."
    az group show --name $RESOURCE_GROUP_NAME > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Resource group $RESOURCE_GROUP_NAME does not exist. Creating it."
        az group create --name $RESOURCE_GROUP_NAME
    else
        echo "Resource group $RESOURCE_GROUP_NAME already exists."
    fi

    # Check if the tag exists in the resource group
    echo "Checking if STORAGE_ACCOUNT_NAME exists as a tag on the resource group."
    STORAGE_ACCOUNT_NAME=$(az resource show --id /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME --query "tags.$RESOURCE_GROUP_TAG_NAME" -o tsv)

    # If the tag doesn't exist, create and store a new unique storage account name
    if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
        echo "Tag $RESOURCE_GROUP_TAG_NAME not found. Generating a new storage account name."
        
        # Generate a globally unique storage account name using $RANDOM
        STORAGE_ACCOUNT_NAME="tfstate$RANDOM$RANDOM$RANDOM"
    
        echo "New storage account name: $STORAGE_ACCOUNT_NAME"
    fi

    # Add the tag to the resource group
    echo "Adding tag $RESOURCE_GROUP_TAG_NAME:$STORAGE_ACCOUNT_NAME to the resource group $RESOURCE_GROUP_NAME"
    az resource tag --tags $RESOURCE_GROUP_TAG_NAME=$STORAGE_ACCOUNT_NAME --id /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME

    # Store the generated storage account name in the local JSON file
    echo "Storing key value pair $RESOURCE_GROUP_TAG_NAME : $STORAGE_ACCOUNT_NAME in the file  $STORAGE_ACCOUNT_FILE"
    echo "{\"STORAGE_ACCOUNT_NAME\": \"$STORAGE_ACCOUNT_NAME\"}" > $STORAGE_ACCOUNT_FILE
fi

# Registering the Microsoft.Storage resource provider.
echo "Attempting to register with the Microsoft.Storage resource provider and waiting for response."
az provider register --namespace Microsoft.Storage --wait
# Create the storage account using the fetched or newly generated name
echo "Creating storage account named $STORAGE_ACCOUNT_NAME if it doesn't already exist."
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# # Create a blob container for the remote state
echo "Creating blob container called 'tfstate' inside storage account $STORAGE_ACCOUNT_NAME if it doesn't already exist."
az storage container create --name tfstate --account-name $STORAGE_ACCOUNT_NAME

echo ""
echo "Storage account $STORAGE_ACCOUNT_NAME and blob container 'tfstate' should now exist."
echo "Resources for Terraform remote state should now exist."