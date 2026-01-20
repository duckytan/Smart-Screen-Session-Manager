#!/usr/bin/env bash
#
# Smart Screen Session Manager - 一键安装脚本
# 使用方法: curl -fsSL https://github.com/duckytan/Smart-Screen-Session-Manager/releases/download/2.0test/smart-screen.sh | bash
#
# 或者下载此文件后直接运行:
# chmod +x quick-install.sh && ./quick-install.sh
#

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 下载URL
DOWNLOAD_URL="https://github.com/duckytan/Smart-Screen-Session-Manager/releases/download/2.0test/smart-screen.sh"
INSTALL_DIR="$HOME"
SCRIPT_NAME="smart-screen.sh"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${WHITE}      Smart Screen Session Manager - 一键安装程序      ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查网络连接
echo -e "${YELLOW}🔍 检查网络连接...${NC}"
if curl -s --head --request GET "$DOWNLOAD_URL" | grep "200 OK" > /dev/null; then
    echo -e "${GREEN}✅ 网络连接正常${NC}"
else
    echo -e "${RED}❌ 无法连接到GitHub，请检查网络连接${NC}"
    exit 1
fi
echo ""

# 下载脚本
echo -e "${YELLOW}📥 正在下载脚本...${NC}"
echo -e "${BLUE}   来源: $DOWNLOAD_URL${NC}"
echo -e "${BLUE}   目标: $SCRIPT_PATH${NC}"
echo ""

if curl -fsSL -o "$SCRIPT_PATH" "$DOWNLOAD_URL"; then
    echo -e "${GREEN}✅ 下载完成${NC}"
else
    echo -e "${RED}❌ 下载失败${NC}"
    exit 1
fi
echo ""

# 设置执行权限
echo -e "${YELLOW}🔧 设置执行权限...${NC}"
chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}✅ 权限设置完成${NC}"
echo ""

# 验证脚本
echo -e "${YELLOW}🔍 验证脚本...${NC}"
if bash -n "$SCRIPT_PATH"; then
    echo -e "${GREEN}✅ 脚本语法正确${NC}"
else
    echo -e "${RED}❌ 脚本语法错误${NC}"
    rm -f "$SCRIPT_PATH"
    exit 1
fi
echo ""

# 显示成功信息
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${WHITE}                   安装完成！                        ${GREEN}║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${WHITE}  脚本位置: $SCRIPT_PATH${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${WHITE}  使用方法:                                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    cd ~                                              ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    ./smart-screen.sh                                 ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 询问是否立即运行
read -p "$(echo -e ${BLUE}"是否立即运行 Smart Screen Session Manager？ [Y/n]: "${NC})" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo ""
    echo -e "${YELLOW}🚀 启动 Smart Screen Session Manager...${NC}"
    echo ""
    exec "$SCRIPT_PATH"
else
    echo ""
    echo -e "${GREEN}👍 安装完成！${NC}"
    echo -e "${WHITE}   要运行脚本，请执行: ${BLUE}$SCRIPT_PATH${NC}"
fi
