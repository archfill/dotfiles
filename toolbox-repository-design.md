# toolbox リポジトリ設計案

## 📌 背景・目的

### 課題
- claude-codeのような**オプショナルなツール**をdotfilesに含めるべきか悩んでいた
- npmグローバルインストールがdotfilesの設計方針（バイナリ、公式スクリプト、パッケージマネージャー）と合わない
- AIツールは個人の選択に依存し、必須ではない

### 調査結果
- **npmグローバルパッケージ管理は一般的**：多くの人気dotfilesリポジトリで管理されている
- よく管理されるパッケージ：eslint, typescript, tldr, trash-cli, live-server等
- 管理方法：テキストファイル + シェルスクリプト

### 採用する解決策

**🎯 推奨案: サブモジュール化 + 最小限npm管理**

```
dotfiles/                               # 親リポジトリ
├── bin/apps/tools/
│   └── npm-essentials.sh               # 必須npmパッケージ（2-3個）
├── .gitmodules                         # サブモジュール設定
└── toolbox/                            # サブモジュール
    ├── bin/
    │   ├── ai/                         # AIツール（npm多用OK）
    │   ├── npm-globals/                # 汎用npmツール
    │   └── experimental/
    └── Makefile
```

**理由:**
1. **一般的慣習への対応**: 最小限のnpm管理を追加
2. **設計方針の維持**: コアは従来通り（バイナリ、公式スクリプト優先）
3. **拡張性**: toolboxで自由に実験
4. **統合管理**: サブモジュールで1つのクローンで完結
5. **オプショナル性**: デフォルトでは実行せず、必要な人だけ

---

## 🎯 リポジトリ名

**`toolbox`**

- 短くてシンプル（7文字）
- ツール箱のイメージで親しみやすい
- 開発ツール以外も含められる汎用性
- 何でも入れられる柔軟性

---

## 📁 ディレクトリ構造

### dotfiles（親リポジトリ）
```
dotfiles/
├── .gitmodules                         # サブモジュール設定
├── toolbox/                            # サブモジュール（別リポジトリ）
│
├── bin/
│   ├── apps/
│   │   └── tools/
│   │       └── npm-essentials.sh       # 必須npmパッケージのみ
│   └── lib/
│       └── common.sh                   # toolboxと共有
│
├── config/
│   ├── versions.conf
│   ├── npm-packages.txt                # 必須npmパッケージリスト
│   └── personal.conf
│
└── Makefile                            # toolbox連携コマンド追加
```

### toolbox（サブモジュール）
```
toolbox/
├── README.md                           # リポジトリ説明
├── Makefile                            # インストールコマンド
│
├── bin/
│   ├── ai/                             # AIツール
│   │   ├── claude-code.sh              # Claude Code CLI
│   │   ├── copilot.sh                  # GitHub Copilot CLI
│   │   ├── aider.sh                    # AIペアプログラミング
│   │   └── codeium.sh                  # AI補完
│   │
│   ├── npm-globals/                    # 汎用npmツール
│   │   ├── utilities.sh                # tldr, trash-cli, serve等
│   │   ├── dev-tools.sh                # prettier, nodemon等
│   │   └── fun.sh                      # cowsay, ascii-cats等
│   │
│   ├── gui/                            # GUIアプリ
│   │   └── ...
│   │
│   ├── media/                          # メディア関連
│   │   └── ...
│   │
│   ├── productivity/                   # 生産性ツール
│   │   └── ...
│   │
│   ├── experimental/                   # 実験的ツール
│   │   └── ...
│   │
│   ├── personal/                       # 個人的な好みのツール
│   │   └── ...
│   │
│   ├── lib/                            # 共通ライブラリ
│   │   └── common.sh                   # dotfiles/bin/lib/common.shを参照/共有
│   │
│   └── init.sh                         # メインエントリーポイント
│
├── config/
│   ├── tools.conf                      # インストールするツールの選択設定
│   └── npm-globals.txt                 # npmパッケージリスト
│
└── .config/                            # ツール固有の設定ファイル
    ├── claude-code/
    ├── aider/
    └── ...
```

---

## ⚖️ 含めるツールの判断基準

### dotfiles に含めるもの
- ✅ **汎用的な開発に必須**
- ✅ **安定版・公式サポート**
- ✅ **大多数の開発者が使う**
- ✅ バイナリ、公式スクリプト、パッケージマネージャー経由
- ✅ **最小限の必須npmパッケージ（2-3個程度）**
  - 例: `typescript`, `eslint`（多くのプロジェクトで必要）

