# ask

Conveniently send questions to Ollama or other OpenAI-compatible APIs for analysis directly from the command line.

安装：

    $ curl -fsSL https://github.com/m666m/ask/raw/master/ask | sudo tee /usr/local/bin/ask >/dev/null

    修改脚本中 MODEL 和 OLLAMA_URL 的值，或设置环境变量 `export ASK_MODEL=xxx` `export ASK_OLLAMA_URL=http:`

用法:

```bash
# 1、问问题
# 单行问题
$ echo "什么是 Bash 函数？" | ask

# 多行问题
$ cat <<- EOF | ask
请用 Python 写一个快速排序函数，
并添加详细注释。
EOF

# 从文件读取问题
$ ask < question.txt

2、自然语言转命令
$ ask @ find files larger than 100M and sort by size
find . -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -h

```

高级用法：

把 tmux 屏幕内容发送给 ask 去问 AI，适合查看程序输出或日志等场合，简化你的操作。

1、tmux 热键设置如下：

```conf
# 绑定 Prefix + Ctrl+e 捕获当前窗格最近100行内容问 AI
bind C-e new-window "echo 'ask AI in progress...'; { echo 'Please analyze the following content:'; tmux capture-pane -p -t '{last}' -S -100; } | ask; echo; read -p 'Press RETURN to close...'"
```

2、在 tmux 里，先按先导键 ctrl + b，然后再按 ctrl+e，会捕获当前窗口的内容发送给 ask，新窗口显示 AI 的回答，按回车键关闭该窗口。
