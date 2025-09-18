# Windows dotfiles setup script
# WSL設定をシンボリックリンクで管理

Write-Host "Setting up Windows dotfiles..." -ForegroundColor Green

# 管理者権限チェック
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Warning "このスクリプトは管理者権限で実行する必要があります"
    Write-Host "PowerShellを管理者として実行してから再実行してください" -ForegroundColor Yellow
    exit 1
}

# 変数設定
$dotfilesDir = "$env:USERPROFILE\dotfiles\windows"
$homeDir = $env:USERPROFILE

# .wslconfig のシンボリックリンク作成
$wslconfigSource = "$dotfilesDir\.wslconfig"
$wslconfigTarget = "$homeDir\.wslconfig"

Write-Host "Setting up .wslconfig..." -ForegroundColor Cyan

# 既存の.wslconfigがある場合はバックアップ
if (Test-Path $wslconfigTarget) {
    if (-not (Get-Item $wslconfigTarget).LinkType) {
        $backupPath = "$wslconfigTarget.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Move-Item $wslconfigTarget $backupPath
        Write-Host "Existing .wslconfig backed up to: $backupPath" -ForegroundColor Yellow
    } else {
        Remove-Item $wslconfigTarget
    }
}

# シンボリックリンク作成
New-Item -ItemType SymbolicLink -Path $wslconfigTarget -Target $wslconfigSource
Write-Host "✓ .wslconfig symlink created" -ForegroundColor Green

Write-Host "`nSetup completed successfully!" -ForegroundColor Green
Write-Host "WSL設定がdotfilesで管理されるようになりました" -ForegroundColor Green
