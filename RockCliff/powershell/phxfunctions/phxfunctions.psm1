function login-usingsp {
    param (
        [bool]$installmodule = $false,
        [bool]$importmodule = $false
    )

    if ($installmodule -eq $true) {
        Install-Module Microsoft.Graph
    }

    if ($importmodule -eq $true) {
        Import-Module Microsoft.Graph
    }

    $CERT_THUMB = "3978C513B8C19823E9E1FE81E8BC1F31E74ABC57"
    $APP_ID = "2f2e20c5-3e9a-41bc-a0bc-1811da5e74c7"
    $TENANT_ID = "5ed94e26-7014-467d-a249-b97cc8fbb45c"
    
    try {
        Connect-MgGraph -ClientID $APP_ID -TenantId $TENANT_ID -CertificateThumbprint $CERT_THUMB | Out-Null
        $mgcontext = Get-MgContext
        Write-Host "Successfully connected via app" $mgcontext.AppName "with authtype" $mgcontext.AuthType "with the following scopes:" -ForegroundColor Green
        foreach ($scope in $mgcontext.scopes) {
            Write-Host $scope -ForegroundColor Green
        }

    }
    catch {
        Write-Host "Authentication failed! Check to make sure you have the correct cert in your store (thumbprint: $CERT_THUMB)" -BackgroundColor Darkred
    }

}

function Generate-RandomUserNamesFile {
    param (
        [string]$path = (Split-Path -Parent (Get-Location)) + "\baby-names.csv"
    )
    $usernamelist = New-Object System.Collections.ArrayList

    $namelist = import-csv $path

    $telephoneprefix = "212-111-1"
    $financesuffix = 101
    $legalsuffix = 201
    $operationssuffix = 301
    $marketssuffix = 401

    do {
        # Referring to an array with index seems much faster than doing a plain $namelist.name | Get-Random
        $randomfirstname = $namelist.name[(Get-Random -Maximum $namelist.count)]
        $randomlastname = $namelist.name[(Get-Random -Maximum $namelist.count)]
        
        switch ($usernamelist.count)
            {
                ({$_ -le 24}) {$department = "Finance"; $telephonenumber = $telephoneprefix + ($financesuffix++).tostring()}
                ({$_ -ge 25 -and $_ -le 49})  {$department = "Legal"; $telephonenumber = $telephoneprefix + ($legalsuffix++).tostring()}
                ({$_ -ge 50 -and $_ -le 74}) {$department = "Operations"; $telephonenumber = $telephoneprefix + ($operationssuffix++).tostring()}
                ({$_ -ge 75 -and $_ -le 100}) {$department = "Markets"; $telephonenumber = $telephoneprefix + ($marketssuffix++).tostring()}
            }

        $userobj = New-Object System.Object
        $userobj | Add-Member -MemberType NoteProperty -Name "FirstName" -Value $randomfirstname
        $userobj | Add-Member -MemberType NoteProperty -Name "LastName" -Value $randomlastname
        $userobj | Add-Member -MemberType NoteProperty -Name "Department" -Value $department
        $userobj | Add-Member -MemberType NoteProperty -Name "TelephoneNumber" -Value $telephonenumber
    
        $usernamelist += $userobj
            
    }
    
    until ($usernamelist.count -eq 100)
    
    $usernamelist | ? Department -ne "" | Export-Csv -Path "usernamelist.csv" -NoTypeInformation
    
}

function Create-AzADUser {
    param (
        [Parameter(Mandatory=$True)] [Object[]]$userobj,
        [Parameter(Mandatory=$True)] [string]$randompassword
    )
    $PasswordProfile = @{Password = $randompassword}
    $displayname = ($userobj.Firstname + " " + $userobj.LastName)
    $mailnickname = $displayname.replace(" ",".")
    
    # Check to see if user with same name exists and if so how many. This cmdlet initializes a $usercount variable automatically
    Get-MgUser -ConsistencyLevel eventual -Count userCount -Search ("DisplayName:$displayname") | Out-Null
    if ($usercount -gt 0) {
        $upn = ($mailnickname + ($usercount + 1).tostring() + '@phoenixfinancialcapital.onmicrosoft.com')
    }
    else {$upn = ($mailnickname + "@phoenixfinancialcapital.onmicrosoft.com")}
    
    try {
        $useraadobj = New-MgUser -DisplayName $displayname -PasswordProfile $PasswordProfile  -UserPrincipalName $upn  -AccountEnabled -MailNickName $mailnickname -CompanyName "Phoenix Financial Capital" -Department $userobj.Department -ShowInAddressList -BusinessPhones $userobj.TelephoneNumber
        Write-Host "Created user" $displayname "on the" $userobj.Department "team with phone number" $userobj.TelephoneNumber "and UPN" $useraadobj.UserPrincipalName
    }
    catch {
        Write-Host "Unable to create user" $upn"!" -BackgroundColor Darkred
    }

    $useraadobj | Add-Member -NotePropertyName "department" -NotePropertyValue $userobj.Department -Force

    return $useraadobj

}

function Destroy-AzADUser {
    param (
    [Parameter(Mandatory=$True)] [string]$upn
    )
    Write-Host "Removing user" $upn

    $userid = (Get-MgUser -ConsistencyLevel eventual -Count userCount -Search ("UserPrincipalName:$upn")).id 

    Remove-MgUser -UserId $upn

}

function Generate-RandomPassword {  
    param (
        [Parameter(Mandatory)]
        [int] $length
    )
    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
    #$charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
 
    $rng.GetBytes($bytes)
 
    $result = New-Object char[]($length)
 
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i]%$charSet.Length]
    }
 
    return (-join $result)
}

function connect-tocitrix {
    Set-XDCredentials -CustomerId "nhlfmfxoftji” -SecureClientFile “secureclient.csv” -ProfileType CloudAPI –StoreAs “default”

}