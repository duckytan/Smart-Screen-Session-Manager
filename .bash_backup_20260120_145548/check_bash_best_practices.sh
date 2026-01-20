#!/usr/bin/env bash
#
# 脚本名称：Bash脚本最佳实践检查工具
# 描述：检查项目中的Bash脚本是否符合最佳实践
# 作者：Claude Code
# 创建日期：2024-01-20
# 版本：1.0
#
set -euo pipefail

################################################################################
# 常量定义
################################################################################

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# 计数器
TOTAL_SCRIPTS=0
PASSED_SCRIPTS=0
FAILED_SCRIPTS=0

################################################################################
# 错误处理函数
################################################################################

error() {
    echo "[ERROR] $*" >&2
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

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $*"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $*"
}

################################################################################
# 检查函数
################################################################################

check_shebang() {
    local file="$1"
    local first_line

    first_line=$(head -n 1 "$file")

    if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
        log_pass "✓ 正确的shebang"
        return 0
    elif [[ "$first_line" == "#!/bin/bash" ]]; then
        log_fail "✗ 使用了硬编码路径 #!/bin/bash，应使用 #!/usr/bin/env bash"
        return 1
    else
        log_warn "⚠ 未识别的shebang: $first_line"
        return 1
    fi
}

check_strict_mode() {
    local file="$1"

    if grep -q "set -euo pipefail" "$file"; then
        log_pass "✓ 启用了严格模式"
        return 0
    else
        log_fail "✗ 未启用严格模式 (set -euo pipefail)"
        return 1
    fi
}

check_error_handling() {
    local file="$1"

    if grep -q "error()" "$file" || grep -q "fatal()" "$file"; then
        log_pass "✓ 包含错误处理函数"
        return 0
    else
        log_warn "⚠ 未找到错误处理函数"
        return 1
    fi
}

check_readonly() {
    local file="$1"
    local readonly_count

    readonly_count=$(grep -c "readonly " "$file" || echo 0)

    if [[ $readonly_count -gt 0 ]]; then
        log_pass "✓ 使用了readonly定义常量 ($readonly_count 处)"
        return 0
    else
        log_warn "⚠ 未使用readonly定义常量"
        return 1
    fi
}

check_local_vars() {
    local file="$1"
    local function_count
    local local_count

    # 检查是否有函数
    function_count=$(grep -c "^[a-z_].*() {" "$file" || echo 0)

    if [[ $function_count -gt 0 ]]; then
        local_count=$(grep -c "local " "$file" || echo 0)

        if [[ $local_count -gt 0 ]]; then
            log_pass "✓ 函数中使用了local关键字 ($local_count 处)"
            return 0
        else
            log_fail "✗ 函数中未使用local关键字（可能导致变量污染）"
            return 1
        fi
    else
        log_pass "○ 跳过（无函数定义）"
        return 0
    fi
}

check_quotation() {
    local file="$1"
    local issues

    # 检查常见的未引用变量
    issues=$(grep -E '\$[a-zA-Z_][a-zA-Z0-9_]*[^")}\s]*[^\s]' "$file" | grep -v '"' | wc -l || echo 0)

    if [[ $issues -eq 0 ]]; then
        log_pass "✓ 变量引用基本正确"
        return 0
    else
        log_warn "⚠ 可能存在未引用的变量引用"
        return 1
    fi
}

check_backticks() {
    local file="$1"
    local backtick_count

    backtick_count=$(grep -c '`' "$file" || echo 0)

    if [[ $backtick_count -eq 0 ]]; then
        log_pass "✓ 未使用反引号（使用了现代的\$()语法）"
        return 0
    else
        log_warn "⚠ 仍在使用反引号（建议使用\$()）"
        return 1
    fi
}

check_syntax() {
    local file="$1"

    if bash -n "$file" 2>/dev/null; then
        log_pass "✓ 语法检查通过"
        return 0
    else
        log_fail "✗ 语法错误"
        return 1
    fi
}

################################################################################
# 检查单个脚本
################################################################################

