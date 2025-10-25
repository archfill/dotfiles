# WezTerm設定のシンボリックリンク作成スクリプト
# WezTermの設定をdotfilesリポジトリで管理するためのスクリプト

Write-Host "Setting up WezTerm configuration symlink..." -ForegroundColor Green

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
$weztermConfigSource = "$env:USERPROFILE\dotfiles\.config\wezterm"
$weztermConfigTarget = "$env:USERPROFILE\.config\wezterm"

Write-Host "`nSetting up WezTerm..." -ForegroundColor Cyan

if (Test-Path $weztermConfigSource) {
    # .config ディレクトリが存在しない場合は作成
    $configDir = "$env:USERPROFILE\.config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        Write-Host "Created .config directory: $configDir" -ForegroundColor Green
    }

    # 既存のWezTerm設定がある場合のバックアップ
    if (Test-Path $weztermConfigTarget) {
        try {
            $item = Get-Item $weztermConfigTarget -ErrorAction Stop
            if (-not $item.LinkType) {
                $backupPath = "$weztermConfigTarget.backup.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
                Move-Item $weztermConfigTarget $backupPath -ErrorAction Stop
                Write-Host "Existing WezTerm config backed up to: $backupPath" -ForegroundColor Yellow
            } else {
                Remove-Item $weztermConfigTarget -Force -ErrorAction Stop
                Write-Host "Removed existing WezTerm symlink" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Failed to handle existing WezTerm config: $($_.Exception.Message)" -ForegroundColor Red
            if ($isAdmin) {
                Read-Host "Enterキーを押して終了してください"
            }
            exit 1
        }
    }

    # シンボリックリンク作成
    try {
        New-Item -ItemType SymbolicLink -Path $weztermConfigTarget -Target $weztermConfigSource -Force -ErrorAction Stop | Out-Null
        Write-Host "✓ WezTerm config symlink created successfully!" -ForegroundColor Green
        Write-Host "  Source: $weztermConfigSource" -ForegroundColor Gray
        Write-Host "  Target: $weztermConfigTarget" -ForegroundColor Gray
        Write-Host "`n💡 Next steps:" -ForegroundColor Yellow
        Write-Host "  • Install WezTerm from https://wezfurlong.org/wezterm/" -ForegroundColor Gray
        Write-Host "  • Launch WezTerm to use your dotfiles configuration" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to create WezTerm config symlink: $($_.Exception.Message)" -ForegroundColor Red
        if ($isAdmin) {
            Read-Host "Enterキーを押して終了してください"
        }
        exit 1
    }
} else {
    Write-Host "⚠️  WezTerm config source directory not found: $weztermConfigSource" -ForegroundColor Yellow
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
