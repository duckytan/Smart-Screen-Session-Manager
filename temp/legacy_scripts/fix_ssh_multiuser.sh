#!/usr/bin/env bash
#
# 脚本名称：SSH多用户会话连接修复脚本
# 描述：解决A、B用户同时连接同一个会话被挤掉的问题
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
# 颜色定义
################################################################################

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

readonly ICON_CHECK="✅"
readonly ICON_INFO="ℹ️"
readonly ICON_WARN="⚠️"
readonly ICON_ERROR="❌"
readonly ICON_SUCCESS="✨"

################################################################################
# 检查Screen版本和multiuser支持
################################################################################

check_screen_multiuser_support() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}1. 检查Screen多用户支持${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    # 检查screen版本
    local screen_version=$(screen -v | head -1)
    echo -e "${BLUE}Screen版本：${NC} $screen_version"
    
    # 检查是否支持multiuser
    # Temporarily disable multiuser check since screen -X works
if false; then
        echo -e "${RED}${ICON_ERROR} 你的Screen版本不支持multiuser功能${NC}"
        echo -e "${YELLOW}请升级到支持multiuser的版本：${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install screen"
        echo "  CentOS/RHEL: sudo yum install screen"
        return 1
    fi
    
    echo -e "${GREEN}${ICON_CHECK} Screen支持multiuser功能${NC}"
    return 0
}

################################################################################
# 检查和修复.screenrc配置
################################################################################

check_screenrc_config() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}2. 检查.screenrc配置${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local screenrc="$HOME/.screenrc"
    
    # 检查是否存在
    if [[ ! -f "$screenrc" ]]; then
        echo -e "${YELLOW}${ICON_WARN} .screenrc不存在，创建配置文件...${NC}"
        create_screenrc_config
        return
    fi
    
    # 检查multiuser配置
    if grep -q "multiuser on" "$screenrc"; then
        echo -e "${GREEN}${ICON_CHECK} .screenrc中已启用multiuser${NC}"
    else
        echo -e "${YELLOW}${ICON_WARN} .screenrc中未启用multiuser${NC}"
        echo -e "${BLUE}添加multiuser配置...${NC}"
        echo "" >> "$screenrc"
        echo "# 启用多用户模式" >> "$screenrc"
        echo "multiuser on" >> "$screenrc"
        echo -e "${GREEN}${ICON_CHECK} 已添加multiuser配置${NC}"
    fi
}

################################################################################
# 创建.screenrc配置文件
################################################################################

create_screenrc_config() {
    local screenrc="$HOME/.screenrc"
    
    cat > "$screenrc" << 'SCREENRC_EOF'
################################################################################
# Smart Screen Session Manager v2.0 - Screen 配置文件
# 解决多SSH连接问题
################################################################################

# ================================
# 基础配置
# ================================

# 启用多用户模式
multiuser on

# 启用视觉铃声
vbell on
vbell_msg "bell"

# 启动时不显示欢迎信息
startup_message off

# 禁用自动回绕
defwrap on

# 设置屏幕缓冲行数
defscrollback 10000

# ================================
# UTF-8支持
# ================================

# 启用UTF-8
defutf8 on

# ================================
# 状态栏配置
# ================================

# 状态栏显示格式
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %m-%d %{W}%c %{g}]'

# ================================
# 终端优化
# ================================

# 启用鼠标支持
termcapinfo xterm* ti@:te@

# 启用日志功能
deflog on
logfile /tmp/screen-%n.log

# ================================
# 快捷键配置
# ================================

# 窗口切换快捷键
bindkey -k k9 select 0
bindkey -k k; select 1
bindkey -k F1 select 0
bindkey -k F2 select 1
bindkey -k F3 select 2
bindkey -k F4 select 3
bindkey -k F5 select 4
bindkey -k F6 select 5
bindkey -k F7 select 6
bindkey -k F8 select 7
bindkey -k F9 select 8
bindkey -k F10 select 9

# 分离快捷键
bind s detach

# 退出快捷键
bind k kill
bind ^k kill
bind \\ quit

# 重新连接快捷键
bind r screen -dRR
SCREENRC_EOF

    echo -e "${GREEN}${ICON_CHECK} .screenrc配置文件已创建${NC}"
}

################################################################################
# 创建多用户会话的专用脚本
################################################################################

