# List of URLs to open
$urls = @(
    "https://creator.nightcafe.studio/my-creations",
    "https://www.canva.com/",
    "https://app.leonardo.ai/",
    "https://www.capcut.com/" 
)

# Open Chrome with the first URL
Start-Process "chrome.exe" $urls[0]

# Open the rest of the URLs in new tabs
foreach ($url in $urls[1..($urls.Count - 1)]) {
    Start-Process "chrome.exe" -ArgumentList "--new-tab", $url
}