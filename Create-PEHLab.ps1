Function Create-VM
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $VMName,
         [Parameter(Mandatory=$false, Position=1)]
         [string] $IP
    )

#Creates the VM from a provided ISO & answer file, names it provided VMName
Set-Location "C:\VM_Stuff_Share\PEH"
$isoFilePath = "..\Windows_Server_2019_Datacenter_EVAL_en-us.iso"
$answerFilePath = ".\autounattend.xml"

New-Item -ItemType Directory -Path C:\Hyper-V_VMs\$VMName

$convertParams = @{
    SourcePath        = $isoFilePath
    SizeBytes         = 100GB
    Edition           = 'Windows Server 2019 Datacenter Evaluation (Desktop Experience)'
    VHDFormat         = 'VHDX'
    VHDPath           = "C:\Hyper-V_VMs\$VMName\$VMName.vhdx"
    DiskLayout        = 'UEFI'
    UnattendPath      = $answerFilePath
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
. '..\Convert-WindowsImage (from PS Gallery)\Convert-WindowsImage.ps1'

Convert-WindowsImage @convertParams

New-VM -Name $VMName -Path "C:\Hyper-V_VMs\$VMName" -MemoryStartupBytes 6GB -Generation 2
Connect-VMNetworkAdapter -VMName $VMName -Name "Network Adapter" -SwitchName Testing
$vm = Get-Vm -Name $VMName
$vm | Add-VMHardDiskDrive -Path "C:\Hyper-V_VMs\$VMName\$VMName.vhdx"
$bootOrder = ($vm | Get-VMFirmware).Bootorder
#$bootOrder = ($vm | Get-VMBios).StartupOrder
if ($bootOrder[0].BootType -ne 'Drive') {
    $vm | Set-VMFirmware -FirstBootDevice $vm.HardDrives[0]
    #Set-VMBios $vm -StartupOrder @("IDE", "CD", "Floppy", "LegacyNetworkAdapter")
}
Start-VM -Name $VMName
}#Close the Create-VM function

Create-VM -VMName Marvel-DC
Create-VM -VMName ThePunisher
Create-VM -VMName Spiderman
Write-Host "Please wait, the VMs are booting up."
Start-Sleep -Seconds 180

[string]$userName = 'marvel\Administrator'
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's local admin, initial name:
[string]$userName = "Changme\Administrator"
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$InitialVMCreds = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's local admin, after VM re-name:
[string]$userName = "Marvel-DC\Administrator"
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CredObject1 = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#--- Config the VMs ---

Invoke-Command -VMName "Marvel-DC" -FilePath ".\VMConfig (DC P1).ps1" -Credential $InitialVMCreds
Start-Sleep -Seconds 180
Invoke-Command -VMName "Marvel-DC" -FilePath ".\VMConfig (DC P2).ps1" -Credential $CredObject1
Start-Sleep -Seconds 180
Invoke-Command -VMName "Marvel-DC" -FilePath ".\VMConfig (DC P3).ps1" -Credential $DomainAdminCredObject

#VM's local admin, after VM re-name:
[string]$userName = "ThePunisher\Administrator"
[string]$userPassword = 'Password1!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CredObject2 = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "ThePunisher" -FilePath ".\VMConfig (ThePunisher P1).ps1" -Credential $InitialVMCreds #Configs the IP, DNS, re-names the VM
Start-Sleep -Seconds 180
Invoke-Command -VMName "ThePunisher" -FilePath ".\VMConfig (ThePunisher P2).ps1" -Credential $CredObject2 #Just joins the domain, Computer Name doesn't matter
Start-Sleep -Seconds 180
Invoke-Command -VMName "ThePunisher" -FilePath ".\VMConfig (ThePunisher P3).ps1" -Credential $DomainAdminCredObject #Makes marvel\fcastle a local admin & grabs PingCastle

#VM's local admin, after VM re-name:
[string]$userName = "Spiderman\Administrator"
[string]$userPassword = 'Password1!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CredObject3 = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#marvel\pparker's creds
[string]$userName = 'marvel\pparker'
[string]$userPassword = 'Password2'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$CredObject4 = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Spiderman" -FilePath ".\VMConfig (Spiderman P1).ps1" -Credential $InitialVMCreds #Configs the IP, DNS, re-names the VM
Start-Sleep -Seconds 180
Invoke-Command -VMName "Spiderman" -FilePath ".\VMConfig (ThePunisher P2).ps1" -Credential $CredObject3 #Just joins the domain, Computer Name doesn't matter
Start-Sleep -Seconds 180
Invoke-Command -VMName "Spiderman" -FilePath ".\VMConfig (Spiderman P3).ps1" -Credential $DomainAdminCredObject #Makes marvel\fcastle & marvel\pparker local admins
Invoke-Command -VMName "Spiderman" {New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\Marvel-DC\HackMe" -Credential $using:DomainAdminCredObject -Persist} -Credential $CredObject4 #map Z drive
Invoke-Command -VMName "Spiderman" -FilePath "C:\VM_Stuff_Share\PEH\VMConfig (Spiderman P4).ps1" -Credential $CredObject4 | Out-Null #Stores Marvel\Administrator creds in credman on Spiderman