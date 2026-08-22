# Run this script in an elevated PowerShell prompt (Run as Administrator)

# Helper function to install via winget and log results
function Install-App {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [string]$Name = $Id
    )
    
    Write-Host "Installing $Name..."
    $result = winget install --id $Id --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Installation of $Name failed. Please check the installer or try running manually."
    }
    else {
        Write-Host "$Name installed successfully." -ForegroundColor Green
    }
}

# Visual Studio Community 2022
Install-App -Id "Microsoft.VisualStudio.2022.Community" -Name "Visual Studio Community 2022"

# Microsoft 365 (Office Desktop Apps)
# Winget sometimes lists this as Microsoft Office or Microsoft 365 Apps
Install-App -Id "Microsoft.Office" -Name "Microsoft 365 (Office Desktop Apps)"

# SQL Server Management Studio (SSMS)
Install-App -Id "Microsoft.SQLServerManagementStudio" -Name "SQL Server Management Studio"

# Optional: SQL Shades installation
# If SQL Shades is available via winget, provide its ID. Otherwise, you may need to download and install manually.
# Example placeholder:
# Install-App -Id "SQLShades.SQLShades" -Name "SQL Shades"

# Azure Storage Explorer
Install-App -Id "Microsoft.Azure.StorageExplorer" -Name "Azure Storage Explorer"

# Postman
Install-App -Id "Postman.Postman" -Name "Postman"

# Warp Terminal
Install-App -Id "Warp.Warp" -Name "Warp Terminal"

# Zen Browser
# Verify the correct Id for Zen Browser from winget's repository.
Install-App -Id "Zen-Team.Zen-Browser" -Name "Zen Browser"

# Git CLI
Install-App -Id "Git.Git" -Name "Git CLI"

# 1Password
$url = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
$output = "$env:TEMP\1PasswordSetup.exe"

Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing

Start-Process -FilePath $output -ArgumentList "/silent", "/verysilent" -Wait -Verb RunAs


Write-Host "Installation script completed!" -ForegroundColor Cyan
