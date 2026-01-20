#!/usr/bin/env bash
#
# 超级简单的多用户Screen测试脚本
#
set -euo pipefail

echo "==============================================="
echo "      Screen 多用户会话测试脚本"
echo "==============================================="
echo ""

# 获取当前用户名
CURRENT_USER=$(whoami)
echo "当前用户: $CURRENT_USER"
echo ""

# 步骤1: 清理旧会话
echo "步骤1: 清理可能存在的旧会话..."
screen -S testmulti -X quit 2>/dev/null || true
sleep 1

# 步骤2: 创建会话
echo ""
echo "步骤2: 创建新会话 'testmulti'..."
screen -S testmulti -d -m bash

# 步骤3: 立即检查
echo ""
echo "步骤3: 检查会话是否创建成功..."
if screen -list | grep -q "testmulti"; then
    echo "✅ 会话创建成功"
else
    echo "❌ 会话创建失败"
    exit 1
fi

# 步骤4: 启用多用户
echo ""
echo "步骤4: 启用多用户模式..."
screen -S testmulti -X multiuser on

# 验证多用户模式
echo ""
echo "步骤5: 验证多用户模式..."
sleep 1
if screen -list | grep -q "testmulti"; then
    SESSION_INFO=$(screen -list | grep "testmulti")
    echo "会话信息: $SESSION_INFO"
    
    if echo "$SESSION_INFO" | grep -q "Multi"; then
        echo "✅ 多用户模式已启用"
    else
        echo "⚠️  多用户模式状态未知，继续测试..."
    fi
fi

# 步骤6: 添加权限
echo ""
echo "步骤6: 添加权限..."
echo "  - 为 $CURRENT_USER 添加权限"
screen -S testmulti -X acladd $CURRENT_USER 2>/dev/null || echo "  权限添加可能失败，继续..."

# 步骤7: 显示最终状态
echo ""
echo "==============================================="
echo "      会话创建完成!"
echo "==============================================="
echo ""
echo "会话名称: testmulti"
echo "会话状态: $(screen -list | grep testmulti)"
echo ""
echo "✅ 测试会话已创建完成!"
echo ""
echo "📋 现在请执行以下操作:"
echo ""
echo "1. 在当前终端连接会话:"
echo "   screen -S testmulti"
echo ""
echo "2. 然后按 Ctrl+A 再按 D 退出会话"
echo ""
echo "3. 重新连接:"
echo "   screen -S testmulti"
echo ""
echo "4. 查看当前连接的用户:"
echo "   screen -S testmulti -X acl"
echo ""
echo "🔍 验证方法:"
echo "   screen -list | grep testmulti"
echo "   应该显示: testmulti (Multi, detached)"
echo ""
echo "🧹 清理:"
echo "   screen -S testmulti -X quit"
echo ""
echo "==============================================="
