###################################################################################################################
# Name: Detect-SecureBootCertReadiness.ps1
# Author: Thomas Marcussen, Thomas@ThomasMarcussen.com
# Date: June, 2025
###################################################################################################################


# Checks Secure Boot status, diagnostic data setting, and certificate opt-in registry key

$results = [PSCustomObject]@{
    SecureBoot_Enabled             = $false
    MicrosoftUpdateManagedOptIn   = $false
    DiagnosticDataEnabled         = $false
    OS_Version                    = (Get-CimInstance Win32_OperatingSystem).Version
    UEFI_FirmwareVersion          = $null
}

# Secure Boot status
try {
    if (Confirm-SecureBootUEFI) {
        $results.SecureBoot_Enabled = $true
    }
} catch {
    # Could not confirm Secure Boot (likely unsupported system)
    $results.SecureBoot_Enabled = $false
}

# Registry opt-in
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot"
try {
    if (Test-Path $regPath) {
        $value = Get-ItemProperty -Path $regPath -Name MicrosoftUpdateManagedOptIn -ErrorAction SilentlyContinue
        if ($value.MicrosoftUpdateManagedOptIn -eq 0x5944) {
            $results.MicrosoftUpdateManagedOptIn = $true
        }
    }
} catch {
    # Registry key or value not accessible
    $results.MicrosoftUpdateManagedOptIn = $false
}

# Diagnostic data level
try {
    $diag = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name AllowTelemetry -ErrorAction SilentlyContinue
    if ($diag.AllowTelemetry -ge 1) {
        $results.DiagnosticDataEnabled = $true
    }
} catch {
    $results.DiagnosticDataEnabled = $false
}

# Optional firmware version
try {
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $results.UEFI_FirmwareVersion = $bios.SMBIOSBIOSVersion
} catch {
    $results.UEFI_FirmwareVersion = "Unavailable"
}

# Output result
$results | Format-List

