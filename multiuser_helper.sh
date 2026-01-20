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
# Screen Multiuser Helper - 多用户会话管理工具
# 用于快速创建和管理多用户共享的 screen 会话
################################################################################

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# 显示帮助信息
show_help() {
    echo -e "${CYAN}Screen Multiuser Helper - 多用户会话管理工具${NC}"
    echo ""
    echo "用法:"
    echo "  $0 create <会话名> <用户列表>  创建多用户会话"
    echo "  $0 connect <所有者> <会话名>    连接多用户会话"
    echo "  $0 list                      列出所有会话"
    echo "  $0 acl <会话名> <用户> <权限>  管理用户权限"
    echo "  $0 help                      显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0 create dev alice,bob,charlie"
    echo "  $0 connect alice dev"
    echo "  $0 acl dev bob +rw"
    echo ""
    echo "权限说明:"
    echo "  +rwx     所有权限"
    echo "  +rw      读写权限"
    echo "  +r       只读权限"
    echo "  -rwx     移除所有权限"
}

# 检查 screen 是否支持 multiuser
check_multiuser_support() {
    if ! screen -v | grep -q "multiuser"; then
        echo -e "${RED}错误: 你的 screen 版本不支持 multiuser 功能${NC}"
        exit 1
    fi
}

# 检查 .screenrc 是否启用了 multiuser
check_screenrc() {
    if [ -f ~/.screenrc ]; then
        if ! grep -q "multiuser on" ~/.screenrc; then
            echo -e "${YELLOW}警告: .screenrc 中未启用 multiuser${NC}"
            echo -e "${BLUE}建议添加 'multiuser on' 到你的 ~/.screenrc 文件${NC}"
        fi
    fi
}

# 创建多用户会话
create_session() {
    local session_name="$1"
    local users="$2"

    if [ -z "$session_name" ] || [ -z "$users" ]; then
        echo -e "${RED}错误: 请提供会话名和用户列表${NC}"
        echo "用法: $0 create <会话名> <用户列表>"
        exit 1
    fi

    echo -e "${CYAN}创建多用户会话: $session_name${NC}"

    # 检查会话是否已存在
    if screen -list | grep -q "$session_name"; then
        echo -e "${YELLOW}警告: 会话 '$session_name' 已存在${NC}"
        read -p "是否要重新创建? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        # 终止现有会话
        screen -S "$session_name" -X quit 2>/dev/null
    fi

    # 创建会话
    echo -e "${BLUE}1. 创建会话...${NC}"
    screen -S "$session_name" -d -m bash

    # 启用多用户模式
    echo -e "${BLUE}2. 启用多用户模式...${NC}"
    screen -S "$session_name" -X multiuser on

    # 添加用户权限
    echo -e "${BLUE}3. 添加用户权限...${NC}"
    IFS=',' read -ra USER_ARRAY <<< "$users"
    for user in "${USER_ARRAY[@]}"; do
        echo "   添加用户: $user"
        screen -S "$session_name" -X acladd "$user"
    done

    # 显示连接信息
    echo ""
    echo -e "${GREEN}✓ 会话 '$session_name' 创建成功!${NC}"
    echo ""
    echo -e "${CYAN}连接命令:${NC}"
    echo "  会话所有者: screen -S ${USER}/$session_name"
    echo "  其他用户:   screen -S username/$session_name"
    echo ""
    echo -e "${CYAN}权限管理:${NC}"
    echo "  添加用户:   $0 acl $session_name <username> +rwx"
    echo "  移除用户:   $0 acl $session_name <username> -rwx"
    echo ""
}

# 连接多用户会话
connect_session() {
    local owner="$1"
    local session_name="$2"

    if [ -z "$owner" ] || [ -z "$session_name" ]; then
        echo -e "${RED}错误: 请提供会话所有者和会话名${NC}"
        echo "用法: $0 connect <所有者> <会话名>"
        exit 1
    fi

    echo -e "${CYAN}连接到会话: $owner/$session_name${NC}"

    # 检查会话是否存在
    if ! screen -list | grep -q "$owner/$session_name"; then
        echo -e "${RED}错误: 会话 '$owner/$session_name' 不存在${NC}"
        echo ""
        echo "可用的会话:"
        screen -list
        exit 1
    fi

    # 连接到会话
    echo -e "${GREEN}正在连接到会话...${NC}"
    screen -S "$owner/$session_name"
}

# 列出所有会话
list_sessions() {
    echo -e "${CYAN}所有 Screen 会话:${NC}"
    echo ""
    screen -list
    echo ""
    echo -e "${YELLOW}多用户会话说明:${NC}"
    echo "  username/sessionname 格式表示多用户会话"
    echo "  username 是会话所有者，sessionname 是会话名称"
}

# 管理用户权限
manage_acl() {
    local session_name="$1"
    local user="$2"
    local permission="$3"

    if [ -z "$session_name" ] || [ -z "$user" ] || [ -z "$permission" ]; then
        echo -e "${RED}错误: 请提供会话名、用户名和权限${NC}"
        echo "用法: $0 acl <会话名> <用户名> <权限>"
        echo "示例: $0 acl dev bob +rw"
        exit 1
    fi

    echo -e "${CYAN}管理权限: $user 在会话 $session_name 中${NC}"

    # 检查会话是否存在
    if ! screen -list | grep -q "$session_name"; then
        echo -e "${RED}错误: 会话 '$session_name' 不存在${NC}"
        exit 1
    fi

    # 应用权限
    echo -e "${BLUE}应用权限: $permission${NC}"
    screen -S "$session_name" -X aclchg "$user" "$permission"

    echo -e "${GREEN}✓ 权限更新完成${NC}"
}

# 显示会话详细信息
show_session_info() {
    local session_name="$1"
    if [ -z "$session_name" ]; then
        echo -e "${RED}错误: 请提供会话名${NC}"
        exit 1
    fi

    echo -e "${CYAN}会话信息: $session_name${NC}"
    echo ""

    # 检查会话是否存在
    if ! screen -list | grep -q "$session_name"; then
        echo -e "${RED}会话不存在${NC}"
        exit 1
    fi

    # 显示会话状态
    echo "会话状态:"
    screen -list | grep "$session_name"

    echo ""
    echo "ACL 权限列表:"
    echo "  (需要在会话内使用 :acl 命令查看)"
    echo ""
    echo "连接命令:"
    echo "  screen -S ${USER}/$session_name  (如果你是会话所有者)"
    echo "  screen -S username/$session_name  (如果是其他用户)"
}

# 主函数
main() {
    check_multiuser_support
    check_screenrc

    case "$1" in
        create)
            create_session "$2" "$3"
            ;;
        connect)
            connect_session "$2" "$3"
            ;;
        list)
            list_sessions
            ;;
        acl)
            manage_acl "$2" "$3" "$4"
            ;;
        info)
            show_session_info "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            echo -e "${RED}错误: 请提供命令${NC}"
            show_help
            exit 1
            ;;
        *)
            echo -e "${RED}错误: 未知命令 '$1'${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
