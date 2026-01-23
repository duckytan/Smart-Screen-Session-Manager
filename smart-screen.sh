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
set -eo pipefail  # 启用严格模式：命令失败时退出、未定义变量时退出、管道失败时退出

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
# 验证会话名称
################################################################################
validate_session_name() {
    local name="$1"

    # 检查是否为空
    if [ -z "$name" ]; then
        echo -e "${RED}❌ 会话名称不能为空${NC}"
        return 1
    fi

    # 检查是否包含非法字符（允许字母、数字、连字符、下划线、空格）
    if [[ ! "$name" =~ ^[a-zA-Z0-9._\-[:space:]]+$ ]]; then
        echo -e "${RED}❌ 会话名称包含非法字符：只能包含字母、数字、点、下划线、连字符和空格${NC}"
        return 1
    fi

    # 检查长度
    if [ ${#name} -gt 50 ]; then
        echo -e "${RED}❌ 会话名称过长（最大50个字符）${NC}"
        return 1
    fi

    return 0
}

################################################################################
# 检查数字输入是否有效
################################################################################
validate_numeric_input() {
    local input="$1"
    local min_value="$2"
    local max_value="$3"

    # 检查是否为空
    if [ -z "$input" ]; then
        echo -e "${RED}❌ 输入不能为空${NC}"
        return 1
    fi

    # 检查是否为数字
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ 请输入有效数字${NC}"
        return 1
    fi

    # 检查是否在有效范围内
    if [ "$input" -lt "$min_value" ] || [ "$input" -gt "$max_value" ]; then
        echo -e "${RED}❌ 请输入 $min_value 到 $max_value 之间的数字${NC}"
        return 1
    fi

    return 0
}

################################################################################
# 检查并启用多用户模式
################################################################################
ensure_multiuser_mode() {
    local session_name="$1"

    # 启用多用户模式
    if screen -S "$session_name" -X multiuser on 2>/dev/null; then
        echo -e "${GREEN}✓ 多用户模式已启用${NC}"
    else
        echo -e "${YELLOW}⚠️  无法启用多用户模式，但可以继续使用${NC}"
    fi

    # 获取当前用户名
    local current_user=$(whoami)

    # 为当前用户添加权限
    if screen -S "$session_name" -X acladd "$current_user" 2>/dev/null; then
        echo -e "${GREEN}✓ 当前用户权限已添加${NC}"
    else
        echo -e "${YELLOW}⚠️  无法添加用户权限，但可以继续使用${NC}"
    fi
}

################################################################################
# 连接到会话（不存在则创建）
################################################################################
connect_session() {
    local session_name="$1"

    # 验证会话名称
    if ! validate_session_name "$session_name"; then
        echo -e "${RED}❌ 会话名称无效，请检查输入${NC}"
        return 1
    fi

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
    local choice=$(safe_read "请选择要连接的会话 (1-$((count-1))): " "")

    # 处理空输入或无效输入
    if [ -z "$choice" ] || ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}无效选择，返回主菜单${NC}"
        return
    fi

    if [ "$choice" -ge 1 ] && [ "$choice" -lt $count ]; then
        local selected_session=$(echo "$sessions" | sed -n "${choice}p")
        echo -e "${GREEN}连接到会话: $selected_session${NC}"
        echo -e "${BLUE}💡 使用 screen -xR 支持多用户协作${NC}"

        # 确保多用户模式已启用
        ensure_multiuser_mode "$selected_session"

        exec screen -xR "$selected_session"
    else
        echo -e "${YELLOW}无效选择，返回主菜单${NC}"
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
    local confirm=$(safe_read "输入 'yes' 确认: " "no")

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
    safe_read "按 Enter 键继续..."
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
        local confirm=$(safe_read "是否重新配置？(y/N): " "n")
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}正在删除旧配置...${NC}"

            # 检查权限
            if [ ! -w ~/.bashrc ]; then
                echo -e "${RED}❌ 没有写入 ~/.bashrc 的权限${NC}"
                safe_read "按 Enter 键继续..."
                return
            fi

            # 备份旧配置
            if [ -f ~/.bashrc ]; then
                local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
                cp ~/.bashrc "$backup_file" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ 已备份旧配置到 $backup_file${NC}"
                fi
            fi

            # 安全删除：使用与卸载相同的逻辑
            local temp_file=$(mktemp)
            local in_smart_screen_block=false
            local block_depth=0

            while IFS= read -r line; do
                # 检测配置块开始
                if [[ "$line" =~ "# Smart Screen Session Manager" ]]; then
                    in_smart_screen_block=true
                    block_depth=1
                    continue
                fi

                # 如果在配置块内
                if [ "$in_smart_screen_block" = true ]; then
                    # 计算大括号嵌套深度
                    if [[ "$line" =~ if\ \[ ]]; then
                        ((block_depth++))
                    elif [[ "$line" =~ ^[[:space:]]*fi[[:space:]]*$ ]]; then
                        ((block_depth--))
                        if [ $block_depth -eq 0 ]; then
                            in_smart_screen_block=false
                            continue
                        fi
                    fi
                    continue
                else
                    # 输出非配置块的行
                    echo "$line" >> "$temp_file"
                fi
            done < ~/.bashrc

            # 替换原文件
            mv "$temp_file" ~/.bashrc 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ 已删除旧配置${NC}"
            else
                echo -e "${RED}❌ 删除旧配置失败${NC}"
                rm -f "$temp_file"
                safe_read "按 Enter 键继续..."
                return
            fi
        else
            echo -e "${BLUE}跳过自动启动配置${NC}"
            echo ""
            safe_read "按 Enter 键继续..."
            return
        fi
    fi

    echo -e "${YELLOW}检查依赖...${NC}"

    # 检查并安装 screen
    if command -v screen &> /dev/null; then
        echo -e "${GREEN}✓ screen 已安装${NC}"
    else
        echo -e "${YELLOW}⚠ screen 未安装，正在安装...${NC}"

        # 检查是否有安装权限
        local need_sudo=false
        local install_cmd=""

        if [ "$EUID" -ne 0 ]; then
            # 非root用户，需要检查sudo
            if command -v sudo &> /dev/null; then
                if sudo -n true 2>/dev/null; then
                    # 有sudo免密权限
                    need_sudo=true
                else
                    echo -e "${YELLOW}检测到需要sudo权限，正在申请...${NC}"
                    if sudo -v 2>/dev/null; then
                        need_sudo=true
                    else
                        echo -e "${RED}❌ 无法获取sudo权限，请检查sudo配置${NC}"
                        echo -e "${YELLOW}💡 提示：可以手动运行 'sudo apt-get install screen' 或 'sudo yum install screen'${NC}"
                        safe_read "按 Enter 键继续..."
                        return
                    fi
                fi
            else
                echo -e "${RED}❌ 需要root权限但系统中未安装sudo${NC}"
                echo -e "${YELLOW}💡 提示：请手动安装screen或联系系统管理员${NC}"
                safe_read "按 Enter 键继续..."
                return
            fi
        fi

        if command -v apt-get &> /dev/null; then
            echo "使用 apt-get 安装..."
            if [ "$need_sudo" = true ]; then
                sudo apt-get update -qq && sudo apt-get install -y screen
            else
                apt-get update -qq && apt-get install -y screen
            fi
        elif command -v yum &> /dev/null; then
            echo "使用 yum 安装..."
            if [ "$need_sudo" = true ]; then
                sudo yum install -y screen
            else
                yum install -y screen
            fi
        else
            echo -e "${RED}❌ 无法自动安装 screen，请手动安装${NC}"
            safe_read "按 Enter 键继续..."
            return
        fi

        # 验证安装结果
        if command -v screen &> /dev/null; then
            echo -e "${GREEN}✓ screen 安装成功${NC}"
        else
            echo -e "${RED}❌ screen 安装失败${NC}"
            echo -e "${YELLOW}💡 提示：请检查网络连接或手动安装screen${NC}"
            safe_read "按 Enter 键继续..."
            return
        fi
    fi

    echo ""
    echo -e "${YELLOW}配置自启动...${NC}"

    # 获取脚本所在目录
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local script_path="$script_dir/smart-screen.sh"

    # 检查 ~/.bashrc 是否有写入权限
    if [ -f ~/.bashrc ] && [ ! -w ~/.bashrc ]; then
        echo -e "${RED}❌ ~/.bashrc 存在但没有写入权限${NC}"
        echo -e "${YELLOW}💡 提示：请检查文件权限或手动添加配置${NC}"
        safe_read "按 Enter 键继续..."
        return
    fi

    # 备份现有的 ~/.bashrc
    if [ -f ~/.bashrc ]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp ~/.bashrc "$backup_file" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 已备份 ~/.bashrc 到 $backup_file${NC}"
        else
            echo -e "${YELLOW}⚠️  备份 ~/.bashrc 失败，将继续尝试配置${NC}"
        fi
    fi

    # 添加自启动配置到 ~/.bashrc（静默启动，不显示提示）
    echo "" >> ~/.bashrc
    echo "# ================================================================ " >> ~/.bashrc
    echo "# Smart Screen Session Manager - Auto Start (Silent Mode) " >> ~/.bashrc
    echo "# Added on $(date)" >> ~/.bashrc
    echo "# ================================================================ " >> ~/.bashrc
    echo "if [ -z \"\$STY\" ] && [ -n \"\$PS1\" ] && [ -z \"\$TMUX\" ] && [ -z \"\$SMART_SCREEN_STARTED\" ]; then" >> ~/.bashrc
    echo "    export SMART_SCREEN_STARTED=1" >> ~/.bashrc
    echo "    SCRIPT_PATH=\"$script_path\"" >> ~/.bashrc
    echo "    if [ -x \"\$SCRIPT_PATH\" ]; then" >> ~/.bashrc
    echo "        # 静默启动，不显示提示" >> ~/.bashrc
    echo "        exec \"\$SCRIPT_PATH\"" >> ~/.bashrc
    echo "    fi" >> ~/.bashrc
    echo "fi" >> ~/.bashrc

    # 验证配置是否成功添加
    if grep -q "Smart Screen Session Manager" ~/.bashrc 2>/dev/null; then
        echo -e "${GREEN}✓ 自启动配置完成${NC}"
    else
        echo -e "${RED}❌ 自启动配置失败${NC}"
        echo -e "${YELLOW}💡 提示：请检查 ~/.bashrc 权限或手动添加配置${NC}"
        safe_read "按 Enter 键继续..."
        return
    fi

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}                  安装完成！                        ${GREEN}║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${WHITE}  安装内容：                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ✓ 已安装 screen                                      ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ✓ 已配置自启动（静默模式）                          ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${WHITE}  使用说明：                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 下次SSH登录时会自动启动会话管理器                   ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 无需手动运行，登录即用                             ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 如需卸载，运行脚本选择 'u'                         ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    safe_read "按 Enter 键继续..."
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
    local confirm=$(safe_read "确认卸载自启动配置？(y/N): " "n")

    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}正在删除自启动配置...${NC}"

        # 检查 ~/.bashrc 是否有写入权限
        if [ ! -w ~/.bashrc ]; then
            echo -e "${RED}❌ 没有写入 ~/.bashrc 的权限${NC}"
            echo -e "${YELLOW}💡 提示：请检查文件权限${NC}"
            safe_read "按 Enter 键继续..."
            return
        fi

        # 备份当前的 ~/.bashrc
        if [ -f ~/.bashrc ]; then
            local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
            cp ~/.bashrc "$backup_file" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ 已备份 ~/.bashrc 到 $backup_file${NC}"
            else
                echo -e "${YELLOW}⚠️  备份 ~/.bashrc 失败，将继续尝试卸载${NC}"
            fi
        fi

        # 安全删除配置：只删除 Smart Screen Session Manager 相关的配置块
        local temp_file=$(mktemp)
        local in_smart_screen_block=false
        local block_depth=0

        while IFS= read -r line; do
            # 检测配置块开始
            if [[ "$line" =~ "# Smart Screen Session Manager" ]]; then
                in_smart_screen_block=true
                block_depth=1
                continue
            fi

            # 如果在配置块内
            if [ "$in_smart_screen_block" = true ]; then
                # 计算大括号嵌套深度
                if [[ "$line" =~ if\ \[ ]]; then
                    ((block_depth++))
                elif [[ "$line" =~ ^[[:space:]]*fi[[:space:]]*$ ]]; then
                    ((block_depth--))
                    if [ $block_depth -eq 0 ]; then
                        # 配置块结束，不输出这个 fi
                        in_smart_screen_block=false
                        continue
                    fi
                fi
                continue  # 跳过配置块内的所有行
            else
                # 输出非配置块的行
                echo "$line" >> "$temp_file"
            fi
        done < ~/.bashrc

        # 替换原文件
        mv "$temp_file" ~/.bashrc 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 已删除 ~/.bashrc 中的自启动配置${NC}"
        else
            echo -e "${RED}❌ 删除配置文件失败${NC}"
            rm -f "$temp_file"
            safe_read "按 Enter 键继续..."
            return
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
    safe_read "按 Enter 键继续..."
}

