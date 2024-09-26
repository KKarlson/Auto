# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Function to display a message box
function Show-MessageBox {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show($Message, "Script Check", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Show-MessageBox -Message "This script is not running as Administrator. Please run as Administrator."
    exit
}

# Check for internet connection
do {
    try {
        Test-netConnection -WarningAction Stop
        Write-Output "Internet connection is available."
        $noInternet = $false
        Write-Progress -Completed -Activity "Finished"
    } catch {
        Show-MessageBox -Message "Internet connection is not available. Please check your connection and click OK to retest."
        $noInternet = $true
    }
} while ($noInternet)

# Set to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Set the time before the system goes to sleep
# The time is specified in seconds, so 12 hours is 43200 seconds
powercfg -change -standby-timeout-ac 43200

# Set the time before the screen turns off
# The time is specified in seconds, so 12 hours is 43200 seconds
powercfg -change -monitor-timeout-ac 43200

# Sets location to run everything.
Set-Location 'C:\TECH\Auto-main\'

# Set the error action preference to stop
#$ErrorActionPreference = "Stop"

# Sets Conferm Preference to None
$ConfirmPreference = 'None'

# Runs second script to collect Windows autopilot hash file.
Set-Location '.\AutoV3Files'
$hashScript = Resolve-Path '.\Register-AutoPilotDevice.ps1'
& $hashScript
Set-Location '.\..'

# Remove all CSV files in parent directory
Get-ChildItem -Path 'd:\' -Filter *.csv | Remove-Item

# Copy all CSV files in current directory to parent directory
Get-ChildItem -Path 'C:\tech\Auto-main\AutoV3Files' -Filter *.csv | Copy-Item -Destination 'd:\'

# Checks for hash file on flash drive and lets the user know they can remove the flash drive if the hash file is there
if (Test-Path 'd:\*.csv') {
    Show-MessageBox -Message "You can now remove your flash"
} else {
    Show-MessageBox -Message "ERROR moving hash file to drive leter D, make sure the flash drive partition you are using is labeled as D"
}

# Makes it so you are not asked to confirm if you want to install a module or provider
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

# SetsTLS to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Installs Nuget Package Provider and Module
    Install-PackageProvider -Name 'NuGet' -Verbose -Force -ErrorAction Stop
    Import-PackageProvider -Name 'NuGet'
    Install-Module -Name Nuget -Force -Verbose

# Ensure you have the latest version of PowerShellGet
Install-Module -Name PowerShellGet -Force -SkipPublisherCheck -Verbose

# Get system manufacturer
$maker = (Get-CimInstance -ClassName win32_computersystem).Manufacturer

# Check if updates have already been run
if (Test-Path C:\Windows\System32\reRun.txt) {
    $result = [System.Windows.Forms.MessageBox]::show("Driver and Firmware updates have already been run on this system, would you like to re-run them?", "Re-Run Driver Updates", [System.Windows.Forms.MessageBoxButtons]::YesNo)
    if ($result -eq "Yes") {
        Remove-Item C:\Windows\System32\reRun.txt
    }
}

# Sets syncs the time zone
Install-Module -Name "WinTZ" -Repository "PSGallery" -Scope CurrentUser -Force -Verbose -SkipPublisherCheck
Set-WindowsTimeZone -force -Verbose

# Install updates based on system manufacturer and installs needed powershell modules
if ((-not (Test-Path C:\Windows\System32\reRun.txt)) -and ($maker -ne ("LENOVO" -or "Dell Inc.")) ) {
    New-Item -Path C:\Windows\System32 -Name "reRun.txt" -ItemType "file"
    if ($maker -eq "LENOVO") {
        Install-Module -Name 'LSUClient' -Force -Verbose -SkipPublisherCheck
        $updates = Get-LSUpdate -Verbose
        $updates | Save-LSUpdate -Verbose
        $i = 1
        foreach ($update in $updates) {
            Write-Output "Installing update $i of $($updates.Count): $($update.Title)"
            Install-LSUpdate -Package $update -Verbose
            $i++
        }
    } elseif ($maker -eq "Dell Inc.") {
        $dcuPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
        if (-not (Test-Path $dcuPath)) {
            Write-Host "Installing DCU"
            Start-Process "C:\Windows\System32\msiexec.exe" -argumentlist '/i "C:\TECH\Auto-main\AutoV3Files\DCU\DCU.msi" /quiet /norestart' -NoNewWindow -Wait
            Write-Host "Installed DCU"
        }
        & $dcuPath "/scan"
        & $dcuPath "/applyupdates"
    } else {

    }
}

# Install Windows updates
Install-Module -Name pswindowsupdate -Force -Verbose
Get-WindowsUpdate -Verbose
$loop = 0
for ($loop = 1; $loop -le 10; $loop++) {
    Write-Progress -Completed -Activity "Finished"
    try {
        Write-Progress -Completed -Activity "Finished"
        Install-WindowsUpdate -AcceptAll -Install -AutoReboot -Verbose
        $loop = 20
    } catch {
        Write-Progress -Completed -Activity "Finished"
        Reset-WUComponents -Verbose

    }
}

# Removes PSGallery modules to be used
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted

# Makes it so you are asked to confirm if you want to install a module or provider
Set-Variable -Name 'ConfirmPreference' -Value 'High' -Scope Global

# Set ExecutionPolicy back to Restricted without any blood appearing in the window
Try {
    Get-ExecutionPolicy -List | Set-ExecutionPolicy -ExecutionPolicy Restricted -Force | Out-Null
} catch {
    Out-Null
}
