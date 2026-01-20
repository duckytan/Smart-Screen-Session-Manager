#!/usr/bin/env bash
#
# Smart Screen Session Manager v2.0
# Copyright (c) 2026 Ducky
# Licensed under the MIT License
# Email: ducky@live.com
#
# 简洁高效的Screen会话管理工具
# 支持多用户协作、预设会话、简洁提示符
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
# Smart Screen Session Manager v2.0
# 智能 Screen 会话管理器 - 支持多用户协作的主脚本
################################################################################

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# 图标定义
readonly ICON_SESSION="📝"
readonly ICON_RUNNING="✅"
readonly ICON_QUIT="👋"
readonly ICON_DELETE="🗑️"
readonly ICON_CLEAN="🧹"
readonly ICON_ALL="📋"
readonly ICON_HELP="❓"
readonly ICON_EDIT="✏️"
readonly ICON_INSTALL="🚀"
readonly ICON_UNINSTALL="🛑"

# 会话映射 - 预设9个常用会话
declare -A SESSION_MAP=(
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

################################################################################
# 显示标题
################################################################################
show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                Smart Screen Session Manager v2.0           ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  智能Screen会话管理器 - 预设会话、自动创建、SSH恢复         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  版权所有 © 2026 Ducky | MIT License | ducky@live.com   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

################################################################################
# 显示会话列表
################################################################################
show_sessions() {
    echo -e "${YELLOW}📋 预设会话：${NC}"
    echo ""

    for i in {1..9}; do
        local session_name="${SESSION_MAP[$i]}"
        if screen -list | grep -q "$session_name"; then
            # 会话存在且运行中
            local pid=$(screen -list | grep "$session_name" | awk '{print $1}' | cut -d'.' -f1)
            echo -e "  [${GREEN}$i${NC}] ${ICON_RUNNING} ${WHITE}$session_name${NC} ${YELLOW}(运行中 - PID: $pid)${NC}"
        else
            # 会话不存在
            echo -e "  [${GREEN}$i${NC}] ${ICON_SESSION} ${WHITE}$session_name${NC} ${CYAN}(未创建)${NC}"
        fi
    done

    echo ""
    echo -e "${CYAN}管理操作：${NC}"
    echo -e "  [${GREEN}a${NC}] ${ICON_ALL} 显示所有活跃会话"
    echo -e "  [${GREEN}c${NC}] ${ICON_CLEAN} 清理重复会话"
    echo -e "  [${GREEN}d${NC}] ${ICON_DELETE} 删除所有会话"
    echo -e "  [${GREEN}e${NC}] ${ICON_EDIT} 编辑脚本"
    echo ""
    echo -e "${CYAN}系统管理：${NC}"
    echo -e "  [${GREEN}i${NC}] ${ICON_INSTALL} 自动安装（安装依赖+配置自启动）"
    echo -e "  [${GREEN}u${NC}] ${ICON_UNINSTALL} 自动卸载（删除自启动配置）"
    echo -e "  [${GREEN}h${NC}] ${ICON_HELP} 帮助信息"
    echo -e "  [${GREEN}q${NC}] ${ICON_QUIT} 退出"
    echo ""
}

################################################################################
# 检查并启用多用户模式
################################################################################
ensure_multiuser_mode() {
    local session_name="$1"

    # 启用多用户模式
    screen -S "$session_name" -X multiuser on 2>/dev/null || true

    # 获取当前用户名
    local current_user=$(whoami)

    # 为当前用户添加权限
    screen -S "$session_name" -X acladd "$current_user" 2>/dev/null || true
}

################################################################################
# 连接到会话（不存在则创建）
################################################################################
connect_session() {
    local session_name="$1"

    # 检查会话是否已存在
    if screen -list | grep -q "$session_name"; then
        echo -e "${GREEN}连接到现有会话: $session_name${NC}"
        echo -e "${BLUE}💡 使用 screen -xR 支持多用户协作${NC}"

        # 确保多用户模式已启用
        ensure_multiuser_mode "$session_name"

        exec screen -xR "$session_name"
    else
        echo -e "${CYAN}创建新会话: $session_name${NC}"
        echo -e "${BLUE}💡 自动启用多用户模式，支持协作${NC}"

        # 创建会话并分离
        screen -S "$session_name" -d -m bash

        # 等待会话创建
        sleep 1

        # 启用多用户模式
        ensure_multiuser_mode "$session_name"

        # 连接会话
        exec screen -xR "$session_name"
    fi
}

################################################################################
# 显示所有活跃会话
################################################################################
show_all_sessions() {
    local sessions=$(screen -list | grep -v "No Sockets found" | grep -v "There is no screen" | awk 'NR>1 {print $1}' | cut -d'.' -f2)

    if [ -z "$sessions" ]; then
        echo -e "${YELLOW}没有找到活跃的会话${NC}"
        return
    fi

    echo -e "${YELLOW}📋 所有活跃会话：${NC}"
    echo ""

    local count=1
    for session in $sessions; do
        echo -e "  [${GREEN}$count${NC}] ${WHITE}$session${NC}"
        count=$((count + 1))
    done

    echo ""
    read -p "请选择要连接的会话 (1-$((count-1))): " choice

    if [ "$choice" -ge 1 ] && [ "$choice" -lt $count ]; then
        local selected_session=$(echo "$sessions" | sed -n "${choice}p")
        echo -e "${GREEN}连接到会话: $selected_session${NC}"
        echo -e "${BLUE}💡 使用 screen -xR 支持多用户协作${NC}"

        # 确保多用户模式已启用
        ensure_multiuser_mode "$selected_session"

        exec screen -xR "$selected_session"
    fi
}

################################################################################
# 清理重复会话
################################################################################
clean_duplicate_sessions() {
    echo -e "${YELLOW}🧹 正在清理重复会话...${NC}"

    # 获取所有会话列表
    local sessions=$(screen -list | grep -v "No Sockets found" | grep -v "There is no screen" | awk 'NR>1 {print $1}' | cut -d'.' -f2)

    if [ -z "$sessions" ]; then
        echo -e "${YELLOW}没有找到重复会话${NC}"
        return
    fi

    # 查找重复的会话名称（去掉编号后缀）
    local unique_names=$(echo "$sessions" | sed 's/[0-9]*$//' | sort -u)

    for name in $unique_names; do
        # 获取同名会话的数量
        local count=$(echo "$sessions" | grep "^$name" | wc -l)

        if [ $count -gt 1 ]; then
            echo -e "${YELLOW}发现重复会话: $name (共 $count 个)${NC}"

            # 保留第一个，删除其他的
            local sessions_to_kill=$(echo "$sessions" | grep "^$name" | tail -n +2)
            for session in $sessions_to_kill; do
                screen -S "$session" -X quit
                echo -e "  ${RED}删除: $session${NC}"
            done
        fi
    done

    echo -e "${GREEN}✨ 清理完成！${NC}"
}

################################################################################
# 删除所有会话
################################################################################
delete_all_sessions() {
    echo -e "${RED}⚠️  确定要删除所有会话吗？此操作不可恢复！${NC}"
    read -p "输入 'yes' 确认: " confirm

    if [ "$confirm" = "yes" ]; then
        echo -e "${RED}🗑️  正在删除所有会话...${NC}"
        screen -wipe &>/dev/null
        echo -e "${GREEN}✨ 所有会话已删除${NC}"
    else
        echo -e "${YELLOW}操作已取消${NC}"
    fi
}

################################################################################
# 显示帮助信息
################################################################################
show_help() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                      帮助信息                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  快捷键：                                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 1-9 → 进入对应预设会话                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 a   → 显示所有活跃会话                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 c   → 清理重复会话                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 d   → 删除所有会话                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 e   → 编辑脚本                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 i   → 自动安装（安装依赖+配置自启动）              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 u   → 自动卸载（删除自启动配置）                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 h   → 显示帮助信息                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 输入 q   → 退出脚本                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  使用技巧：                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 按 Ctrl+A 然后按 D 可从screen会话返回                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 预设会话会自动创建或连接，无需担心重复                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 所有screen会话会在后台持续运行                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 支持多用户协作！多个人可以同时操作同一个会话           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 首次使用建议运行 'i' 进行自动安装                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "按 Enter 键继续..."
}

