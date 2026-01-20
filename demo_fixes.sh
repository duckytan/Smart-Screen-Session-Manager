#!/usr/bin/env bash
#
# 脚本名称：自动修复的脚本
# 描述：已应用Bash最佳实践
# 作者：Smart Screen Team
# 版本：1.0
#
set -euo pipefail

################################################################################
# 错误处理函数
################################################################################

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

fatal() {
    echo "[FATAL] $*" >&2
    local frame=0
    while caller $frame; do
        echo "  Frame $frame: $(caller $frame)" >&2
        ((frame++))
    done
    exit 1
}

cleanup() {
    echo "执行清理操作..."
}

trap cleanup EXIT
trap 'error "脚本被中断"' INT
trap 'error "收到终止信号"' TERM

################################################################################
# 演示脚本 - 展示smart-screen修复效果
################################################################################

# 颜色定义
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}                Smart Screen 修复演示                    ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  展示修复后的功能                                   ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 会话映射
declare -A SESSION_MAP=(
    [1]="dev-开发环境"
    [2]="test-测试环境"
    [3]="prod-生产环境"
)

echo -e "${YELLOW}📋 预设会话列表：${NC}"
for i in {1..3}; do
    local session_name="${SESSION_MAP[$i]}"
    echo -e "  [${GREEN}$i${NC}] ${WHITE}$session_name${NC} ${CYAN}(未创建)${NC}"
done

echo ""
echo -e "${CYAN}管理操作：${NC}"
echo -e "  [${GREEN}debug${NC}] 🔍 显示所有Screen会话详情"
echo -e "  [${GREEN}q${NC}] ${ICON_QUIT} 退出"
echo ""

echo -e "${YELLOW}开始演示...${NC}"
echo ""

# 演示1：创建会话
echo -e "${CYAN}🆕 演示：创建会话1 (dev-开发环境)${NC}"
SESSION_NAME="${SESSION_MAP[1]}"
echo "正在创建新会话: $SESSION_NAME"

# 创建后台会话
screen -dmS "$SESSION_NAME"
sleep 1

# 检查会话状态
PID=$(screen -list 2>/dev/null | grep "\.${SESSION_NAME}[[:space:]]" | awk '{print $1}' | cut -d'.' -f1 | head -1)
if [ -n "$PID" ]; then
    echo -e "${GREEN}✓ 会话创建成功: $SESSION_NAME (PID: $PID)${NC}"
    echo -e "${YELLOW}状态: Detached (后台运行)${NC}"
else
    echo -e "${RED}✗ 会话创建失败${NC}"
fi

echo ""

# 演示2：再次尝试创建相同会话（应该检测到已存在）
echo -e "${CYAN}🔍 演示：检测现有会话${NC}"
echo "正在检查会话是否存在: $SESSION_NAME"

# 检查会话是否存在
CHECK_PID=$(screen -list 2>/dev/null | grep "\.${SESSION_NAME}[[:space:]]" | awk '{print $1}' | cut -d'.' -f1 | head -1)
if [ -n "$CHECK_PID" ]; then
    echo -e "${GREEN}✓ 找到现有会话: $SESSION_NAME (PID: $CHECK_PID)${NC}"
    echo -e "${YELLOW}💡 不会创建重复会话${NC}"
else
    echo -e "${YELLOW}⚠ 未找到会话${NC}"
fi

echo ""

# 演示3：显示调试信息
echo -e "${CYAN}🔍 演示：显示所有Screen会话详情${NC}"
echo ""
echo -e "${YELLOW}📊 当前Screen会话列表：${NC}"

ALL_SESSIONS=$(screen -list 2>/dev/null)
if [ -n "$ALL_SESSIONS" ]; then
    COUNT=$(echo "$ALL_SESSIONS" | grep -c "^\s*[0-9]\+\." || echo 0)
    echo "$ALL_SESSIONS" | grep -E "^[[:space:]]+[0-9]+\." | while IFS= read -r line; do
        echo -e "  ${CYAN}$line${NC}"
    done
    echo ""
    echo -e "  ${YELLOW}总会话数: ${WHITE}$COUNT${NC}"
else
    echo -e "${YELLOW}没有找到任何screen会话${NC}"
fi

echo ""
echo -e "${GREEN}✓ 演示完成！${NC}"
echo ""
echo -e "${YELLOW}修复总结：${NC}"
echo -e "${GREEN}1.${NC} ${WHITE}退出会话后不再直接退出SSH${NC} - 已移除exec命令"
echo -e "${GREEN}2.${NC} ${WHITE}会话检测更准确${NC} - 使用更精确的正则表达式"
echo -e "${GREEN}3.${NC} ${WHITE}避免重复会话${NC} - 改进的会话检测逻辑"
echo -e "${GREEN}4.${NC} ${WHITE}增强调试功能${NC} - 添加了debug选项"
echo ""
echo -e "${YELLOW}使用方法：${NC}"
echo -e "  ${WHITE}• 运行: bash /root/smart-screen/smart-screen.sh${NC}"
echo -e "  ${WHITE}• 按数字键1-9进入对应会话${NC}"
echo -e "  ${WHITE}• 在screen会话中按 Ctrl+A 然后按 D 返回${NC}"
echo -e "  ${WHITE}• 输入 'debug' 查看所有会话详情${NC}"
echo -e "  ${WHITE}• 输入 'q' 退出管理器${NC}"
echo ""

# 清理演示会话
echo -e "${YELLOW}清理演示会话...${NC}"
if [ -n "$PID" ]; then
    screen -S "$PID" -X quit
    echo -e "${GREEN}✓ 演示会话已清理${NC}"
fi

echo ""
read -p "按 Enter 键继续..."