### toolbox に含めるもの
- ✅ **個人の選択に依存**
- ✅ **AI/外部サービス依存**（API認証必要等）
- ✅ **実験的・ベータ版**
- ✅ **npm/pip/cargoのグローバルインストール**（必須以外）
  - 例: tldr, trash-cli, serve, prettier, nodemon
- ✅ **GUIアプリ、メディアツール等の非開発ツール**
- ✅ **ニッチなユーティリティ**

---

## 🔗 dotfiles と toolbox の関係

### サブモジュール構成
```
dotfiles (親)
  └── toolbox (子: サブモジュール)
```

### セットアップフロー
```
1. dotfiles クローン（サブモジュール含む）
   git clone --recurse-submodules ssh://git@forgejo.archfill.com:2222/archfill/dotfiles.git

2. 基本環境構築（必須ツール）
   cd dotfiles
   make init

3. オプショナルツール（必要な人だけ）
   make toolbox-init    # サブモジュール初期化
   make toolbox-ai      # AIツールのみ
   # または
   cd toolbox && make install
```

### dotfiles側の変更

#### .gitmodules（新規作成）
```ini
[submodule "toolbox"]
    path = toolbox
    url = ssh://git@forgejo.archfill.com:2222/archfill/toolbox.git
    branch = main
```

#### Makefile（追加）
```makefile
# Toolbox integration
.PHONY: toolbox-init toolbox-update toolbox-ai

toolbox-init:
	@echo "Initializing toolbox submodule..."
	@git submodule update --init --recursive
	@echo "Toolbox initialized. Run 'make toolbox-ai' or 'cd toolbox && make help'"

toolbox-update:
	@echo "Updating toolbox to latest version..."
	@git submodule update --remote toolbox
	@echo "Toolbox updated"

toolbox-ai:
	@if [ -d "toolbox" ]; then \
		cd toolbox && make ai; \
	else \
		echo "Toolbox not initialized. Run 'make toolbox-init' first"; \
	fi
```

#### config/npm-packages.txt（新規作成）
```
# Essential npm global packages
typescript
eslint
```

#### bin/apps/tools/npm-essentials.sh（新規作成）
```bash
#!/usr/bin/env bash
# npm-essentials.sh - Install essential npm global packages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
source "${DOTFILES_ROOT}/bin/lib/common.sh"

install_npm_essentials() {
    print_header "Installing Essential NPM Packages"

    # Node.jsの確認
    if ! command_exists node; then
        print_error "Node.js is not installed"
        print_info "Run nodejs.sh first"
        return 1
    fi

    local npm_packages_file="${DOTFILES_ROOT}/config/npm-packages.txt"

    if [ ! -f "$npm_packages_file" ]; then
        print_warning "npm-packages.txt not found, skipping"
        return 0
    fi

    # コメント行と空行を除外してパッケージリストを取得
    local packages=($(grep -v '^#' "$npm_packages_file" | grep -v '^$' | tr '\n' ' '))

    if [ ${#packages[@]} -eq 0 ]; then
        print_info "No packages to install"
        return 0
    fi

    print_info "Installing packages: ${packages[*]}"

    for package in "${packages[@]}"; do
        if npm list -g "$package" &>/dev/null; then
            print_success "$package already installed"
        else
            print_info "Installing $package..."
            npm install -g "$package" --quiet
        fi
    done

    print_success "Essential npm packages installed"
}

install_npm_essentials
```

#### bin/apps_setup.sh（追加）
```bash
# CLI tools
install_if_needed "${APPS_DIR}/tools/sheldon.sh"
install_if_needed "${APPS_DIR}/tools/npm-essentials.sh"  # ← 追加
```

---

## 🛠️ toolbox 実装例

### bin/ai/claude-code.sh
```bash
#!/usr/bin/env bash
# claude-code.sh - Claude Code CLI installation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLBOX_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${TOOLBOX_ROOT}/bin/lib/common.sh"

install_claude_code() {
    print_header "Installing Claude Code"

    # Node.js 18+が必要
    if ! command_exists node; then
        print_error "Node.js is required. Please install it first."
        print_info "Run 'make init' in dotfiles repository"
        return 1
    fi

    local node_version=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$node_version" -lt 18 ]; then
        print_error "Node.js 18+ is required (current: v$node_version)"
        return 1
    fi

    # 既にインストール済みか確認
    if command_exists claude; then
        local current_version=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
        print_success "Claude Code is already installed: $current_version"
        return 0
    fi

    # ripgrepの確認（推奨）
    if ! command_exists rg; then
        print_warning "ripgrep is recommended but not installed"
        print_info "It should be installed via dotfiles"
    fi

    print_info "Installing Claude Code via npm..."
    npm install -g @anthropic-ai/claude-code

    if command_exists claude; then
        local version=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
        print_success "Claude Code installed successfully: $version"
        print_info "Run 'claude doctor' to verify installation"
    else
        print_error "Installation failed"
        return 1
    fi
}

install_claude_code
```

