# Terraform Setup

Sets up the remote terraform state.

## Setup

Make sure you've setup the `az` cli and run the az_setup script in the root directory of this repo.

Then run the Terraform remote state setup script. 

```bash
sh remote_state_setup.sh
```

This will create the remote state in Azure storage if it doesn't already exist.
