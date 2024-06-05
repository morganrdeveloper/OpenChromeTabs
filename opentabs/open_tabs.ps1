param (
    [string]$Set
)

# Load URLs from the JSON file
$urlData = Get-Content -Path .\urls.json | ConvertFrom-Json

# Get an array of the set names (property names)
$availableSets = $urlData.PSObject.Properties.Name

# Check if Set parameter is not provided
if (-not $Set) {
    Write-Host "Available sets:"
    foreach ($set in $availableSets) {
        Write-Host "- $set"
    }
    $Set = Read-Host -Prompt "Enter the set name you want to open: "

    # Check if the user-provided set name exists
    while (-not $urlData.PSObject.Properties.Name -contains $Set) {
        Write-Host "Invalid set name."
        $Set = Read-Host -Prompt "Enter the set name you want to open: "
    }
}

# Check if the specified set name exists
if (-not $urlData.PSObject.Properties.Name -contains $Set) {
    Write-Error "Invalid set name. Check the 'urls.json' file."
    return
}

$selectedUrls = $urlData.$Set

# Open the first URL in a new Chrome window
Start-Process "chrome.exe" -ArgumentList "--new-window", $selectedUrls[0]

# Open the rest of the URLs in new tabs within the new window
foreach ($url in $selectedUrls[1..($selectedUrls.Count - 1)]) {
    Start-Process "chrome.exe" -ArgumentList "--new-tab", $url
}