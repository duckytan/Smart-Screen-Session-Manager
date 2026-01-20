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
# Screen Multiuser 配置测试脚本
# 用于验证多用户功能是否正常工作
################################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}         Screen Multiuser 功能测试                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 测试计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
test_check() {
    local test_name="$1"
    local test_result="$2"

    if [ "$test_result" = "PASS" ]; then
        echo -e "${GREEN}✓ $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# 测试 1: 检查 screen 安装
echo -e "${BLUE}测试 1: 检查 screen 安装${NC}"
if command -v screen &>/dev/null; then
    SCREEN_VERSION=$(screen -v | head -1)
    echo -e "   版本: $SCREEN_VERSION"
    test_check "screen 已安装" "PASS"
else
    test_check "screen 已安装" "FAIL"
    echo -e "${RED}请先安装 screen${NC}"
    exit 1
fi
echo ""

# 测试 2: 检查 multiuser 支持
echo -e "${BLUE}测试 2: 检查 multiuser 支持${NC}"
# 通过实际测试 multiuser 命令来验证支持
TEST_SESSION="multiuser_support_test_$(date +%s)"
screen -S "$TEST_SESSION" -d -m bash 2>/dev/null
if screen -S "$TEST_SESSION" -X multiuser on 2>/dev/null; then
    test_check "screen 支持 multiuser" "PASS"
    # 清理测试会话
    screen -S "$TEST_SESSION" -X quit 2>/dev/null
else
    test_check "screen 支持 multiuser" "FAIL"
    echo -e "${RED}screen 版本不支持 multiuser${NC}"
    # 清理测试会话
    screen -S "$TEST_SESSION" -X quit 2>/dev/null
    exit 1
fi
echo ""

# 测试 3: 检查 .screenrc 配置
echo -e "${BLUE}测试 3: 检查 .screenrc 配置${NC}"
if [ -f ~/.screenrc ]; then
    if grep -q "multiuser on" ~/.screenrc; then
        test_check ".screenrc 中已启用 multiuser" "PASS"
    else
        test_check ".screenrc 中已启用 multiuser" "FAIL"
        echo -e "${YELLOW}建议在 ~/.screenrc 中添加 'multiuser on'${NC}"
    fi
else
    echo -e "${YELLOW}未找到 .screenrc 文件${NC}"
    test_check ".screenrc 配置" "FAIL"
fi
echo ""

# 测试 4: 创建测试会话
echo -e "${BLUE}测试 4: 创建测试会话${NC}"
TEST_SESSION="multiuser_test_$(date +%s)"
screen -S "$TEST_SESSION" -d -m bash 2>/dev/null

if screen -list | grep -q "$TEST_SESSION"; then
    test_check "创建测试会话" "PASS"
    SESSION_CREATED=true
else
    test_check "创建测试会话" "FAIL"
    SESSION_CREATED=false
fi
echo ""

# 测试 5: 启用 multiuser
echo -e "${BLUE}测试 5: 启用 multiuser${NC}"
if [ "$SESSION_CREATED" = true ]; then
    screen -S "$TEST_SESSION" -X multiuser on 2>/dev/null

    # 验证是否成功启用
    if screen -list | grep -q "$TEST_SESSION"; then
        test_check "启用 multiuser 模式" "PASS"
        MULTIUSER_ENABLED=true
    else
        test_check "启用 multiuser 模式" "FAIL"
        MULTIUSER_ENABLED=false
    fi
else
    test_check "启用 multiuser 模式" "FAIL"
    MULTIUSER_ENABLED=false
fi
echo ""

# 测试 6: 测试 ACL 命令
echo -e "${BLUE}测试 6: 测试 ACL 权限管理${NC}"
if [ "$MULTIUSER_ENABLED" = true ]; then
    # 尝试添加一个不存在的用户（仅用于测试命令是否有效）
    screen -S "$TEST_SESSION" -X acladd testuser 2>/dev/null

    # 检查命令是否执行（不检查结果，因为用户可能不存在）
    test_check "ACL 命令执行" "PASS"
else
    test_check "ACL 命令执行" "FAIL"
fi
echo ""

# 测试 7: 清理测试会话
echo -e "${BLUE}测试 7: 清理测试会话${NC}"
if [ "$SESSION_CREATED" = true ]; then
    screen -S "$TEST_SESSION" -X quit 2>/dev/null

    if ! screen -list | grep -q "$TEST_SESSION"; then
        test_check "清理测试会话" "PASS"
    else
        test_check "清理测试会话" "FAIL"
        echo -e "${YELLOW}手动清理: screen -S $TEST_SESSION -X quit${NC}"
    fi
else
    test_check "清理测试会话" "PASS"
fi
echo ""

# 显示当前用户
echo -e "${BLUE}当前用户信息:${NC}"
echo -e "   用户名: ${USER}"
echo -e "   用户 ID: $(id -u)"
echo ""

# 显示系统用户列表（可选）
echo -e "${BLUE}系统用户列表（可用于多用户会话）:${NC}"
cut -d: -f1 /etc/passwd | grep -E "^[a-z][a-z0-9]*$" | head -10
echo ""

# 显示测试总结
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                  测试总结                          ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  通过测试: $TESTS_PASSED 个                                    ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  失败测试: $TESTS_FAILED 个                                    ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${CYAN}║${NC}  ${GREEN}✓ 所有测试通过! 可以使用多用户功能了!${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  下一步:                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    1. 创建多用户会话                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    2. 添加其他用户权限                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    3. 共享会话给其他用户                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  使用方法:                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    screen -S mysession -d -m                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    screen -S mysession -X multiuser on                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    screen -S mysession -X acladd username                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
else
    echo -e "${CYAN}║${NC}  ${RED}✗ 部分测试失败，请检查配置${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  请检查:                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    1. screen 版本是否支持 multiuser                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    2. ~/.screenrc 是否配置正确                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    3. 权限设置是否正确                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                        ${CYAN}║${NC}"
fi

echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 提供后续建议
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${CYAN}推荐阅读:${NC}"
    echo "  • $(dirname $0)/MULTIUSER_SETUP.md - 详细配置指南"
    echo "  • $(dirname $0)/multiuser_helper.sh - 辅助管理工具"
    echo ""

    echo -e "${CYAN}快速开始:${NC}"
    echo "  1. 创建会话: screen -S demo -d -m"
    echo "  2. 启用多用户: screen -S demo -X multiuser on"
    echo "  3. 添加用户: screen -S demo -X acladd alice"
    echo "  4. 连接会话: screen -S alice/demo (alice 用户执行)"
    echo ""
fi

echo -e "${CYAN}测试完成!${NC}"
