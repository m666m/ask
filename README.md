# ask

命令行 AI 助手 — 提问、把你说的话转成 Shell 命令、自动推荐命令补全、分析日志。轻量、纯 Shell 实现，支持本地运行大模型的后端如 ollama/LM Studio/llama.cpp，或具备互联网上提供 OpenAI 兼容格式的 AI 供应商账户。

## 前提

    本地运行了大模型的后端，如 ollama/LM Studio/llama.cpp，或具备互联网上提供 OpenAI 兼容格式的 AI 供应商账户

    本地操作系统已经安装了软件包 jq, curl/wget, bash-completion

## 安装

1、运行安装脚本，它会从 GitHub 下载 ask 及其 bash 命令行自动完成脚本，安装到用户级目录：

    $ curl -fsSL https://github.com/m666m/ask/raw/main/install.sh | bash

安装后，ask 默认连接本地 Ollama，使用模型名 llama3.1:8b

    $ ask hi

2、设置模型供应商地址和模型名

若使用本地供应商（可以提供 OpenAI 兼容格式的访问）如 ollama/LM studio/llama.cpp 等，设置如下变量即可：

    $ export ASK_MODEL=llama3.1:8b
    $ export ASK_OLLAMA_URL=http://localhost:11434/v1/chat/completions

    $ ask hi

若使用需要 API Key 的外部服务（如 OpenAI、其他兼容 API），设置如下变量即可：

    $ export ASK_API_KEY=sk-your-key-here
    $ export ASK_API_URL=https://api.openai.com/v1/chat/completions
    $ export ASK_API_MODEL=gpt-4o

    $ ask hi

如果以上环境变量都存在，则 ASK_API_* 系列优先生效。

取消或切换回本地 Ollama，只需清除这三个变量：

    $ unset ASK_API_KEY ASK_API_URL ASK_API_MODEL

之后 ask 仍照常连接本地供应商。

为了方便，可以自行将环境变量的设置写入 ~/.bashrc，在登录时即自动加载。

3、设置环境变量不是必须的，ask 的处理原则是优先使用环境变量，没有也可以运行，顺序依次回落：

    ASK_API_* 环境变量 -> 非 ASK_API_* 的环境变量 -> 使用 ask 脚本默认的连接本地 ollama 模型 llama3.1:8b

## 使用方法

### 参数模式，ask 后直接跟问题

    $ ask Linux 磁盘分区用什么工具

### 交互模式，输入多行内容提问

适合调试程序，复制错误日志的输出，粘贴到 ask 让 AI 进行分析

    $ ask
    Enter or paste your question (press Ctrl+D when done):
    分析下： <paste your log>

输入 Ctrl+D 后，会把内容发送给 AI，并显示 AI 的回复。

### 自然语言转 shell 命令

适合想不起来 shell 命令用法的场景。

在 ask 后跟随 @ 符号，然后输入你的 shell 问题，会回答推荐的 shell 命令

    $ ask @ find files larger than 100M and sort by size
    #--- AI prompt ---#
    find . -type f -size +100M -exec ls -lh {} + | sort -rh -k5

    $ ask @ iostat 分析磁盘io及利用率
    #--- AI prompt ---#
    iostat -x 1

注意：

    该用法会获取当前环境信息，附加到发送给模型的请求中，包含操作系统、当前目录及其文件列表（最多10个），这是为了让 AI 给出的建议更贴合你的环境。

### 管道传送你的问题给 ask

适合从别的输出接收信息，然后发送给 AI 进行分析的场景，参见 [把 tmux 面板内容发送给 AI]

    # 单行问题
    $ echo "iostat -xz 1 什么意思" | ask

    # 多行输入，可粘贴
    $ cat <<- EOF | ask
    分析下
    $ df -h
    Filesystem            Size  Used Avail Use% Mounted on
    C:/Program Files/Git  1.9T  1899G  2G  99.99% /
    EOF

    # 从文件读取
    $ ask < err_log.txt

### Bash 命令自动完成

ask 可借助 bash-completion 系统软件包的功能，自动提示可用的命令用法，适合想不起来命令参数的场景

示例：输入 `ask tar` 然后按 2 次 Tab 键，稍侯会显示推荐命令清单，如：

    $ l
    aa.txt  bbb/

    $ ask tar c
    #--- AI prompt ---#
    tar cf archive.tar aa.txt bbb (Create an uncompressed tar archive)
    tar cp archive.tar aa.txt (Append files to an existing archive)
    tar czvf archive.tar.gz aa.txt (Compress all files into a gzip archive)
    tar tf archive.tar.gz (List contents of a gzip archive)
    tar xvf archive.tar.gz (Extract files from a gzip archive)

## 高级用法

### 把 tmux 面板内容发送给 AI

适合分析程序输出或错误日志等场景

1、tmux 热键设置如下

```conf
# 绑定 Prefix + Ctrl+e 捕获当前窗格最近100行内容问 AI
bind C-e capture-pane -S -100 \; new-window \; send-keys "tmux show-buffer | ask; echo; printf 'Press RETURN to close...'; read _dummy; exit" Enter
```

2、在 tmux 里，先按先导键 ctrl + b，然后再按 ctrl+e，会捕获当前窗口的内容发送给 ask，新窗口显示 AI 的回答，按回车键关闭该窗口

### 手动安装

1. 下载 ask 命令脚本和 bash 命令行自动完成脚本到用户级目录，并设置权限

    $ mkdir -p ~/.local/bin ~/.local/share/bash-completion/completions

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask -o ~/.local/bin/ask

    $ chmod 755 ~/.local/bin/ask

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask_completion -o ~/.local/share/bash-completion/completions/ask

2. 确保 `~/.local/bin` 在 PATH 中，将以下行添加到 `~/.bashrc`：

    export PATH="$PATH:~/.local/bin"

3. 配置环境变量即可使用，详见章节 [安装] 中的 `2、设置模型供应商地址和模型名`

## 声明

本项目代码是我指导 AI 编写的，思路不断调整，但是我自己没有写任何一行 shell 代码，详见 git log。

我可以独立完成本项目的脚本编写，但是为了节省精力，完全用自然语言指导 AI 完成了 shell 代码。

不过，我认真审查了 AI 生成的**每一行**代码，我确信自己理解每行代码的意思。我的审查原则是 AI 编写代码没有偏离主题，没有任意发挥，精确围绕功能点，用最简单最直接的方式实现。