################################################################################
# 编辑脚本
################################################################################
edit_script() {
    echo -e "${CYAN}正在打开编辑器...${NC}"
    if command -v nano &>/dev/null; then
        nano "$0"
    elif command -v vim &>/dev/null; then
        vim "$0"
    else
        echo -e "${YELLOW}请安装 nano 或 vim 编辑器${NC}"
    fi
}

################################################################################
# 自动安装功能
################################################################################
auto_install() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                   🚀 自动安装                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 检查是否已配置自启动
    if grep -q "smart-screen.sh" ~/.bashrc 2>/dev/null; then
        echo -e "${YELLOW}⚠ 检测到已存在的自启动配置${NC}"
        read -p "是否重新配置？(y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}正在删除旧配置...${NC}"
            sed -i '/smart-screen.sh/,/^fi$/d' ~/.bashrc 2>/dev/null
        else
            echo -e "${BLUE}跳过自动启动配置${NC}"
            echo ""
            read -p "按 Enter 键继续..."
            return
        fi
    fi

    echo -e "${YELLOW}检查依赖...${NC}"

    # 检查并安装 screen
    if command -v screen &> /dev/null; then
        echo -e "${GREEN}✓ screen 已安装${NC}"
    else
        echo -e "${YELLOW}⚠ screen 未安装，正在安装...${NC}"

        if command -v apt-get &> /dev/null; then
            echo "使用 apt-get 安装..."
            apt-get update -qq && apt-get install -y screen
        elif command -v yum &> /dev/null; then
            echo "使用 yum 安装..."
            yum install -y screen
        else
            echo -e "${RED}❌ 无法自动安装 screen，请手动安装${NC}"
            read -p "按 Enter 键继续..."
            return
        fi

        if command -v screen &> /dev/null; then
            echo -e "${GREEN}✓ screen 安装成功${NC}"
        else
            echo -e "${RED}❌ screen 安装失败${NC}"
            read -p "按 Enter 键继续..."
            return
        fi
    fi

    echo ""
    echo -e "${YELLOW}配置自启动...${NC}"

    # 获取脚本所在目录
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local script_path="$script_dir/smart-screen.sh"

    # 添加自启动配置到 ~/.bashrc
    cat >> ~/.bashrc << 'BASHRC_EOF'

