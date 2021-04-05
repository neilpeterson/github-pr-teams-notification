param($Timer)

# Once a day, get all pull requests
$GitHubHeader = @{authorization = "Token $env:GitHubPAT"}
Try {$pr = Invoke-RestMethod -Uri $env:PullRequestsAPI -Method Get -Headers $GitHubHeader}
Catch {throw $_.Exception.Message}

# Get pull request diff and format for Teams.
function Get-PullRequestDiff ($diff) {

    # Get Pull Request diff from GitHub diff API.
    Try {$diff = Invoke-RestMethod -Uri $item.diff_url -Method Get -Headers $GitHubHeader}
    Catch {throw $_.Exception.Message}

    # Format diff for Teams webhook.
    $lines = $diff.Split([Environment]::NewLine) | ? { $_ -ne "" }
    foreach ($item in $lines) {
        $results += "$item <br>"
    }
    return $results
}

# Send a message to a Teams channel which includes the URL of the pull request and pull request details.
function Send-TeamsMessage ($url, $diff) {

    $webhookMessage = @{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "Doc GitHub automation"
        "themeColor" = '700015'
        "title"      = "Public to private pull request awaiting approval."
        "text"       = $diff
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

foreach ($item in $pr) {
    if ($item.title -like $env:TitleFilter) {
        
        # Determine if the date delay threshold has been breached.
        $creationDate = $item.created_at
        $dateDiff = ((get-date) - ($creationDate))

        # If so, get pull request details, format the diff, and send Teams message.
        if ($dateDiff.Days -gt $env:DelayDays) {     
            $finalDiff = Get-PullRequestDiff($item)
            Send-TeamsMessage $item.html_url $finalDiff
        }
    }
}