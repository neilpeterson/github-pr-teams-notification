# GitHub ADO Sync

## Configuration

## Solution deployment parameters

| Parameter | Type | Description |
|---|---|---|
| GitHubPAT | securestring | GitHub personal access token. |
| EmailAddress | string | Email address where function failure alerts will be sent. |
| RemoveSourceControll | bool | When true, removes source control integration. |

## Solution deployment

Create a resource group for the deployment.

```azurecli
az group create --name github-pr-teams-notification-003 --location eastus
```

Run the following command to initiate the deployment (update with details from your environment).

```azurecli
az deployment group create \
    --resource-group github-pr-teams-notification-003 \
    --template-uri https://raw.githubusercontent.com/neilpeterson/github-pr-teams-notification/master/deployment/azuredeploy.json \
    --parameters emailAddress=nepeters@microsoft.com RemoveSourceControll=true
```

Add `RemoveSourceControll=true` to remove source controll integration.

```azurecli
az deployment group create \
    --resource-group github-pr-teams-notification \
    --template-uri https://raw.githubusercontent.com/neilpeterson/github-pr-teams-notification/master/deployment/azuredeploy.json \
    --parameters GitHubPAT=<> emailAddress=nepeters@microsoft.com RemoveSourceControll=true
```

## Configure WebHook on Function

Once the deployment has completed, retrieve the Function webhook address from the comment function, and add this to the Teams notification function's application configuration.