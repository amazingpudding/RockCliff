$env:PSModulePath = $env:PSModulePath + ";" + (Get-Location)
Import-Module -Name phxfunctions -Force -DisableNameChecking

login-usingsp

# Create static groups
$existinggroups = Get-MgGroup
foreach ($department in @("Finance","Legal","Markets","Operations")) {
    if ($existinggroups.DisplayName -notcontains "ADG_$department") {
        New-MgGroup -DisplayName "ADG_$department" -MailEnabled:$false -MailNickname $department -SecurityEnabled
    }
}

# Create dynamic group (if dept -ne null) and assign licenses to it
$dynamicgroupname = "ADG_All_Users"
if ($existinggroups.DisplayName -notcontains $dynamicgroupname) {
    New-MgGroup -DisplayName $dynamicgroupname -MailEnabled:$false -MailNickname $dynamicgroupname -SecurityEnabled -GroupTypes "DynamicMembership" -MembershipRule "(user.department -ne null)" -MembershipRuleProcessingState "On"
}

# Sleep here to allow groups to finish provisioning
sleep 5

# Import user mapping file
$users = (import-csv "usernamelist.csv")
$userupnspws = @();

# Provision users with random passwords and join to group
foreach ($userobj in $users)
{ 
    # Generate random password
    $randompassword = Generate-RandomPassword 16
    
    # Create manipulatable useraadobj
    $useraadobj = Create-AzADUser $userobj $randompassword
    
    # Assign user to relevant group
    $targetgroupdisplayname = "ADG_" + $useraadobj.department
    New-MgGroupMember -GroupId ($existinggroups | ? DisplayName -eq $targetgroupdisplayname).Id -DirectoryObjectId $useraadobj.Id
    
    # For the purposes of this project only! Write useraadobj to an array with upns and passwords
    $userupnspws += $useraadobj | select DisplayName, UserPrincipalName, @{N="password";E={$randompassword}}
}

# Write users and passwords array to a file
$userupnspws | Export-Csv .\userspws.csv -NoTypeInformation

$env:PSModulePath = "C:\Users\ccrain.TREMBLANT\Documents\PowerShell\Modules;C:\Program Files\PowerShell\Modules;c:\program files\powershell\7\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules"