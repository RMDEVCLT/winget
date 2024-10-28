################################
# Global Variables
$pathroot = $PSScriptRoot
$install = "$pathroot\installjob.ps1"
$update = "$pathroot\updatejob.ps1"
$uninstall = "$pathroot\uninstalljob.ps1"


function application-search {
# Prompt user for application name
$appName = Read-Host "Enter the application name to search for"

# Construct the URL
# Main site: https://winget.run/ Meta data site, collection of all available winget repositories.
$url = "https://api.winget.run/v2/packages?ensureContains=true&partialMatch=true&take=12&query=$appName&order=1"
# alternative to using the API, example: winget search "notepad++" 

$response = Invoke-RestMethod -Uri $url

#only get ID and Publisher data from web response.
$regex = '"Id":"(.*?)".*?"Publisher":"(.*?)"'
$matches = [regex]::Matches($response, $regex)

#setup custom objects for powershell use.
$extractedInfo = $matches | ForEach-Object {
    [PSCustomObject]@{
        Id        = $_.Groups[1].Value
        Publisher = $_.Groups[2].Value
    }
}

# Display the data in an Out-GridView and allow the user to select a product
$selectedItem = $extractedInfo | Out-GridView -PassThru -Title "Select an application"

# Output the selected application ID
if ($selectedItem -ne $null) {

    $appid = $selectedItem.Id
    Write-Host "Selected Application ID: $($selecteditem.name, "-", $selectedItem.Id)"
    write-host "Creating Install Code"
    "winget install --id '$appid' -h" >> "$install"
    "winget upgrade --id '$appid' -h" >> "$update"
    "winget uninstall --id '$appid' -h" >> "$uninstall"
} else {
    Write-Host "No application selected."
}


}



#Clean Install,Uninstall,Upgrade Scripts
function Reset-Files {

$filesToRemove = @("$install", "$update", "$uninstall")



foreach ($file in $filesToRemove) {
    if (Test-Path -Path $file) {
        Remove-Item -Path $file
        Write-Host "Removed $file"
    } else {
        Write-Host "$file not found"
    }
}

}

# Main Program Loop
while ($true) {
    Write-Host "Select an option: [1] Build Instal File, [2] Reset Files, [3] Exit" -ForegroundColor Cyan
    $choice = Read-Host "Your choice"

    switch ($choice) {
        1 { application-search }
        2 { Reset-Files }
        3 { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid option, please select [1], [2], or [3]." }
    }
}

