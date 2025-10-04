# Windows Dotfiles Status Check Script
# This script checks the status of Windows dotfiles symbolic links

param(
    [switch]$Help
)

function Show-Help {
    Write-Host "Windows Dotfiles Status Check" -ForegroundColor Cyan
    Write-Host "Usage: .\status.ps1 [-Help]" -ForegroundColor White
    Write-Host ""
    Write-Host "This script checks the status of Windows dotfiles symbolic links:" -ForegroundColor Gray
    Write-Host "  - .wslconfig file status" -ForegroundColor Gray
    Write-Host "  - Windows Terminal settings status" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Help    Show this help message" -ForegroundColor Gray
}

function Test-SymbolicLink {
    param(
        [string]$Path,
        [string]$Name
    )

    if (Test-Path $Path) {
        $item = Get-Item $Path
        if ($item.LinkType -eq 'SymbolicLink') {
            Write-Host "✅ $Name is properly linked" -ForegroundColor Green
            Write-Host "   Target: $($item.Target)" -ForegroundColor Gray
        } else {
            Write-Host "❌ $Name exists but is not a symlink" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ $Name not found" -ForegroundColor Red
    }
}

function Get-WindowsTerminalSettingsPath {
    # Check for Store version
    $storePackage = Get-AppxPackage -Name 'Microsoft.WindowsTerminal' -ErrorAction SilentlyContinue
    if ($storePackage) {
        $settingsPath = Join-Path $env:LOCALAPPDATA "Packages\$($storePackage.PackageFamilyName)\LocalState\settings.json"
        if (Test-Path (Split-Path $settingsPath -Parent) -ErrorAction SilentlyContinue) {
            return $settingsPath
        }
    }

    # Check for Preview version
    $previewPackage = Get-AppxPackage -Name 'Microsoft.WindowsTerminalPreview' -ErrorAction SilentlyContinue
    if ($previewPackage) {
        $settingsPath = Join-Path $env:LOCALAPPDATA "Packages\$($previewPackage.PackageFamilyName)\LocalState\settings.json"
        if (Test-Path (Split-Path $settingsPath -Parent) -ErrorAction SilentlyContinue) {
            return $settingsPath
        }
    }

    # Check for unpackaged version
    $unpackagedPath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json"
    if (Test-Path (Split-Path $unpackagedPath -Parent) -ErrorAction SilentlyContinue) {
        return $unpackagedPath
    }

    return $null
}

function Main {
    if ($Help) {
        Show-Help
        return
    }

    Write-Host "Checking Windows dotfiles status..." -ForegroundColor Cyan
    Write-Host ""

    # Check .wslconfig
    Write-Host "🔍 WSL Configuration Status:" -ForegroundColor Yellow
    $wslConfigPath = Join-Path $env:USERPROFILE ".wslconfig"
    Test-SymbolicLink -Path $wslConfigPath -Name ".wslconfig"
    Write-Host ""

    # Check Windows Terminal settings
    Write-Host "🖥️ Windows Terminal Configuration Status:" -ForegroundColor Yellow
    $wtPath = Get-WindowsTerminalSettingsPath

    if (-not $wtPath) {
        Write-Host "⚠️  Windows Terminal not installed" -ForegroundColor Yellow
    } else {
        Test-SymbolicLink -Path $wtPath -Name "Windows Terminal settings"
    }

    Write-Host ""
    Write-Host "Status check completed." -ForegroundColor Green
}

# Execute main function
Main