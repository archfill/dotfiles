# Windows dotfiles setup script
# WSL設定とWindows Terminal設定をシンボリックリンクで管理

Write-Host "Setting up Windows dotfiles..." -ForegroundColor Green

# 管理者権限チェックと昇格処理
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "管理者権限が必要です。管理者として再実行します..." -ForegroundColor Yellow

    # 現在のスクリプトパスを取得
    $scriptPath = $MyInvocation.MyCommand.Path

    # 管理者権限でPowerShell 7を再実行
    $arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"")
    $process = Start-Process pwsh -Verb RunAs -ArgumentList $arguments -PassThru

    # プロセスの終了を待機
    $process.WaitForExit()

    Write-Host "管理者権限での実行が完了しました (ExitCode: $($process.ExitCode))" -ForegroundColor Green
    if ($process.ExitCode -ne 0) {
        Write-Host "⚠️ スクリプトの実行中にエラーが発生した可能性があります" -ForegroundColor Yellow
    }
    Read-Host "Enterキーを押して終了してください"
    exit 0
}

# 変数設定
$dotfilesDir = "$env:USERPROFILE\dotfiles\windows"
$homeDir = $env:USERPROFILE

# .wslconfig のシンボリックリンク作成
$wslconfigSource = "$dotfilesDir\.wslconfig"
$wslconfigTarget = "$homeDir\.wslconfig"

Write-Host "Setting up .wslconfig..." -ForegroundColor Cyan

