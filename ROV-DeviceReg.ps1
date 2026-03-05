<#
Script: Autopilot Intune Upload Script with Group Tag Prompt
Author: Daniel Fraubaum
Version: 1.1
Description: Collects Autopilot info from device and uploads it to Intune. 
             Allows selecting join type (Hybrid Azure AD or Azure AD) to set Group Tag.
https://headsinthecloud.blog/2025/04/05/register-devices-to-windows-autopilot-the-easy-way/
#>

####################################################################
# Set execution policy (session only)
####################################################################
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force

####################################################################
# Install required components (silent)
####################################################################
Write-Host "`n[i] Installing required components ..." -ForegroundColor Cyan
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Script -Name Get-WindowsAutoPilotInfo -Force -ErrorAction Stop | Out-Null
Install-Module -Name WindowsAutopilotIntune -Force -ErrorAction Stop | Out-Null

####################################################################
# Select Join Type and set Group Tag
####################################################################
Write-Host "`n[?] Select the join type for this device:" -ForegroundColor Yellow
Write-Host "    [1] Hybrid Azure AD Join" -ForegroundColor White
Write-Host "    [2] Azure AD Join" -ForegroundColor White
Write-Host ""

do {
    $JoinChoice = Read-Host "Enter 1 or 2"
} while ($JoinChoice -notin @("1", "2"))

switch ($JoinChoice) {
    "1" {
        $GroupTag = "HybridAAD"
        Write-Host "`n[+] Join type set to: Hybrid Azure AD Join" -ForegroundColor Green
        Write-Host "[+] Group Tag will be: $GroupTag" -ForegroundColor Green
    }
    "2" {
        $GroupTag = "AzureAD"
        Write-Host "`n[+] Join type set to: Azure AD Join" -ForegroundColor Green
        Write-Host "[+] Group Tag will be: $GroupTag" -ForegroundColor Green
    }
}

####################################################################
# Define parameters
####################################################################
$AutopilotParams = @{
    Online     = $true
    TenantId   = "82a9aebd-f1af-4214-b0d2-24b55999e10b"
    AppId      = "9e2fdb86-d96f-48e9-8c74-a27c212d90f6"
    AppSecret  = "XaK8Q~JkQt.0H2C5r0E-0Q1hYuYiFUVBigXrhdl_"
    GroupTag   = $GroupTag
}

####################################################################
# Upload Autopilot info to Intune
####################################################################
Write-Host "`n[i] Uploading Autopilot info to Intune ..." -ForegroundColor Cyan
Get-WindowsAutoPilotInfo @AutopilotParams

####################################################################
# Wait for user input, then reboot
####################################################################
Write-Host "`n[i] Press Enter to reboot the device now ..." -ForegroundColor Cyan
[void][System.Console]::ReadLine()
Restart-Computer -Force

