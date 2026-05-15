#!/bin/bash
# ask 智能安装脚本
# 从 GitHub 下载 ask 及其自动完成脚本，安装到用户级目录，并生成环境变量文件

set -euo pipefail

# 用户级目录
BIN_DIR="${HOME}/.local/bin"
COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
CONFIG_DIR="${HOME}/.config/ask"

# GitHub 原始文件 URL
ASK_URL="https://github.com/m666m/ask/raw/main/ask"
COMPLETION_URL="https://github.com/m666m/ask/raw/main/ask_completion"

echo "开始安装 ask AI 助手..."

# 创建目录
mkdir -p "$BIN_DIR"
mkdir -p "$COMPLETION_DIR"
mkdir -p "$CONFIG_DIR"

# 下载 ask 脚本
echo "下载 ask 脚本..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$ASK_URL" -o "$BIN_DIR/ask"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$ASK_URL" -O "$BIN_DIR/ask"
else
    echo "错误: 需要 curl 或 wget" >&2
    exit 1
fi

# 设置执行权限
chmod 755 "$BIN_DIR/ask"

# 下载自动完成脚本，重命名为 ask_completion
echo "下载自动完成脚本..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$COMPLETION_URL" -o "$COMPLETION_DIR/ask_completion"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$COMPLETION_URL" -O "$COMPLETION_DIR/ask_completion"
else
    echo "错误: 需要 curl 或 wget" >&2
    exit 1
fi

# 生成环境变量文件
echo "生成环境变量配置文件..."
cat > "$CONFIG_DIR/ask.env" << 'EOF'
# ask 环境变量配置文件
# 修改以下值以适应你的 AI 服务

# 本地 Ollama 设置
# ASK_MODEL=llama3.1:8b
# ASK_OLLAMA_URL=http://localhost:11434/v1/chat/completions

# 外部 OpenAI 兼容 API 设置（优先级高于本地）
# ASK_API_KEY=your_api_key_here
# ASK_API_MODEL=gpt-4
# ASK_API_URL=https://api.openai.com/v1/chat/completions

# 取消注释并修改上面的值
EOF

# 检查 PATH 是否包含 BIN_DIR
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "警告: $BIN_DIR 不在 PATH 中。请将以下行添加到你的 ~/.bashrc 或 ~/.profile:"
    echo "export PATH=\"\$PATH:$BIN_DIR\""
fi

echo "安装完成！"
echo "请编辑 $CONFIG_DIR/ask.env 以设置你的 AI 服务配置。"
echo "然后运行: source $CONFIG_DIR/ask.env"
echo "测试: ask hi"
