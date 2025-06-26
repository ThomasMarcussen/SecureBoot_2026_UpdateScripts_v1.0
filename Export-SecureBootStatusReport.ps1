###################################################################################################################
# Name: Export-SecureBootStatusReport.ps1
# Author: Thomas Marcussen, Thomas@ThomasMarcussen.com
# Date: June, 2025
###################################################################################################################

# Logs Secure Boot readiness to a CSV file

$results = [PSCustomObject]@{
    ComputerName                  = $env:COMPUTERNAME
    SecureBoot_Enabled            = $false
    MicrosoftUpdateManagedOptIn  = $false
    DiagnosticDataEnabled        = $false
    OS_Version                   = (Get-CimInstance Win32_OperatingSystem).Version
    FirmwareVersion              = $null
    Timestamp                    = (Get-Date).ToString("s")
}

try {
    if (Confirm-SecureBootUEFI) {
        $results.SecureBoot_Enabled = $true
    }
} catch {}

try {
    $key = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot" -Name MicrosoftUpdateManagedOptIn -ErrorAction SilentlyContinue
    if ($key.MicrosoftUpdateManagedOptIn -eq 0x5944) {
        $results.MicrosoftUpdateManagedOptIn = $true
    }
} catch {}

try {
    $telemetry = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name AllowTelemetry -ErrorAction SilentlyContinue
    if ($telemetry.AllowTelemetry -ge 1) {
        $results.DiagnosticDataEnabled = $true
    }
} catch {}

try {
    $firmware = Get-CimInstance -ClassName Win32_BIOS
    $results.FirmwareVersion = $firmware.SMBIOSBIOSVersion
} catch {}

# Export
$logPath = "C:\Logs\SecureBootStatus.csv"
if (-not (Test-Path "C:\Logs")) {
    New-Item -Path "C:\Logs" -ItemType Directory -Force | Out-Null
}
$results | Export-Csv -Path $logPath -NoTypeInformation -Append
