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
    Write-Host "  - PowerShell 7 profile status" -ForegroundColor Gray
    Write-Host "  - WezTerm configuration status (optional)" -ForegroundColor Gray
    Write-Host "  - Alacritty configuration status (optional)" -ForegroundColor Gray
    Write-Host "  - GlazeWM configuration status" -ForegroundColor Gray
    Write-Host "  - Zebar configuration status" -ForegroundColor Gray
    Write-Host "  - Installed Nerd Fonts" -ForegroundColor Gray
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

function Get-InstalledScoopFonts {
    # Scoopがインストールされているかチェック
    $scoopPath = Get-Command scoop -ErrorAction SilentlyContinue
    if (-not $scoopPath) {
        return @()
    }

    # Scoopフォントのリスト（install-fonts.ps1と同期）
    $scoopFonts = @(
        "FiraCode-NF-Mono",
        "JetBrainsMono-NF-Mono",
        "CascadiaCode-NF-Mono",
        "Hack-NF-Mono"
    )

    $installedFonts = @()
    $scoopList = & scoop list 2>$null | Out-String

    foreach ($font in $scoopFonts) {
        if ($scoopList -match $font) {
            $installedFonts += $font
        }
    }

    return $installedFonts
}

function Get-InstalledGitHubFonts {
    # GitHubフォントのリスト（install-fonts.ps1と同期）
    $githubFonts = @{
        # HackGen 通常版（Nerd Fontsなし）
        "HackGen" = @("HackGen-Regular.ttf", "HackGen-Bold.ttf")
        "HackGen-Console" = @("HackGenConsole-Regular.ttf", "HackGenConsole-Bold.ttf")
        "HackGen35" = @("HackGen35-Regular.ttf", "HackGen35-Bold.ttf")
        "HackGen35-Console" = @("HackGen35Console-Regular.ttf", "HackGen35Console-Bold.ttf")

        # HackGen Nerd Fonts版（v2.7.0以降Console版のみ提供）
        "HackGenConsole-NF" = @("HackGenConsoleNF-Regular.ttf", "HackGenConsoleNF-Bold.ttf")
        "HackGen35Console-NF" = @("HackGen35ConsoleNF-Regular.ttf", "HackGen35ConsoleNF-Bold.ttf")

        # その他の日本語フォント
        "PlemolJPConsole" = @("PlemolJPConsoleNF-Regular.ttf", "PlemolJPConsoleNF-Bold.ttf")
        "UDEVGothic" = @("UDEVGothicNF-Regular.ttf", "UDEVGothicNF-Bold.ttf")
    }

    $installedFonts = @()
    $fontsFolder = [Environment]::GetFolderPath("Fonts")

    foreach ($fontName in $githubFonts.Keys) {
        $fontFiles = $githubFonts[$fontName]
        $found = $false

        foreach ($fontFile in $fontFiles) {
            $fontPath = Join-Path $fontsFolder $fontFile
            if (Test-Path $fontPath) {
                $found = $true
                break
            }
        }

        if ($found) {
            $installedFonts += $fontName
        }
    }

    return $installedFonts
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

    # Check PowerShell 7 profile
    Write-Host "💻 PowerShell 7 Profile Status:" -ForegroundColor Yellow
    try {
        $ps7ProfilePath = & pwsh -NoProfile -Command '$PROFILE' 2>$null
        if (-not $ps7ProfilePath -or $ps7ProfilePath.Contains("Profile Loaded")) {
            $ps7ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        }
        Test-SymbolicLink -Path $ps7ProfilePath -Name "PowerShell 7 profile"
    } catch {
        Write-Host "⚠️  PowerShell 7 not installed or not accessible" -ForegroundColor Yellow
    }
    Write-Host ""

    # Check WezTerm configuration
    Write-Host "🖥️ WezTerm Configuration Status:" -ForegroundColor Yellow
    $weztermPath = "$env:USERPROFILE\.config\wezterm"
    Test-SymbolicLink -Path $weztermPath -Name "WezTerm config"
    Write-Host ""

    # Check Alacritty configuration
    Write-Host "🖥️ Alacritty Configuration Status:" -ForegroundColor Yellow
    $alacrittyPath = "$env:APPDATA\alacritty"
    Test-SymbolicLink -Path $alacrittyPath -Name "Alacritty config"
    Write-Host ""

    # Check GlazeWM configuration
    Write-Host "🪟 GlazeWM Configuration Status:" -ForegroundColor Yellow
    $glazewmPath = "$env:USERPROFILE\.glzr\glazewm\config.yaml"
    Test-SymbolicLink -Path $glazewmPath -Name "GlazeWM config"
    Write-Host ""

    # Check Zebar configuration
    Write-Host "📊 Zebar Configuration Status:" -ForegroundColor Yellow
    $zebarPath = "$env:USERPROFILE\.glzr\zebar\settings.json"
    Test-SymbolicLink -Path $zebarPath -Name "Zebar config"
    Write-Host ""

    # Check installed fonts
    Write-Host "🔤 Installed Fonts:" -ForegroundColor Yellow

    # Scoopフォント
    $scoopFonts = Get-InstalledScoopFonts
    if ($scoopFonts.Count -gt 0) {
        Write-Host "  📦 Scoop (nerd-fonts):" -ForegroundColor Cyan
        foreach ($font in $scoopFonts) {
            Write-Host "    ✅ $font" -ForegroundColor Green
        }
    }

    # GitHubフォント
    $githubFonts = Get-InstalledGitHubFonts
    if ($githubFonts.Count -gt 0) {
        Write-Host "  🐙 GitHub (日本語フォント):" -ForegroundColor Cyan
        foreach ($font in $githubFonts) {
            Write-Host "    ✅ $font" -ForegroundColor Green
        }
    }

    # フォントが1つもインストールされていない場合
    if ($scoopFonts.Count -eq 0 -and $githubFonts.Count -eq 0) {
        Write-Host "  ⚠️  No fonts installed" -ForegroundColor Yellow
        Write-Host "     Run .\install-fonts.ps1 to install fonts" -ForegroundColor Gray
    }
    Write-Host ""

    Write-Host "Status check completed." -ForegroundColor Green
}

# Execute main function
Main