
## Azure login

```bash
az login
```

Use the details on the `Resources` tab to login to the Azure portal.
You can click on the `T` icon to type the credentials into the browser.

## Clone the repository and open VS Code

```bash
git clone https://github.com/matt-FFFFFF/terraform-azure-avm-ptn-enterprise-minecraft.git
cd terraform-azure-avm-ptn-enterprise-minecraft
code .
```

## Set your subscription id in Terraform

Find your subscription id by running the following command:

```bash
az account show --query id
```

Now edit the `terraform.tf` file and set the `subscription_id` variable to the value you just found.
Change the provider block to look like this:

```hcl
provider "azurerm" {
  subscription_id = "00000000-0000-0000-0000-000000000000" # Change this to your subscription id
  features {}
}
```

## Install the base infrastructure

Some of these resources can take a few minutes to create, so please start this step as soon as possible.

```bash
terraform init
terraform apply
```

Note the public IP address output, you will need this if you are intending to connect to the server.

## Inspect the configuration during apply

## (Optional) Install Minecraft (Java Edition) on your company laptop

If you have a Minecraft account, you can install the game on your company laptop to test the world.

> Note you must have a license to play minecraft - you can use GamePass or purchase the game from the store.

<https://aka.ms/minecraftClientGameCoreWindows>

## Deploy the storage account private endpoint

In the `main.storage.tf` file, you will see a placeholder for the private endpoint configuration.
You need to configure the following fields to make the private endpoint work with the storage account:

- name
- subnet resource id
- sub-resource name (hint! this is `file` for Azure file storage)
- private DNS zone resource IDs (this is a list of the resource IDs for all the private DNS zones that we want to associate)

Once you have configured the private endpoint, run `terraform apply` again.

## Deploy the container app

We now need to define the minecraft application.
As ever there is an AVM module to do this!

You can see this by running this command:

```shell
git checkout finalanswer main.container_app.tf
```

Have a look at the file, then run `terraform apply` to deploy the workload.

## Check the container logs

In the Azure portal, look at the output from the container.
Check that the server has started successfully.

## (Optional) Connect to the server

Using your minecraft client, or a proctor's client, connect to the server.

## Stop the container and restore the data

In the Azure portal, stop the container.

Using Azure Storage Explorer, connect to your storage account.
In the minecraft data share, delete the `world` directory.

Downlaod and unzip the `world.zip` file supplied to you by the proctors.
Copy the world directory from your lab VM to the Azure File share.

## Start the container

In the Azure portal, start the container.
Check the logs for errors.

## Connect to the restored world

Using yours, or a proctor's minecraft client, connect to your server.
You should see that the world is different!

## Completion

Thanks for completing the Azure Verified Modules lab.
We hope that you have seen how AVM can be used to simplify the process of re-host migration in Azure.
