#!/usr/bin/env bash
#
# Screen 简洁提示符配置脚本
# 用于在 Screen 会话中设置简洁提示符
#
# 用法：
#   ./setup_screen_prompt.sh
#

set -euo pipefail

# 获取当前脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Screen 简洁提示符配置 ==="
echo ""

# 检查是否已存在配置
if grep -q "screen.*PS1" ~/.bashrc 2>/dev/null; then
    echo "⚠️  已存在 Screen PS1 配置，是否覆盖？"
    read -p "输入 'yes' 确认: " confirm
    if [[ $confirm != "yes" ]]; then
        echo "操作已取消"
        exit 0
    fi
fi

# 创建 PS1 配置
cat > ~/.screenrc.ps1 << 'EOF'
# Screen PS1 配置文件
# 用于在 Screen 会话中设置简洁提示符

# 获取当前Screen会话名称
if [ -n "$STY" ]; then
    SESSION_NAME=$(echo $STY | cut -d. -f2)
else
    SESSION_NAME="screen"
fi

# 设置简洁的PS1提示符
# 格式：[会话名称] 用户@主机$
export PS1="\[\e]0;[\$SESSION_NAME] \u@\h:\w\a\]\\$ "
EOF

echo "✅ 已创建 ~/.screenrc.ps1"

# 修改 .bashrc 自动加载
if ! grep -q "\.screenrc\.ps1" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Screen 简洁提示符配置" >> ~/.bashrc
    echo "if [ -f ~/.screenrc.ps1 ]; then" >> ~/.bashrc
    echo "    source ~/.screenrc.ps1" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "✅ 已将配置添加到 ~/.bashrc"
else
    echo "✅ ~/.bashrc 中已存在配置"
fi

# 修改 .screenrc 使用简洁提示符
if [ -f ~/.screenrc ]; then
    # 备份原始 .screenrc
    cp ~/.screenrc ~/.screenrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ 已备份原始 .screenrc"
fi

# 更新 .screenrc 使用简洁提示符
cat > ~/.screenrc << 'EOF'
################################################################################
# Smart Screen Session Manager v2.0 - Screen 配置文件
# 简化提示符：只显示 [会话名称]用户@主机
# 移除所有多余的screen标识和路径信息
################################################################################

# ================================
# 基础配置
# ================================

# 启用多用户模式
multiuser on

# 启用视觉铃声
vbell on
vbell_msg "bell"

# 启动时不显示欢迎信息
startup_message off

# 禁用自动回绕
defwrap on

# 设置屏幕缓冲行数
defscrollback 10000

# 启用UTF-8
defutf8 on

# ================================
# 简洁提示符配置
# ================================

# 设置简洁的硬状态栏
# 只显示会话名称、用户和主机
hardstatus alwayslastline
hardstatus string '%{= kG}[%{G}%S%{g}]%{W} %H %{g}%'

# 禁用默认硬状态栏标题
defhstatus ""

# 设置窗口标题格式
shelltitle "$ |"

# 禁用自动标题设置
termcapinfo screen* 'hs:ts=\E]0;:fs=\007:ds=\E]0;screen\007'

# ================================
# 快捷键配置
# ================================

# 窗口切换快捷键
bindkey -k k9 select 0
bindkey -k k; select 1
bindkey -k F1 select 0
bindkey -k F2 select 1
bindkey -k F3 select 2
bindkey -k F4 select 3
bindkey -k F5 select 4
bindkey -k F6 select 5
bindkey -k F7 select 6
bindkey -k F8 select 7
bindkey -k F9 select 8
bindkey -k F10 select 9

# 分离快捷键
bind s detach

# 退出快捷键
bind k kill
bind ^k kill
bind \\ quit

# 重新连接快捷键
bind r screen -dRR

# ================================
# 状态栏配置
# ================================

# 状态栏显示格式
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %m-%d %{W}%c %{g}]'

# ================================
# 终端优化
# ================================

# 启用鼠标支持
termcapinfo xterm* ti@:te@

# 启用日志功能
deflog on
logfile /tmp/screen-%n.log

# 设置默认终端类型
term screen-256color

# 启用自动分离
autodetach on
EOF

echo "✅ 已更新 ~/.screenrc"

# 重新加载配置
echo ""
echo "=== 配置完成 ==="
echo ""
echo "请重新启动 Screen 会话以应用更改："
echo "  screen -r <会话名>"
echo ""
echo "或者退出当前会话并重新连接："
echo "  按 Ctrl+A D 退出"
echo "  然后重新连接：screen -r <会话名>"
echo ""
echo "新提示符格式："
echo "  [会话名称] 用户@主机$"
echo ""
echo "示例："
echo "  [dev-开发环境] root@VM-0-8-opencloudos:/path$"
echo ""
