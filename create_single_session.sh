#!/usr/bin/env bash
#
# 创建单一多用户会话（自动清理旧会话）
#
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "用法: $0 <会话名> [用户1] [用户2] ..."
    echo "示例: $0 'dev-开发环境' alice bob"
    exit 1
fi

SESSION_NAME="$1"
shift
USERS=("$@")

if [[ ${#USERS[@]} -eq 0 ]]; then
    USERS=("$USER")
fi

echo "=== 创建多用户会话: $SESSION_NAME ==="
echo ""

# 步骤1: 清理旧会话
echo "步骤1: 清理可能存在的旧会话..."
for session in $(screen -list 2>/dev/null | grep "$SESSION_NAME" | awk '{print $1}'); do
    echo "  清理会话: $session"
    screen -X -S "$session" quit 2>/dev/null || true
done
sleep 1

# 步骤2: 验证清理完成
if screen -list 2>/dev/null | grep -q "$SESSION_NAME"; then
    echo "⚠️  仍有会话存在，请手动清理"
    exit 1
fi

echo "✅ 清理完成"
echo ""

# 步骤3: 创建新会话
echo "步骤2: 创建新会话..."
screen -S "$SESSION_NAME" -d -m bash
sleep 1

# 步骤4: 启用多用户
echo "步骤3: 启用多用户模式..."
screen -S "$SESSION_NAME" -X multiuser on

# 步骤5: 添加权限
echo "步骤4: 添加用户权限..."
for user in "${USERS[@]}"; do
    echo "  添加用户: $user"
    screen -S "$SESSION_NAME" -X acladd "$user" 2>/dev/null || true
done

echo ""
echo "=== 创建完成 ==="
echo ""

# 步骤6: 验证结果
echo "步骤5: 验证会话状态..."
if screen -list 2>/dev/null | grep -q "$SESSION_NAME"; then
    SESSION_INFO=$(screen -list | grep "$SESSION_NAME" | head -1)
    echo "✅ 会话创建成功:"
    echo "   $SESSION_INFO"
    echo ""
    echo "🎉 可以开始使用了！"
    echo ""
    echo "连接命令:"
    echo "  screen -r '$SESSION_NAME'"
    echo ""
    echo "⚠️  重要提示："
    echo "  • 使用 screen -r 连接，不要用 screen -S"
    echo "  • screen -S 会创建新会话"
    echo "  • screen -r 会连接到现有会话"
else
    echo "❌ 会话创建失败"
    exit 1
fi
