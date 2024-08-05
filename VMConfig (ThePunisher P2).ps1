[string]$userName = 'Administrator@marvel.local'
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

If($env:USERDOMAIN -ne "marvel")
{
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
Add-Computer -DomainName marvel.local -Credential $credObject -restart -force
}

Else{Write-Host "System is already on the domain." | Out-Null}