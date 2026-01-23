#!/bin/bash
#
# 服务器一键配置脚本 v2.0 (公开版本)
# 用于分享和开源的安全版本
#
# ⚠️  重要提醒：
#    - 本版本不包含任何API密钥或敏感信息
#    - 请在使用前手动配置所需的认证信息
#    - 仅供学习、测试和公开分享使用
#
# Copyright (c) 2026
#

# 启用严格模式
set -eo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

################################################################################
# 安全函数
################################################################################

# 安全读取输入
safe_read() {
    local prompt="$1"
    local default_value="${2:-}"
    local result=""

    if [ -t 0 ] && [ -t 1 ]; then
        # 交互式环境：正常读取用户输入
        read -r "$prompt" result
    else
        # 非交互式环境：使用默认值
        echo -n "$prompt" >&2
        result="$default_value"
    fi

    echo "$result"
}

# 检查网络连接
check_network() {
    if ! ping -c 1 google.com &>/dev/null; then
        echo -e "${RED}❌ 网络连接异常，请检查网络配置${NC}"
        return 1
    fi
    return 0
}

# 检查磁盘空间（至少需要2GB）
check_disk_space() {
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 2097152 ]; then  # 2GB in KB
        echo -e "${RED}❌ 磁盘空间不足，至少需要2GB可用空间${NC}"
        return 1
    fi
    return 0
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &>/dev/null
}

################################################################################
# 错误处理函数
################################################################################

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

################################################################################
# 安装函数
################################################################################

# 安装系统依赖
install_system_dependencies() {
    info "更新系统包..."
    if ! yum update -y; then
        error "系统更新失败，请检查网络连接和权限"
    fi
    success "系统更新完成"

    info "安装基础工具..."
    if ! yum install -y curl git wget unzip screen ca-certificates; then
        error "基础工具安装失败"
    fi
    success "基础工具安装完成"
}

# 安装NVM
install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        info "NVM 已存在，跳过安装"
        return 0
    fi

    info "安装 NVM..."
    if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash; then
        error "NVM 安装失败"
    fi

    # 加载NVM
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        source "$NVM_DIR/nvm.sh"
        success "NVM 安装并加载成功"
    else
        error "NVM 安装后无法加载，请重启shell"
    fi
}

# 安装Node.js
install_nodejs() {
    # 确保NVM已加载
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"

    if command_exists node; then
        local current_version=$(node --version)
        info "Node.js 已存在 (版本: $current_version)"
        if [[ "$current_version" =~ ^v20\. ]]; then
            info "Node.js 20.x 已安装"
            return 0
        fi
    fi

    info "安装 Node.js 20.x..."
    if ! nvm install 20; then
        error "Node.js 安装失败"
    fi

    if ! nvm use 20; then
        error "Node.js 版本切换失败"
    fi

    success "Node.js 20.x 安装完成"
}

# 安装GitHub CLI
install_github_cli() {
    if command_exists gh; then
        info "GitHub CLI 已安装"
        return 0
    fi

    info "安装 GitHub CLI..."
    if ! curl -fsSL https://cli.github.com/packages/rpm/gh.repo > /etc/yum.repos.d/gh.repo; then
        error "下载 GitHub CLI 仓库配置失败"
    fi

    if ! yum install -y gh; then
        error "GitHub CLI 安装失败"
    fi

    success "GitHub CLI 安装完成"
}

# 配置环境变量（公开版本）
setup_environment() {
    info "配置环境变量..."

    # 检查是否有现有的bashrc配置
    if [ -f ~/.bashrc ]; then
        # 创建带时间戳的备份
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        if cp ~/.bashrc "$backup_file" 2>/dev/null; then
            success "已备份 ~/.bashrc 到 $backup_file"
        else
            warning "备份 ~/.bashrc 失败，将继续配置"
        fi
    fi

    # 添加NVM配置
    cat >> ~/.bashrc << 'ENVEOF'

# ================================================================
# NVM (Node Version Manager) Configuration
# Added by server-setup.sh on $(date)
# ================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ================================================================
# 用户自定义环境变量
# 请手动添加您的API密钥和Token
# ================================================================
# export MINIMAX_API_KEY="your_api_key_here"
# export GH_TOKEN="your_github_token_here"
ENVEOF

    success "环境变量配置完成"
    echo ""
    echo -e "${YELLOW}⚠️  请手动配置以下认证信息：${NC}"
    echo -e "${WHITE}  1. GitHub Token: ${CYAN}export GH_TOKEN=\"your_token_here\"${NC}"
    echo -e "${WHITE}  2. MiniMax API Key: ${CYAN}export MINIMAX_API_KEY=\"your_api_key_here\"${NC}"
    echo ""
}