################################################################################
# 检查 screen 是否可用
################################################################################
check_screen_available() {
    if ! command -v screen &>/dev/null; then
        return 1
    fi
    return 0
}

################################################################################
# 安全读取输入
################################################################################
safe_read() {
    local prompt="$1"
    local default_value="${2:-}"
    local result=""

    if [ -t 0 ] && [ -t 1 ]; then
        # 交互式环境：正常读取用户输入
        read -r "$prompt" result
    else
        # 非交互式环境：使用默认值，静默处理
        echo -n "$prompt" >&2  # 提示信息输出到stderr
        result="$default_value"
    fi

    echo "$result"
}

################################################################################
# 检查是否为交互式终端
################################################################################
is_interactive() {
    if [ -t 0 ] && [ -t 1 ]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# 显示非交互式模式提示
################################################################################
show_non_interactive_message() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}              Smart Screen Session Manager v2.0            ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}  检测到非交互式环境                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  最佳使用方式：                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  1. 下载脚本到本地：                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     curl -fsSL https://.../smart-screen.sh -o smart-screen.sh ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  2. 赋予执行权限：                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     chmod +x smart-screen.sh                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  3. 直接运行脚本：                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ./smart-screen.sh                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  或者手动安装 screen 后重新运行：                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     sudo apt-get install screen                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
}

