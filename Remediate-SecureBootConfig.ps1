###################################################################################################################
# Name: Remediate-SecureBootConfig.ps1
# Author: Thomas Marcussen, Thomas@ThomasMarcussen.com
# Date: June, 2025
###################################################################################################################

# Sets registry key for Secure Boot certificate opt-in and enables required telemetry level

# Ensure registry key exists
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set MicrosoftUpdateManagedOptIn
Set-ItemProperty -Path $regPath -Name "MicrosoftUpdateManagedOptIn" -Type DWord -Value 0x5944 -Force

# Ensure required diagnostic data level (minimum: 1)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1 -Force
