# Load URLs from the JSON file
$urlData = Get-Content -Path .\urls.json | ConvertFrom-Json

try {
    $urlData = Get-Content -Path .\urls.json | ConvertFrom-Json
} catch {
    Write-Error "Error: The 'urls.json' file was not found. Please make sure it exists in the same directory as this script."
    return  # Exit the script
}

# Get an array of the set names (property names)
$availableSets = $urlData.PSObject.Properties.Name

# Function to display available sets and get user input
function GetValidSetName {
    Write-Host "Available sets:"
    foreach ($set in $availableSets) {
        Write-Host "- $set"
    }
    return Read-Host -Prompt "Enter the set name you want to open (or 'exit' to quit): "
}

# Keep prompting until a valid set is chosen or user types 'exit'
do {
    # If Set parameter is provided, check if it's valid
    if ($Set) {
        if ($urlData.PSObject.Properties.Name -contains $Set) {
            $selectedUrls = $urlData.$Set
            break  # Exit the loop if a valid set is provided as a parameter
        } else {
            Write-Host "Invalid set name provided as parameter."
            $Set = $null
        }
    }
    
    $Set = GetValidSetName
    if ($Set -eq "exit") {
        return  # Exit the script if the user types 'exit'
    }

    # Check if the set name exists
    if ($urlData.PSObject.Properties.Name -contains $Set) {
        $selectedUrls = $urlData.$Set
    } else {
        Write-Host "No URLs found for set: $Set"
    }
} while (-not $selectedUrls)


# Open the first URL in a new Chrome window
if ($selectedUrls) {
    Start-Process "chrome.exe" -ArgumentList "--new-window", $selectedUrls[0]

    # Open the rest of the URLs in new tabs within the new window
    foreach ($url in $selectedUrls[1..($selectedUrls.Count - 1)]) {
        Start-Process "chrome.exe" -ArgumentList "--new-tab", $url
    }
} 