################################################################################
# 主循环
################################################################################
main() {
    # 检查是否为交互式环境
    if ! is_interactive; then
        show_non_interactive_message
    fi

    while true; do
        show_header

        # 检查 screen 是否安装
        if ! check_screen_available; then
            # screen 未安装，显示简化菜单
            echo -e "${RED}⚠️  screen 未安装${NC}"
            echo -e "${YELLOW}首次使用建议先运行 'i' 进行自动安装${NC}"
            echo ""
            echo -e "${CYAN}可用的操作：${NC}"
            echo -e "  [${GREEN}i${NC}] ${ICON_INSTALL} 自动安装（安装依赖+配置自启动）"
            echo -e "  [${GREEN}h${NC}] ${ICON_HELP} 帮助信息"
            echo -e "  [${GREEN}q${NC}] ${ICON_QUIT} 退出"
            echo ""

            local choice=$(safe_read "请选择操作: " "q")

            case $choice in
                i|I)
                    auto_install
                    ;;
                h|H)
                    show_help
                    ;;
                q|Q)
                    echo -e "${GREEN}👋 再见！${NC}"
                    exit 0
                    ;;
                "")
                    echo -e "${YELLOW}请输入选择！${NC}"
                    sleep 1
                    ;;
                *)
                    echo -e "${RED}无效选择，请重试${NC}"
                    sleep 1
                    ;;
            esac
        else
            # screen 已安装，正常显示会话列表
            show_sessions

            local choice=$(safe_read "请选择操作: " "q")

            case $choice in
                [1-9])
                    if validate_numeric_input "$choice" 1 9; then
                        local session_name="${SESSION_MAP[$choice]}"
                        if connect_session "$session_name"; then
                            # 连接成功，不会返回到这里
                            :
                        else
                            # 连接失败，暂停一下让用户看到错误信息
                            sleep 2
                        fi
                    else
                        sleep 2
                    fi
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
                "")
                    echo -e "${YELLOW}请输入选择！${NC}"
                    sleep 1
                    ;;
                *)
                    echo -e "${RED}无效选择，请重试${NC}"
                    sleep 1
                    ;;
            esac
        fi
    done
}

################################################################################
# 启动主程序
################################################################################
main
