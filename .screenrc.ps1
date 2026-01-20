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
