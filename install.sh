#!/bin/bash
# ask 智能安装脚本
# 从 GitHub 下载 ask 及其自动完成脚本，安装到用户级目录

set -euo pipefail

# 用户级目录
BIN_DIR="${HOME}/.local/bin"
COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"

# GitHub 原始文件 URL
ASK_URL="https://github.com/m666m/ask/raw/main/ask"
COMPLETION_URL="https://github.com/m666m/ask/raw/main/ask_completion"

echo "开始安装 ask AI 助手..."

# 创建目录
mkdir -p "$BIN_DIR"
mkdir -p "$COMPLETION_DIR"

download_file() {
    local url="$1"
    local dest="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$dest"
    else
        echo "错误: 需要 curl 或 wget" >&2
        exit 1
    fi
}

# 下载 ask 脚本
echo "下载 ask 脚本..."
download_file "$ASK_URL" "$BIN_DIR/ask"

# 设置执行权限
chmod 755 "$BIN_DIR/ask"

# 下载自动完成脚本，重命名为 ask，这样才符合标准：补全脚本的文件名必须与命令名完全一致
echo "下载自动完成脚本..."
download_file "$COMPLETION_URL" "$COMPLETION_DIR/ask"

# 检查 PATH 是否包含 BIN_DIR
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "警告: $BIN_DIR 不在 PATH 中。请将以下行添加到你的 ~/.bashrc:"
    echo "  export PATH=\"\$PATH:$BIN_DIR\""
    echo "  source ~/.bashrc"
fi

echo "安装完成！"
echo "请根据 README.md 的说明设置环境变量"
echo "测试: ask hi"
