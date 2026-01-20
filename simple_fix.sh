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
EOF

        # 跳过原文件的shebang行，追加剩余内容
        sed '1,/^################################################################################$/d' "$file" >> "$temp_file"

        # 替换原文件
        mv "$temp_file" "$file"

        # 验证语法
        if bash -n "$file" 2>/dev/null; then
            echo "  ✓ 成功修复"
        else
            echo "  ✗ 语法错误"
            # 恢复备份（如果有）
            if [ -f "${file}.bak" ]; then
                mv "${file}.bak" "$file"
                echo "  已恢复备份"
            fi
        fi
    fi
done

echo "=== 修复完成 ==="
