param($Timer)

$GitHubHeader = @{authorization = "Token $env:GitHubPAT"}
Try {$pr = Invoke-RestMethod -Uri $env:PullRequestsAPI -Method Get -Headers $GitHubHeader}
Catch {throw $_.Exception.Message}

function Send-TeamsMessage ($url) {

    $webhookMessage = @{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "Doc GitHub automation"
        "themeColor" = '700015'
        "title"      = "Public to private pull request awaiting approval."
        "text"       = "Please review the pull request found at <a href=$url>$url</a>"
    }
    
     
    $webhookJSON = convertto-json $webhookMessage -Depth 50
     
    $webhookCall = @{
        "URI"         = $env:TeamsWebHook
        "Method"      = 'POST'
        "Body"        = $webhookJSON
        "ContentType" = 'application/json'
    }
     
    Invoke-RestMethod @webhookCall
}

foreach ($item in $pr) {
    if ($item.title -like $env:TitleFilter) {
        
        $creationDate = $item.created_at
        $dateDiff = ((get-date) - ($creationDate))

        if ($dateDiff.Days -gt 1) {
            Send-TeamsMessage($item.html_url)
            # write-output $item
        }
    }
}