check_script() {
    local file="$1"
    local filename
    local score
    local checks_passed
    local checks_total

    filename=$(basename "$file")
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}检查脚本: $filename${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

    checks_passed=0
    checks_total=8

    # 执行所有检查
    check_shebang "$file" && ((checks_passed++))
    echo ""
    check_strict_mode "$file" && ((checks_passed++))
    echo ""
    check_error_handling "$file" && ((checks_passed++))
    echo ""
    check_readonly "$file" && ((checks_passed++))
    echo ""
    check_local_vars "$file" && ((checks_passed++))
    echo ""
    check_quotation "$file" && ((checks_passed++))
    echo ""
    check_backticks "$file" && ((checks_passed++))
    echo ""
    check_syntax "$file" && ((checks_passed++))

    # 计算分数
    score=$((checks_passed * 100 / checks_total))

    # 显示结果
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    if [[ $score -eq 100 ]]; then
        echo -e "${GREEN}✓ 完全符合最佳实践 ($checks_passed/$checks_total)${NC}"
    elif [[ $score -ge 80 ]]; then
        echo -e "${GREEN}✓ 基本符合最佳实践 ($checks_passed/$checks_total)${NC}"
    elif [[ $score -ge 60 ]]; then
        echo -e "${YELLOW}⚠ 部分符合最佳实践 ($checks_passed/$checks_total)${NC}"
    else
        echo -e "${RED}✗ 严重不符合最佳实践 ($checks_passed/$checks_total)${NC}"
    fi
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

    ((TOTAL_SCRIPTS++))

    if [[ $score -ge 80 ]]; then
        ((PASSED_SCRIPTS++))
        return 0
    else
        ((FAILED_SCRIPTS++))
        return 1
    fi
}

################################################################################
# 主函数
################################################################################

main() {
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}       Bash脚本最佳实践检查工具        ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 查找所有.sh脚本
    local scripts
    mapfile -t scripts < <(find "$SCRIPT_DIR" -maxdepth 1 -name "*.sh" -type f | sort)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        log_warn "未找到.sh脚本文件"
        exit 0
    fi

    log_info "找到 ${#scripts[@]} 个脚本文件"
    echo ""

    # 检查每个脚本
    for script in "${scripts[@]}"; do
        check_script "$script"
    done

    # 显示汇总结果
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                   检查完成！                  ${GREEN}║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${WHITE}  检查结果：                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 总脚本数: ${TOTAL_SCRIPTS}                                 ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 符合标准: ${GREEN}${PASSED_SCRIPTS}${NC}                               ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  • 需要改进: ${RED}${FAILED_SCRIPTS}${NC}                               ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"

    local pass_rate=0
    if [[ $TOTAL_SCRIPTS -gt 0 ]]; then
        pass_rate=$((PASSED_SCRIPTS * 100 / TOTAL_SCRIPTS))
    fi

    echo -e "${GREEN}║${NC}  • 符合率: ${pass_rate}%                                  ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"

    if [[ $pass_rate -eq 100 ]]; then
        echo -e "${GREEN}║${WHITE}  🎉 所有脚本都符合最佳实践！                       ${GREEN}║${NC}"
    elif [[ $pass_rate -ge 80 ]]; then
        echo -e "${GREEN}║${WHITE}  ✓ 大部分脚本符合最佳实践                    ${GREEN}║${NC}"
    else
        echo -e "${YELLOW}║${WHITE}  ⚠ 建议使用修复工具改进脚本                  ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}     运行: bash fix_bash_scripts.sh               ${GREEN}║${NC}"
    fi

    echo -e "${GREEN}║${NC}                                                            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 退出码
    if [[ $FAILED_SCRIPTS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
用法: $SCRIPT_NAME [选项]

选项:
    -h, --help          显示帮助信息

示例:
    $SCRIPT_NAME              # 检查所有.sh脚本

说明:
    此脚本会检查项目中的Bash脚本是否符合最佳实践：
    1. Shebang检查
    2. 严格模式检查
    3. 错误处理函数检查
    4. readonly使用检查
    5. 局部变量检查
    6. 引号使用检查
    7. 反引号使用检查
    8. 语法检查

检查项目基于: bash脚本编写心得.md
EOF
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
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