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
# Quick Setup for Root User
# 快速配置脚本（适用于root用户）
################################################################################

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${WHITE}         Smart Screen Manager - 快速配置脚本             ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查是否在正确目录
if [ ! -f "smart-screen.sh" ]; then
    echo -e "${RED}错误：请在 /root/smart-screen 目录下运行此脚本${NC}"
    exit 1
fi

# 检查脚本权限
echo -e "${YELLOW}检查脚本权限...${NC}"
chmod +x *.sh
if [ ! -x "smart-screen.sh" ]; then
    echo -e "${RED}错误：无法设置脚本权限${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 权限检查通过${NC}"
echo ""

# 测试脚本语法
echo -e "${YELLOW}测试脚本语法...${NC}"
if bash -n smart-screen.sh; then
    echo -e "${GREEN}✓ 脚本语法正确${NC}"
else
    echo -e "${RED}错误：脚本语法错误${NC}"
    exit 1
fi
echo ""

# 检查screen
echo -e "${YELLOW}检查 screen...${NC}"
if command -v screen &> /dev/null; then
    echo -e "${GREEN}✓ screen 已安装${NC}"
else
    echo -e "${YELLOW}⚠ screen 未安装，正在安装...${NC}"
    if command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y screen
    elif command -v yum &> /dev/null; then
        yum install -y screen
    else
        echo -e "${RED}错误：无法自动安装 screen，请手动安装${NC}"
        exit 1
    fi
fi
echo ""

# 配置自动启动
echo -e "${YELLOW}配置 SSH 自动启动...${NC}"

# 检查是否已配置
if grep -q "smart-screen.sh" ~/.bashrc 2>/dev/null; then
    echo -e "${YELLOW}⚠ 检测到已存在的配置，是否重新配置？(y/N)${NC}"
    read -p "输入选择: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}跳过自动启动配置${NC}"
    else
        # 删除旧配置
        sed -i '/smart-screen.sh/,/^fi$/d' ~/.bashrc
    fi
fi

# 添加新配置
if ! grep -q "smart-screen.sh" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'BASHRC_EOF'

# ================================================================
# Smart Screen Session Manager - Auto Start (Root Quick Setup)
# ================================================================
if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$SMART_SCREEN_STARTED" ]; then
    export SMART_SCREEN_STARTED=1
    SCRIPT_PATH="/root/smart-screen/smart-screen.sh"
    if [ -x "$SCRIPT_PATH" ]; then
        clear
        echo ""
        echo -e "\033[0;36m╔════════════════════════════════════════════════════════════╗\033[0m"
        echo -e "\033[0;36m║\033[1;37m              欢迎使用 Smart Screen Session Manager           \033[0;36m║\033[0m"
        echo -e "\033[0;36m╚════════════════════════════════════════════════════════════╝\033[0m"
        echo ""
        echo -e "\033[0;33m📋 预设会话：\033[0m"
        echo -e "  \033[0;32m1-dev\033[0m  \033[0;32m2-test\033[0m  \033[0;32m3-prod\033[0m  \033[0;32m4-db\033[0m  \033[0;32m5-monitor\033[0m"
        echo -e "  \033[0;32m6-backup\033[0m  \033[0;32m7-log\033[0m  \033[0;32m8-debug\033[0m  \033[0;32m9-research\033[0m"
        echo ""
        read -p "\033[0;33m是否启动Screen会话管理器？ [\033[0;32mY\033[0;33m/n]: \033[0m" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            echo ""
            echo -e "\033[0;32m启动 Smart Screen Session Manager...\033[0m"
            sleep 1
            exec "$SCRIPT_PATH"
        fi
    fi
fi
BASHRC_EOF
    echo -e "${GREEN}✓ 自动启动配置完成${NC}"
else
    echo -e "${GREEN}✓ 自动启动已配置${NC}"
fi
echo ""

# 测试screen
echo -e "${YELLOW}测试 screen 功能...${NC}"
if screen -list &> /dev/null; then
    echo -e "${GREEN}✓ screen 工作正常${NC}"
else
    echo -e "${RED}⚠ screen 可能无法正常工作${NC}"
fi
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${WHITE}                    配置完成！                        ${GREEN}║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${WHITE}  接下来的步骤：                                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  1. 断开SSH连接重新登录                               ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  2. 登录时会自动提示是否启动会话管理器                 ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  3. 选择 Y 启动，或稍后手动运行:                       ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}      /root/smart-screen/smart-screen.sh          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${WHITE}  使用方法：                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  • 输入 1-9 进入对应预设会话                           ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  • 输入 a 显示所有活跃会话                               ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  • 输入 q 退出                                         ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 询问是否立即测试
echo -e "${YELLOW}是否立即测试脚本？(y/N)${NC}"
read -p "输入选择: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}启动 Smart Screen Session Manager...${NC}"
    sleep 1
    exec ./smart-screen.sh
fi