if (Test-Path $wslconfigSource) {
    # 既存の.wslconfigがある場合のバックアップ
    if (Test-Path $wslconfigTarget) {
        if (-not (Get-Item $wslconfigTarget).LinkType) {
            $backupPath = "$wslconfigTarget.backup.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
            Move-Item $wslconfigTarget $backupPath
            Write-Host "Existing .wslconfig backed up to: $backupPath" -ForegroundColor Yellow
        } else {
            Remove-Item $wslconfigTarget -Force
        }
    }

    # シンボリックリンク作成
    try {
        New-Item -ItemType SymbolicLink -Path $wslconfigTarget -Target $wslconfigSource -Force | Out-Null
        Write-Host "✓ .wslconfig symlink created" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create .wslconfig symlink: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  .wslconfig source file not found: $wslconfigSource" -ForegroundColor Yellow
}

# PowerShell 7プロファイルのシンボリックリンク作成
Write-Host "`nSetting up PowerShell 7 profile..." -ForegroundColor Cyan

$ps7ProfileSource = "$dotfilesDir\PowerShell_profile.ps1"

# PowerShell 7のプロファイルパスを安全に取得
try {
    $ps7ProfileTarget = & pwsh -NoProfile -Command '$PROFILE' 2>$null
    if (-not $ps7ProfileTarget -or $ps7ProfileTarget.Contains("Profile Loaded")) {
        # デフォルトのプロファイルパスを使用
        $ps7ProfileTarget = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    }
} catch {
    # フォールバック: デフォルトパスを使用
    $ps7ProfileTarget = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}

Write-Host "PowerShell 7 profile path: $ps7ProfileTarget" -ForegroundColor Gray

if (Test-Path $ps7ProfileSource) {
    # プロファイルディレクトリが存在しない場合は作成
    $ps7ProfileDir = Split-Path $ps7ProfileTarget -Parent
    if (-not (Test-Path $ps7ProfileDir)) {
        try {
            New-Item -ItemType Directory -Path $ps7ProfileDir -Force | Out-Null
            Write-Host "Created profile directory: $ps7ProfileDir" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to create profile directory: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    # 既存のプロファイルがある場合のバックアップ
    if (Test-Path $ps7ProfileTarget) {
        try {
            $item = Get-Item $ps7ProfileTarget -ErrorAction Stop
            if (-not $item.LinkType) {
                $backupPath = "$ps7ProfileTarget.backup.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
                Move-Item $ps7ProfileTarget $backupPath -ErrorAction Stop
                Write-Host "Existing PowerShell 7 profile backed up to: $backupPath" -ForegroundColor Yellow
            } else {
                Remove-Item $ps7ProfileTarget -Force -ErrorAction Stop
                Write-Host "Removed existing symlink" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Failed to handle existing profile: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    # シンボリックリンク作成
    try {
        New-Item -ItemType SymbolicLink -Path $ps7ProfileTarget -Target $ps7ProfileSource -Force -ErrorAction Stop | Out-Null
        Write-Host "✓ PowerShell 7 profile symlink created" -ForegroundColor Green
        Write-Host "  Source: $ps7ProfileSource" -ForegroundColor Gray
        Write-Host "  Target: $ps7ProfileTarget" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to create PowerShell 7 profile symlink: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  PowerShell 7 profile source file not found: $ps7ProfileSource" -ForegroundColor Yellow
}

# GlazeWMの設定シンボリックリンク作成
Write-Host "`nSetting up GlazeWM..." -ForegroundColor Cyan

$glazewmConfigSource = "$dotfilesDir\.glazewm\config.yaml"
$glazewmConfigTarget = "$homeDir\.glzr\glazewm\config.yaml"

if (Test-Path $glazewmConfigSource) {
    # .glzr\glazewmディレクトリが存在しない場合は作成
    $glazewmConfigDir = Split-Path $glazewmConfigTarget -Parent
    if (-not (Test-Path $glazewmConfigDir)) {
        New-Item -ItemType Directory -Path $glazewmConfigDir -Force | Out-Null
        Write-Host "Created GlazeWM config directory: $glazewmConfigDir" -ForegroundColor Green
    }

    # 既存の設定ファイルがある場合のバックアップ
    if (Test-Path $glazewmConfigTarget) {
        if (-not (Get-Item $glazewmConfigTarget).LinkType) {
            $backupPath = "$glazewmConfigTarget.backup.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
            Move-Item $glazewmConfigTarget $backupPath
            Write-Host "Existing GlazeWM config backed up to: $backupPath" -ForegroundColor Yellow
        } else {
            Remove-Item $glazewmConfigTarget -Force
        }
    }

    # シンボリックリンク作成
    try {
        New-Item -ItemType SymbolicLink -Path $glazewmConfigTarget -Target $glazewmConfigSource -Force | Out-Null
        Write-Host "✓ GlazeWM config symlink created" -ForegroundColor Green
        Write-Host "  Source: $glazewmConfigSource" -ForegroundColor Gray
        Write-Host "  Target: $glazewmConfigTarget" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to create GlazeWM config symlink: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  GlazeWM config source file not found: $glazewmConfigSource" -ForegroundColor Yellow
}

# Zebarの設定シンボリックリンク作成
Write-Host "`nSetting up Zebar..." -ForegroundColor Cyan

$zebarConfigSource = "$dotfilesDir\.zebar\settings.json"
$zebarConfigTarget = "$homeDir\.glzr\zebar\settings.json"

if (Test-Path $zebarConfigSource) {
    # .glzr\zebarディレクトリが存在しない場合は作成
    $zebarConfigDir = Split-Path $zebarConfigTarget -Parent
    if (-not (Test-Path $zebarConfigDir)) {
        New-Item -ItemType Directory -Path $zebarConfigDir -Force | Out-Null
        Write-Host "Created Zebar config directory: $zebarConfigDir" -ForegroundColor Green
    }

    # 既存の設定ファイルがある場合のバックアップ
    if (Test-Path $zebarConfigTarget) {
        if (-not (Get-Item $zebarConfigTarget).LinkType) {
            $backupPath = "$zebarConfigTarget.backup.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
            Move-Item $zebarConfigTarget $backupPath
            Write-Host "Existing Zebar config backed up to: $backupPath" -ForegroundColor Yellow
        } else {
            Remove-Item $zebarConfigTarget -Force
        }
    }

    # シンボリックリンク作成
    try {
        New-Item -ItemType SymbolicLink -Path $zebarConfigTarget -Target $zebarConfigSource -Force | Out-Null
        Write-Host "✓ Zebar config symlink created" -ForegroundColor Green
        Write-Host "  Source: $zebarConfigSource" -ForegroundColor Gray
        Write-Host "  Target: $zebarConfigTarget" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to create Zebar config symlink: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Zebar config source file not found: $zebarConfigSource" -ForegroundColor Yellow
}

Write-Host "`n Setup completed successfully!" -ForegroundColor Green
Write-Host "WSL, PowerShell 7 profile, GlazeWM, and Zebar are now managed by dotfiles" -ForegroundColor Green
Write-Host "Restart PowerShell 7 to fix encoding issues" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Gray
Write-Host "💡 Next steps for GlazeWM and Zebar:" -ForegroundColor Yellow
Write-Host "  • Install GlazeWM from GitHub releases" -ForegroundColor Gray
Write-Host "  • Install Zebar from GitHub releases" -ForegroundColor Gray
Write-Host "  • Start GlazeWM to enable tiling window management" -ForegroundColor Gray
Write-Host "  • Start Zebar to enable status bar" -ForegroundColor Gray
Write-Host "" -ForegroundColor Gray
Write-Host "💡 Optional terminal emulator setup:" -ForegroundColor Yellow
Write-Host "  • Run .\link-wezterm.ps1 to setup WezTerm config" -ForegroundColor Gray
Write-Host "  • Run .\link-alacritty.ps1 to setup Alacritty config" -ForegroundColor Gray

# 管理者権限で実行された場合は結果確認のために待機
if ($isAdmin) {
    Write-Host "`nPress Enter to close this window..." -ForegroundColor Yellow
    Read-Host
}