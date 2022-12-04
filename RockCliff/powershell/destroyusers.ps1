$env:PSModulePath = $env:PSModulePath + ";" + (Get-Location)

Import-Module -Name phxfunctions -Force -DisableNameChecking

# Destroy-AzADUser "Leonora.Renee@phoenixfinancialcapital.onmicrosoft.com"

$users = import-csv "usernamelist.csv" 

# This doesn't account for duplicate users with numbers in their upns
foreach ($user in $users) {
    $upn = $user.FirstName + "." + $user.LastName + "@phoenixfinancialcapital.onmicrosoft.com"
    Destroy-AzADUser $upn
} 