### bin/npm-globals/utilities.sh
```bash
#!/usr/bin/env bash
# utilities.sh - Install useful npm utility packages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLBOX_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${TOOLBOX_ROOT}/bin/lib/common.sh"

install_npm_utilities() {
    print_header "Installing NPM Utility Packages"

    if ! command_exists npm; then
        print_error "npm is not installed"
        return 1
    fi

    local packages=(
        "tldr"           # Simplified man pages
        "trash-cli"      # Safe rm alternative
        "serve"          # Static file server
        "live-server"    # Development server with live reload
        "npkill"         # Remove node_modules easily
    )

    for package in "${packages[@]}"; do
        if npm list -g "$package" &>/dev/null; then
            print_success "$package already installed"
        else
            print_info "Installing $package..."
            npm install -g "$package" --quiet
        fi
    done

    print_success "NPM utilities installed"
}

install_npm_utilities
```

### Makefile
```makefile
.PHONY: help install ai npm-utils experimental clean

help:
	@echo "Toolbox - Optional Tools Setup"
	@echo ""
	@echo "Usage:"
	@echo "  make install      - Install all selected tools"
	@echo "  make ai           - Install AI tools only"
	@echo "  make npm-utils    - Install npm utility packages"
	@echo "  make experimental - Install experimental tools"
	@echo "  make clean        - Clean installation artifacts"

install:
	@bin/init.sh

ai:
	@echo "Installing AI tools..."
	@bin/ai/claude-code.sh
	@bin/ai/aider.sh

npm-utils:
	@echo "Installing npm utilities..."
	@bin/npm-globals/utilities.sh
	@bin/npm-globals/dev-tools.sh

experimental:
	@for script in bin/experimental/*.sh; do \
		[ -f "$$script" ] && bash "$$script"; \
	done

clean:
	@echo "Cleaning installation artifacts..."
```

### config/tools.conf
```bash
# Toolbox Configuration
# インストールするツールを選択

# AI Tools
INSTALL_CLAUDE_CODE=true
INSTALL_COPILOT=false
INSTALL_AIDER=false

# NPM Utilities
INSTALL_NPM_UTILS=true

# Experimental Tools
INSTALL_EXPERIMENTAL=false
```

---

## 📦 含めるツール候補

### dotfiles（必須のみ）
- ✅ **typescript** - 多くのプロジェクトで必要
- ✅ **eslint** - Linting標準

### toolbox - AIカテゴリ
- ✅ **claude-code** - AIコーディング支援
- ✅ **GitHub Copilot CLI** - gh拡張機能
- ✅ **aider** - AIペアプログラミング
- ✅ **codeium** - AI補完

### toolbox - npm-globals（ユーティリティ）
- ✅ **tldr** - Simplified man pages
- ✅ **trash-cli** - Safe rm alternative
- ✅ **serve** / **live-server** - Development servers
- ✅ **npkill** - Remove node_modules easily
- ✅ **prettier** - Code formatter
- ✅ **nodemon** - Development watcher

### toolbox - 実験的ツール
- 試験的なCLIツール
- ベータ版ツール
- 個人的な自作ツール

### toolbox - その他
- GUIアプリ
- メディア編集ツール
- 生産性向上ツール

---

## 🚀 実装手順

### Phase 1: dotfiles側の準備

```bash
cd dotfiles

# 1. 必須npmパッケージリスト作成
cat > config/npm-packages.txt << 'EOF'
# Essential npm global packages
typescript
eslint
EOF

# 2. npm-essentials.shの作成
# （上記の実装例を bin/apps/tools/npm-essentials.sh に配置）

# 3. apps_setup.shに追加
# install_if_needed "${APPS_DIR}/tools/npm-essentials.sh"

# 4. Makefileにtoolbox連携コマンド追加
# （上記の実装例を追加）

# 5. コミット
git add config/npm-packages.txt bin/apps/tools/npm-essentials.sh
git commit -m "feat: add essential npm packages management"
```

### Phase 2: toolboxリポジトリ作成

