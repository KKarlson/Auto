powershell -command "Get-ChildItem D:\Drivers\X1CG12WiFiDriver\ -Recurse -Filter '*inf' | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }"
net start wlansvc
netsh wlan add profile filename="Wi-Fi-Profile.xml"
powershell -executionPolicy Bypass -File C:\TECH\Auto-main\AutoV3Files\NGD-Auto.ps1
