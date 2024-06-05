param (
    [Parameter(Mandatory = $true)]
    [string]$Set
)

# Load URLs from the JSON file
$urlData = Get-Content -Path .\urls.json | ConvertFrom-Json

# Check if the specified array name exists
if (-not $urlData.ContainsKey($Set)) {
    Write-Error "Invalid array name. Check the 'urls.json' file."
    return
}

$selectedUrls = $urlData[$Set]

# Open the first URL in a new Chrome window
Start-Process "chrome.exe" -ArgumentList "--new-window", $selectedUrls[0]

# Open the rest of the URLs in new tabs within the new window
foreach ($url in $selectedUrls[1..($selectedUrls.Count - 1)]) {
    Start-Process "chrome.exe" -ArgumentList "--new-tab", $url
}
