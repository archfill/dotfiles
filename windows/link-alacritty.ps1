# Alacritty設定のシンボリックリンク作成スクリプト
# Alacrittyの設定をdotfilesリポジトリで管理するためのスクリプト

Write-Host "Setting up Alacritty configuration symlink..." -ForegroundColor Green

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
$alacrittyConfigSource = "$env:USERPROFILE\dotfiles\.config\alacritty"
$alacrittyConfigTarget = "$env:APPDATA\alacritty"

Write-Host "`nSetting up Alacritty..." -ForegroundColor Cyan

if (Test-Path $alacrittyConfigSource) {
    # 既存のAlacritty設定がある場合のバックアップ
    if (Test-Path $alacrittyConfigTarget) {
        try {
            $item = Get-Item $alacrittyConfigTarget -ErrorAction Stop
            if (-not $item.LinkType) {
                $backupPath = "$alacrittyConfigTarget.backup.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
                Move-Item $alacrittyConfigTarget $backupPath -ErrorAction Stop
                Write-Host "Existing Alacritty config backed up to: $backupPath" -ForegroundColor Yellow
            } else {
                Remove-Item $alacrittyConfigTarget -Force -ErrorAction Stop
                Write-Host "Removed existing Alacritty symlink" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Failed to handle existing Alacritty config: $($_.Exception.Message)" -ForegroundColor Red
            if ($isAdmin) {
                Read-Host "Enterキーを押して終了してください"
            }
            exit 1
        }
    }

    # シンボリックリンク作成
    try {
        New-Item -ItemType SymbolicLink -Path $alacrittyConfigTarget -Target $alacrittyConfigSource -Force -ErrorAction Stop | Out-Null
        Write-Host "✓ Alacritty config symlink created successfully!" -ForegroundColor Green
        Write-Host "  Source: $alacrittyConfigSource" -ForegroundColor Gray
        Write-Host "  Target: $alacrittyConfigTarget" -ForegroundColor Gray

        # os-specific.toml -> windows.toml のシンボリックリンク作成
        $osSpecificLink = Join-Path $alacrittyConfigSource "os-specific.toml"
        $windowsToml = Join-Path $alacrittyConfigSource "windows.toml"

        if (Test-Path $osSpecificLink) {
            Remove-Item $osSpecificLink -Force -ErrorAction Stop
        }

        New-Item -ItemType SymbolicLink -Path $osSpecificLink -Target $windowsToml -Force -ErrorAction Stop | Out-Null
        Write-Host "✓ os-specific.toml -> windows.toml symlink created!" -ForegroundColor Green

        Write-Host "`n💡 Next steps:" -ForegroundColor Yellow
        Write-Host "  • Install Alacritty from https://alacritty.org/" -ForegroundColor Gray
        Write-Host "  • Launch Alacritty to use your dotfiles configuration" -ForegroundColor Gray
        Write-Host "`n📝 Note:" -ForegroundColor Cyan
        Write-Host "  Alacritty will use windows.toml for Windows-specific settings via os-specific.toml" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to create Alacritty config symlink: $($_.Exception.Message)" -ForegroundColor Red
        if ($isAdmin) {
            Read-Host "Enterキーを押して終了してください"
        }
        exit 1
    }
} else {
    Write-Host "⚠️  Alacritty config source directory not found: $alacrittyConfigSource" -ForegroundColor Yellow
    Write-Host "Please ensure you have cloned the dotfiles repository to $env:USERPROFILE\dotfiles" -ForegroundColor Yellow
    if ($isAdmin) {
        Read-Host "Enterキーを押して終了してください"
    }
    exit 1
}

# 管理者権限で実行された場合は結果確認のために待機
if ($isAdmin) {
    Write-Host "`nPress Enter to close this window..." -ForegroundColor Yellow
    Read-Host
}
