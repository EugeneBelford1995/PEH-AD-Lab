#Map the HackMe share drive to Z as The Adminstrator, aka SID 500 on marvel.local
[string]$userName = 'marvel\Administrator'
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\Marvel-DC\HackMe" -Credential $DomainAdminCredObject -Persist
 
Install-Module -Name CredentialManager -Force -SkipPublisherCheck
New-StoredCredential -Comment "Access share drvie on Marvel-DC" -Credentials $DomainAdminCredObject -Target "Marvel-DC" -Persist Enterprise