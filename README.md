# GitHub ADO Sync

## Configuration

To configure this solution:

- First, create a Teams webhook on the target Teams channel (docs).
- Deploy the templates found in this repository (instructions).
Add the Azure functions app webhook from the commenting function to the notification function's app settings (instructions).

## Solution deployment parameters

These values are needed when deploying the solution. At deployment time, you are prompted for each.

| Parameter | Type | Description |
|---|---|---|
| GitHubPAT | securestring | GitHub personal access token. |
| TeamsWebHook | string | Teams webhook URI. |
| PullRequestsAPI | string | Address of the pulls api for the target GitHub repository ([docs](https://docs.github.com/en/rest/reference/pulls)). |
| PullRequestTitleFilter | string | Pull requests are filtered on this value. |
| DelayDays | int | Only pull requests older than this value are processed. |
| EmailAddress | string | Email address where function failure alerts will be sent. |
| RemoveSourceControll | bool | When true, removes source control integration. |

## Solution deployment

Create a resource group for the deployment.

```azurecli
az group create --name github-pr-teams-notification --location eastus
```

Run the following command to initiate the deployment. When prompted, enter the value for each parameter.

```azurecli
az deployment group create \
    --resource-group github-pr-teams-notification-003 \
    --template-uri https://raw.githubusercontent.com/neilpeterson/github-pr-teams-notification/master/deployment/azuredeploy.json
```

Add `RemoveSourceControll=true` to remove source controll integration.

```azurecli
az deployment group create \
    --resource-group github-pr-teams-notification \
    --template-uri https://raw.githubusercontent.com/neilpeterson/github-pr-teams-notification/master/deployment/azuredeploy.json
    --parameters RemoveSourceControll=true
```

## Configure WebHook on Function

Once the deployment has completed, retrieve the Function webhook address from the comment function, and add this to the Teams notification function's application configuration.