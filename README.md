# ask

Conveniently send questions to Ollama or other OpenAI-compatible APIs for analysis directly from the command line.

## 前提

    本地运行了大模型如 ollama/LM Studio，或其它 OpenAI 兼容格式的 AI 供应商账户

    本地操作系统已经安装了软件包 jq，bash-completion

## 安装方法

1.下载 ask 命令脚本和自动完成脚本

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask | sudo tee /usr/local/bin/ask >/dev/null; sudo chmod 755 /usr/local/bin/ask

    $ curl -fsSL https://github.com/m666m/ask/raw/main/completions/ask | sudo tee /usr/share/bash-completion/completions/ask >/dev/null

2.修改脚本中 MODEL 和 OLLAMA_URL 的值

TODO: 设置环境变量文件

    $ mkdir -p $HOME/.config/ask

    $ touch $HOME/.config/ask/.env && chmod 600 $HOME/.config/ask/.env

```bash
cat > ~/.config/ask/.env << 'EOF'
ASK_MODEL=gemma4:26b
ASK_OLLAMA_URL=http://localhost:11434/v1/chat/completions
ASK_OLLAMA_API=your_api_key
EOF
```

## 使用方法

### 交互模式使用

    $ ask
    分析如下问题： <paste your log>

输入回车后，会把内容发送给 AI，并显示 AI 的回复。

### 管道传送你的问题给 ask

    # 单行问题
    $ echo "给我几个 shell 命令 test 的示例" | ask

    # 多行问题
    $ cat <<- EOF | ask
    请用 Python 写一个快速排序函数，
    并添加详细注释。
    EOF

    # 从文件读取问题
    $ ask < question.txt

### 自然语言转 shell 命令

ask 后跟随 @ 符号，然后输入你的问题，会转化成 shell 命令

    $ ask @ find files larger than 100M and sort by size
    find . -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -h

### Bash 命令自动完成

ask 自动提示可用的命令参数。

    打开一个支持补全的 Bash 终端。

示例：输入 `ask tar ` 然后按 Tab 键两次。

    终端显示候选菜单，例如：

        tar czf archive.tar.gz file1 file2    (描述：压缩文件)
        tar xf archive.tar.gz                 (描述：解压缩文件)
        tar czvf archive.tar.gz /path/to/dir   (描述：压缩目录并显示过程)

    使用方向键选择其中一个，回车后命令行被替换为完整命令（如 tar czf archive.tar.gz file1 file2），可再按回车执行。

示例：输入 `ask find ` 然后 Tab，应显示 find 的常用示例。

## 高级用法

### 把 tmux 屏幕内容发送给 ask 去问 AI，适合查看程序输出或日志等场合，简化你的操作。

1. tmux 热键设置如下

```conf
# 绑定 Prefix + Ctrl+e 捕获当前窗格最近100行内容问 AI
bind C-e new-window "echo 'ask AI in progress...'; { echo 'Please analyze the following content:'; tmux capture-pane -p -t '{last}' -S -100; } | ask; echo; read -p 'Press RETURN to close...'"
```

2. 在 tmux 里，先按先导键 ctrl + b，然后再按 ctrl+e，会捕获当前窗口的内容发送给 ask，新窗口显示 AI 的回答，按回车键关闭该窗口。
