param($Timer)

$Strings = @(
    "Doc GitHub automation"
    "Public to private pull request awaiting approval."
    "Pull Request Diff"
    "Please review or sign off on the pull request"
)

# Get pull request diff and format for Teams.
function Get-PullRequestDiff ($diff) {

    # Get Pull Request diff from GitHub diff API.
    Try {$diff = Invoke-RestMethod -Uri $pull.diff_url -Method Get -Headers $GitHubHeader}
    Catch {throw $_.Exception.Message}

    # Format diff for Teams webhook.
    $lines = $diff.Split([Environment]::NewLine) | ? { $_ -ne "" }
    foreach ($pull in $lines) {
        $results += "$pull <br>"
    }
    return $results
}

# Send a message to a Teams channel which includes the URL of the pull request and pull request details.
function Send-TeamsMessage ($url, $commentsUrl, $diff) {

    $webhookMessage = @{
        "@type"      = "ActionCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = $Strings[0]
        "themeColor" = '700015'
        "title"      = $Strings[1]
        # "text"       = $diff
        "sections" = @(
            @{
                "activityTitle" = $Strings[2]
            }
            @{
                "activityText" = $diff
            }
            @{
                "activityTitle" = $Strings[3]
            }
        )
        "potentialAction" = @(
            @{
                '@type' = "OpenUri"
                name = "View PR"
                targets = @(
                    @{
                    "os" = "default"
                    "uri" = $url
                    }
                )
            }
            @{
                '@type' = "HttpPOST"
                name = "Sign Off"
                target = $env:CommentFunctionWebhook
                body = $commentsUrl
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

        if ($dateDiff.Days -gt $env:DelayDays) {     
            $finalDiff = Get-PullRequestDiff($pull)
            Send-TeamsMessage $pull.html_url $pull.comments_url $finalDiff
        }
    }
}