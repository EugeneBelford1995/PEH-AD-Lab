Write-Host "Generate-Traffic simulates a user on ThePunisher fat fingering a share drive name every 2 minutes."
Write-Host "Create-LNK -VMName Marvel-DC creates a LNK file on the hackme share to elecit authentication attempts."
Write-Host "Check your Kali VM's IP and put it in LNK_File.ps1, otherwise the LNK will point to the wrong target."

Function Generate-Traffic
{
#Run this on ThePunisher to simulate a user fat fingering a share drive
#On Kali: sudo responder -I eth0 -dwv

[string]$userName = 'marvel\fcastle'
[string]$userPassword = 'Password1'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$fcastleCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

$X = 0
Do
{
Invoke-Command -VMName "ThePunisher" {Get-Content "\\NoExist\C$"} -Credential $fcastleCredObject
Start-Sleep -Seconds 120
$X = $X + 1
}
While($X -le 10)
} #Close the function

Function Create-LNK
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $VMName,
         [Parameter(Mandatory=$false, Position=1)]
         [string] $IP
    )

[string]$userName = 'marvel\Administrator'
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "$VMName" -FilePath ".\LNK_File.ps1" -Credential $DomainAdminCredObject
} #Close the function