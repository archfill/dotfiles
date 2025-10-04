# PowerShell 7 Profile for Japanese Environment
# UTF-8エンコーディング設定

# コードページをUTF-8に変更
chcp 65001 > $null

# コンソールエンコーディングをUTF-8に設定
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# PowerShellの出力エンコーディングをUTF-8に設定
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# 環境変数でUTF-8を明示
$env:PYTHONIOENCODING = "utf-8"

# プロンプトのカスタマイズ（オプション）
function prompt {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    if($principal.IsInRole($adminRole)) {
        $prefix = "Admin"
    } else {
        $prefix = "PS"
    }

    "$prefix $($executionContext.SessionState.Path.CurrentLocation)> "
}

# エイリアス設定
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String

# dotfiles管理用の関数
function Edit-DotFiles {
    Set-Location "$env:USERPROFILE\dotfiles"
}
Set-Alias -Name dotfiles -Value Edit-DotFiles

Write-Host "PowerShell 7 Profile Loaded - UTF-8 Encoding Enabled" -ForegroundColor Green