# ================================================================
# Smart Screen Session Manager - Auto Start
# ================================================================
if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$SMART_SCREEN_STARTED" ]; then
    export SMART_SCREEN_STARTED=1
    SCRIPT_PATH="SMART_SCREEN_SCRIPT_PATH"
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

    # 替换脚本路径
    sed -i "s|SMART_SCREEN_SCRIPT_PATH|$script_path|g" ~/.bashrc

    echo -e "${GREEN}✓ 自启动配置完成${NC}"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}                  安装完成！                        ${GREEN}║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${WHITE}  接下来的步骤：                                        ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  1. 断开SSH连接重新登录                               ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  2. 登录时会自动提示是否启动会话管理器                 ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  3. 选择 Y 启动，或稍后手动运行:                       ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}      $script_path${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    read -p "按 Enter 键继续..."
}

################################################################################
# 自动卸载功能
################################################################################
auto_uninstall() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                   🛑 自动卸载                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${RED}⚠️  此操作将删除自启动配置，但不会删除现有会话${NC}"
    echo -e "${YELLOW}注意：删除后需要手动运行脚本来启动会话管理器${NC}"
    echo ""
    read -p "确认卸载自启动配置？(y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}正在删除自启动配置...${NC}"

        # 删除 ~/.bashrc 中的配置
        if grep -q "smart-screen.sh" ~/.bashrc 2>/dev/null; then
            sed -i '/smart-screen.sh/,/^fi$/d' ~/.bashrc 2>/dev/null
            echo -e "${GREEN}✓ 已删除 ~/.bashrc 中的自启动配置${NC}"
        else
            echo -e "${YELLOW}未找到自启动配置${NC}"
        fi

        # 删除环境变量
        unset SMART_SCREEN_STARTED 2>/dev/null

        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${WHITE}                  卸载完成！                        ${GREEN}║${NC}"
        echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  卸载内容：                                            ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ✓ 已删除 ~/.bashrc 中的自启动配置                     ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ✓ 已清理环境变量                                     ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  后续操作：                                            ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  • 现有会话将继续运行，不会被删除                     ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  • 下次登录不会再自动提示                             ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  • 如需手动启动，运行: $0${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${YELLOW}操作已取消${NC}"
    fi

    echo ""
    read -p "按 Enter 键继续..."
}

################################################################################
# 主循环
################################################################################
main() {
    # 检查 screen 是否安装
    if ! command -v screen &>/dev/null; then
        echo -e "${RED}错误: screen 未安装${NC}"
        echo -e "${YELLOW}请运行: sudo apt-get install screen${NC}"
        exit 1
    fi

    while true; do
        show_header
        show_sessions

        read -p "请选择操作: " choice

        case $choice in
            [1-9])
                connect_session "${SESSION_MAP[$choice]}"
                ;;
            a|A)
                show_all_sessions
                ;;
            c|C)
                clean_duplicate_sessions
                sleep 2
                ;;
            d|D)
                delete_all_sessions
                sleep 2
                ;;
            e|E)
                edit_script
                ;;
            i|I)
                auto_install
                ;;
            u|U)
                auto_uninstall
                ;;
            h|H)
                show_help
                ;;
            q|Q)
                echo -e "${GREEN}👋 再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重试${NC}"
                sleep 1
                ;;
        esac
    done
}

################################################################################
# 启动主程序
################################################################################
main
