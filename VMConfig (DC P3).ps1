#Setup the OUs, Containers, and Users according to PEH's video

#--- Create all these in the Users CN, yuck I know ---

#Create user Tony Stark, tstark, Password12345!, Password never expires, Add to $Groups
#Store a password for Tony Stark
[string]$DSRMPassword = 'Password12345!'
# Convert to SecureString
[securestring]$TonyStarkPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

New-ADUser -SamAccountName "tstark" -Name "Tony Stark" -UserPrincipalName "tstark@marvel.local" -AccountPassword $TonyStarkPassword -Path "cn=users,$ADRoot" -Enabled $true -Description "The juice is worth the squeeze!" -PasswordNeverExpires $true

#Create user SQL Service, SQLService, MYpassword123#, Description = "The password is MYpassword123#"
#Store a password for SQL Service
[string]$DSRMPassword = 'MYpassword123#'
# Convert to SecureString
[securestring]$SQLServicePassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

New-ADUser -SamAccountName "SQLService" -Name "SQL Service" -UserPrincipalName "SQLService@marvel.local" -AccountPassword $SQLServicePassword -Path "cn=users,$ADRoot" -Enabled $true -Description "The password is MYpassword123#" -PasswordNeverExpires $true
    
#Heath uses yucky, yucky cmd.exe for this:
#setspn -a Hydra-DC/SQLService.marvel.local:60111 marvel\SQLService
#Confirm
#setspn -T marvel.local -Q */*

Set-ADUser -Identity "SQLService" -ServicePrincipalNames @{Add='Hydra-DC/SQLService.marvel.local:60111'}

#Add Tony Stark and SQL Service to all the groups that Administrator is in
$Groups = (Get-ADUser "Administrator" -Properties *).MemberOf
ForEach($Group in $Groups)
{
Add-ADGroupMember -Identity "$Group" -Members tstark, SQLService
}

# --- Domain Users ---
#Frank Castle, fcastle, Password1, password never expires
#Store a password for fcastle
[string]$DSRMPassword = 'Password1'
# Convert to SecureString
[securestring]$FrankCastlePassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force
New-ADUser -SamAccountName "fcastle" -Name "Frank Castle" -UserPrincipalName "fcastle@marvel.local" -AccountPassword $FrankCastlePassword -Path "cn=users,$ADRoot" -Enabled $true -PasswordNeverExpires $true

#Peter Parker, pparker, Password2, password never expires
#Store a password for pparker
[string]$DSRMPassword = 'Password2'
# Convert to SecureString
[securestring]$PeterParkerPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force
New-ADUser -SamAccountName "pparker" -Name "Peter Parker" -UserPrincipalName "pparker@marvel.local" -AccountPassword $PeterParkerPassword -Path "cn=users,$ADRoot" -Enabled $true -PasswordNeverExpires $true

# --- Domain Workstations
New-ADComputer -Name "ThePunisher" -Description "Frank Castle's computer" -Path "cn=computers,$ADRoot"
New-ADComputer -Name "Spiderman" -Description "Peter Parker's computer" -Path "cn=computers,$ADRoot"
Start-Sleep -Seconds 60

#Create an OU called Groups and move the groups in the Users CN into it. (PEH does this so we replicated the process.)
$ADRoot = (Get-ADDomain).DistinguishedName
New-ADOrganizationalUnit -Name "Groups" -Path "$ADRoot" -Description "Groups"
$Groups = (Get-ADGroup -Filter * -SearchBase "cn=users,$ADRoot").DistinguishedName
ForEach($Group in $Groups)
{
Move-ADObject "$Group" -TargetPath "ou=groups,$ADRoot"
}

#Install AD CS with default settings
Install-WindowsFeature Adcs-Cert-Authority, RSAT-ADCS, RSAT-ADCS-Mgmt
Install-AdcsCertificationAuthority -CAType StandaloneRootCa

#Share the C:\Shares\hackme as hackme, default permissions
New-Item -Path "C:\Shares\HackMe" -ItemType Directory
New-SmbShare -Name "HackMe" -Path "C:\Shares\HackMe"
#New-ADObject -Name "HackMe" -CN "HackMe" -DistinguishedName "cn=HackMe,cn=Marvel-DC,ou=domain controllers,$ADRoot" -ObjectClass "volume" -uNCName "\\Marvel-DC\HackMe"
New-ADObject -Name "HackMe" -DisplayName "HackMe" -Path "cn=HackMe,cn=Marvel-DC,ou=domain controllers,$ADRoot" -Type "volume"
Restart-Computer -Force