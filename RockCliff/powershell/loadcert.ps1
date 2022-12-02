$pwd = "Cherokee!"
$notAfter = (Get-Date).AddMonths(6) # Valid for 6 months
$thumb = (New-SelfSignedCertificate -DnsName "phoenixfinancial.onmicrosoft.com" -CertStoreLocation "cert:\LocalMachine\My"  -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
$pwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText
Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath C:\Users\ccrain.TREMBLANT\Documents\Git\SRProject\certs\client.pfx -Password $pwd

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("C:\Users\ccrain.TREMBLANT\Documents\Git\SRProject\certs\client.pfx", $pwd)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

$application = New-AzureADApplication -DisplayName "Phoenix AD SP" -IdentifierUris "https://rodejo2177668"
New-AzureADApplicationKeyCredential -ObjectId $application.ObjectId -CustomKeyIdentifier "PhxCert" -Type AsymmetricX509Cert -Usage Verify -Value $keyValue -EndDate $notAfter