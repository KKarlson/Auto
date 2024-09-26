Enable-PSRemoting -SkipNetworkProfileCheck -Force | Out-Null
.\Get-WindowsAutoPilotInfo.ps1 -ComputerName $env:computername -OutputFile "$env:computername.csv" -GroupTag NGD
