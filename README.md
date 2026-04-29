# ask

Conveniently send questions to Ollama or other OpenAI-compatible APIs for analysis directly from the command line.

## 前提

    本地运行了大模型如 ollama/LM Studio，或其它 OpenAI 兼容格式的 AI 供应商账户

    本地操作系统已经安装了软件包 jq, curl/wget, bash-completion

## 安装方法

1.下载 ask 命令脚本和自动完成脚本

    $ curl -fsSL https://github.com/m666m/ask/raw/main/ask | sudo tee /usr/local/bin/ask >/dev/null; sudo chmod 755 /usr/local/bin/ask

    $ curl -fsSL https://github.com/m666m/ask/raw/main/completions/ask | sudo tee /usr/share/bash-completion/completions/ask >/dev/null

2.修改脚本中 MODEL 和 OLLAMA_URL 的值，改为你自己的本地 AI 供应商的值

## 使用方法

### 参数模式，ask 后直接跟问题

    $ ask Linux 磁盘分区用什么工具

### 交互模式，输入多行内容提问

适合复制命令行的错误输出，粘贴给 AI 进行分析的场景

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

ask 自动提示可用的命令参数，适合想不起来命令参数的场景

    打开一个支持补全的 Bash 终端。

示例：输入 `ask tar ` 然后按 Tab 键，稍后。

    终端显示候选菜单，例如：

        tar czf archive.tar.gz file1 file2    (描述：压缩文件)
        tar xf archive.tar.gz                 (描述：解压缩文件)
        tar czvf archive.tar.gz /path/to/dir   (描述：压缩目录并显示过程)

    使用方向键选择其中一个，回车后命令行被替换为完整命令（如 tar czf archive.tar.gz file1 file2），可再按回车执行。

示例：输入 `ask find ` 然后 Tab，应显示 find 的常用示例。

## 高级用法

### 把 tmux 面板内容发送给 AI

适合分析程序输出或错误日志等场景

1、tmux 热键设置如下

```conf
# 绑定 Prefix + Ctrl+e 捕获当前窗格最近100行内容问 AI
bind C-e new-window "echo 'ask AI in progress...'; { echo 'Please analyze the following content:'; tmux capture-pane -p -t '{last}' -S -100; } | ask; echo; read -p 'Press RETURN to close...'"
```

2、在 tmux 里，先按先导键 ctrl + b，然后再按 ctrl+e，会捕获当前窗口的内容发送给 ask，新窗口显示 AI 的回答，按回车键关闭该窗口
