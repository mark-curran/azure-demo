# Terraform Setup

Sets up the remote terraform state.

## Setup

Make sure you've setup the `az` cli and run the az_setup script in the root directory of this repo.

Then run the Terraform remote state setup script. 

```shell
source remote_state_setup.sh
```

This will create the remote state in Azure storage if it doesn't already exist, and export an access key for that state to the shell variable `ARM_ACCESS_KEY`. This variable will allow you to access the remote state.

## Details

A resource group scopes everything needed to manage the remote state. This resource group has a tag with the storage account name, which is globally scoped across Azure and needs to be globally unique.

Current method for initialising the backend only supports a User Principal, which is appropriate for private sandbox projects.

Will add default terraform variables to a git ignored filae `terraform.tfvars`.
