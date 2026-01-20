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
# 多用户会话问题诊断和修复工具
# 专门解决A、B两个用户无法同时进入1号预设会话的问题
################################################################################

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}       多用户会话问题诊断和修复工具          ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查screen是否安装
if ! command -v screen &>/dev/null; then
    echo -e "${RED}错误: screen 未安装${NC}"
    echo -e "${YELLOW}请先安装 screen: sudo apt-get install screen${NC}"
    exit 1
fi

echo -e "${GREEN}✓ screen 已安装${NC}"
echo ""

# 检查screen版本
SCREEN_VERSION=$(screen -v 2>&1)
echo -e "${CYAN}Screen 版本信息:${NC}"
echo -e "  $SCREEN_VERSION"
echo ""

# 显示当前所有screen会话
echo -e "${CYAN}当前所有Screen会话:${NC}"
screen -ls
echo ""

# 检查multiuser支持
echo -e "${CYAN}检查multiuser支持:${NC}"
TEST_SESSION="multiuser_test_$$"
screen -S "$TEST_SESSION" -d -m bash 2>/dev/null

if screen -S "$TEST_SESSION" -X multiuser on 2>/dev/null; then
    echo -e "${GREEN}✓ screen 支持 multiuser 模式${NC}"
    MULTIUSER_SUPPORT=true
else
    echo -e "${RED}✗ screen 不支持 multiuser 模式${NC}"
    MULTIUSER_SUPPORT=false
fi

# 清理测试会话
screen -S "$TEST_SESSION" -X quit 2>/dev/null
echo ""

# 如果不支持multiuser，给出解决方案
if [ "$MULTIUSER_SUPPORT" = false ]; then
    echo -e "${RED}⚠️  问题诊断：${NC}"
    echo -e "${YELLOW}您的 screen 版本不支持 multiuser 功能${NC}"
    echo ""
    echo -e "${CYAN}解决方案：${NC}"
    echo -e "1. 升级到支持 multiuser 的 screen 版本"
    echo -e "   Ubuntu/Debian: sudo apt-get install screen${NC}"
    echo -e "   CentOS/RHEL: sudo yum install screen${NC}"
    echo ""
    echo -e "2. 或者使用其他终端复用器："
    echo -e "   - tmux (推荐，支持真正的多用户会话)"
    echo -e "   - byobu (基于 tmux 的增强版)"
    echo ""
    exit 1
fi

# 诊断预设会话
echo -e "${CYAN}诊断预设会话状态:${NC}"
echo ""

declare -A SESSION_MAP=(
    [1]="dev"
    [2]="test"
    [3]="prod"
    [4]="db"
    [5]="monitor"
    [6]="backup"
    [7]="log"
    [8]="debug"
    [9]="research"
)

declare -A SESSION_DISPLAY_MAP=(
    [1]="dev-开发环境"
    [2]="test-测试环境"
    [3]="prod-生产环境"
    [4]="db-数据库"
    [5]="monitor-监控"
    [6]="backup-备份"
    [7]="log-日志"
    [8]="debug-调试"
    [9]="research-研究"
)

# 检查每个预设会话
for i in {1..9}; do
    session_name="${SESSION_MAP[$i]}"
    display_name="${SESSION_DISPLAY_MAP[$i]}"

    # 查找会话
    pid=$(screen -list 2>/dev/null | grep "\.$session_name[[:space:]]" | awk '{print $1}' | cut -d'.' -f1 | head -1)

    echo -e "${YELLOW}会话 $i: $display_name${NC}"

    if [ -n "$pid" ]; then
        echo -e "  状态: ${GREEN}存在${NC} (PID: $pid)"

        # 检查attached状态
        attached=$(screen -list 2>/dev/null | grep "^[[:space:]]*$pid\." | grep -q "Attached" && echo "yes" || echo "no")

        if [ "$attached" = "yes" ]; then
            echo -e "  连接状态: ${YELLOW}已连接${NC}"
        else
            echo -e "  连接状态: ${CYAN}未连接${NC}"
        fi

        # 检查multiuser模式
        echo -e "  检查multiuser模式..."

        # 尝试启用multiuser（如果尚未启用）
        if screen -S "$pid" -X multiuser on 2>/dev/null; then
            echo -e "  multiuser状态: ${GREEN}已启用${NC}"
        else
            echo -e "  multiuser状态: ${RED}启用失败${NC}"
        fi

        # 为当前用户添加权限
        echo -e "  添加用户权限 ($USER)..."
        if screen -S "$pid" -X acladd "$USER" 2>/dev/null; then
            echo -e "  权限添加: ${GREEN}成功${NC}"
        else
            echo -e "  权限添加: ${YELLOW}可能已存在或失败${NC}"
        fi

    else
        echo -e "  状态: ${RED}不存在${NC}"
        echo -e "  建议: 运行 smart-screen.sh 创建会话"
    fi

    echo ""
done

# 提供修复建议
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                   修复建议                          ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}现在您可以尝试以下操作：${NC}"
echo ""
echo -e "${GREEN}1. 测试会话连接${NC}"
echo -e "   • 在A电脑终端：运行 bash smart-screen.sh，输入 1"
echo -e "   • 在B电脑终端：运行 bash smart-screen.sh，输入 1"
echo -e "   • 现在两个终端应该都能进入同一个会话"
echo ""

echo -e "${GREEN}2. 手动连接（如果脚本仍有问题）${NC}"
echo -e "   screen -S $USER/dev"
echo ""

echo -e "${GREEN}3. 查看会话列表${NC}"
echo -e "   screen -ls"
echo ""

echo -e "${GREEN}4. 如果仍有问题，可以尝试：${NC}"
echo -e "   • 强制detach现有连接: screen -d <PID>"
echo -e "   • 重新创建会话: screen -S dev -X quit && screen -S dev -d -m"
echo ""

echo -e "${YELLOW}注意事项：${NC}"
echo -e "• 多个终端连接到同一会话时，所有操作会同步显示"
echo -e "• 按 Ctrl+A 然后按 D 可以从会话返回"
echo -e "• 最后一个退出的人会真正结束会话"
echo ""

echo -e "${CYAN}如需更多信息，请查看 MULTIUSER_FIX_GUIDE.md${NC}"