# GitHub认证（交互式）
github_auth() {
    if command_exists gh; then
        info "请完成 GitHub CLI 认证..."
        info "推荐使用以下方式之一："
        echo -e "  ${WHITE}1. 运行: ${CYAN}gh auth login${NC}"
        echo -e "  ${WHITE}2. 设置Token: ${CYAN}export GH_TOKEN=\"your_personal_access_token\"${NC}"
        echo ""
        if gh auth login 2>/dev/null; then
            success "GitHub CLI 认证完成"
        else
            warning "GitHub CLI 认证失败或已取消，请稍后手动运行 'gh auth login'"
        fi
    fi
}

# 交互式组件安装
interactive_installs() {
    info "可选组件安装..."

    # 宝塔面板安装
    local bt_install=$(safe_read "是否安装宝塔面板? (y/N): " "n")
    if [[ "$bt_install" =~ ^[Yy]$ ]]; then
        info "安装宝塔面板..."
        if ! command_exists wget; then
            yum install -y wget
        fi

        if wget -O install.sh https://download.bt.cn/src/install/install-6.0.sh &>/dev/null; then
            if bash install.sh ed8484bec &>/dev/null; then
                success "宝塔面板安装完成"
            else
                warning "宝塔面板安装失败"
            fi
        else
            warning "下载宝塔面板安装脚本失败"
        fi
    fi

    # Claude Code安装询问
    local claude_install=$(safe_read "是否安装 Claude Code (zcf)? (y/N): " "n")
    if [[ "$claude_install" =~ ^[Yy]$ ]]; then
        info "安装 Claude Code..."
        # 确保NVM已加载
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        source "$NVM_DIR/nvm.sh"

        if npx zcf &>/dev/null; then
            success "Claude Code 安装完成"
        else
            warning "Claude Code 安装失败，请稍后手动运行 'npx zcf'"
        fi
    fi
}

# 验证安装
verify_installation() {
    info "验证安装结果..."

    local errors=0

    # 检查 Node.js
    if command_exists node; then
        local node_version=$(node --version)
        success "Node.js: $node_version"
    else
        error "Node.js 未安装"
        ((errors++))
    fi

    # 检查 npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        success "npm: $npm_version"
    else
        error "npm 未安装"
        ((errors++))
    fi

    # 检查 GitHub CLI
    if command_exists gh; then
        local gh_version=$(gh --version | head -1)
        success "GitHub CLI: $gh_version"
    else
        warning "GitHub CLI 未安装"
    fi

    # 检查 NVM
    if [ -d "$HOME/.nvm" ]; then
        success "NVM: 已安装"
    else
        error "NVM 未安装"
        ((errors++))
    fi

    return $errors
}

################################################################################
# 主函数
################################################################################
main() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}          🚀 服务器一键配置脚本 v2.0            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}              (公开版本)                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}  ⚠️  本版本不包含任何API密钥或敏感信息      ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}  请使用前手动配置所需的认证信息            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}  ✅ 适用于分享、测试和开源项目            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 权限检查
    if [ "$EUID" -ne 0 ]; then
        error "请使用 root 用户运行此脚本"
    fi
    success "权限检查通过"

    # 系统检查
    info "检查系统环境..."
    if ! check_network; then
        error "网络连接检查失败"
    fi
    success "网络连接正常"

    if ! check_disk_space; then
        error "磁盘空间检查失败"
    fi
    success "磁盘空间充足"

    # 安装流程
    echo ""
    info "开始安装..."
    echo ""

    install_system_dependencies
    install_nvm
    install_nodejs
    install_github_cli
    setup_environment

    # 交互式安装
    echo ""
    interactive_installs

    # GitHub认证
    echo ""
    github_auth

    # 验证安装
    echo ""
    info "验证安装结果..."
    echo ""
    if verify_installation; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${WHITE}                ✅ 安装完成！                    ${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${WHITE}┌────────────────────────────────────────────────────────┐${NC}"
        echo -e "${WHITE}│${NC}  下一步操作:                                     ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}                                                    ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}  1. 配置认证信息:                                ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}     export GH_TOKEN=\"your_github_token\"           ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}     export MINIMAX_API_KEY=\"your_api_key\"        ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}                                                    ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}  2. 重载配置:                                   ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}     source ~/.bashrc && nvm use 20                ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}                                                    ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}  3. 启动 Claude Code:                             ${WHITE}│${NC}"
        echo -e "${WHITE}│${NC}     claude                                      ${WHITE}│${NC}"
        echo -e "${WHITE}└────────────────────────────────────────────────────────┘${NC}"
    else
        error "安装验证失败，请检查上述错误信息"
    fi
}

# 执行主函数
main "$@"
