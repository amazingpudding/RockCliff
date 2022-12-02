$env:PSModulePath = $env:PSModulePath + ";" + (Get-Location)

Import-Module -Name phxfunctions -Force -DisableNameChecking

Generate-RandomUserNamesFile

$env:PSModulePath = "C:\Users\ccrain.TREMBLANT\Documents\PowerShell\Modules;C:\Program Files\PowerShell\Modules;c:\program files\powershell\7\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules"