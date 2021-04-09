using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$Strings = @(
    "Request empty or not json, check GitHub webhook content type."
)

# Throw error if no request.body.action
if (!$Request.RawBody) {throw $Strings[0]}

$input = $Request.RawBody.Split(',')

# GitHub POST body
$BodyObjectGitHub = @{
    body = $input[0]
} | ConvertTo-Json

# Create GitHub comment
$GitHubHeader = @{authorization = "Token $env:GitHubPAT"}
Invoke-RestMethod -Uri $input[1] -Method Post -ContentType "application/json-patch+json" -Headers $GitHubHeader -Body $BodyObjectGitHub