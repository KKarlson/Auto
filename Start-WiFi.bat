netsh wlan add profile filename="Wi-Fi-Profile.xml"
cd/d c:\
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force"
powershell -executionPolicy Bypass -File C:\TECH\Auto-main\AutoV3Files\NGD-Auto.ps1
