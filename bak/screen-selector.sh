#!/bin/bash
# 原始版本的screen选择脚本（备份）

# 简单的screen会话选择器
echo "Screen Session Selector"

if command -v screen &>/dev/null; then
    screen -list
    echo ""
    read -p "输入要连接的会话名称: " session
    if [ -n "$session" ]; then
        screen -r "$session"
    fi
else
    echo "screen 未安装"
fi
