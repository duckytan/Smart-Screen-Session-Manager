#!/usr/bin/env bash
#
# 多用户会话创建脚本 (本地版本)
#

set -euo pipefail

# 检查参数
if [[ $# -lt 1 ]]; then
    echo "用法: $0 <会话名> [用户1] [用户2] ..."
    echo "示例: $0 dev alice bob"
    exit 1
fi

SESSION_NAME="$1"
shift
USERS=("$@")

# 如果没有指定用户，使用当前用户名
if [[ ${#USERS[@]} -eq 0 ]]; then
    USERS=("$USER")
fi

echo "创建多用户会话: $SESSION_NAME"
echo "授权用户: ${USERS[*]}"

# 创建会话
screen -S "$SESSION_NAME" -d -m bash

# 等待会话创建
sleep 1

# 启用multiuser模式
screen -S "$SESSION_NAME" -X multiuser on

# 为每个用户添加权限
for user in "${USERS[@]}"; do
    echo "为用户 $user 添加权限..."
    screen -S "$SESSION_NAME" -X acladd "$user" 2>/dev/null || echo "警告: 无法为用户 $user 添加权限"
done

echo ""
echo "会话 $SESSION_NAME 已创建并配置完成"
echo ""
echo "连接方式:"
echo "  - 所有者 ($USER): screen -S $SESSION_NAME"
echo "  - 其他用户: screen -S $USER/$SESSION_NAME"
echo ""
echo "查看会话状态: screen -list"
