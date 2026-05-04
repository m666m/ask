# ask

命令行 AI 助手 — 提问、把你说的话转成 Shell 命令、自动推荐命令补全、分析日志。轻量、纯 Shell 实现，支持本地 Ollama 或任意 OpenAI 兼容 API。

## 前提

    本地运行了大模型如 ollama/LM Studio，或其它 OpenAI 兼容格式的 AI 供应商账户

    本地操作系统已经安装了软件包 jq, curl/wget, bash-completion

## 安装

1.下载 ask 命令脚本和自动完成脚本到本地的相关目录，并设置权限

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask | sudo tee /usr/local/bin/ask >/dev/null; sudo chmod 755 /usr/local/bin/ask

    $ curl -fsSL https://github.com/m666m/ask/raw/main/completions/ask | sudo tee /usr/share/bash-completion/completions/ask >/dev/null

2.修改脚本中 MODEL 和 OLLAMA_URL 的值，改为你自己的本地 AI 供应商的值

### 设置 API Key 以使用外部 OpenAI 兼容服务

ask 默认连接本地 Ollama，无需 API Key。可以设置环境变量，这样就不需要修改 ask 脚本：

    $ export ASK_MODEL=xxx
    $ export ASK_OLLAMA_URL=xxx
    $ ask hi

若使用需要 API Key 的外部服务（如 OpenAI、其他兼容 API），可以设置环境变量

    $ export ASK_API_KEY=xxx
    $ export ASK_API_MODEL=xxx
    $ export ASK_API_URL=xxx
    $ ask hi

设置环境变量不是必须的，ask 的处理原则是优先使用环境变量，没有也可以运行，顺序依次回落：

    API 相关环境变量 -> 非 API 环境变量 -> 使用 ask 脚本中的默认连接本地 ollama 地址

#### 1. 创建配置文件

建议在 `~/.local/ask/` 下创建 `ask.env`（或其他路径）：

```bash
mkdir -p ~/.config/ask
touch ~/.config/ask/ask.env
```

写入以下内容，并替换为你的实际值：

```bash
# export ASK_MODEL="llama3.1:8b"
# export ASK_OLLAMA_URL="http://localhost:11434/v1/chat/completions"
# 如果环境变量都存在，则 ASK_API_ 系列生效，优先连接外部服务
export ASK_API_KEY="sk-your-key-here"
export ASK_API_URL="https://api.openai.com/v1/chat/completions"
export ASK_API_MODEL="gpt-4o"

```

#### 2. 每次使用前手动加载（推荐，安全）

    $ source ~/.config/ask/ask.env

或者将其加入 ~/.bashrc 自动加载：

    $ [ -f ~/.config/ask/ask.env ] && source ~/.config/ask/ask.env

#### 3. 使用

加载环境变量后，ask 的所有模式（参数模式、交互模式、管道、@ 命令）都会自动使用 API 服务和 Key。

取消或切换回本地 Ollama，只需清除这三个变量：

    $ unset ASK_API_KEY ASK_API_URL ASK_API_MODEL

之后 ask 仍照常连接本地服务。

## 使用方法

### 参数模式，ask 后直接跟问题

    $ ask Linux 磁盘分区用什么工具

### 交互模式，输入多行内容提问

适合复制命令的错误输出，粘贴给 AI 进行分析的场景

    $ ask
    Enter or paste your question (press Ctrl+D when done):
    分析下： <paste your log>

输入 Ctrl+D 后，会把内容发送给 AI，并显示 AI 的回复。

### 自然语言转 shell 命令

适合想不起来命令用法的场景。

在 ask 后跟随 @ 符号，然后输入你的问题，会转化成 shell 命令

    $ ask @ find files larger than 100M and sort by size
    find . -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -h

    $ ask @ iostat 分析磁盘io及利用率
    iostat -xz 1

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
bind C-e new-window "echo 'ask AI in progress...'; { echo 'Please analyze the following content:'; tmux capture-pane -p -t '{last}' -S -100; } | ask; echo; read -p 'Press RETURN to close...'"
```

2、在 tmux 里，先按先导键 ctrl + b，然后再按 ctrl+e，会捕获当前窗口的内容发送给 ask，新窗口显示 AI 的回答，按回车键关闭该窗口

## 声明

本项目代码是我指导 AI 编写的，思路不断调整，但是我自己没有写任何一行 shell 代码，详见 git log.

我可以独立完成本项目的脚本编写，但是为了节省精力，完全用自然语言指导 AI 完成了 shell 代码。不过，我认真审查了 AI 生成的**每一行**代码，我确信自己理解每行代码的意思。我的审查原则是 AI 编写代码没有偏离主题，没有任意发挥，精确围绕功能点，用最简单最直接的方式实现，详见本程序代码。
