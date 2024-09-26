netsh wlan add profile filename="Wi-Fi-Profile.xml"
cd/d c:\
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force"
powershell -executionPolicy Bypass -File d:\AutoV2Files\NGD-Auto.ps1
