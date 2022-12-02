# Install and import module
Install-Module Microsoft.Graph -Scope CurrentUser
Import-Module Microsoft.Graph

$certname = "phxcert"
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256

$mypwd = ConvertTo-SecureString -String "phxauto" -Force -AsPlainText  ## Replace {myPassword}
Export-PfxCertificate -Cert $cert -FilePath "$certname.pfx" -Password $mypwd   ## Specify your preferred location


# Connect via standard auth. 
Connect-MgGraph 

Connect-MgGraph 

#-ClientID 2f2e20c5-3e9a-41bc-a0bc-1811da5e74c7 -TenantId 5ed94e26-7014-467d-a249-b97cc8fbb45c #-CertificateName YOUR_CERT_SUBJECT ## Or -CertificateThumbprint instead of -CertificateName

$certname = "phxcert"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256

$CERT_THUMB = "3978C513B8C19823E9E1FE81E8BC1F31E74ABC57"
$CERT_SUBJ = "phxcert"
$APP_ID = "2f2e20c5-3e9a-41bc-a0bc-1811da5e74c7"
$TENANT_ID = "5ed94e26-7014-467d-a249-b97cc8fbb45c"

Connect-MgGraph -ClientID $APP_ID -TenantId $TENANT_ID -CertificateThumbprint $CERT_THUMB #-CertificateName $CERT_SUBJ ## Or -CertificateThumbprint instead of -CertificateName

Find-MgGraphCommand -Command 'Get-MgGroup' | select -first 1 permissions -expandproperty permissions

[System.Environment]::SetEnvironmentVariable('ARM_CLIENT_ID','2f2e20c5-3e9a-41bc-a0bc-1811da5e74c7')
[System.Environment]::SetEnvironmentVariable('ARM_CLIENT_CERTIFICATE_PATH','C:\Users\ccrain.TREMBLANT\Documents\Git\SRProject\certs\phxcert.pfx')
[System.Environment]::SetEnvironmentVariable('ARM_CLIENT_CERTIFICATE_PASSWORD','phxauto')
[System.Environment]::SetEnvironmentVariable('ARM_SUBSCRIPTION_ID','808499be-9a45-4135-9db5-997fbbe5626f')
[System.Environment]::SetEnvironmentVariable('ARM_TENANT_ID','5ed94e26-7014-467d-a249-b97cc8fbb45c')