# Enterprise minecraft lab

## Target Audience

This lab guidance is **Level 300** and will guide participants through the **deployment of Azure resources using Bicep OR Terraform with Azure Verified Modules (AVM)**.

It demonstrates how AVM simplifies Infrastructure-as-Code (IaC) practices by offering pre-built, reusable, and secure modules that ensure compliance and operational excellence.

Participants will **learn how to implement scalable, resilient, and secure architectures using these modules**, aligning with enterprise standards and best practices for resource provisioning in Azure.

## Foreword

**If you have any questions** or the need for more clarity on what is happening during the lab, please don't hesitate to **raise your hand to get help by our proctors**.

Good luck!

## Table of Contents

The following experiences are covered in this course. Select the appropriate path:

- [Bicep](#bicep-instructions)

- [Terraform](#terraform-instructions)

===

# Bicep instructions

Welcome to the bicep instructions for LAB310: Infra-as-Code based migrations with Azure Verified Modules

In this repository ++<https://github.com/ChrisSidebotham/avm-bicep-lab-minecraft/tree/main++> you will find the content to get started with the deployment under the lab folder. You should use the `sample.main.bicep` to get started with your deployment. The samples look like as follows:

```bicep
module vnet 'br/public:avm/res/network/virtual-network:0.x.x' = {

}
```

**Tasks**

- You should update the version to the appropiate version
- You should complete all of the required parameters for the resource deployment

## Tips

- Remember to use `ctrl+space` to bring up intellisense
- Hover over the 'friendly name' of the resource (e.g vnet) for a link to the documentation:

!IMAGE[LAB310_bicep_01.jpg](instructions281460/LAB310_bicep_01.jpg)

## Scenario

- Contoso wants to migrate its LoB application to Azure
- Re-factor the app to run using cloud-native services
- A container + persistent storage
- Implement well-architected reliability and security best-practices
- App is isolated with dedicated ingress/egress

### Target Architecture

!IMAGE[LAB310_architecture.jpg](instructions281460/LAB310_architecture.jpg)

### Requirements

- Use Azure Verified Modules
- Use Managed Identities
- Private Endpoints must be utilised for connectivity
- Vnet Integration for Container Apps
- Azure Firewall should be used as the cental ingress/egress point
- Minecraft image used should be `itzg/docker-minecraft-server`

## Deployment Commands

To deploy your resources to the azure subscription within the lab, you can use your own commands or some quickstarts are provided below:

### Create the Resource group

```bash
az login
az group create -n 'lab310-rg'
```

### Create the Resources using Deployment Stacks

```bash
cd <Enter location of Directory holding main.bicep>
az login
az stack group create -n 'lab310stack01' -g 'lab310-rg' --template-file .\main.bicep --dm none --aou detachAll --yes
```

===

**Congratulations, you have completed all tasks in this lab**

[**Go back to the main table of content**](#table-of-contents)

===

# Terraform instructions

Welcome to the Terraform instructions for LAB310: Infra-as-Code based migrations with Azure Verified Modules

In this repository ++<https://github.com/matt-ffffff/terraform-azure-avm-ptn-enterprise-minecraft++> you will find the content to get started with the deployment.

## Scenario

- Contoso wants to migrate its LoB application to Azure
- Re-factor the app to run using cloud-native services
- A container + persistent storage
- Implement well-architected reliability and security best-practices
- App is isolated with dedicated ingress/egress

### Target Architecture

!IMAGE[LAB310_architecture.jpg](instructions281460/LAB310_architecture.jpg)

1. [ ] Azure login

    ```shell
    az login -t "@lab.CloudSubscription.TenantId" -u "@lab.CloudPortalCredential(User1).Username" -p "@lab.CloudPortalCredential(User1).Password"
    az account set --subscription "@lab.CloudSubscription.Id"
    echo 'logged in'
    ```

    Use the details on the `Resources` tab to login to the Azure portal.
    You can click on the `T` icon to type the credentials into the browser.

1. [ ]  Clone the repository and open VS Code

    ```shell
    git clone https://github.com/matt-FFFFFF/terraform-azure-avm-ptn-enterprise-minecraft.git
    cd terraform-azure-avm-ptn-enterprise-minecraft
    code .
    echo 'vscode opened'
    ```

1. [ ] Set your subscription id in Terraform

    Open the `terraform.tf` file and paste in this information:

    ```hcl
    provider "azurerm" {
      subscription_id = "@lab.CloudSubscription.Id"
      features {}
    }
    ```

===

# Terraform instructions 2

1. [ ] Install the base infrastructure

    Some of these resources can take a few minutes to create, so please start this step as soon as possible!

    ```shell
    terraform init && terraform apply
    echo 'apply complete'
    ```

1. [ ] Inspect the configuration during apply

    Take a look at the terraform configuration that you have started with.
    Understand how the modules we have selected correcpond to the architecture.

    Look how the AVM modules are used together to deploy this enterprise style configuration.

    Look at the [AVM interface definitions](https://azure.github.io/Azure-Verified-Modules/specs/tf/interfaces/) and see how they are implemented identically on each resource module.

1. [ ] (Optional) Install Minecraft Java Edition on your laptop

    If you have a Minecraft account, you can install the game on your laptop to test the world when it is deployed.

    > Note you must have a license to play minecraft - you can use GamePass or purchase the game from the store.

    <https://aka.ms/minecraftClientGameCoreWindows>

1. [ ] Deploy the container app

    We now need to define the minecraft application.
    As ever there is an AVM module to do this!

    You can see this by running this command:

    ```shell
    git checkout finalanswer main.container_app.tf
    echo 'checked out the container app file'
    ```

    Have a look at the file, then run `terraform apply` to deploy the workload.

    ```shell
    terraform apply
    echo 'deployed the container app'
    ```

1. [ ] Check the container logs

    Open @lab.CloudPortal.Link, look at the output from the container.
    Check that the server has started successfully.

    - Go to your container app in the Azure portal.

    - Select Log stream under the Monitoring section on the sidebar menu.

    - To view the console log stream, select Console.

1. [ ] (Optional) Connect to the server

    Using your minecraft client, or a proctor's client, connect to the server using the public IP address displayed after the `terraform apply` command.

===

# Terraform instructions 3

1. [ ] Stop the container and restore the data

    - In the Azure portal, stop the container.

    - Using Azure Storage Explorer, connect to your Azure subscription using the plug socket icon.

    - In the minecraft data share, delete the `world` directory.

    - Download and unzip the [`world.zip`](https://stgavmlab84732.blob.core.windows.net/data/world.zip) file.

    - Copy the world directory from your lab VM to the Azure File share.

1. [ ] Start the container

    - Open @lab.CloudPortal.Link, and start the container.
    - Check the logs for errors.

1. [ ] Connect to the restored world

    Using your own, or a proctor's minecraft client, connect to your server.
    You should see that the world is different!

1. [ ] Complete!

    Congratulations on completing the lab!
