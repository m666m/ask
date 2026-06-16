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

# curlgh - 从 GitHub 下载文件，支持多种 URL 格式，直连失败自动降级到 jsDelivr CDN
curlgh() {
    if [ $# -eq 0 ]; then
        echo "获取 github 文件，下载超时则自动更换 CDN 下载：" >&2
        echo "  curlgh https://github.com/m666m/ask/blob/main/install.sh" >&2
        echo "  curlgh https://github.com/m666m/ask/raw/refs/heads/main/install.sh" >&2
        echo "  curlgh https://raw.githubusercontent.com/m666m/ask/main/install.sh" >&2
        return 1
    fi

    local url="$1"
    local raw_url=""

    # NOTE: 调用可能不存在的命令，必须先 `command -v` 判断一下，否则不存在的命令Fedora会搜索软件仓库导致卡顿
    if ! command -v curl >/dev/null 2>&1; then
        echo "  Error: Cant find curl!" >&2
        return 1
    fi

    # ---------- 第一步：统一转换为 raw.githubusercontent.com 地址 ----------
    if [[ "$url" == *"raw.githubusercontent.com"* ]]; then
        # 已经是原始文件地址
        raw_url="$url"
    elif [[ "$url" == *"github.com"* ]]; then
        # 处理页面浏览地址，例如 https://github.com/m666m/ask/blob/main/install.sh
        # 转换为原始文件地址   https://raw.githubusercontent.com/m666m/ask/main/install.sh
        if [[ "$url" == *"/blob/"* ]]; then
            raw_url=$(echo "$url" | sed 's#https://github.com/#https://raw.githubusercontent.com/#; s#/blob/#/#')

        # 处理 /raw/ 格式的浏览地址，自动去除 /refs/heads/ 和 /refs/tags/ 部分
        # https://github.com/m666m/ask/raw/refs/heads/main/install.sh
        #   → https://raw.githubusercontent.com/m666m/ask/main/install.sh
        elif [[ "$url" == *"/raw/"* ]]; then
            raw_url=$(echo "$url" | sed -E 's#https://github.com/([^/]+)/([^/]+)/raw/(refs/(heads|tags)/)?([^/]+)/(.*)#https://raw.githubusercontent.com/\1/\2/\5/\6#')
        else
            echo "[curlgh] 不支持的 GitHub 链接格式: $url" >&2
            return 1
        fi
    else
        # 非 GitHub 链接，直接报错
        echo "[curlgh] 不支持的非 GitHub 链接: $url" >&2
        return 1
    fi

    # ---------- 第二步：优先从原始地址下载 ----------
    if curl -fsSL --connect-timeout 5 --max-time 30 "$raw_url"; then
        return 0
    fi

    # ---------- 第三步：原始地址下载失败，则尝试 jsDelivr CDN 地址 ----------
    # https://raw.githubusercontent.com/m666m/ask/main/install.sh
    #   ↓
    # https://cdn.jsdelivr.net/gh/m666m/ask@main/install.sh
    local cdn_url
    # shellcheck disable=SC2001  # 需要正则回引号重组 URL，不能用 ${//}
    cdn_url=$(echo "$raw_url" | sed 's|https://raw.githubusercontent.com/\([^/]*\)/\([^/]*\)/\([^/]*\)/\(.*\)|https://cdn.jsdelivr.net/gh/\1/\2@\3/\4|')

    echo "[curlgh] 原始地址下载失败，尝试 CDN 地址: $cdn_url" >&2

    if curl -fsSL --connect-timeout 10 --max-time 60 "$cdn_url"; then
        return 0
    else
        echo "[curlgh] CDN 下载也失败了，请重试！" >&2
        return 1
    fi
}

# 下载 ask 脚本
echo "下载 ask 脚本..."
if ! curlgh "$ASK_URL" > "$BIN_DIR/ask"; then
    rm -f "$BIN_DIR/ask"
    echo "错误: ask 安装失败，请检查网络后重试" >&2
    exit 1
fi

# 设置执行权限
chmod 755 "$BIN_DIR/ask"

# 下载自动完成脚本，重命名为 ask，这样才符合标准：补全脚本的文件名必须与命令名完全一致
echo "下载自动完成脚本..."
if ! curlgh "$COMPLETION_URL" > "$COMPLETION_DIR/ask"; then
    rm -f "$COMPLETION_DIR/ask"
    echo "错误: 自动完成脚本安装失败，请检查网络后重试" >&2
    exit 1
fi

# 下载 zsh 自动完成脚本
echo "下载 zsh 自动完成脚本..."
if ! curlgh "$ZSH_COMPLETION_URL" > "$ZSH_COMPLETION_DIR/_ask"; then
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
