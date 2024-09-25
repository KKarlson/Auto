powershell -command "Get-ChildItem D:\Drivers\7440WiFiDriver\ -Recurse -Filter '*inf' | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }"
net start wlansvc
netsh wlan add profile filename="Wi-Fi-Profile.xml"
cd/d c:\
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force"
powershell -executionPolicy Bypass -File d:\AutoV2Files\NGD-AutoCopy.ps1
