#!/bin/bash

################################################################################
# Smart Screen Session Manager - 测试脚本
# 功能：验证所有组件是否正常工作
################################################################################

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# 图标
readonly ICON_CHECK="✅"
readonly ICON_INFO="ℹ️"
readonly ICON_WARN="⚠️"
readonly ICON_ERROR="❌"
readonly ICON_SUCCESS="✨"

# 测试结果
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

################################################################################
# 测试函数
################################################################################
test() {
    local test_name="$1"
    local test_command="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${CYAN}[测试 $TOTAL_TESTS]${NC} $test_name"
    echo "----------------------------------------"

    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}${ICON_CHECK} 通过${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}${ICON_ERROR} 失败${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

################################################################################
# 检查 screen 是否安装
################################################################################
check_screen_installed() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}检查 screen 是否安装${NC}"
    echo -e "${PURPLE}================================${NC}"

    if command -v screen &> /dev/null; then
        echo -e "${GREEN}${ICON_CHECK} screen 已安装${NC}"
        echo -e "${BLUE}版本信息：${NC}"
        screen -v 2>&1 | head -1
        return 0
    else
        echo -e "${RED}${ICON_ERROR} screen 未安装${NC}"
        echo -e "${YELLOW}请运行以下命令安装：${NC}"
        echo -e "${CYAN}  Ubuntu/Debian: sudo apt-get install screen${NC}"
        echo -e "${CYAN}  CentOS/RHEL: sudo yum install screen${NC}"
        return 1
    fi
}

################################################################################
# 检查脚本文件
################################################################################
check_script_files() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}检查脚本文件${NC}"
    echo -e "${PURPLE}================================${NC}"

    local files=(
        "/root/smart-screen.sh"
        "/root/install_auto_start.sh"
        "/root/README.md"
        "/root/AUTO_START_SETUP.md"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo -e "${GREEN}${ICON_CHECK} 找到文件：$file${NC}"
            if [[ -x "$file" ]]; then
                echo -e "  ${GREEN}  ✓ 有执行权限${NC}"
            else
                echo -e "  ${YELLOW}  ⚠ 无执行权限${NC}"
            fi
        else
            echo -e "${RED}${ICON_ERROR} 缺少文件：$file${NC}"
        fi
    done
}

################################################################################
# 脚本语法检查
################################################################################
check_script_syntax() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}脚本语法检查${NC}"
    echo -e "${PURPLE}================================${NC}"

    test "主脚本语法检查" "bash -n /root/smart-screen.sh"
    test "安装脚本语法检查" "bash -n /root/install_auto_start.sh"
}

################################################################################
# 检查 .bashrc 配置
################################################################################
check_bashrc_config() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}检查 .bashrc 配置${NC}"
    echo -e "${PURPLE}================================${NC}"

    if grep -q "smart-screen.sh" ~/.bashrc 2>/dev/null; then
        echo -e "${GREEN}${ICON_CHECK} 检测到自动启动配置${NC}"
        echo -e "${BLUE}配置摘要：${NC}"
        grep -A 5 "smart-screen.sh" ~/.bashrc | head -6
    else
        echo -e "${YELLOW}${ICON_WARN} 未检测到自动启动配置${NC}"
        echo -e "${BLUE}您可以运行安装脚本或手动配置：${NC}"
        echo -e "${CYAN}  ./install_auto_start.sh${NC}"
    fi
}

################################################################################
# 测试 screen 基本功能
################################################################################
test_screen_basic() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}测试 screen 基本功能${NC}"
    echo -e "${PURPLE}================================${NC}"

    # 测试 screen -list
    if screen -list &>/dev/null; then
        echo -e "${GREEN}${ICON_CHECK} screen -list 命令正常${NC}"
    else
        echo -e "${RED}${ICON_ERROR} screen -list 命令失败${NC}"
        return 1
    fi

    # 测试创建会话
    local test_session="test_smart_screen_$$"
    screen -dmS "$test_session" bash
    sleep 1

    if screen -list | grep -q "$test_session"; then
        echo -e "${GREEN}${ICON_CHECK} 创建测试会话成功${NC}"
        # 清理测试会话
        screen -S "$test_session" -X quit 2>/dev/null
    else
        echo -e "${RED}${ICON_ERROR} 创建测试会话失败${NC}"
        return 1
    fi
}

################################################################################
# 测试会话配置
################################################################################
test_session_config() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}测试会话配置${NC}"
    echo -e "${PURPLE}================================${NC}"

    # 检查预设会话配置
    if grep -q "SESSION_MAP" /root/smart-screen.sh; then
        echo -e "${GREEN}${ICON_CHECK} 找到 SESSION_MAP 配置${NC}"

        # 验证9个预设会话
        local expected_sessions=9
        local configured_sessions=$(grep -oP '\[.*?\]' /root/smart-screen.sh | grep -c '^[0-9]')

        if [[ $configured_sessions -ge $expected_sessions ]]; then
            echo -e "${GREEN}${ICON_CHECK} 预设会话数量正确${NC}"
        else
            echo -e "${YELLOW}${ICON_WARN} 预设会话数量可能不足${NC}"
        fi
    else
        echo -e "${RED}${ICON_ERROR} 未找到 SESSION_MAP 配置${NC}"
        return 1
    fi
}

################################################################################
# 显示测试摘要
################################################################################
show_summary() {
    echo -e "\n\n${PURPLE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${WHITE}                    测试摘要                           ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC}                                                            ${PURPLE}║${NC}"

    echo -e "${PURPLE}║${WHITE}  总测试数： $TOTAL_TESTS                                         ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${GREEN}  通过： $TESTS_PASSED                                              ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${RED}  失败： $TESTS_FAILED                                              ${PURPLE}║${NC}"

    echo -e "${PURPLE}║${NC}                                                            ${PURPLE}║${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${PURPLE}║${GREEN}  🎉 所有测试通过！系统已就绪！                       ${PURPLE}║${NC}"
    else
        echo -e "${PURPLE}║${YELLOW}  ⚠️  部分测试失败，请检查上述错误信息               ${PURPLE}║${NC}"
    fi

    echo -e "${PURPLE}║${NC}                                                            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}  下一步：                                                   ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}    • 运行 ./install_auto_start.sh 进行完整安装            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}    • 或手动运行 /root/smart-screen.sh              ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}                                                            ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════╝${NC}"
}

################################################################################
# 主函数
################################################################################
main() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Smart Screen Session Manager - 测试程序           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # 检查 screen 安装
    check_screen_installed

    # 检查脚本文件
    check_script_files

    # 脚本语法检查
    check_script_syntax

    # 检查 .bashrc 配置
    check_bashrc_config

    # 测试 screen 基本功能
    if command -v screen &> /dev/null; then
        test_screen_basic
    fi

    # 测试会话配置
    test_session_config

    # 显示测试摘要
    show_summary

    echo ""
}

################################################################################
# 执行主函数
################################################################################
main "$@"
