#
# Version 1, Problem formatting application table using native winget search command is difficult.
#
################################
# Global Variables
$pathroot = $PSScriptRoot
$wingetsearchresult = "$pathroot\winget_search_results.txt"
$wingetcleanresult = "$pathroot\winget_clean_results.txt"
$converttocsv = "$pathroot\winget_convert_results.csv"


function application-search {
#clean previous search:
$filesToRemove = @("$wingetsearchresult", "$wingetcleanresult", "$converttocsv")


foreach ($file in $filesToRemove) {
    if (Test-Path -Path $file) {
        Remove-Item -Path $file
        Write-Host "Removed $file"
    } else {
        Write-Host "$file not found"
    }
}

################################
# Prompt Admin for ID software lookup
# save this as winget-search-wrapper.ps1
write-host "Enter the application to search" -ForegroundColor Yellow
$appName = Read-Host "Application to Search"

# Execute winget search and capture the results
$searchResults = winget search $appName

# Write the results to the specified output file
$searchResults | Out-File -FilePath $wingetsearchresult -Encoding UTF8

Write-Host "Search results for '$appName' have been written to $wingetsearchresult"



###################################
# save this as remove-first-three-lines.ps1

# Read the contents of the text file
$content = Get-Content -Path $wingetsearchresult

# Skip the first three lines
$filteredContent1 = $content[3..$($content.Length - 1)] 

# Filter out lines starting with "-"
$filteredContent2 = $filteredContent1 | Where-Object { $_ -notmatch "^-+" } | Out-File -FilePath $wingetcleanresult -Encoding UTF8



###################################

# Prepare content for Powershell import and handling.
# Read the contents of the text file
$content = Get-Content -Path $wingetcleanresult

# Split the content by lines and trim any extra spaces
$lines = $content | ForEach-Object { $_.Trim() }

# Extract the headers and data
$headers = $lines[0] -split "\s+"
$data = $lines[1..($lines.Length - 1)]

# Create an array of custom objects
$csvData = @()
foreach ($line in $data) {
    if ($line -ne "") {
        $values = $line -split "\s{2,}"
        $obj = New-Object PSObject -Property @{
            Name = $values[0]
            Id = $values[1]
            Version = $values[2]
            Match = $values[3]
            Source = $values[4]
        }
        $csvData += $obj
    }
}

# Export the data to a CSV file
$csvData | Export-Csv -Path $converttocsv -NoTypeInformation

Write-Host "Converted content has been written to $converttocsv"

###################################
# User Output
$csvoutdata = Import-Csv -Path $converttocsv

# Display the data in an Out-GridView and allow the user to select a product
$selectedItem = $csvoutdata | Out-GridView -PassThru -Title "Select an application"

# Output the selected application ID
if ($selectedItem -ne $null) {

    $var = $selectedItem.Id
    Write-Host "Selected Application ID: $($selecteditem.name, "-", $selectedItem.Id)"
    write-host "Creating Install Code"
    "winget install --id $var -h" >> "$pathroot\installjob.ps1"
    "winget upgrade --id $var -h" >> "$pathroot\updatejob.ps1"
    "winget uninstall --id $var -h" >> "$pathroot\uninstalljob.ps1"
} else {
    Write-Host "No application selected."
}


}



#Clean Install,Uninstall,Upgrade Scripts
function Reset-Files {

$install = "$pathroot\installjob.ps1"
$update = "$pathroot\updatejob.ps1"
$uninstall = "$pathroot\uninstalljob.ps1"

$filesToRemove = @("$install", "$update", "$uninstall","$wingetsearchresult", "$wingetcleanresult", "$converttocsv")



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

