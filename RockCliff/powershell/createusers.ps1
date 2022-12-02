$env:PSModulePath = $env:PSModulePath + ";" + (Get-Location)
Import-Module -Name phxfunctions -Force -DisableNameChecking

login-usingsp

# Create static groups

# Create dynamic group (if dept -ne null OR upn is chris.crain@phoenixfinancialcapital.onmicrosoft.com)

# Assign dynamic group virtual machine logon role at the subscription level

# Import user mapping file
$users = (import-csv "usernamelist.csv")
$userupnspws = @();

# Provision users with random passwords
foreach ($userobj in $users)
{ 
    $randompassword = Generate-RandomPassword 16
    Create-AzADUser $userobj $randompassword

    # For the purposes of this project only- export all upns and passwords
    $userupnspws += $userobj | select FirstName, LastName, @{N="password";E={$randompassword}}

}

# Write userupnspws file for demo purposes
$userupnspws | Export-Csv .\userspws.csv -NoTypeInformation

# Apparently the department attribute doesn't immediately reflect. Sleep here for 15 seconds.
sleep 15

# Seems more efficient to loop through the groups and check their current members than looping through each user and checking their group membership. Will write a separate function for one off group additions
# Also worth noting dynamic groups that look at the department may be the better option here depending on future flexibility requirements
foreach ($group in Get-MgGroup | ? displayname -like "ADG_*") {
    $groupmemberids = (Get-MgGroupMember -GroupId $group.Id).Id
    $depttoken = $group.DisplayName.replace("ADG_","")
    Get-MgUser -ConsistencyLevel eventual -Count userCount -Search ("Department:$depttoken") | % {
        if ($groupmemberids -notcontains $_.Id) {
            Write-Host "Adding" $_.UserPrincipalName "to" $group.DisplayName
            New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $_.Id
        }
    }

}



$env:PSModulePath = "C:\Users\ccrain.TREMBLANT\Documents\PowerShell\Modules;C:\Program Files\PowerShell\Modules;c:\program files\powershell\7\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules"