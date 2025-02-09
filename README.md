
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

## Inspect the configuration during apply

## (Optional) Install Minecraft (Java Edition) on your company laptop

If you have a Minecraft account, you can install the game on your company laptop to test the world.

> Note you must have a license to play minecraft - you can use GamePass or purchase the game from the store.

<https://aka.ms/minecraftClientGameCoreWindows>
