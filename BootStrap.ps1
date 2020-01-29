
<# 
 
.SYNOPSIS
	BootStrap.ps1 is a Windows PowerShell script to download and kickstart the Azure AD App Proxy Demo environment 
.DESCRIPTION
	Version: 1.0.0
	BootStrap.ps1 is a Windows PowerShell script to download and kickstart the Azure AD App Proxy Demo environment.
    It will install IIS completely, configure the application including KCD
.DISCLAIMER
	THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
	THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
	Copyright (c) Microsoft Corporation. All rights reserved.
#> 
cls

##This can be customized ensure the folder path has trailing "\" 
$destinationDirectory ="c:\AppDemov1\"
$NodeApp ="c:\NodeApp\"
$ParticipantCode=""

if ([int]$PSVersionTable.PSVersion.Major -lt 5)
{
    Write-Host "Minimum required version is PowerShell 5.0"
    Write-Host "Refer https://aka.ms/wmf5download"
    Write-Host "Program will terminate now .."
    exit
}


$DonotMatch =$true

while ($DonotMatch)
{
    [string] $Code =  Read-Host  "Enter   Participant Code" 
    [string] $Code2 =  Read-Host "Confirm Participant Code" 

    if($Code -eq $Code2)
    {
        $DonotMatch=$false
    }
    else
    {
        cls
        Write-Host "Codes Dont Match" 
    }
    
    $ParticipantCode = $Code
}


##Donot Modify
function Invoke-Script
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Script,

        [Parameter(Mandatory = $false)]
        [object[]]
        $ArgumentList
    )

    $ScriptBlock = [Scriptblock]::Create((Get-Content $Script -Raw))
    Invoke-Command -NoNewScope -ArgumentList $ArgumentList -ScriptBlock $ScriptBlock -Verbose
}


[string]$kickStartFolder = $destinationDirectory + "TR20AppsInstaller-master\Website\"
[string]$kickStartScript = $kickStartFolder + "install.ps1"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri "https://github.com/jeevanbisht/TR20AppsInstaller/archive/master.zip"
(New-Object Net.WebClient).DownloadFile('https://github.com/jeevanbisht/TR20AppsInstaller/archive/master.zip',"$env:TEMP\master.zip");
New-Item -Force -ItemType directory -Path $destinationDirectory
Expand-Archive  "$env:TEMP\master.zip" -DestinationPath $destinationDirectory -Force 

Invoke-WebRequest -Uri "https://github.com/japere/header-demo-app/archive/master.zip"
(New-Object Net.WebClient).DownloadFile('https://github.com/japere/header-demo-app/archive/master.zip',"$env:TEMP\nodeapp.zip");
New-Item -Force -ItemType directory -Path $NodeApp
Expand-Archive  "$env:TEMP\nodeapp.zip" -DestinationPath $NodeApp -Force 

$NodeJSPortFile = $NodeApp + "\header-demo-app-master\.env"
New-Item -ItemType file -path $NodeJSPortFile
$NodeConfig = "port =70" + $ParticipantCode
$NodeConfig > $NodeJSPortFile
    


$args = @()
$args += ("$kickStartFolder", "$ParticipantCode")
Invoke-Script $kickStartScript $args


