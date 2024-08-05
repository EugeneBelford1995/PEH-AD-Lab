[string]$userName = 'marvel\Administrator'
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Spiderman" -FilePath ".\LNK_File.ps1" -Credential $DomainAdminCredObject