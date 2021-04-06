using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$GitHubCommentsAPI = $Request.RawBody

$Strings = @(
    "Request empty or not json, check GitHub webhook content type."
    "#sign-off"
)

# Throw error if no request.body.action
if (!$Request.RawBody) {throw $Strings[0]}

# GitHub POST body
$BodyObjectGitHub = @{
    body = $strings[1]
} | ConvertTo-Json

# Create GitHub comment
$GitHubHeader = @{authorization = "Token $env:GitHubPAT"}
$status = Invoke-RestMethod -Uri $Request.RawBody -Method Post -ContentType "application/json-patch+json" -Headers $GitHubHeader -Body $BodyObjectGitHub