# Windows PowerShell用 WezTerm シンボリックリンク設定スクリプト
# WezTerm設定ファイルのシンボリックリンクを作成します

param(
    [switch]$Force,
    [switch]$WhatIf,
    [switch]$Verbose
)

# スクリプトの場所を取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

# 管理者権限チェック
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ログ出力関数
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "Info"    { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# シンボリックリンク作成関数
function New-SymbolicLinkSafe {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [switch]$IsDirectory
    )
    
    try {
        # ソースパスの存在確認
        if (-not (Test-Path $SourcePath)) {
            Write-Log "Source path does not exist: $SourcePath" -Level "Error"
            return $false
        }
        
        # ターゲットディレクトリの作成
        $targetDir = Split-Path -Parent $TargetPath
        if (-not (Test-Path $targetDir)) {
            Write-Log "Creating target directory: $targetDir" -Level "Info"
            if (-not $WhatIf) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
        }
        
        # 既存ファイル/ディレクトリの処理
        if (Test-Path $TargetPath) {
            if ($Force) {
                Write-Log "Removing existing item: $TargetPath" -Level "Warning"
                if (-not $WhatIf) {
                    Remove-Item -Path $TargetPath -Recurse -Force
                }
            } else {
                Write-Log "Target already exists (use -Force to overwrite): $TargetPath" -Level "Warning"
                return $false
            }
        }
        
        # WhatIfモードの場合
        if ($WhatIf) {
            Write-Log "Would create symbolic link: $TargetPath -> $SourcePath" -Level "Info"
            return $true
        }
        
        # シンボリックリンクの作成
        $linkType = if ($IsDirectory) { "Junction" } else { "SymbolicLink" }
        
        Write-Log "Creating $linkType : $TargetPath -> $SourcePath" -Level "Info"
        New-Item -ItemType $linkType -Path $TargetPath -Value $SourcePath -Force | Out-Null
        
        # 作成確認
        if (Test-Path $TargetPath) {
            Write-Log "Successfully created: $TargetPath" -Level "Success"
            return $true
        } else {
            Write-Log "Failed to create: $TargetPath" -Level "Error"
            return $false
        }
        
    } catch {
        Write-Log "Error creating symbolic link: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

# WezTerm設定のシンボリックリンク作成
function Set-WeztermLinks {
    Write-Log "=== WezTerm Configuration Setup ===" -Level "Info"
    Write-Log "Dotfiles Root: $DotfilesRoot" -Level "Info"
    
    # 設定ファイルのパス定義
    $weztermConfigs = @(
        @{
            Source = "$DotfilesRoot\.config\wezterm"
            Target = "$env:USERPROFILE\.config\wezterm"
            IsDirectory = $true
        }
    )
    
    $successCount = 0
    $totalCount = $weztermConfigs.Count
    
    foreach ($config in $weztermConfigs) {
        Write-Log "Processing: $($config.Source)" -Level "Info"
        
        if (New-SymbolicLinkSafe -SourcePath $config.Source -TargetPath $config.Target -IsDirectory:$config.IsDirectory) {
            $successCount++
        }
        
        Write-Host "" # 空行
    }
    
    # 結果サマリー
    Write-Log "=== Setup Summary ===" -Level "Info"
    Write-Log "Total configurations: $totalCount" -Level "Info"
    Write-Log "Successfully created: $successCount" -Level "Success"
    Write-Log "Failed: $($totalCount - $successCount)" -Level "Error"
    
    if ($successCount -eq $totalCount) {
        Write-Log "All WezTerm configurations have been successfully linked!" -Level "Success"
        Write-Log "You can now use your dotfiles WezTerm configuration." -Level "Info"
    } else {
        Write-Log "Some configurations failed to link. Please check the errors above." -Level "Warning"
    }
}

# メイン実行
function Main {
    Write-Log "Starting WezTerm symbolic link setup for Windows" -Level "Info"
    
    # 管理者権限の確認
    if (-not (Test-Administrator)) {
        Write-Log "This script requires administrator privileges to create symbolic links." -Level "Warning"
        Write-Log "Please run PowerShell as Administrator and try again." -Level "Warning"
        Write-Log "Or use 'mklink' command manually in elevated Command Prompt." -Level "Info"
        
        if (-not $Force) {
            exit 1
        }
    }
    
    # Verbose出力の設定
    if ($Verbose) {
        $VerbosePreference = "Continue"
    }
    
    # WhatIfモードの説明
    if ($WhatIf) {
        Write-Log "Running in WhatIf mode - no actual changes will be made" -Level "Info"
    }
    
    # DotfilesROOTの存在確認
    if (-not (Test-Path "$DotfilesRoot\.config\wezterm")) {
        Write-Log "WezTerm configuration not found in dotfiles: $DotfilesRoot\.config\wezterm" -Level "Error"
        Write-Log "Please make sure you're running this script from the correct location." -Level "Error"
        exit 1
    }
    
    # シンボリックリンク作成実行
    Set-WeztermLinks
    
    Write-Log "Script execution completed." -Level "Info"
}

# スクリプト実行
Main