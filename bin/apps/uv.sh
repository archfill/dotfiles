#!/usr/bin/env bash

# uv - Python package and project manager
# Install uv using the official installer
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH for the current session
export PATH="$HOME/.cargo/bin:$PATH"

# Verify installation
if command -v uv >/dev/null 2>&1; then
  echo "uv installed successfully"
  uv --version
else
  echo "uv installation failed"
  exit 1
fi
