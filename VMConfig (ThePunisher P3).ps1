Add-LocalGroupMember -Group "Administrators" -Member "marvel\fcastle"

#Download & unzip PingCastle. Just run PingCastle.exe in C:\Users\Public\Downloads once done
Invoke-WebRequest "https://github.com/vletoux/pingcastle/releases/download/3.2.0.1/PingCastle_3.2.0.1.zip" -OutFile "C:\Users\Public\Downloads\PingCastle_3.2.0.1.zip"
Expand-Archive "C:\Users\Public\Downloads\PingCastle_3.2.0.1.zip" -DestinationPath "C:\Users\Public\Downloads"