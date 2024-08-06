# PEH-AD-Lab
IaC of the AD lab in TCM's PEH course

Review of the PJPT exam and explanation of the course's lab here: https://happycamper84.medium.com/pjpt-review-484fc9ec4f3b

If you want to use this:
Enable Hyper-V

Create a VMSwitch named "Testing" (needs to be in bridge mode, mostly so a Kali VM running in VMware Player, VirtualBox, etc can hit the target VMs)

Create two folders called PEH and ISOs

Drop the files from our GitHub in the PEH folder

Drop a Windows Server 2019 ISO in the ISOs folder

Run Create-PEHLab.ps1

Run Generate-Traffic to import the function. Once Heath Adams gets to the part of the course covering Name Poisoning run the command Generate-Traffic to automate a user fat fingering a share drive name.

Please note: Create-PEHLab checks your host's IP address, takes the first 3 octets, and then sets TCM's 3 VMs to those octets.IP:
X.Y.Z.130  Marvel-DC    (DC, of course)
X.Y.Z.131  ThePunisher  (client)
X.Y.Z.132  Spiderman    (client)

If your home router is actually using .130 - .132 then don't just blindly run our lab setup as the IPs will conflict.
