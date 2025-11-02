# Windows Font Installation Script
# Installs fonts via Scoop (nerd-fonts) and GitHub (Japanese fonts)

param(
    [switch]$Help,
    [switch]$All,
    [switch]$Programming,
    [switch]$Japanese,
    [string[]]$Fonts
)

# 色付き出力のヘルパー関数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "Windows Font Installation Script" "Cyan"
    Write-ColorOutput "Usage: .\install-fonts.ps1 [options]" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Options:" "White"
    Write-ColorOutput "  -Help              Show this help message" "Gray"
    Write-ColorOutput "  -All               Install all recommended fonts" "Gray"
    Write-ColorOutput "  -Programming       Install programming fonts only (via Scoop)" "Gray"
    Write-ColorOutput "  -Japanese          Install Japanese fonts only (via GitHub)" "Gray"
    Write-ColorOutput "  -Fonts <names>     Install specific fonts (comma-separated)" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:" "White"
    Write-ColorOutput "  .\install-fonts.ps1                # Interactive mode" "Gray"
    Write-ColorOutput "  .\install-fonts.ps1 -All           # Install all fonts" "Gray"
    Write-ColorOutput "  .\install-fonts.ps1 -Programming   # Programming fonts only" "Gray"
    Write-ColorOutput "  .\install-fonts.ps1 -Japanese      # Japanese fonts only" "Gray"
    Write-ColorOutput "  .\install-fonts.ps1 -Fonts FiraCode-NF-Mono,HackGenConsole" "Gray"
}

# Scoopフォント定義（nerd-fonts bucket）
$ScoopFonts = @{
    "FiraCode-NF-Mono" = "Fira Code (リガチャ対応、人気)"
    "JetBrainsMono-NF-Mono" = "JetBrains Mono (JetBrains製、人気)"
    "CascadiaCode-NF-Mono" = "Cascadia Code (Microsoft製)"
    "Hack-NF-Mono" = "Hack (シンプル、読みやすい)"
}

# GitHubフォント定義（日本語対応フォント）
$GitHubFonts = @{
    # HackGen 通常版（Nerd Fontsなし）
    "HackGen" = @{
        Description = "HackGen (Hack + 源ノ角ゴシック)"
        Repo = "yuru7/HackGen"
        AssetPattern = "HackGen_v*.zip"
        FontFiles = @("HackGen-Regular.ttf", "HackGen-Bold.ttf")
    }
    "HackGen-Console" = @{
        Description = "HackGen Console (全角スペース可視化)"
        Repo = "yuru7/HackGen"
        AssetPattern = "HackGen_v*.zip"
        FontFiles = @("HackGenConsole-Regular.ttf", "HackGenConsole-Bold.ttf")
    }
    "HackGen35" = @{
        Description = "HackGen35 (3:5幅版)"
        Repo = "yuru7/HackGen"
        AssetPattern = "HackGen_v*.zip"
        FontFiles = @("HackGen35-Regular.ttf", "HackGen35-Bold.ttf")
    }
    "HackGen35-Console" = @{
        Description = "HackGen35 Console (3:5幅 + 可視化)"
        Repo = "yuru7/HackGen"
        AssetPattern = "HackGen_v*.zip"
        FontFiles = @("HackGen35Console-Regular.ttf", "HackGen35Console-Bold.ttf")
    }

    # HackGen Nerd Fonts版（v2.7.0以降Console版のみ）
    "HackGenConsole-NF" = @{
        Description = "HackGen Console NF (Nerd Fonts)"
        Repo = "yuru7/HackGen"
        AssetPattern = "HackGen_NF_v*.zip"
        FontFiles = @("HackGenConsoleNF-Regular.ttf", "HackGenConsoleNF-Bold.ttf")
    }
    "HackGen35Console-NF" = @{
        Description = "HackGen35 Console NF (Nerd Fonts 3:5幅)"
        Repo = "yuru7/HackGen"
        AssetPattern = "HackGen_NF_v*.zip"
        FontFiles = @("HackGen35ConsoleNF-Regular.ttf", "HackGen35ConsoleNF-Bold.ttf")
    }

    # PlemolJP
    "PlemolJPConsole" = @{
        Description = "PlemolJP Console NF (IBM Plex Mono + 日本語)"
        Repo = "yuru7/PlemolJP"
        AssetPattern = "PlemolJP_NF_v*.zip"
        FontFiles = @("PlemolJPConsoleNF-Regular.ttf", "PlemolJPConsoleNF-Bold.ttf")
    }

    # UDEV Gothic
    "UDEVGothic" = @{
        Description = "UDEV Gothic NF (BIZ UDゴシック + JetBrains Mono)"
        Repo = "yuru7/udev-gothic"
        AssetPattern = "UDEVGothic_NF_v*.zip"
        FontFiles = @("UDEVGothicNF-Regular.ttf", "UDEVGothicNF-Bold.ttf")
    }
}

