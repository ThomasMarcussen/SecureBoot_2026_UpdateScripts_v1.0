###################################################################################################################
# Name: Check-OEMFirmwareReadiness.ps1
# Author: Thomas Marcussen, Thomas@ThomasMarcussen.com
# Date: June, 2025
###################################################################################################################

# Lists OEM model and current BIOS/UEFI firmware version

$system = Get-CimInstance -Class Win32_ComputerSystem
$bios = Get-CimInstance -Class Win32_BIOS

$info = [PSCustomObject]@{
    ComputerName     = $env:COMPUTERNAME
    Manufacturer     = $system.Manufacturer
    Model            = $system.Model
    BIOS_Version     = $bios.SMBIOSBIOSVersion
    BIOS_ReleaseDate = $bios.ReleaseDate
}

$info | Format-List
