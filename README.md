# ask

命令行 AI 助手 — 提问、把你说的话转成 Shell 命令、自动推荐命令补全、分析日志。轻量、纯 Shell 实现，支持多种后端：支持管道操作的命令行工具 Claude code/OpenAI codex/OpenClaw 等；本地运行的大模型如 Ollama/LM Studio/llama.cpp；具备 OpenAI 兼容格式的 AI 供应商账户（API Key）。

## 前提

ask 有三种方式连接到 AI 模型，满足其一即可：

**方式一：CLI 客户端工具（开箱即用）**

- 已认证的 CLI 工具，如 `claude`、`codex`、`openai`、`openclaw`

**方式二：本地大模型后端**

- 本地运行的 ollama/LM Studio/llama.cpp 等
- 需要 `jq`、`curl`/`wget`

**方式三：互联网上的 OpenAI 兼容 API**

- 具备 OpenAI 兼容格式的 AI 供应商账户（API Key）
- 需要 `jq`、`curl`/`wget`

bash-completion 为可选依赖，安装后可启用 Tab 键命令补全的 AI 提示。详见 [Bash 命令自动完成](#bash-命令自动完成)。

## 安装

1、运行安装脚本，它会从 GitHub 下载 ask 及其 bash 命令行自动完成脚本，安装到用户级目录

    $ curl -fsSL https://github.com/m666m/ask/raw/main/install.sh | bash

安装后，ask 默认连接本地 Ollama，使用模型名 llama3.1:8b

    $ ask hi

2、后端配置（三选一）

只需要配置环境变量，即可连接到指定的后端。

**选项 A：CLI 客户端工具 — 最简单**

将已认证的本地 CLI 工具赋值给 `ASK_CLI`，ask 将提问通过管道转发给该工具：

    $ export ASK_CLI=claude

    $ ask hi

CLI 工具应该是已经配置好了认证和模型选择，可以在命令行直接使用。支持的 `ASK_CLI` 值: `claude`, `codex`, `openai`, `openclaw`。

**选项 B：本地大模型后端**

使用 ollama / LM Studio / llama.cpp 等本地后端：

    $ export ASK_MODEL=llama3.1:8b
    $ export ASK_OLLAMA_URL=http://localhost:11434/v1/chat/completions

    $ ask hi

**选项 C：云 API 服务**

使用需要 API Key 的外部服务（如 OpenAI、其他兼容 API）：

    $ export ASK_API_KEY=sk-your-key-here
    $ export ASK_API_URL=https://api.openai.com/v1/chat/completions
    $ export ASK_API_MODEL=gpt-4o

    $ ask hi

为了方便，可以将环境变量设置写入 `~/.bashrc`，登录时自动加载。

3、环境变量回退机制

设置环境变量不是必须的。ask 按以下优先级选择后端，没有配置时依次回落：

    ASK_CLI → ASK_API_KEY + ASK_API_URL + ASK_API_MODEL → ASK_MODEL + ASK_OLLAMA_URL → 脚本默认值（本地 Ollama, llama3.1:8b）

清除对应的环境变量即可回退到默认后端（本地 Ollama）：

    $ unset ASK_CLI          # 取消 CLI 客户端

    $ unset ASK_API_KEY ASK_API_URL ASK_API_MODEL  # 取消云 API

    $ unset ASK_MODEL ASK_OLLAMA_URL  # 取消指定本地服务端

之后 ask 将恢复使用默认的本地 Ollama（`llama3.1:8b` @ `localhost:11434`）。

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

适合想不起来命令用法的场景。

在 ask 后跟随 @ 符号，然后输入你的要求，会回答推荐的 shell 命令

    $ ask @ find files larger than 100M and sort by size
    #--- AI prompt ---#
    find . -type f -size +100M -exec ls -lh {} + | sort -rh -k5

    $ ask @ iostat 分析磁盘io及利用率
    #--- AI prompt ---#
    iostat -x 1

注意：

    该用法会获取当前环境信息，附加到发送给模型的请求中，包含 `uname -a` 输出的系统信息、当前目录及其文件列表（最多10个），这是为了让 AI 给出的建议更贴合你的环境。

### 管道传送你的问题给 ask

适合从别的输出接收信息，然后发送给 AI 进行分析的场景，推荐用法：[把 tmux 面板内容发送给 AI]

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

ask 可借助 bash-completion 系统软件包的功能，自动提示可用的命令用法，适合想不起来命令参数的场景。

示例：输入 `ask tar ` 然后按 2 次 Tab 键，稍侯会显示推荐命令清单，如：

    $ l
    aa.txt  bbb/

    $ ask tar c
    #--- AI prompt ---#
    tar cf archive.tar aa.txt bbb (Create an uncompressed tar archive)
    tar cp archive.tar aa.txt (Append files to an existing archive)
    tar czvf archive.tar.gz aa.txt (Compress all files into a gzip archive)
    tar tf archive.tar.gz (List contents of a gzip archive)
    tar xvf archive.tar.gz (Extract files from a gzip archive)

注意：

    该用法会获取当前环境信息，附加到发送给模型的请求中，包含 `uname -a` 的系统信息、当前目录及其文件列表（最多10个），这是为了让 AI 给出的建议更贴合你的环境。

## 高级用法

### 把 tmux 面板内容发送给 AI

适合分析程序输出或错误日志等场景

1、tmux 热键设置如下

```conf
# 绑定 Prefix + Ctrl+e 捕获当前窗格最近100行内容问 AI
bind C-e capture-pane -S -100 \; new-window \; send-keys "{ echo '请分析以下内容:'; tmux show-buffer; } | ask; echo; printf 'Press RETURN to close...'; read _dummy; exit" Enter
```

2、在 tmux 里，先按先导键 ctrl + b，然后再按 ctrl+e，会捕获当前窗格的内容发送给 ask，在新窗口显示 AI 的回答，按回车键即可关闭该窗口。

### 手动安装

1. 下载 ask 命令脚本和 bash 命令行自动完成脚本到用户级目录，并设置权限

    $ mkdir -p ~/.local/bin ~/.local/share/bash-completion/completions

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask -o ~/.local/bin/ask

    $ chmod 755 ~/.local/bin/ask

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask_completion -o ~/.local/share/bash-completion/completions/ask

2. 确保 `~/.local/bin` 在 PATH 中，将以下行添加到 `~/.bashrc`：

    export PATH="$PATH:~/.local/bin"

3. 配置环境变量即可使用，详见章节 [安装] 中的 `2、后端配置（三选一）`

## 声明

本项目代码是我指导 AI 编写的，思路不断调整，但是我自己没有写任何一行 shell 代码，详见 git log。

我可以独立完成本项目的脚本编写，但是为了节省精力，完全用自然语言指导 AI 完成了 shell 代码。

不过，我认真审查了 AI 生成的**每一行**代码，我确信自己理解每行代码的意思。我的审查原则是 AI 编写代码没有偏离主题，没有任意发挥，精确围绕功能点，用最简单最直接的方式实现。
