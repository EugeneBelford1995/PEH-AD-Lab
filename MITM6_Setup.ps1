certutil -viewstore "ldap:///CN=marvel-MARVEL-DC-CA,CN=Certification Authorities,CN=Public Key Services,CN=Services,CN=Configuration,DC=marvel,DC=local?cACertificate?base?objectClass=certificationAuthority"

#If the cert doesn't show, publish it to a file and then
certutil -dspublish %certificatefilename% Root

[string]$userName = 'marvel\Administrator'
[string]$userPassword = 'P@$$w0rd!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Enable IPv6 for the MITM6 lab
Invoke-Command -VMName "ThePunisher" {$NIC = (Get-NetAdapter).InterfaceAlias ; Enable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6} -Credential $DomainAdminCredObject
Invoke-Command -VMName "Spiderman" {$NIC = (Get-NetAdapter).InterfaceAlias ; Enable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6} -Credential $DomainAdminCredObject
Invoke-Command -VMName "Marvel-DC" {$NIC = (Get-NetAdapter).InterfaceAlias ; Enable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6} -Credential $DomainAdminCredObject

#Enable DHCP
Invoke-Command -VMName "ThePunisher" {$NIC = (Get-NetAdapter).InterfaceAlias ; Set-NetIPInterface -InterfaceAlias $NIC -Dhcp Enabled} -Credential $DomainAdminCredObject
Invoke-Command -VMName "Spiderman" {$NIC = (Get-NetAdapter).InterfaceAlias ; Set-NetIPInterface -InterfaceAlias $NIC -Dhcp Enabled} -Credential $DomainAdminCredObject

#Run MITM6 on Kali, then
Invoke-Command -VMName "ThePunisher" {hostname;whoami} -Credential $DomainAdminCredObject
Invoke-Command -VMName "Marvel-DC" {ipconfig /all} -Credential $DomainAdminCredObject