powershell -command "Get-ChildItem D:\Drivers\7450WiFiDriver\ -Recurse -Filter '*inf' | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }"
net start wlansvc
netsh wlan add profile filename="Wi-Fi-Profile.xml"
cd/d c:\
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force"
powershell -executionPolicy Bypass -File C:\TECH\Auto-main\AutoV3Files\NGD-Auto.ps1
