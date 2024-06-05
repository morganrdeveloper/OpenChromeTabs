param (
    [string]$Set
)

#region Functions

function GetUrlData {
    try {
        $urlData = Get-Content -Path .\urls.json | ConvertFrom-Json
    } catch {
        Write-Error "Error: The 'urls.json' file was not found or is invalid. Please check the file."
        return $null 
    }

    # Validate all URLs in all sets
    $urlRegex = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'
    foreach ($set in $urlData.PSObject.Properties) {
        foreach ($url in $set.Value) {
            if (-not ([regex]::IsMatch($url, $urlRegex))) {
                throw "Invalid URL format found in set '$($set.Name)': $url"
            }
        }
    }

    return $urlData
}

function GetAvailableSets($urlData) {
    return $urlData.PSObject.Properties.Name
}

function DisplayAvailableSets($availableSets) {
    Write-Host "Available sets:"
    foreach ($set in $availableSets) {
        Write-Host "- $set"
    }
}

function GetValidSetName($availableSets) {
    DisplayAvailableSets $availableSets
    return Read-Host -Prompt "Enter the set name you want to open (or 'exit' to quit): "
}

#endregion Functions

# Get URL data and validate it
$urlData = GetUrlData
if (-not $urlData) { return }  # Exit if there was an error loading/validating the URL data
$availableSets = GetAvailableSets $urlData

# Check if Set parameter is provided and valid, otherwise prompt the user
if ($PSBoundParameters.ContainsKey('Set')) {
    # Check if the set name exists
    if ($availableSets -contains $Set) {
        $selectedUrls = $urlData.$Set
    } else { # If the set name is invalid
        Write-Host "Invalid set name provided as parameter."
        $Set = $null
    }
}

# If selectedUrls is still null (parameter not provided or invalid)
if (-not $selectedUrls) {
    # Get a valid set name from the user
    do {
        $Set = GetValidSetName $availableSets
    } while ($Set -ne "exit" -and -not ($availableSets -contains $Set))

    # Get the selected URLs
    $selectedUrls = $urlData.$Set
}

# Open URLs if a valid set was chosen
if ($Set -ne "exit") {
    # Check if any URL was found
    if ($selectedUrls) {
        # Open the first URL in a new Chrome window, then the rest in tabs
        $firstUrl = $selectedUrls[0]
        $remainingUrls = $selectedUrls | Select-Object -Skip 1 
        Start-Process "chrome.exe" -ArgumentList "--new-window $firstUrl"
        foreach ($url in $remainingUrls) {
            Start-Process "chrome.exe" -ArgumentList "--new-tab $url"
        }
    } else {
        Write-Host "No URLs found for set: $Set"
    }
}