function Test-ScoopInstalled {
    $scoopPath = Get-Command scoop -ErrorAction SilentlyContinue
    if (-not $scoopPath) {
        Write-ColorOutput "⚠️  Scoopがインストールされていません（プログラミング用フォントに必要）" "Yellow"
        Write-ColorOutput "   インストール: irm get.scoop.sh | iex" "Gray"
        return $false
    }
    return $true
}

function Add-NerdFontsBucket {
    Write-ColorOutput "🔍 nerd-fonts bucketの確認中..." "Cyan"

    $buckets = & scoop bucket list 2>$null | Out-String
    if ($buckets -match "nerd-fonts") {
        Write-ColorOutput "✅ nerd-fonts bucketは既に追加されています" "Green"
        return $true
    }

    Write-ColorOutput "📦 nerd-fonts bucketを追加中..." "Yellow"
    try {
        & scoop bucket add nerd-fonts 2>&1 | Out-Null
        Write-ColorOutput "✅ nerd-fonts bucketを追加しました" "Green"
        return $true
    } catch {
        Write-ColorOutput "❌ nerd-fonts bucketの追加に失敗しました: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-FontInstalled {
    param(
        [string]$FontName
    )

    # Scoopフォントチェック
    if ($ScoopFonts.ContainsKey($FontName)) {
        $installed = & scoop list 2>$null | Out-String
        return $installed -match $FontName
    }

    # GitHubフォントチェック（フォントファイルの存在確認）
    if ($GitHubFonts.ContainsKey($FontName)) {
        $fontDef = $GitHubFonts[$FontName]
        $fontsFolder = [Environment]::GetFolderPath("Fonts")

        foreach ($fontFile in $fontDef.FontFiles) {
            $fontPath = Join-Path $fontsFolder $fontFile
            if (Test-Path $fontPath) {
                return $true
            }
        }
        return $false
    }

    return $false
}

function Install-ScoopFont {
    param(
        [string]$FontName,
        [string]$Description
    )

    if (Test-FontInstalled -FontName $FontName) {
        Write-ColorOutput "⏭️  $Description : 既にインストール済み" "Gray"
        return $true
    }

    Write-ColorOutput "📥 $Description をインストール中..." "Cyan"
    try {
        & scoop install "nerd-fonts/$FontName" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ $Description をインストールしました" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ $Description のインストールに失敗しました (Exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ $Description のインストールに失敗しました: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Install-GitHubFont {
    param(
        [string]$FontName,
        [hashtable]$FontDef
    )

    if (Test-FontInstalled -FontName $FontName) {
        Write-ColorOutput "⏭️  $($FontDef.Description) : 既にインストール済み" "Gray"
        return $true
    }

    Write-ColorOutput "📥 $($FontDef.Description) をGitHubからダウンロード中..." "Cyan"

    try {
        # 最新リリース取得
        $apiUrl = "https://api.github.com/repos/$($FontDef.Repo)/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop

        # アセット検索
        $assetPattern = $FontDef.AssetPattern -replace '\*', '.*'
        $asset = $release.assets | Where-Object { $_.name -match $assetPattern } | Select-Object -First 1

        if (-not $asset) {
            Write-ColorOutput "❌ アセットが見つかりません: $($FontDef.AssetPattern)" "Red"
            return $false
        }

        # 一時ディレクトリ
        $tempDir = Join-Path $env:TEMP "font-install-$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        $zipPath = Join-Path $tempDir $asset.name
        $extractPath = Join-Path $tempDir "extracted"

        # ダウンロード
        Write-ColorOutput "   ダウンロード中: $($asset.name) ($([Math]::Round($asset.size / 1MB, 2)) MB)" "Gray"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -ErrorAction Stop

        # 解凍
        Write-ColorOutput "   解凍中..." "Gray"
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force -ErrorAction Stop

        # フォントインストール
        Write-ColorOutput "   フォントをインストール中..." "Gray"
        $installed = 0
        $fontsFolder = [Environment]::GetFolderPath("Fonts")
        $shellApp = New-Object -ComObject Shell.Application
        $fontsFolderObj = $shellApp.Namespace($fontsFolder)

        foreach ($fontFile in $FontDef.FontFiles) {
            # 解凍されたフォルダからフォントファイルを検索
            $fontPath = Get-ChildItem -Path $extractPath -Filter $fontFile -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

            if ($fontPath) {
                $fontsFolderObj.CopyHere($fontPath.FullName, 0x10)  # 0x10 = 上書き確認なし
                $installed++
            }
        }

        # クリーンアップ
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

        if ($installed -gt 0) {
            Write-ColorOutput "✅ $($FontDef.Description) をインストールしました ($installed ファイル)" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ フォントファイルが見つかりませんでした" "Red"
            return $false
        }

    } catch {
        Write-ColorOutput "❌ $($FontDef.Description) のインストールに失敗しました: $($_.Exception.Message)" "Red"
        # クリーンアップ
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        return $false
    }
}

function Show-InteractiveMenu {
    Write-ColorOutput "`n=== フォント選択メニュー ===" "Cyan"
    Write-ColorOutput ""

    Write-ColorOutput "📝 プログラミング用フォント (via Scoop):" "Yellow"
    $index = 1
    foreach ($font in $ScoopFonts.GetEnumerator()) {
        Write-ColorOutput "  [$index] $($font.Value)" "Gray"
        $index++
    }

    Write-ColorOutput ""
    Write-ColorOutput "🇯🇵 日本語対応フォント (via GitHub):" "Yellow"
    foreach ($font in $GitHubFonts.GetEnumerator()) {
        Write-ColorOutput "  [$index] $($font.Value.Description)" "Gray"
        $index++
    }

    Write-ColorOutput ""
    Write-ColorOutput "クイックオプション:" "White"
    Write-ColorOutput "  [A] すべてインストール" "Gray"
    Write-ColorOutput "  [P] プログラミング用のみ" "Gray"
    Write-ColorOutput "  [J] 日本語対応のみ" "Gray"
    Write-ColorOutput "  [Q] 終了" "Gray"
    Write-ColorOutput ""

    $choice = Read-Host "選択してください (番号/A/P/J/Q)"
    return $choice.ToUpper()
}

function Install-FontsByChoice {
    param(
        [string]$Choice
    )

    switch ($Choice) {
        "A" {
            Write-ColorOutput "`n📦 すべてのフォントをインストールします" "Cyan"

            # Scoopフォント
            if (Test-ScoopInstalled) {
                Add-NerdFontsBucket | Out-Null
                foreach ($font in $ScoopFonts.GetEnumerator()) {
                    Install-ScoopFont -FontName $font.Key -Description $font.Value
                }
            }

            # GitHubフォント
            foreach ($font in $GitHubFonts.GetEnumerator()) {
                Install-GitHubFont -FontName $font.Key -FontDef $font.Value
            }
        }
        "P" {
            Write-ColorOutput "`n📦 プログラミング用フォントをインストールします" "Cyan"
            if (Test-ScoopInstalled) {
                Add-NerdFontsBucket | Out-Null
                foreach ($font in $ScoopFonts.GetEnumerator()) {
                    Install-ScoopFont -FontName $font.Key -Description $font.Value
                }
            } else {
                Write-ColorOutput "⚠️  Scoopが必要です" "Yellow"
            }
        }
        "J" {
            Write-ColorOutput "`n📦 日本語対応フォントをインストールします" "Cyan"
            foreach ($font in $GitHubFonts.GetEnumerator()) {
                Install-GitHubFont -FontName $font.Key -FontDef $font.Value
            }
        }
        "Q" {
            Write-ColorOutput "終了します" "Yellow"
            exit 0
        }
        default {
            # 数字で個別選択
            try {
                $num = [int]$Choice
                $allFonts = @()

                # Scoopフォントを追加
                foreach ($font in $ScoopFonts.GetEnumerator()) {
                    $allFonts += @{
                        Type = "Scoop"
                        Name = $font.Key
                        Description = $font.Value
                    }
                }

                # GitHubフォントを追加
                foreach ($font in $GitHubFonts.GetEnumerator()) {
                    $allFonts += @{
                        Type = "GitHub"
                        Name = $font.Key
                        FontDef = $font.Value
                    }
                }

                if ($num -gt 0 -and $num -le $allFonts.Count) {
                    $selectedFont = $allFonts[$num - 1]

                    if ($selectedFont.Type -eq "Scoop") {
                        if (Test-ScoopInstalled) {
                            Add-NerdFontsBucket | Out-Null
                            Install-ScoopFont -FontName $selectedFont.Name -Description $selectedFont.Description
                        } else {
                            Write-ColorOutput "⚠️  Scoopが必要です" "Yellow"
                        }
                    } else {
                        Install-GitHubFont -FontName $selectedFont.Name -FontDef $selectedFont.FontDef
                    }
                } else {
                    Write-ColorOutput "❌ 無効な選択です" "Red"
                }
            } catch {
                Write-ColorOutput "❌ 無効な入力です" "Red"
            }
        }
    }
}

function Main {
    if ($Help) {
        Show-Help
        return
    }

    Write-ColorOutput "🔤 Windows Font Installer" "Green"
    Write-ColorOutput "   Scoop (nerd-fonts) + GitHub (日本語フォント)" "Gray"
    Write-ColorOutput ""

    # インストール済みフォント表示
    Write-ColorOutput "📋 インストール済みフォント:" "Yellow"
    $hasInstalled = $false

    foreach ($font in $ScoopFonts.GetEnumerator()) {
        if (Test-FontInstalled -FontName $font.Key) {
            Write-ColorOutput "  ✅ $($font.Value) [Scoop]" "Green"
            $hasInstalled = $true
        }
    }

    foreach ($font in $GitHubFonts.GetEnumerator()) {
        if (Test-FontInstalled -FontName $font.Key) {
            Write-ColorOutput "  ✅ $($font.Value.Description) [GitHub]" "Green"
            $hasInstalled = $true
        }
    }

    if (-not $hasInstalled) {
        Write-ColorOutput "  (なし)" "Gray"
    }
    Write-ColorOutput ""

    # コマンドライン引数による処理
    if ($All) {
        Write-ColorOutput "📦 すべてのフォントをインストールします" "Cyan"
        Write-ColorOutput ""

        # Scoopフォント
        if (Test-ScoopInstalled) {
            Add-NerdFontsBucket | Out-Null
            foreach ($font in $ScoopFonts.GetEnumerator()) {
                Install-ScoopFont -FontName $font.Key -Description $font.Value
            }
        }

        # GitHubフォント
        foreach ($font in $GitHubFonts.GetEnumerator()) {
            Install-GitHubFont -FontName $font.Key -FontDef $font.Value
        }
    }
    elseif ($Programming) {
        Write-ColorOutput "📦 プログラミング用フォントをインストールします" "Cyan"
        Write-ColorOutput ""

        if (Test-ScoopInstalled) {
            Add-NerdFontsBucket | Out-Null
            foreach ($font in $ScoopFonts.GetEnumerator()) {
                Install-ScoopFont -FontName $font.Key -Description $font.Value
            }
        } else {
            Write-ColorOutput "⚠️  Scoopが必要です。インストール: irm get.scoop.sh | iex" "Yellow"
        }
    }
    elseif ($Japanese) {
        Write-ColorOutput "📦 日本語対応フォントをインストールします" "Cyan"
        Write-ColorOutput ""

        foreach ($font in $GitHubFonts.GetEnumerator()) {
            Install-GitHubFont -FontName $font.Key -FontDef $font.Value
        }
    }
    elseif ($Fonts.Count -gt 0) {
        Write-ColorOutput "📦 指定されたフォントをインストールします" "Cyan"
        Write-ColorOutput ""

        foreach ($fontName in $Fonts) {
            if ($ScoopFonts.ContainsKey($fontName)) {
                if (Test-ScoopInstalled) {
                    Add-NerdFontsBucket | Out-Null
                    Install-ScoopFont -FontName $fontName -Description $ScoopFonts[$fontName]
                } else {
                    Write-ColorOutput "⚠️  Scoopが必要です: $fontName" "Yellow"
                }
            }
            elseif ($GitHubFonts.ContainsKey($fontName)) {
                Install-GitHubFont -FontName $fontName -FontDef $GitHubFonts[$fontName]
            }
            else {
                Write-ColorOutput "⚠️  未知のフォント: $fontName (スキップ)" "Yellow"
            }
        }
    }
    else {
        # インタラクティブモード
        do {
            $choice = Show-InteractiveMenu
            if ($choice -ne "Q") {
                Install-FontsByChoice -Choice $choice
                Write-ColorOutput "`nPress Enter to continue..." "Gray"
                Read-Host
            }
        } while ($choice -ne "Q")
    }

    Write-ColorOutput "`n✅ フォントのインストール処理が完了しました" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "💡 ターミナルを再起動してフォントを反映してください" "Yellow"
}

# スクリプト実行
Main
