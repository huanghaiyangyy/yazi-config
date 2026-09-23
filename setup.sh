#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAZI_CONFIG_DIR="${HOME}/.config/yazi"
LOCAL_BIN_DIR="${HOME}/.local/bin"

echo "==> Deploying Yazi configurations..."

mkdir -p "${YAZI_CONFIG_DIR}/flavors"
mkdir -p "${LOCAL_BIN_DIR}"

# 1. 复制配置文件
cp "${SCRIPT_DIR}/yazi.toml" "${YAZI_CONFIG_DIR}/"
cp "${SCRIPT_DIR}/keymap.toml" "${YAZI_CONFIG_DIR}/"
cp "${SCRIPT_DIR}/init.lua" "${YAZI_CONFIG_DIR}/"
cp "${SCRIPT_DIR}/package.toml" "${YAZI_CONFIG_DIR}/"
cp "${SCRIPT_DIR}/theme.toml" "${YAZI_CONFIG_DIR}/"
cp "${SCRIPT_DIR}/starship.toml" "${YAZI_CONFIG_DIR}/"
cp "${SCRIPT_DIR}/bookmark" "${YAZI_CONFIG_DIR}/"
cp -r "${SCRIPT_DIR}/flavors/"* "${YAZI_CONFIG_DIR}/flavors/"

# 2. 安装并赋权智能多模态剪贴板助手脚本 (yazi-clip)
echo "==> Installing smart clipboard helper (yazi-clip)..."
cp "${SCRIPT_DIR}/scripts/yazi-clip" "${LOCAL_BIN_DIR}/yazi-clip"
chmod +x "${LOCAL_BIN_DIR}/yazi-clip"

# 3. 安装依赖插件
if command -v ya >/dev/null 2>&1; then
    echo "==> Installing Yazi plugins via ya pkg install..."
    ya pkg install
else
    echo "==> Warning: 'ya' CLI not found. Please ensure Yazi package manager is in your PATH to install plugins."
fi

echo "==> Yazi configuration deployed successfully!"
