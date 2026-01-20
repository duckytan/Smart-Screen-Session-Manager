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
# Screen Multiuser 快速设置脚本
# 用于快速配置 screen 多用户环境
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}        Screen Multiuser 快速配置向导              ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查 root 权限
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}警告: 你正在以 root 用户运行${NC}"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查 screen 安装
if ! command -v screen &>/dev/null; then
    echo -e "${RED}错误: screen 未安装${NC}"
    echo ""
    echo "请先安装 screen:"
    echo "  Ubuntu/Debian: sudo apt-get install screen"
    echo "  CentOS/RHEL:    sudo yum install screen"
    echo "  macOS:          brew install screen"
    exit 1
fi

# 检查 screen 版本
echo -e "${BLUE}1. 检查 screen 版本...${NC}"
SCREEN_VERSION=$(screen -v | head -1)
echo -e "   $SCREEN_VERSION"

# 检查 multiuser 支持
if ! screen -v | grep -q "multiuser"; then
    echo -e "${RED}错误: 你的 screen 版本不支持 multiuser 功能${NC}"
    echo "请升级到支持 multiuser 的版本"
    exit 1
fi
echo -e "${GREEN}✓ multiuser 功能支持检查通过${NC}"
echo ""

# 配置 .screenrc
echo -e "${BLUE}2. 配置 .screenrc 文件...${NC}"

SCREENRC="$HOME/.screenrc"
SCREENRC_BACKUP="$HOME/.screenrc.backup.$(date +%Y%m%d_%H%M%S)"

# 备份现有配置
if [ -f "$SCREENRC" ]; then
    echo -e "${YELLOW}备份现有配置到: $SCREENRC_BACKUP${NC}"
    cp "$SCREENRC" "$SCREENRC_BACKUP"
fi

# 检查是否已存在 multiuser on
if grep -q "multiuser on" "$SCREENRC" 2>/dev/null; then
    echo -e "${GREEN}✓ multiuser 已启用${NC}"
else
    echo -e "${YELLOW}添加 multiuser 配置...${NC}"
    cat >> "$SCREENRC" << 'EOF'

################################################################################
# Multiuser Configuration - 多用户配置
################################################################################
# 启用多用户模式，允许其他用户访问此用户的会话
multiuser on

# 默认多用户权限设置
# 注意：实际权限需要在会话中通过 acladd 命令设置
EOF
    echo -e "${GREEN}✓ multiuser 配置已添加${NC}"
fi

# 添加快捷键配置（如果不存在）
if ! grep -q "bindkey -k k9 select 0" "$SCREENRC" 2>/dev/null; then
    echo -e "${YELLOW}添加快捷键配置...${NC}"
    cat >> "$SCREENRC" << 'EOF'

# 快捷键配置
# F1-F10 快速切换窗口
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

EOF
    echo -e "${GREEN}✓ 快捷键配置已添加${NC}"
fi

echo ""

# 创建示例多用户会话
echo -e "${BLUE}3. 创建示例多用户会话...${NC}"
read -p "是否创建一个示例会话? (Y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    SESSION_NAME="demo"
    echo -e "${YELLOW}创建示例会话: $SESSION_NAME${NC}"

    # 创建会话
    screen -S "$SESSION_NAME" -d -m bash 2>/dev/null

    # 启用多用户模式
    screen -S "$SESSION_NAME" -X multiuser on 2>/dev/null

    # 提示用户添加其他用户
    echo ""
    echo -e "${CYAN}示例会话 '$SESSION_NAME' 已创建${NC}"
    echo ""
    echo -e "${YELLOW}添加用户权限:${NC}"
    echo "  格式: screen -S $SESSION_NAME -X acladd <username>"
    echo "  示例: screen -S $SESSION_NAME -X acladd alice"
    echo "        screen -S $SESSION_NAME -X acladd bob"
    echo ""
    echo -e "${CYAN}连接命令:${NC}"
    echo "  所有者: screen -S ${USER}/$SESSION_NAME"
    echo "  其他用户: screen -S username/$SESSION_NAME"
    echo ""
fi

# 显示使用说明
echo -e "${BLUE}4. 安装辅助工具...${NC}"

# 复制 multiuser_helper.sh 到 PATH
HELPER_PATH="$HOME/.local/bin/multiuser_helper.sh"
mkdir -p "$HOME/.local/bin"

if [ -f "$(dirname $0)/multiuser_helper.sh" ]; then
    cp "$(dirname $0)/multiuser_helper.sh" "$HELPER_PATH"
    chmod +x "$HELPER_PATH"
    echo -e "${GREEN}✓ 辅助工具已安装到: $HELPER_PATH${NC}"

    # 添加到 PATH（如果不存在）
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# 添加 multiuser_helper 到 PATH" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
        echo -e "${YELLOW}已将 ~/.local/bin 添加到 PATH${NC}"
    fi

    echo ""
    echo -e "${CYAN}使用辅助工具:${NC}"
    echo "  创建会话: $HELPER_PATH create dev alice,bob"
    echo "  连接会话: $HELPER_PATH connect alice dev"
    echo "  查看帮助: $HELPER_PATH help"
    echo ""
fi

# 复制配置指南
GUIDE_PATH="$HOME/Documents/Screen_Multiuser_Guide.md"
mkdir -p "$HOME/Documents"

if [ -f "$(dirname $0)/MULTIUSER_SETUP.md" ]; then
    cp "$(dirname $0)/MULTIUSER_SETUP.md" "$GUIDE_PATH"
    echo -e "${GREEN}✓ 配置指南已保存到: $GUIDE_PATH${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                  配置完成!                          ${GREEN}║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}                                                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  下一步操作:                                           ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  1. 创建多用户会话:                                     ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}     screen -S <会话名> -d -m                            ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}     screen -S <会话名> -X multiuser on                  ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}     screen -S <会话名> -X acladd <username>             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  2. 其他用户连接:                                       ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}     screen -S <username>/<会话名>                       ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  3. 使用辅助工具（如果已安装）:                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}     multiuser_helper.sh create dev alice,bob             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  详细文档: $GUIDE_PATH${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                        ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 重新加载 .bashrc
read -p "是否现在重新加载 .bashrc 以应用 PATH 更改? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    source "$HOME/.bashrc"
    echo -e "${GREEN}✓ .bashrc 已重新加载${NC}"
fi

echo ""
echo -e "${CYAN}配置完成! 开始使用多用户 screen 会话吧! 🚀${NC}"
