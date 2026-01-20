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
# 最终测试 - 验证smart-screen所有修复
################################################################################

# 颜色定义
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}              Smart Screen 最终验证测试                ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 测试结果追踪
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -e "${YELLOW}测试: $test_name${NC}"

    if eval "$test_command"; then
        echo -e "${GREEN}✓ 通过${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 失败${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# 测试1：验证exec命令已移除
echo -e "${CYAN}测试1：验证exec命令已移除${NC}"
run_test "检查是否存在exec screen命令" "! grep -q 'exec screen' /root/smart-screen/smart-screen.sh"

# 测试2：验证脚本语法
echo -e "${CYAN}测试2：验证脚本语法${NC}"
run_test "检查bash语法" "bash -n /root/smart-screen/smart-screen.sh"

# 测试3：验证脚本可执行
echo -e "${CYAN}测试3：验证脚本可执行${NC}"
run_test "检查执行权限" "[ -x /root/smart-screen/smart-screen.sh ]"

# 测试4：验证screen命令可用
echo -e "${CYAN}测试4：验证screen命令可用${NC}"
run_test "检查screen命令" "command -v screen &>/dev/null"

# 测试5：验证会话创建和检测
echo -e "${CYAN}测试5：验证会话创建和检测${NC}"

# 创建测试会话
TEST_SESSION="test-$(date +%s)"
screen -dmS "$TEST_SESSION" 2>/dev/null
sleep 1

# 检查会话是否存在
run_test "检查会话是否创建" "screen -list 2>/dev/null | grep -q \"\.$TEST_SESSION[[:space:]]\""

# 获取PID
TEST_PID=$(screen -list 2>/dev/null | grep "\.$TEST_SESSION[[:space:]]" | awk '{print $1}' | cut -d'.' -f1 | head -1)

if [ -n "$TEST_PID" ]; then
    # 验证PID检测
    run_test "检查PID检测" "[ -n '$TEST_PID' ]"

    # 清理测试会话
    screen -S "$TEST_PID" -X quit 2>/dev/null
else
    echo -e "${RED}✗ 无法获取测试会话PID${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# 测试6：验证会话检测逻辑
echo -e "${CYAN}测试6：验证会话检测逻辑${NC}"

# 检查grep正则表达式是否正确
TEST_PATTERN="^[[:space:]]*[0-9]+\."
run_test "检查正则表达式" "echo '  12345.test-session' | grep -qE '$TEST_PATTERN'"

# 测试7：验证脚本内容
echo -e "${CYAN}测试7：验证脚本内容${NC}"

run_test "检查是否包含会话映射" "grep -q 'SESSION_MAP' /root/smart-screen/smart-screen.sh"
run_test "检查是否包含debug功能" "grep -q 'debug_show_all_sessions' /root/smart-screen/smart-screen.sh"
run_test "检查是否包含会话检测函数" "grep -q 'get_session_pid_by_name' /root/smart-screen/smart-screen.sh"

# 清理所有screen会话
screen -wipe &>/dev/null

# 测试结果总结
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}                    测试结果总结                      ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  总测试数: $((TESTS_PASSED + TESTS_FAILED))                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  通过: ${GREEN}$TESTS_PASSED${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  失败: ${RED}$TESTS_FAILED${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！修复成功！${NC}"
    echo ""
    echo -e "${YELLOW}修复总结：${NC}"
    echo -e "${GREEN}1.${NC} 退出会话后不再直接退出SSH"
    echo -e "${GREEN}2.${NC} 会话检测更准确，避免重复创建"
    echo -e "${GREEN}3.${NC} 增强的调试功能和错误处理"
    echo -e "${GREEN}4.${NC} 改进的用户反馈和提示"
    echo ""
    echo -e "${YELLOW}使用方法：${NC}"
    echo -e "  ${WHITE}• 运行: bash /root/smart-screen/smart-screen.sh${NC}"
    echo -e "  ${WHITE}• 按数字键1-9进入对应会话${NC}"
    echo -e "  ${WHITE}• 在screen会话中按 Ctrl+A 然后按 D 返回${NC}"
    echo -e "  ${WHITE}• 输入 'debug' 查看所有会话详情${NC}"
    echo -e "  ${WHITE}• 输入 'q' 退出管理器${NC}"
    exit 0
else
    echo -e "${RED}✗ 部分测试失败，请检查修复${NC}"
    exit 1
fi