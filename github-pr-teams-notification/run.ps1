param($Timer)

$Strings = @(
    "Doc GitHub automation"
    "Pull request awaiting approval"
)

# Get pull request diff and format for Teams.
function Get-PullRequestDiff ($diff) {

    # Get Pull Request diff from GitHub diff API.
    Try {$diff = Invoke-RestMethod -Uri $pull.diff_url -Method Get -Headers $GitHubHeader}
    Catch {throw $_.Exception.Message}

    # Format diff for Teams webhook (add line break)
    $lines = $diff.Split([Environment]::NewLine) | ? { $_ -ne "" }
    foreach ($pull in $lines) {
        $results += "$pull <br>"
    }
    return $results
}

# Send a message to a Teams channel which includes the URL of the pull request and pull request details.
function Send-TeamsMessage ($PullDetails, $diff) {

    # Adaptive cards are not yet supported in Teams, here we are using a message card.
    # https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference
    $webhookMessage = @{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = $Strings[0]
        "title"      = $Strings[1]
        "themeColor" = '0078D7'
        "sections" = @(
            @{
                "activityTitle" = $PullDetails.user.login
                "activitySubtitle" = $PullDetails.created_at
                "activityImage" = $PullDetails.user.avatar_url
                "activityText" = $PullDetails.title
            }
            @{
                "activityTitle" = "Pull Request Diff"
                "activityText" = $diff
            }
        )
        "potentialAction" = @(
            @{
                '@type' = "OpenUri"
                name = "View PR"
                targets = @(
                    @{
                    "os" = "default"
                    "uri" = $PullDetails.html_url
                    }
                )
            }
            @{
                '@type' = "HttpPOST"
                name = "Sign Off"
                target = $env:CommentFunctionWebhook
                body = $PullDetails.comments_url
            }
        )
    } | ConvertTo-Json -Depth 50
         
    $webhookCall = @{
        "URI"         = $env:TeamsWebHook
        "Method"      = 'POST'
        "Body"        = $webhookMessage
        "ContentType" = 'application/json'
    }

    Invoke-RestMethod @webhookCall
}

# Get pull requests from GitHub pulls API.
$GitHubHeader = @{authorization = "Token $env:GitHubPAT"}
Try {$pulls = Invoke-RestMethod -Uri $env:PullRequestsAPI -Method Get -Headers $GitHubHeader}
Catch {throw $_.Exception.Message}

# Process pull requests and send Teams notification if applicable.
foreach ($pull in $pulls) {
    if ($pull.title -like $env:PullRequestTitleFilter) {
        $creationDate = $pull.created_at
        $dateDiff = ((get-date) - ($creationDate))

        if ($dateDiff.Days -lt $env:DelayDays) {     
            $finalDiff = Get-PullRequestDiff($pull)
            Send-TeamsMessage $pull $finalDiff
        }
    }
}