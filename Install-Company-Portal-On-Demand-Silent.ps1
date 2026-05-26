#requires -runasadministrator
#requires -Version 3.0
<#
.SYNOPSIS
    Intune Detection Script - Checks if Company Portal is installed

.DESCRIPTION
    This script is designed to be used as an Intune detection script to check if the
    Microsoft Company Portal app is installed on a Windows device.

.HOW IT WORKS
    1. Logging Setup
       - Creates a timestamped log folder: C:\Temp\PAR-CompanyPortal_yyyyMMdd_HHmmss\
       - Generates a log file to track detection checks
       - All actions are logged with timestamps

    2. Detection Phase
       - Uses Get-AppxPackage to check if Microsoft Company Portal is installed
       - Package searched: Microsoft.CompanyPortal_8wekyb3d8bbwe

    3. Intune Exit Codes
       - Exit 0 with output: App is installed (COMPLIANT - no remediation needed)
       - Exit 1 or no output: App not found (NON-COMPLIANT - triggers remediation script)

.INTUNE USAGE
    Detection Script: Use this script
    Remediation Script: Pair with a remediation script that silently installs Company Portal
                       using the MDM Bridge WMI Provider method (Oliver Kieselbach's approach)

.KEY FEATURES
    - Lightweight detection only (no installation)
    - Logged: Full audit trail of detection checks
    - Silent Operation: No user interaction
    - Intune-compliant exit codes

.NOTES
    Author: Mark Orr
    Based on: Oliver Kieselbach's MDM Bridge approach
    Reference: https://oliverkieselbach.com/2020/04/22/how-to-completely-change-windows-10-language-with-intune/

.MODIFICATION_HISTORY
    Bill Powell     - 2024-06-08 - Initial Release
    Mark Orr        - 2026-05-26 - Converted to Intune detection script with logging
#>

# Logging setup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFolder = "C:\Temp\PAR-CompanyPortal_$timestamp"
New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
$logFile = Join-Path $logFolder "CompanyPortal-Detection.log"

function Write-Log {
    param([string]$Message)
    $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $logFile -Value $entry
    Write-Output $Message
}

# Detection logic
$packageFamilyName = 'Microsoft.CompanyPortal_8wekyb3d8bbwe'
Write-Log "Starting Company Portal detection check for: $packageFamilyName"

$app = Get-AppxPackage -Name "Microsoft.CompanyPortal" -ErrorAction SilentlyContinue

if ($app) {
    Write-Log "DETECTED: Company Portal is installed."
    Write-Log "Package Family Name: $($app.PackageFamilyName)"
    Write-Log "Version: $($app.Version)"
    Write-Output "Company Portal is installed"
    exit 0  # Compliant - app found, no remediation needed
}
else {
    Write-Log "NOT DETECTED: Company Portal is not installed."
    Write-Log "Intune will trigger remediation script."
    exit 1  # Non-compliant - app not found, trigger remediation
}
