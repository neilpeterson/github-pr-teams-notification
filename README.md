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
az group create --name github-pr-teams-notification --location eastus
```

Run the following command to initiate the deployment (update with details from your environment).

```azurecli
az deployment group create \
    --resource-group github-pr-teams-notification \
    --template-uri https://raw.githubusercontent.com/neilpeterson/github-pr-teams-notification/master/deployment/azuredeploy.json \
    --parameters GitHubPAT=<> emailAddress=nepeters@microsoft.com
```

Add `RemoveSourceControll=true` to remove source controll integration.

```azurecli
az deployment group create \
    --resource-group github-pr-teams-notification \
    --template-uri https://raw.githubusercontent.com/neilpeterson/github-pr-teams-notification/master/deployment/azuredeploy.json \
    --parameters GitHubPAT=<> emailAddress=nepeters@microsoft.com RemoveSourceControll=true
```