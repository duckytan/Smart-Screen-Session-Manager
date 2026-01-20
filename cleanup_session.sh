#!/usr/bin/env bash
# 清理指定会话的所有实例

SESSION_NAME="dev-开发环境"

echo "正在清理会话: $SESSION_NAME"

# 查找并终止所有匹配的会话
for session in $(screen -list | grep "$SESSION_NAME" | awk '{print $1}'); do
    echo "终止会话: $session"
    screen -X -S "$session" quit 2>/dev/null || true
done

echo "清理完成"
sleep 1

# 验证清理结果
if screen -list | grep -q "$SESSION_NAME"; then
    echo "⚠️  仍有会话存在："
    screen -list | grep "$SESSION_NAME"
else
    echo "✅ 所有会话已清理"
fi
