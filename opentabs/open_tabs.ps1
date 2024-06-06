[CmdletBinding()] 
param (
    [Parameter(Mandatory = $false)]  # Make the $Set parameter optional
    [string[]]$Set
)

#region Functions

# Function to read and validate URL data
function Get-UrlData {
    try {
        $urlData = Get-Content -Path .\urls.json | ConvertFrom-Json
    }
    catch {
        Write-Error "Error loading URLs: $_"
        return $null
    }

    $urlRegex = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'
    $urlData.PSObject.Properties.Value | ForEach-Object {
        if (-not ($_ -match $urlRegex)) {
            throw "Invalid URL: $_"
        }
    }
    return $urlData
}

# Function to get available set names
function Get-AvailableSets {
    param($urlData)
    return $urlData.PSObject.Properties.Name
}

# Function to display available sets
function Display-AvailableSets {
    param($availableSets)
    Write-Host "Available sets:"
    $availableSets | ForEach-Object { Write-Host "- $_" }
}

# Function to get a valid set name from user input
function Get-ValidSetName {
    param($availableSets)
    do {
        Display-AvailableSets $availableSets
        $setName = Read-Host -Prompt "Enter the set name (or 'exit'): "
    } while ($setName -ne "exit" -and -not $availableSets.Contains($setName))
    return $setName
}

# Function to validate parameters and open Chrome windows/tabs
function Open-Tabs {
    param(
        [string]$setName,
        [pscustomobject]$urlData
    )
    $selectedUrls = $urlData.$setName
    if ($selectedUrls) {
        Start-Process "chrome.exe" -ArgumentList "--new-window", $selectedUrls[0]
        $selectedUrls[1..$selectedUrls.Count] | ForEach-Object {
            Start-Process "chrome.exe" -ArgumentList "--new-tab", $_
            Start-Sleep -Milliseconds 200
        }
    } else {
        Write-Warning "No URLs found for set: $setName"
    }
}

#endregion Functions

# Get URL data and validate it
$urlData = Get-UrlData
if (-not $urlData) { return }  # Exit if there was an error
$availableSets = Get-AvailableSets $urlData

# Handle parameters or prompt for input
if ($Set) { 
    # Filter valid sets from the provided parameters
    $validSets = $Set | Where-Object { $availableSets -contains $_ }
    if (-not $validSets) {
        Write-Warning "No valid sets provided in parameters."
    } 
} else {
    $validSets = @(Get-ValidSetName $availableSets)  # Get set names from user input
}

# Open tabs for each valid set in separate Chrome windows
$validSets | Where-Object { $_ -ne "exit" } | ForEach-Object { Open-Tabs -setName $_ -urlData $urlData } 
