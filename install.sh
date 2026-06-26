#!/bin/bash
# ask 智能安装脚本
# 从 GitHub 下载 ask 及其自动完成脚本，安装到用户级目录

set -euo pipefail

# 用户级目录
BIN_DIR="${HOME}/.local/bin"
COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
ZSH_COMPLETION_DIR="${HOME}/.local/share/zsh/site-functions"

# GitHub 原始文件 URL
ASK_URL="https://github.com/m666m/ask/raw/main/ask"
COMPLETION_URL="https://github.com/m666m/ask/raw/main/ask_completion"
ZSH_COMPLETION_URL="https://github.com/m666m/ask/raw/main/_ask"

echo "开始安装 ask AI 助手..."

# 创建目录
mkdir -p "$BIN_DIR"
mkdir -p "$COMPLETION_DIR"
mkdir -p "$ZSH_COMPLETION_DIR"

# 下载工具：可通过 ASK_INSTALL_CURL 环境变量自定义（如传入自定义函数名或 curl 参数）
CURL="${ASK_INSTALL_CURL:-curl -fsSL}"

# 下载 ask 脚本
echo "下载 ask 脚本..."
if ! $CURL "$ASK_URL" > "$BIN_DIR/ask"; then
    rm -f "$BIN_DIR/ask"
    echo "错误: ask 安装失败，请检查网络后重试" >&2
    exit 1
fi

# 设置执行权限
chmod 755 "$BIN_DIR/ask"

# 下载自动完成脚本，重命名为 ask，这样才符合标准：补全脚本的文件名必须与命令名完全一致
echo "下载自动完成脚本..."
if ! $CURL "$COMPLETION_URL" > "$COMPLETION_DIR/ask"; then
    rm -f "$COMPLETION_DIR/ask"
    echo "错误: 自动完成脚本安装失败，请检查网络后重试" >&2
    exit 1
fi

# 下载 zsh 自动完成脚本
echo "下载 zsh 自动完成脚本..."
if ! $CURL "$ZSH_COMPLETION_URL" > "$ZSH_COMPLETION_DIR/_ask"; then
    rm -f "$ZSH_COMPLETION_DIR/_ask"
    echo "错误: zsh 自动完成脚本安装失败，请检查网络后重试" >&2
    exit 1
fi

# 检查 PATH 是否包含 BIN_DIR
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "警告: $BIN_DIR 不在 PATH 中。请将以下行添加到你使用的 shell 配置文件:"
    echo "  bash: echo 'export PATH=\"\$PATH:$BIN_DIR\"' >> ~/.bashrc"
    [[ -f "${HOME}/.zshrc" ]]  && echo "  zsh:  echo 'export PATH=\"\$PATH:$BIN_DIR\"' >> ~/.zshrc"
fi

# 如果用户使用 zsh，提示配置 fpath 以启用命令补全
if [[ -f "${HOME}/.zshrc" ]]; then
    echo "注意: 为启用 zsh 命令补全，请将以下行添加到 ~/.zshrc:"
    echo "  fpath=(\"$ZSH_COMPLETION_DIR\" \$fpath)"
    echo "  autoload -Uz compinit && compinit"
fi

echo "安装完成！"
echo "请根据 README.md 的说明设置环境变量"
echo "测试: ask hi"