```bash
# 1. 新規リポジトリ作成
mkdir -p ~/repos/toolbox
cd ~/repos/toolbox
git init

# 2. 基本構造の作成
mkdir -p bin/{ai,npm-globals,gui,media,experimental,personal,lib}
mkdir -p config .config
touch README.md Makefile bin/init.sh

# 3. 実装ファイル配置
# - bin/ai/claude-code.sh
# - bin/npm-globals/utilities.sh
# - bin/lib/common.sh（dotfilesから共有または複製）
# - Makefile
# - config/tools.conf

# 4. README.md作成
cat > README.md << 'EOF'
# toolbox

Optional tools for dotfiles environment.

## Setup

This repository is designed to be used as a submodule of dotfiles.

```bash
cd dotfiles
make toolbox-init
make toolbox-ai
```

## Usage

```bash
make help         # Show all commands
make ai           # Install AI tools
make npm-utils    # Install npm utilities
```

## Tools

### AI
- claude-code - AI coding assistant
- aider - AI pair programming

### NPM Utilities
- tldr, trash-cli, serve, live-server, npkill

EOF

# 5. コミット & プッシュ
git add .
git commit -m "feat: initial toolbox setup"
# Forgejoでリポジトリ作成後
git remote add origin ssh://git@forgejo.archfill.com:2222/archfill/toolbox.git
git push -u origin main
```

### Phase 3: サブモジュール化

```bash
cd ~/repos/dotfiles

# 1. サブモジュール追加
git submodule add ssh://git@forgejo.archfill.com:2222/archfill/toolbox.git toolbox

# 2. 確認
git submodule status

# 3. コミット
git add .gitmodules toolbox
git commit -m "feat: add toolbox as submodule"

# 4. プッシュ
git push
```

### Phase 4: 動作確認

```bash
# 新規クローン（サブモジュール含む）
git clone --recurse-submodules ssh://git@forgejo.archfill.com:2222/archfill/dotfiles.git test-dotfiles
cd test-dotfiles

# 基本セットアップ
make init

# toolbox初期化
make toolbox-init

# AIツールインストール
make toolbox-ai

# 確認
claude --version
```

---

## 💡 設計上のメリット

### 1. 一般的慣習への対応
dotfilesでnpm管理を採用（最小限の必須パッケージのみ）

### 2. 関心の分離
- **dotfiles**: 必須の開発環境（汎用・安定）
- **toolbox**: オプショナルなツール（個別選択・実験的）

### 3. 設計方針の維持
dotfilesのコアは従来通り（バイナリ、公式スクリプト、パッケージマネージャー優先）

### 4. 統合管理
サブモジュールで1つのクローンで完結（`--recurse-submodules`）

### 5. オプショナル性
- `make init`: 必須ツールのみ（toolbox不要）
- `make toolbox-ai`: 必要な人だけ個別に追加

### 6. 拡張性
開発ツール以外（GUI、メディア、ゲーム等）もtoolboxで管理可能

### 7. 実験しやすい
toolboxで失敗しても、dotfilesに影響なし

---

## ⚠️ サブモジュールの注意点

### クローン時
```bash
# サブモジュール含む
git clone --recurse-submodules ssh://git@forgejo.archfill.com:2222/archfill/dotfiles.git

# 既存リポジトリでサブモジュール初期化
git submodule update --init --recursive
```

### 更新時
```bash
# toolbox最新版に更新
cd dotfiles
git submodule update --remote toolbox
git add toolbox
git commit -m "chore: update toolbox"

# または
make toolbox-update
```

### 開発時
```bash
# toolbox単独で作業
cd toolbox
git checkout main
git pull

# 変更をコミット
git add .
git commit -m "feat: add new tool"
git push

# dotfiles側で参照を更新
cd ..
git add toolbox
git commit -m "chore: update toolbox reference"
```

---

## 📝 補足

### プラットフォーム対応
- macOS
- Linux (Arch, Ubuntu/Debian)
- Windows (WSL)
- Termux (Android)

dotfilesで各プラットフォームの基盤（Node.js, ripgrep等）が整っているため、toolboxは基本的にクロスプラットフォームで動作するツールを中心に扱う。

### バージョン管理
- dotfiles: `config/versions.conf` で言語・ツールのバージョン管理
- toolbox: `config/tools.conf` でインストール対象の選択

### common.shの共有
dotfiles/bin/lib/common.shをtoolboxからも参照する方法：
- シンボリックリンク（推奨しない: サブモジュールの独立性が失われる）
- 複製（推奨: toolbox単独でも動作）
- 共通部分を最小限にして、各リポジトリで独自実装

---

## 🎉 まとめ

**採用する設計:**
- dotfilesに最小限のnpm管理を追加（一般的慣習に対応）
- toolboxをサブモジュール化（オプショナルツールの分離）
- 統合管理で使いやすさを維持（1つのクローンで完結）
- 拡張性と実験性を確保（toolboxで自由に追加）

**次のアクション:**
1. dotfiles側でnpm-essentials.sh実装
2. toolboxリポジトリ作成
3. サブモジュール追加
4. 動作確認
