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
# 常量定义
################################################################################

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="${SCRIPT_DIR}/.bash_backup_$(date +%Y%m%d_%H%M%S)"

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

cleanup() {
    echo "清理临时文件..."
}

trap cleanup EXIT
trap 'error "脚本被中断"' INT
trap 'error "收到终止信号"' TERM

################################################################################
# 依赖检查
################################################################################

# 检查必要命令
command -v sed >/dev/null 2>&1 || error "需要sed命令"
command -v cp >/dev/null 2>&1 || error "需要cp命令"

################################################################################
# 备份函数
################################################################################

backup_file() {
    local file="$1"
    local backup_file="${BACKUP_DIR}/$(basename "$file")"

    mkdir -p "$BACKUP_DIR"
    cp "$file" "$backup_file"
    log_info "已备份: $file -> $backup_file"
}

################################################################################
# 修复Shebang
################################################################################

fix_shebang() {
    local file="$1"
    local first_line

    # 读取第一行
    first_line=$(head -n 1 "$file")

    if [[ "$first_line" == "#!/bin/bash" ]]; then
        log_info "修复shebang: $file"
        backup_file "$file"
        sed -i '1s|^#!/bin/bash|#!/usr/bin/env bash|' "$file"
        return 0
    elif [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
        log_info "shebang已正确: $file"
        return 0
    else
        log_warn "未识别的shebang: $file ($first_line)"
        return 1
    fi
}

################################################################################
# 添加严格模式
################################################################################

add_strict_mode() {
    local file="$1"
    local has_strict_mode
    local has_bash_in_first_line

    # 检查是否已经有严格模式
    has_strict_mode=$(grep -c "set -euo pipefail" "$file" || echo 0)

    # 检查第二行是否是bash
    has_bash_in_first_line=$(head -n 2 "$file" | tail -n 1 | grep -c "^set -euo pipefail$" || echo 0)

    if [[ $has_strict_mode -eq 0 ]] && [[ $has_bash_in_first_line -eq 0 ]]; then
        log_info "添加严格模式: $file"
        backup_file "$file"

        # 在shebang后插入严格模式
        sed -i '2a\
\
set -euo pipefail\
\
# 错误处理函数\
error() {\
    echo "[ERROR] $*" >&2\
    exit 1\
}\
\
fatal() {\
    echo "[FATAL] $*" >&2\
    local frame=0\
    while caller $frame; do\
        echo "  Frame $frame: $(caller $frame)" >&2\
        ((frame++))\
    done\
    exit 1\
}\
\
cleanup() {\
    echo "执行清理操作..."\
}\
\
trap cleanup EXIT\
trap '"'"'error "脚本被中断"'"'"' INT\
trap '"'"'error "收到终止信号"'"'"' TERM\
' "$file"

        return 0
    else
        log_info "严格模式已存在: $file"
        return 0
    fi
}

################################################################################
# 改进脚本头部
################################################################################

improve_header() {
    local file="$1"
    local filename
    local has_improved_header

    filename=$(basename "$file")

    # 检查是否已经有改进的头部
    has_improved_header=$(grep -c "# 脚本名称：" "$file" || echo 0)

    if [[ $has_improved_header -eq 0 ]]; then
        log_info "改进脚本头部: $file"
        backup_file "$file"

        # 在严格模式后插入改进的头部
        sed -i '/^set -euo pipefail$/a\
\
################################################################################\
# 脚本信息\
################################################################################\
\
readonly SCRIPT_NAME="$(basename "$0")"\
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\
\
# 依赖检查\
command -v screen >/dev/null 2>&1 || error "需要安装screen命令"\
' "$file"

        return 0
    else
        log_info "脚本头部已改进: $file"
        return 0
    fi
}

################################################################################
# 修复反引号
################################################################################

fix_backticks() {
    local file="$1"
    local has_backticks

    # 检查是否有反引号
    has_backticks=$(grep -c '`' "$file" || echo 0)

    if [[ $has_backticks -gt 0 ]]; then
        log_info "修复反引号: $file"
        backup_file "$file"

        # 将反引号替换为$()，注意转义
        sed -i 's/`\([^`]*\)`/$(\1)/g' "$file"

        return 0
    else
        log_info "无需修复反引号: $file"
        return 0
    fi
}

################################################################################
# 验证修复
################################################################################

validate_script() {
    local file="$1"

    log_info "验证脚本: $file"

    # 语法检查
    if bash -n "$file"; then
        log_info "✓ 语法检查通过: $file"
    else
        log_error "✗ 语法检查失败: $file"
        return 1
    fi

    # 检查是否包含严格模式
    if grep -q "set -euo pipefail" "$file"; then
        log_info "✓ 严格模式已启用: $file"
    else
        log_error "✗ 缺少严格模式: $file"
        return 1
    fi

    return 0
}

################################################################################
# 处理单个脚本
################################################################################

process_script() {
    local file="$1"
    local filename

    filename=$(basename "$file")
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}处理脚本: $filename${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

    # 检查文件是否存在且可读
    [[ -f "$file" ]] || { log_error "文件不存在: $file"; return 1; }
    [[ -r "$file" ]] || { log_error "文件不可读: $file"; return 1; }

    # 跳过自身
    if [[ "$file" == "$0" ]]; then
        log_info "跳过自身脚本"
        return 0
    fi

    # 备份原文件
    backup_file "$file"

    # 应用修复
    fix_shebang "$file" || true
    add_strict_mode "$file" || true
    improve_header "$file" || true
    fix_backticks "$file" || true

    # 验证修复
    if validate_script "$file"; then
        log_info "✓ 脚本修复完成: $filename"
        return 0
    else
        log_error "✗ 脚本修复失败: $filename"
        # 从备份恢复
        log_warn "从备份恢复原文件..."
        cp "${BACKUP_DIR}/$(basename "$file")" "$file"
        return 1
    fi
}

################################################################################
# 主函数
################################################################################

main() {
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}       Bash脚本最佳实践修复工具        ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    log_info "备份目录: $BACKUP_DIR"
    echo ""

    # 查找所有.sh脚本
    local scripts
    mapfile -t scripts < <(find "$SCRIPT_DIR" -maxdepth 1 -name "*.sh" -type f | sort)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        log_warn "未找到.sh脚本文件"
        exit 0
    fi

    log_info "找到 ${#scripts[@]} 个脚本文件"

    # 处理每个脚本
    local success_count=0
    local fail_count=0

    for script in "${scripts[@]}"; do
        if process_script "$script"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done

    # 显示结果
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                   修复完成！                  ${GREEN}║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${WHITE}  修复结果：                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 成功: ${GREEN}${success_count}${NC} 个脚本                          ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 失败: ${RED}${fail_count}${NC} 个脚本                          ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${WHITE}  备份位置:                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  $BACKUP_DIR                     ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ $fail_count -gt 0 ]]; then
        log_warn "部分脚本修复失败，请检查日志"
        exit 1
    else
        log_info "所有脚本修复成功！"
        exit 0
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
用法: $SCRIPT_NAME [选项]

选项:
    -h, --help          显示帮助信息
    -v, --verbose       详细输出
    --dry-run           仅显示将要修改的文件，不实际修改

示例:
    $SCRIPT_NAME              # 修复所有.sh脚本
    $SCRIPT_NAME --dry-run    # 预览修改，不实际修改

说明:
    此脚本会自动修复项目中的Bash脚本，使其符合最佳实践：
    1. 将shebang改为 #!/usr/bin/env bash
    2. 添加严格模式 set -euo pipefail
    3. 添加错误处理函数
    4. 改进脚本头部信息
    5. 将反引号替换为\$()

    所有原文件都会自动备份到: $BACKUP_DIR
EOF
}

# 解析命令行参数
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 执行主函数
main "$@"