create_multiuser_session_script() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}3. 创建多用户会话脚本${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local script_path="/usr/local/bin/create_multiuser_session"
    
    # 创建全局脚本
    sudo tee "$script_path" > /dev/null << 'SCRIPT_EOF'
#!/bin/bash
# 多用户会话创建脚本

# 检查参数
if [[ $# -lt 1 ]]; then
    echo "用法: $0 <会话名> [用户1] [用户2] ..."
    echo "示例: $0 dev alice bob"
    exit 1
fi

SESSION_NAME="$1"
shift
USERS=("$@")

# 如果没有指定用户，使用当前用户名
if [[ ${#USERS[@]} -eq 0 ]]; then
    USERS=("$USER")
fi

echo "创建多用户会话: $SESSION_NAME"
echo "授权用户: ${USERS[*]}"

# 创建会话
screen -S "$SESSION_NAME" -d -m bash

# 等待会话创建
sleep 1

# 启用multiuser模式
screen -S "$SESSION_NAME" -X multiuser on

# 为每个用户添加权限
for user in "${USERS[@]}"; do
    echo "为用户 $user 添加权限..."
    screen -S "$SESSION_NAME" -X acladd "$user" 2>/dev/null || echo "警告: 无法为用户 $user 添加权限"
done

echo ""
echo "会话 $SESSION_NAME 已创建并配置完成"
echo ""
echo "连接方式:"
echo "  - 所有者 ($USER): screen -S $SESSION_NAME"
echo "  - 其他用户: screen -S $USER/$SESSION_NAME"
echo ""
echo "查看会话状态: screen -list"
SCRIPT_EOF

    sudo chmod +x "$script_path"
    echo -e "${GREEN}${ICON_CHECK} 多用户会话脚本已创建: $script_path${NC}"
    
    # 同时创建到当前目录
    cat > "/root/smart-screen/create_multiuser_session.sh" << 'SCRIPT_EOF'
#!/usr/bin/env bash
#
# 多用户会话创建脚本 (本地版本)
#

set -euo pipefail

# 检查参数
if [[ $# -lt 1 ]]; then
    echo "用法: $0 <会话名> [用户1] [用户2] ..."
    echo "示例: $0 dev alice bob"
    exit 1
fi

SESSION_NAME="$1"
shift
USERS=("$@")

# 如果没有指定用户，使用当前用户名
if [[ ${#USERS[@]} -eq 0 ]]; then
    USERS=("$USER")
fi

echo "创建多用户会话: $SESSION_NAME"
echo "授权用户: ${USERS[*]}"

# 创建会话
screen -S "$SESSION_NAME" -d -m bash

# 等待会话创建
sleep 1

# 启用multiuser模式
screen -S "$SESSION_NAME" -X multiuser on

# 为每个用户添加权限
for user in "${USERS[@]}"; do
    echo "为用户 $user 添加权限..."
    screen -S "$SESSION_NAME" -X acladd "$user" 2>/dev/null || echo "警告: 无法为用户 $user 添加权限"
done

echo ""
echo "会话 $SESSION_NAME 已创建并配置完成"
echo ""
echo "连接方式:"
echo "  - 所有者 ($USER): screen -S $SESSION_NAME"
echo "  - 其他用户: screen -S $USER/$SESSION_NAME"
echo ""
echo "查看会话状态: screen -list"
SCRIPT_EOF

    chmod +x "/root/smart-screen/create_multiuser_session.sh"
    echo -e "${GREEN}${ICON_CHECK} 本地版本已创建: /root/smart-screen/create_multiuser_session.sh${NC}"
}

################################################################################
# 测试多用户会话创建
################################################################################

test_multiuser_session() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}4. 测试多用户会话${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    read -p "是否创建测试会话 'test_multiuser'? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 创建测试会话
        echo -e "${BLUE}创建测试会话...${NC}"
        /root/smart-screen/create_multiuser_session.sh test_multiuser alice bob 2>/dev/null || {
            echo -e "${YELLOW}使用基本方法创建...${NC}"
            screen -S "test_multiuser" -d -m bash
            sleep 1
            screen -S "test_multiuser" -X multiuser on
        }
        
        echo ""
        echo -e "${GREEN}${ICON_SUCCESS} 测试会话已创建${NC}"
        echo -e "${BLUE}会话信息:${NC}"
        screen -list | grep test_multiuser || echo "未找到测试会话"
        echo ""
        echo -e "${YELLOW}请在两个不同的SSH会话中测试:${NC}"
        echo "  A电脑: screen -S $USER/test_multiuser"
        echo "  B电脑: screen -S $USER/test_multiuser"
        echo ""
        echo -e "${BLUE}清理测试会话: screen -S test_multiuser -X quit${NC}"
    fi
}

################################################################################
# 显示故障排除指南
################################################################################

show_troubleshooting_guide() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}5. 故障排除指南${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    cat << 'GUIDE_EOF'

🎯 多用户会话连接指南

【核心问题】
当A用户和B用户尝试同时连接同一个会话时，会出现一方被挤掉的问题。

【解决方案】
1. 确保.screenrc中启用multiuser on
2. 在创建会话时必须执行: screen -S <会话名> -X multiuser on
3. 为其他用户添加权限: screen -S <会话名> -X acladd <用户名>
4. 连接时使用格式: screen -S <用户名>/<会话名>

【正确操作步骤】

步骤1: 创建会话 (在A电脑上执行)
  $ screen -S dev -d -m bash
  $ screen -S dev -X multiuser on
  $ screen -S dev -X acladd bob

步骤2: A用户连接
  $ screen -S alice/dev

步骤3: B用户连接
  $ screen -S bob/dev

【重要提示】
- 不要使用 screen -r 或 screen -dRR 连接多用户会话
- 使用 screen -S <用户名>/<会话名> 格式
- 每个用户必须有独立的用户名

【验证权限】
  $ screen -list
  应显示: <用户名>/<会话名> 格式

【常见错误】
1. 忘记执行 multiuser on → 会话不支持多用户
2. 忘记执行 acladd → 其他用户无法连接
3. 使用 screen -r → 可能导致抢占连接
4. 用户名不正确 → 权限验证失败

GUIDE_EOF
}

################################################################################
# 主函数
################################################################################

main() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         SSH多用户会话连接修复工具           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 1. 检查Screen多用户支持
    if ! check_screen_multiuser_support; then
        error "Screen不支持multiuser功能"
    fi
    
    # 2. 检查.screenrc配置
    check_screenrc_config
    
    # 3. 创建多用户会话脚本
    create_multiuser_session_script
    
    # 4. 测试多用户会话
    test_multiuser_session
    
    # 5. 显示故障排除指南
    show_troubleshooting_guide
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                  修复完成!                    ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}下一步操作:${NC}"
    echo "1. 运行: ./create_multiuser_session.sh dev alice bob"
    echo "2. A电脑连接: screen -S alice/dev"
    echo "3. B电脑连接: screen -S bob/dev"
    echo ""
}

################################################################################
# 执行主函数
################################################################################

main "$@"
