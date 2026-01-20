# Bash脚本编写心得

## 目录
- [简介](#简介)
- [基础概念](#基础概念)
- [最佳实践](#最佳实践)
- [错误处理](#错误处理)
- [函数编写](#函数编写)
- [变量和数据结构](#变量和数据结构)
- [输入输出处理](#输入输出处理)
- [文本处理](#文本处理)
- [系统管理自动化](#系统管理自动化)
- [测试和调试](#测试和调试)
- [性能优化](#性能优化)
- [安全最佳实践](#安全最佳实践)
- [常见模式和模板](#常见模式和模板)
- [CentOS特定技巧](#centos特定技巧)
- [参考资源](#参考资源)

---

## 简介

Bash（Bourne Again Shell）是Linux系统中最常用的Shell之一，也是CentOS等RHEL系发行版的默认Shell。Bash脚本编写是系统管理员和DevOps工程师的必备技能，它能够极大地提高日常工作效率，实现任务自动化。

### 为什么需要学习Bash脚本？

1. **系统管理**：自动化日常运维任务，如备份、监控、日志轮转
2. **部署自动化**：快速部署应用、配置环境
3. **任务调度**：结合cron实现定时任务
4. **效率提升**：减少重复性工作，避免人为错误
5. **问题诊断**：快速收集系统信息、排查故障

### Bash的特点

- **优势**：
  - 与命令行无缝衔接，可以直接使用Linux命令
  - 学习曲线相对平缓
  - 几乎所有Linux系统都预装
  - 适合编写短小精悍的自动化脚本
  - 进程管理能力强，适合系统级操作

- **局限**：
  - 不是强类型语言，需要注意变量类型
  - 某些复杂数据处理不如Python/Perl方便
  - 错误处理机制相对简单
  - 性能在某些场景下不如编译型语言
  - 不适合编写大型应用程序

**何时选择Bash**：当任务主要是系统操作、文件处理、命令组合时，Bash是最佳选择。当需要复杂数据处理、图形界面或网络编程时，考虑使用Python等高级语言。

---

## 基础概念

### Shebang和脚本开头

每个Bash脚本应该以shebang开头，指定脚本的解释器：

```bash
#!/bin/bash
# 或使用env查找
#!/usr/bin/env bash
```

**推荐使用`#!/usr/bin/env bash`的原因**：
- 更加便携，能够自动找到系统中bash的位置
- 不需要硬编码bash的绝对路径

### 执行权限和运行

```bash
# 添加执行权限
chmod +x script.sh

# 运行脚本
./script.sh

# 使用bash解释器运行（不需要执行权限）
bash script.sh

# 在当前shell中运行（会导入脚本中的函数和变量）
source script.sh
# 或
. script.sh
```

### 基本语法规则

```bash
# 注释
# 这是单行注释

# 变量赋值（等号两边不能有空格）
NAME="value"

# 使用变量（需要加$符号）
echo $NAME

# 字符串引用
echo "My name is $NAME"  # 双引号会解析变量
echo 'My name is $NAME'  # 单引号不会解析变量

# 命令替换
CURRENT_DATE=$(date +%Y-%m-%d)
# 或
CURRENT_DATE=`date +%Y-%m-%d`

# 算术运算
result=$((5 + 3))
result=$((result * 2))
```

### 退出状态码

每个命令执行后都会返回一个退出状态码：

```bash
# 0表示成功，非0表示失败
echo $?

# 自定义退出状态码
exit 0   # 成功
exit 1   # 一般错误
exit 2   # 命令用法错误
exit 126 # 命令无法执行
exit 127 # 命令找不到
exit 128 # 无效的退出参数
```

---

## 最佳实践

### 1. 始终使用严格模式

在脚本开头添加以下内容，启用严格模式：

```bash
#!/usr/bin/env bash
set -euo pipefail

# -e: 任何命令失败时立即退出
# -u: 使用未定义的变量时报错
# -o pipefail: 管道中任何命令失败时退出
```

**详细解释**：

```bash
#!/usr/bin/env bash

# 启用所有安全检查
set -euo pipefail

# 可选：调试模式（输出每个命令）
# set -x

# 错误处理函数
error_exit() {
    echo "错误: $1" >&2
    exit 1
}

# 使用变量时检查是否为空
: "${VAR_NAME:?变量未设置}"
```

### 2. 使用有意义的变量名和注释

```bash
# ✅ 好的命名
BACKUP_DIR="/var/backups/mysql"
MAX_RETRIES=3
LOG_FILE_PATH="/var/log/app/error.log"

# ❌ 不好的命名
a=1
xx=10
fff="/path/to/file"
```

### 3. 脚本结构模板

```bash
#!/usr/bin/env bash
#
# 脚本名称：系统健康检查脚本
# 描述：检查系统关键服务的运行状态
# 作者：Your Name
# 创建日期：2024-01-20
# 版本：1.0
#

set -euo pipefail

# 全局常量
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/${SCRIPT_NAME}.log"

# 颜色定义（增强可读性）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# 帮助信息
show_help() {
    cat << EOF
用法: $SCRIPT_NAME [选项]

选项:
    -h, --help      显示帮助信息
    -v, --verbose   详细输出
    -q, --quiet     安静模式
EOF
}

# 解析命令行参数
parse_args() {
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
            -q|--quiet)
                QUIET=true
                shift
                ;;
            *)
                echo "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 主函数
main() {
    parse_args "$@"
    
    log_info "脚本开始执行"
    
    # 主逻辑
    echo "执行任务..."
    
    log_info "脚本执行完成"
}

# 执行主函数
main "$@"
```

### 4. 使用readonly定义常量

```bash
readonly CONFIG_FILE="/etc/myapp/config.conf"
readonly APP_PORT=8080
readonly MAX_CONNECTIONS=100
```

### 5. 函数定义和使用

```bash
# 函数定义
check_service() {
    local service_name="$1"
    local max_retries="${2:-3}"
    
    if systemctl is-active --quiet "$service_name"; then
        echo "服务 $service_name 正在运行"
        return 0
    else
        echo "服务 $service_name 未运行"
        return 1
    fi
}

# 调用函数
check_service "nginx" || systemctl start nginx
```

---

## 错误处理

### 使用set -euo pipefail

这是Bash脚本安全的基础：

```bash
#!/usr/bin/env bash
set -euo pipefail

# -e: 命令返回非零状态码时立即退出
# -u: 使用未定义变量时报错
# -o pipefail: 管道中任何命令失败时整个管道失败
```

### trap捕获信号和错误

```bash
#!/usr/bin/env bash
set -euo pipefail

# 清理函数
cleanup() {
    echo "执行清理操作..."
    rm -f /tmp/temp_file_$$
}

# 陷阱设置
trap cleanup EXIT      # 脚本退出时执行
trap cleanup SIGINT    # Ctrl+C中断
trap cleanup SIGTERM   # 终止信号

# 也可以只捕获错误
error_handler() {
    echo "发生错误，退出码: $?"
    exit 1
}

trap error_handler ERR
```

### 条件测试

```bash
# 字符串测试
if [[ -z "$string" ]]; then
    echo "字符串为空"
fi

if [[ -n "$string" ]]; then
    echo "字符串不为空"
fi

if [[ "$a" == "$b" ]]; then
    echo "相等"
fi

# 数值比较（使用-eq, -lt, -gt等）
if [[ $num1 -lt $num2 ]]; then
    echo "num1 < num2"
fi

# 文件测试
if [[ -f "/path/to/file" ]]; then
    echo "是普通文件"
fi

if [[ -d "/path/to/dir" ]]; then
    echo "是目录"
fi

if [[ -r "/path/to/file" ]]; then
    echo "可读"
fi

# 组合条件
if [[ -f "$file" ]] && [[ -r "$file" ]]; then
    echo "文件存在且可读"
fi
```

### 安全的命令执行

```bash
# ❌ 危险写法（set -e下会直接退出）
result=$(command_that_might_fail)

# ✅ 安全写法1：检查命令是否成功
if command_that_might_fail; then
    result=$(command_that_might_fail)
fi

# ✅ 安全写法2：使用||允许失败
result=$(command_that_might_fail) || true

# ✅ 安全写法3：设置忽略错误
set +e
result=$(command_that_might_fail)
set -e

# ✅ 安全写法4：使用条件判断
output=$(grep "pattern" file.txt) && echo "找到" || echo "未找到"
```

### 自定义错误处理函数

```bash
#!/usr/bin/env bash
set -euo pipefail

# 错误处理函数
error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# 致命错误（打印调用栈）
fatal() {
    echo "[FATAL] $*" >&2
    echo "调用栈:" >&2
    local frame=0
    while caller $frame; do
        echo "  Frame $frame: $(caller $frame)" >&2
        ((frame++))
    done
    exit 1
}

# 使用示例
[[ -f "$config_file" ]] || error "配置文件不存在: $config_file"

# 检查命令是否存在
command -v jq >/dev/null 2>&1 || error "需要安装jq命令"
```

---

## 函数编写

### 基本函数定义

```bash
# 方式1：function关键字（可省略）
function get_system_info() {
    echo "主机名: $(hostname)"
    echo "系统: $(uname -s)"
    echo "内核: $(uname -r)"
}

# 方式2：直接定义（推荐）
get_system_info() {
    echo "主机名: $(hostname)"
    echo "系统: $(uname -s)"
}

# 调用函数
get_system_info
```

### 函数参数

```bash
# 函数通过位置参数获取参数
process_file() {
    local input_file="$1"
    local output_file="$2"
    local verbose="${3:-false}"  # 默认值为false
    
    if [[ "$verbose" == "true" ]]; then
        echo "处理文件: $input_file -> $output_file"
    fi
    
    # 处理逻辑
    cat "$input_file" > "$output_file"
}

# 调用函数
process_file "input.txt" "output.txt" "true"

# 获取所有参数
show_args() {
    echo "参数数量: $#"
    echo "所有参数: $@"
    echo "逐个打印:"
    for arg in "$@"; do
        echo "  - $arg"
    done
}

# 使用$@而不是$*，保留参数边界
```

### 局部变量

```bash
# 使用local声明局部变量
calculate_sum() {
    local a="$1"
    local b="$2"
    local result=$((a + b))
    echo "$result"
}

# 全局变量陷阱示例
counter=0

increment_counter() {
    # 不加local会修改全局变量
    counter=$((counter + 1))
}

increment_counter_safe() {
    local counter=0
    counter=$((counter + 1))
    echo "$counter"
}
```

### 返回值

Bash函数只能返回状态码（0-255），返回值通过echo输出：

```bash
# 返回状态码
check_file() {
    if [[ -f "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# 调用并检查
if check_file "test.txt"; then
    echo "文件存在"
fi

# 返回字符串值
get_user_by_id() {
    local id="$1"
    local username
    
    # 查询逻辑
    username=$(grep "^$id:" /etc/passwd | cut -d: -f5)
    
    echo "$username"
}

# 获取返回值
user=$(get_user_by_id 1000)
echo "用户名: $user"

# 返回多个值
get_system_stats() {
    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    local mem=$(free -m | awk '/Mem:/ {print $3}')
    local disk=$(df -h / | awk '/\// {print $5}')
    
    # 使用echo输出多个值，用换行分隔
    echo "$cpu"
    echo "$mem"
    echo "$disk"
}

# 读取多个返回值
read cpu mem disk < <(get_system_stats)
echo "CPU: $cpu%, 内存: ${mem}MB, 磁盘: $disk"
```

### 递归函数

```bash
# 计算阶乘
factorial() {
    local n="$1"
    if (( n <= 1 )); then
        echo 1
    else
        local prev
        prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}

# 遍历目录
traverse_dir() {
    local dir="$1"
    local indent="${2:-0}"
    
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            echo "$(printf '%*s' $indent '')$item/"
            traverse_dir "$item" $((indent + 2))
        else
            echo "$(printf '%*s' $indent '')$item"
        fi
    done
}
```

---

## 变量和数据结构

### 变量类型和作用域

```bash
#!/usr/bin/env bash
set -euo pipefail

# 全局变量（默认）
GLOBAL_VAR="全局变量"

# 局部变量（函数内）
my_function() {
    local local_var="局部变量"
    echo "$local_var"
}

# 常量（只读）
readonly CONST_VAR="常量值"
# CONST_VAR="新值"  # 会报错

# 环境变量导出
export EXPORTED_VAR="可被子进程访问"
```

### 数组

```bash
#!/usr/bin/env bash

# 定义数组
fruits=("apple" "banana" "cherry")

# 访问元素
echo "${fruits[0]}"  # apple
echo "${fruits[-1]}"  # cherry（最后一个）

# 数组长度
echo "${#fruits[@]}"  # 3

# 遍历数组
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# 添加元素
fruits+=("date")
fruits+=(["new_key"]="value")

# 切片
echo "${fruits[@]:1:2}"  # banana cherry

# 数组作为参数传递
process_array() {
    local -a arr=("$@")
    for item in "${arr[@]}"; do
        echo "$item"
    done
}

process_array "${fruits[@]}"

# 读取文件到数组
mapfile -t lines < file.txt
# 或
while IFS= read -r line; do
    lines+=("$line")
done < file.txt
```

### 关联数组（字典）

需要Bash 4.0+：

```bash
#!/usr/bin/env bash

# 声明关联数组
declare -A user_info

# 设置键值对
user_info["name"]="张三"
user_info["age"]="25"
user_info["city"]="北京"

# 获取值
echo "${user_info[name]}"
echo "${user_info[age]}"

# 遍历键值对
for key in "${!user_info[@]}"; do
    echo "$key: ${user_info[$key]}"
done

# 检查键是否存在
if [[ -v user_info[email] ]]; then
    echo "邮箱存在"
fi

# 删除键
unset user_info[age]

# 转换为JSON格式
array_to_json() {
    local -A arr=("$@")
    local first=true
    echo "{"
    for key in "${!arr[@]}"; do
        [[ $first == false ]] && echo ","
        first=false
        echo -n "  \"$key\": \"${arr[$key]}\""
    done
    echo ""
    echo "}"
}

array_to_json "${user_info[@]}"
```

### 字符串处理

```bash
#!/usr/bin/env bash

string="Hello, World!"

# 长度
echo ${#string}

# 子字符串
echo ${string:7}      # World!
echo ${string:7:5}    # World

# 查找和替换
echo ${string/World/Bash}  # 替换第一个
echo ${string//o/a}        # 替换所有

# 去除前缀后缀
path="/home/user/file.txt"
echo ${path##*/}  # file.txt（去除最长匹配前缀）
echo ${path%/*}   # /home/user（去除最长匹配后缀）

# 大小写转换
echo ${string^^}  # HELLO, WORLD!
echo ${string,,}  # hello, world!

# 分割字符串
IFS=',' read -ra parts <<< "a,b,c,d"
for part in "${parts[@]}"; do
    echo "$part"
done

# 字符串连接
str1="Hello"
str2="World"
combined="$str1 $str2"
```

---

## 输入输出处理

### 参数解析

```bash
#!/usr/bin/env bash
set -euo pipefail

# 基本参数解析
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
        -f|--file)
            FILE="$2"
            shift 2
            ;;
        -*)
            echo "未知选项: $1"
            exit 1
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

# 恢复位置参数
set -- "${POSITIONAL[@]}"
```

### 使用getopts解析短选项

```bash
#!/usr/bin/env bash

# 选项字符串：冒号表示需要参数
OPTSTRING=":hf:v"

while getopts "$OPTSTRING" opt; do
    case $opt in
        h)
            echo "帮助信息"
            ;;
        f)
            FILE="$OPTARG"
            echo "文件: $FILE"
            ;;
        v)
            VERBOSE=true
            ;;
        :)
            echo "选项 -$OPTARG 需要参数"
            exit 1
            ;;
        \?)
            echo "无效选项: -$OPTARG"
            exit 1
            ;;
    esac
done
```

### 使用getopt解析长选项

```bash
#!/usr/bin/env bash

# 使用getopt支持长选项
OPTIONS=$(getopt -o hf:v -l help,file:,verbose -n "$0" -- "$@")
eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -h|--help)
            echo "帮助信息"
            exit 0
            ;;
        -f|--file)
            FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done
```

### Here Document

```bash
# 多行字符串输出
cat << EOF
这是一个多行字符串。
变量会被解析: $HOME
命令也会执行: $(date)
EOF

# 禁用变量解析
cat << 'EOF'
这是原样输出。
$HOME 不会被解析
$(date) 也不会执行
EOF

# 动态生成配置
generate_config() {
    local app_name="$1"
    local port="$2"
    
    cat << CONFIG
# $app_name 配置文件
app_name="$app_name"
port=$port
debug=true
log_level="INFO"
CONFIG
}

generate_config "myapp" 8080 > config.txt
```

### Here String

```bash
# 单行输入
read -r name <<< "John Doe"
echo "$name"

# 作为命令输入
grep "pattern" <<< "$text_content"

# bc计算
result=$(bc <<< "scale=2; 10/3")
echo "$result"
```

### 文件描述符

```bash
#!/usr/bin/env bash

# 重定向文件描述符
exec 3> output.txt   # 文件描述符3指向输出文件
echo "发送到FD 3" >&3

exec 4< input.txt    # 文件描述符4指向输入文件
read -r line <&4

# 关闭文件描述符
exec 3>&-

# 标准错误重定向
command 2> error.log
command 2>&1 | tee output.log  # 同时输出到stdout和日志

# 静默输出（丢弃）
command > /dev/null 2>&1

# 错误输出到文件，标准输出到终端
command 2> error.log

# 使用tee同时输出到文件和屏幕
command | tee /tmp/output.log
```

---

## 文本处理

### grep命令

```bash
# 基本搜索
grep "pattern" file.txt

# 递归搜索
grep -r "pattern" /path/to/dir

# 忽略大小写
grep -i "pattern" file.txt

# 只显示文件名
grep -l "pattern" *.txt

# 显示行号
grep -n "pattern" file.txt

# 显示匹配行及上下文
grep -A 3 -B 3 "pattern" file.txt

# 统计匹配行数
grep -c "pattern" file.txt

# 使用正则表达式
grep -E "[a-z]+@[a-z]+\.[a-z]+" file.txt  # 邮箱匹配

# 反向选择（不匹配的行）
grep -v "pattern" file.txt

# 多个模式
grep -e "pattern1" -e "pattern2" file.txt
```

### sed命令

```bash
# 替换（默认只替换每行第一个）
sed 's/old/new/' file.txt

# 替换所有
sed 's/old/new/g' file.txt

# 指定行号
sed '3s/old/new/' file.txt

# 多行替换
sed '1,5s/old/new/g' file.txt

# 删除行
sed '/pattern/d' file.txt
sed '3d' file.txt

# 插入行
sed '3i\新行内容' file.txt

# 追加行
sed '3a\新行内容' file.txt

# 原处编辑
sed -i 's/old/new/g' file.txt

# 多个命令
sed -e 's/a/A/g' -e 's/b/B/g' file.txt

# 使用正则表达式
sed -E 's/[0-9]+/NUM/g' file.txt
```

### awk命令

```bash
# 基本用法
awk '{print $1}' file.txt  # 打印第一列

# 指定分隔符
awk -F: '{print $1, $5}' /etc/passwd

# 使用多个分隔符
awk -F'[:,]' '{print $1, $3}' file.txt

# 条件处理
awk '/pattern/ {print}' file.txt  # 只处理匹配行

# 内置变量
awk 'BEGIN {FS=":"; OFS="-"} {print $1, $2}' /etc/passwd

# 统计计算
awk '{sum+=$1} END {print sum}' numbers.txt

# 模式匹配
awk '$3 > 100 {print}' data.txt

# 字符串函数
awk '{gsub(/old/, "new", $0); print}' file.txt

# NR（行号）和FNR（文件行号）
awk 'NR==5 {print}' file.txt  # 打印第5行

# 字段数量
awk '{print NF}' file.txt  # 每行的字段数
```

### 组合使用

```bash
#!/usr/bin/env bash

# 复杂数据处理管道
tail -f /var/log/syslog | \
    grep "ERROR" | \
    awk '{print $5, $6, $NF}' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -20

# 查找大文件
find /var -type f -size +100M -exec ls -lh {} \; | \
    awk '{print $5, $9}' | \
    sort -h

# 日志分析
grep "GET /api" access.log | \
    awk '{print $7}' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -10
```

---

## 系统管理自动化

### 系统信息收集

```bash
#!/usr/bin/env bash
set -euo pipefail

# 收集系统信息
get_system_info() {
    cat << EOF
========================================
系统信息报告
生成时间: $(date)
========================================

主机名: $(hostname)
操作系统: $(cat /etc/redhat-release)
内核版本: $(uname -r)
架构: $(uname -m)
运行时间: $(uptime -p 2>/dev/null || uptime)

----------------------------------------
CPU信息:
$(lscpu | grep -E "Model name|CPU\(s\)|Core\(s\) per socket|CPU MHz")

----------------------------------------
内存信息:
$(free -h)

----------------------------------------
磁盘使用:
$(df -h | grep -E "^/dev|Filesystem")

----------------------------------------
网络信息:
$(ip -brief addr show | grep UP)

========================================
EOF
}

get_system_info | tee system_info_$(date +%Y%m%d).txt
```

### 服务管理

```bash
#!/usr/bin/env bash
set -euo pipefail

# 检查服务状态
check_service() {
    local service="$1"
    
    if systemctl is-active --quiet "$service"; then
        echo "[✓] $service 正在运行"
        return 0
    else
        echo "[✗] $service 未运行"
        return 1
    fi
}

# 启动服务（如果未运行）
start_service_if_needed() {
    local service="$1"
    
    if ! systemctl is-active --quiet "$service"; then
        echo "启动服务: $service"
        sudo systemctl start "$service"
        
        # 等待服务启动
        sleep 2
        
        if systemctl is-active --quiet "$service"; then
            echo "[✓] $service 启动成功"
        else
            echo "[✗] $service 启动失败"
            return 1
        fi
    else
        echo "[✓] $service 已在运行"
    fi
}

# 检查所有关键服务
check_all_services() {
    local services=("nginx" "mysql" "redis" "sshd")
    local failed=0
    
    for service in "${services[@]}"; do
        if ! check_service "$service"; then
            ((failed++))
        fi
    done
    
    if (( failed > 0 )); then
        echo "$failed 个服务异常"
        return 1
    fi
    
    echo "所有服务正常"
    return 0
}
```

### 备份脚本

```bash
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "备份失败"; exit 1' ERR

readonly BACKUP_DIR="/var/backups"
readonly DATE=$(date +%Y%m%d_%H%M%S)
readonly BACKUP_FILE="backup_${DATE}.tar.gz"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 创建备份
create_backup() {
    local source_dir="$1"
    local backup_file="$BACKUP_DIR/$BACKUP_FILE"
    
    log "开始备份: $source_dir"
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    
    # 复制文件（保留权限）
    cp -a "$source_dir/." "$temp_dir/"
    
    # 排除不必要的文件
    find "$temp_dir" -name "*.log" -delete
    find "$temp_dir" -name "*.tmp" -delete
    
    # 创建压缩包
    tar -czf "$backup_file" -C "$temp_dir" .
    
    # 清理临时目录
    rm -rf "$temp_dir"
    
    # 验证备份
    if [[ -f "$backup_file" ]] && [[ $(stat -c%s "$backup_file") -gt 0 ]]; then
        log "备份成功: $backup_file (大小: $(du -h "$backup_file" | cut -f1))"
        
        # 清理旧备份（保留最近7天）
        find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    else
        log "备份文件异常"
        rm -f "$backup_file"
        return 1
    fi
}

# 使用
create_backup "/data/myapp"
```

### 监控脚本

```bash
#!/usr/bin/env bash
set -euo pipefail

# 阈值设置
readonly CPU_THRESHOLD=80
readonly MEM_THRESHOLD=90
readonly DISK_THRESHOLD=85

# 检查CPU使用率
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        echo "[警告] CPU使用率过高: ${cpu_usage}%"
        return 1
    fi
    echo "[正常] CPU使用率: ${cpu_usage}%"
    return 0
}

# 检查内存使用
check_memory() {
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    
    if (( mem_usage > MEM_THRESHOLD )); then
        echo "[警告] 内存使用率过高: ${mem_usage}%"
        return 1
    fi
    echo "[正常] 内存使用率: ${mem_usage}%"
    return 0
}

# 检查磁盘使用
check_disk() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    if (( disk_usage > DISK_THRESHOLD )); then
        echo "[警告] 磁盘使用率过高: ${disk_usage}%"
        return 1
    fi
    echo "[正常] 磁盘使用率: ${disk_usage}%"
    return 0
}

# 综合健康检查
system_health_check() {
    local status=0
    
    echo "========================================"
    echo "系统健康检查 - $(date)"
    echo "========================================"
    
    check_cpu || ((status++))
    check_memory || ((status++))
    check_disk || ((status++))
    
    # 检查关键服务
    for service in nginx mysql; do
        if ! systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "[警告] 服务 $service 未运行"
            ((status++))
        else
            echo "[正常] 服务 $service 运行中"
        fi
    done
    
    echo "========================================"
    
    if (( status == 0 )); then
        echo "系统状态: 正常"
        return 0
    else
        echo "系统状态: 发现 $status 个问题"
        return 1
    fi
}

system_health_check | tee health_check_$(date +%Y%m%d).log
```

---

## 测试和调试

### ShellCheck静态分析

ShellCheck是Bash脚本的静态分析工具：

```bash
# 安装
sudo yum install shellcheck  # CentOS

# 使用
shellcheck myscript.sh

# 输出示例：
# In myscript line 5:
# a=1
# ^-- SC2034: (warning): a appears unused. Consider using a_ or removing it.
```

### 使用set -x调试

```bash
#!/usr/bin/env bash

# 调试模式（输出每个命令）
set -x

# 只调试特定部分
debug_function() {
    set -x
    # 调试代码
    result=$((1 + 1))
    set +x
}
```

### 自定义调试函数

```bash
#!/usr/bin/env bash

# 调试级别
DEBUG=${DEBUG:-0}

debug() {
    if [[ $DEBUG -ge 1 ]]; then
        echo "[DEBUG] $*"
    fi
}

debug_var() {
    if [[ $DEBUG -ge 2 ]]; then
        echo "[DEBUG] $1=${!1}"
    fi
}

# 使用
DEBUG=2
debug_var "PATH"
```

### 使用BATS测试

安装BATS：

```bash
# CentOS
sudo yum install bats

# 或从源码安装
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

测试脚本示例：

```bash
#!/usr/bin/env bats

# 测试辅助函数
setup() {
    # 每个测试前执行
    load test_helper
}

teardown() {
    # 每个测试后执行
    rm -f /tmp/test_output
}

@test "测试加法函数" {
    result=$(add 2 3)
    [[ "$result" -eq 5 ]]
}

@test "测试文件创建" {
    touch /tmp/test_file
    [[ -f /tmp/test_file ]]
}

@test "测试命令成功" {
    run ls /
    [[ $status -eq 0 ]]
    [[ ${#lines[@]} -gt 0 ]]
}

@test "测试条件判断" {
    run bash -c 'source myscript.sh; check_service nginx'
    [[ $status -eq 0 ]]
    [[ "$output" == *"运行中"* ]]
}
```

---

## 性能优化

### 避免子shell和外部命令

```bash
#!/usr/bin/env bash

# ❌ 慢：循环中调用外部命令
for i in $(seq 1 1000); do
    echo $(date +%s)  # 每次都fork外部命令
done

# ✅ 快：使用内置命令
for ((i=0; i<1000; i++)); do
    echo "$i"  # 纯bash
done
```

### 使用内置命令代替外部命令

```bash
#!/usr/bin/env bash

# ❌ 使用外部expr（慢）
result=$(expr 5 + 3)

# ✅ 使用内置算术运算（快）
result=$((5 + 3))

# ❌ 使用外部echo（可能有问题）
output=$(echo "$var")

# ✅ 使用printf（更可靠）
printf '%s' "$var"

# ❌ 使用外部test（慢）
if test -f "$file"; then

# ✅ 使用内置[[（快且功能强大）
if [[ -f "$file" ]]; then
```

### 减少管道使用

```bash
#!/usr/bin/env bash

# ❌ 创建临时文件进行中间存储
cat file.txt | grep pattern > /tmp/temp
wc -l /tmp/temp
rm /tmp/temp

# ✅ 使用process substitution
count=$(grep pattern <(cat file.txt) | wc -l)

# ✅ 使用awk一次性处理
awk '/pattern/ {count++} END {print count}' file.txt

# ❌ 循环中管道（每次迭代都fork）
cat file.txt | while read line; do
    process "$line"
done

# ✅ 使用while读取（不fork）
while IFS= read -r line; do
    process "$line"
done < file.txt
```

### 缓存命令结果

```bash
#!/usr/bin/env bash

# 缓存IP地址查询
get_ip() {
    local domain="$1"
    local cache_key="ip_cache_$domain"
    
    if [[ -v $cache_key ]]; then
        echo "${!cache_key}"
    else
        local ip
        ip=$(dig +short "$domain" | tail -1)
        eval "$cache_key=$ip"
        echo "$ip"
    fi
}
```

---

## 安全最佳实践

### 输入验证

```bash
#!/usr/bin/env bash
set -euo pipefail

# 验证输入参数
validate_input() {
    local input="$1"
    local pattern="$2"
    local field="$3"
    
    if [[ ! "$input" =~ $pattern ]]; then
        echo "错误: $field 格式不正确" >&2
        return 1
    fi
}

# 使用示例
validate_input "$username" '^[a-zA-Z0-9_]+$' "用户名"
validate_input "$email" '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' "邮箱"

# 防止命令注入
# ❌ 危险
user_input="; rm -rf /"
eval "command $user_input"

# ✅ 安全
safe_command() {
    local input="$1"
    # 只允许特定字符
    if [[ ! "$input" =~ ^[a-zA-Z0-9_./-]+$ ]]; then
        echo "输入包含非法字符"
        return 1
    fi
    command "$input"
}
```

### 避免eval

```bash
#!/usr/bin/env bash

# ❌ 危险：eval可能导致命令注入
eval "ls $user_input"

# ✅ 安全：使用数组
args=("ls")
args+=("$user_input")
"${args[@]}"

# ✅ 安全：使用函数
execute_command() {
    local cmd="$1"
    shift
    case "$cmd" in
        ls|cat|pwd)
            "$cmd" "$@"
            ;;
        *)
            echo "不允许的命令"
            return 1
            ;;
    esac
}
```

### 临时文件安全

```bash
#!/usr/bin/env bash

# 使用mktemp创建安全临时文件
temp_file=$(mktemp)
temp_dir=$(mktemp -d)

# 确保清理
trap 'rm -f "$temp_file"; rm -rf "$temp_dir"' EXIT

# 使用安全权限
temp_file=$(mktemp -p /tmp app.XXXXXX)
chmod 600 "$temp_file"
```

### 最小权限原则

```bash
#!/usr/bin/env bash

# 检查是否以root运行（如果需要）
if [[ $EUID -ne 0 ]]; then
    echo "此脚本需要root权限"
    exit 1
fi

# 使用最小权限运行命令
run_as_app_user() {
    local app_user="appuser"
    local app_group="appgroup"
    
    # 切换用户执行
    sudo -u "$app_user" bash -c "$@"
}
```

### 安全的变量扩展

```bash
#!/usr/bin/env bash

# ❌ 危险：变量可能为空或包含空格
rm -rf $MYDIR/*

# ✅ 安全：使用引号和默认值
rm -rf "${MYDIR:?}/"*  # MYDIR为空时会报错

# 使用参数扩展默认值
MYDIR="${MYDIR:-/default/path}"
rm -rf "$MYDIR"/*

# 处理特殊字符
filename="file with spaces.txt"
rm -rf "$filename"  # 正确：双引号
```

---

## 常见模式和模板

### 最小安全模板

```bash
#!/usr/bin/env bash
set -euo pipefail

# 脚本元信息
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

# 依赖检查
check_dependency() {
    if ! command -v "$1" &>/dev/null; then
        error "缺少依赖: $1"
        exit 1
    fi
}

# 主函数
main() {
    check_dependency curl
    
    # 主逻辑
    log "开始执行"
    
    log "执行完成"
}

main "$@"
```

### 交互式脚本模板

```bash
#!/usr/bin/env bash
set -euo pipefail

# 确认函数
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    read -p "$prompt [y/$default]: " answer
    
    case "$answer" in
        y|Y) return 0 ;;
        n|N) return 1 ;;
        *)   [[ "$default" == "y" ]] && return 0 || return 1 ;;
    esac
}

# 选择函数
select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            return 0
        fi
    done
    return 1
}

# 使用示例
if confirm "是否继续?" y; then
    echo "继续执行"
fi

choice=$(select_option "选择操作:" "选项1" "选项2" "选项3")
echo "选择了: $choice"
```

### 守护进程模板

```bash
#!/usr/bin/env bash
set -euo pipefail

DAEMON_NAME="myapp"
DAEMON_PID="/var/run/${DAEMON_NAME}.pid"

start_daemon() {
    if [[ -f "$DAEMON_PID" ]]; then
        if kill -0 $(cat "$DAEMON_PID") 2>/dev/null; then
            echo "守护进程已在运行"
            return 0
        fi
        rm -f "$DAEMON_PID"
    fi
    
    echo "启动守护进程..."
    nohup /path/to/myapp > /var/log/myapp.log 2>&1 &
    echo $! > "$DAEMON_PID"
    echo "守护进程已启动 (PID: $(cat "$DAEMON_PID"))"
}

stop_daemon() {
    if [[ -f "$DAEMON_PID" ]]; then
        local pid=$(cat "$DAEMON_PID")
        if kill -0 "$pid" 2>/dev/null; then
            echo "停止守护进程 (PID: $pid)..."
            kill "$pid"
            rm -f "$DAEMON_PID"
            echo "守护进程已停止"
        else
            echo "守护进程未运行"
            rm -f "$DAEMON_PID"
        fi
    else
        echo "守护进程未运行"
    fi
}

status_daemon() {
    if [[ -f "$DAEMON_PID" ]]; then
        local pid=$(cat "$DAEMON_PID")
        if kill -0 "$pid" 2>/dev/null; then
            echo "守护进程正在运行 (PID: $pid)"
            return 0
        else
            echo "守护进程未运行（PID文件存在但进程不存在）"
            return 1
        fi
    else
        echo "守护进程未运行"
        return 1
    fi
}

case "$1" in
    start) start_daemon ;;
    stop) stop_daemon ;;
    restart) 
        stop_daemon
        sleep 1
        start_daemon
        ;;
    status) status_daemon ;;
    *) echo "用法: $0 {start|stop|restart|status}" ;;
esac
```

### 命令行工具模板

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly VERSION="1.0.0"
readonly DESCRIPTION="一个实用的命令行工具"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

show_help() {
    cat << EOF
$DESCRIPTION

用法: $(basename "$0") [选项] [参数]

选项:
    -h, --help          显示帮助信息
    -v, --version       显示版本信息
    -q, --quiet         安静模式
    -o, --output FILE   输出文件
    --verbose           详细输出

示例:
    $(basename "$0") -o output.txt input.txt
    $(basename "$0") --verbose input.txt
EOF
}

# 解析参数
VERBOSE=false
QUIET=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$VERSION"
            exit 0
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
        *)
            INPUT="$1"
            shift
            ;;
    esac
done

# 主逻辑
if [[ -z "${INPUT:-}" ]]; then
    print_error "缺少输入文件"
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    print_error "文件不存在: $INPUT"
    exit 1
fi

print_info "处理文件: $INPUT"

# 处理逻辑
echo "处理完成"
```

---

## CentOS特定技巧

### 系统版本检测

```bash
#!/usr/bin/env bash

# 检测CentOS版本
get_centos_version() {
    if [[ -f /etc/centos-release ]]; then
        cat /etc/centos-release
    elif [[ -f /etc/redhat-release ]]; then
        cat /etc/redhat-release
    else
        echo "未知"
    fi
}

# 检测是CentOS还是RHEL
if [[ -f /etc/centos-release ]]; then
    echo "这是CentOS系统"
elif [[ -f /etc/redhat-release ]]; then
    echo "这是RHEL系统"
fi

# 获取版本号
VERSION_ID=$(grep -oE '[0-9]+\.[0-9]+' /etc/centos-release | cut -d. -f1)
echo "主版本号: $VERSION_ID"
```

### 使用yum/dnf

```bash
#!/usr/bin/env bash

# 安装包（支持yum和dnf）
install_package() {
    local package="$1"
    
    if command -v dnf &>/dev/null; then
        sudo dnf install -y "$package"
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$package"
    else
        echo "未找到yum或dnf"
        return 1
    fi
}

# 检查包是否已安装
is_package_installed() {
    local package="$1"
    
    if command -v dnf &>/dev/null; then
        dnf list --installed "$package" &>/dev/null
    elif command -v yum &>/dev/null; then
        yum list installed "$package" &>/dev/null
    fi
}

# 启用EPEL仓库
enable_epel() {
    if ! is_package_installed "epel-release"; then
        if command -v dnf &>/dev/null; then
            sudo dnf install -y epel-release
        else
            sudo yum install -y epel-release
        fi
    fi
}
```

### Systemd服务管理

```bash
#!/usr/bin/env bash

# 检查服务状态
check_systemd_service() {
    local service="$1"
    
    if systemctl is-enabled --quiet "$service" 2>/dev/null; then
        echo "[已启用] $service"
    fi
    
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "[运行中] $service"
    else
        echo "[未运行] $service"
    fi
}

# 创建systemd服务文件
create_systemd_service() {
    local name="$1"
    local description="$2"
    local exec_start="$3"
    local user="${4:-root}"
    
    cat > "/etc/systemd/system/${name}.service" << EOF
[Unit]
Description=$description

[Service]
Type=simple
User=$user
ExecStart=$exec_start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable "$name"
    sudo systemctl start "$name"
}
```

### Cron任务管理

```bash
#!/usr/bin/env bash

# 添加cron任务（每小时执行）
add_hourly_cron() {
    local script_path="$1"
    local description="$2"
    
    local cron_line="0 * * * * $script_path"
    
    # 检查是否已存在
    if ! crontab -l 2>/dev/null | grep -qF "$description"; then
        (crontab -l 2>/dev/null; echo "# $description") | crontab -
        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
        echo "Cron任务已添加: $description"
    else
        echo "Cron任务已存在: $description"
    fi
}

# 添加每日任务（每天凌晨2点）
add_daily_cron() {
    local script_path="$1"
    local description="$2"
    
    local cron_line="0 2 * * * $script_path"
    
    (crontab -l 2>/dev/null; echo "# $description") | crontab -
    (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
}
```

### SELinux上下文

```bash
#!/usr/bin/env bash

# 检查SELinux状态
check_selinux() {
    if command -v getenforce &>/dev/null; then
        local status=$(getenforce)
        echo "SELinux状态: $status"
        
        if [[ "$status" == "Enforcing" ]]; then
            echo "SELinux已启用并强制执行"
        elif [[ "$status" == "Permissive" ]]; then
            echo "SELinux已启用但处于宽容模式"
        else
            echo "SELinux已禁用"
        fi
    else
        echo "SELinux未安装"
    fi
}

# 修改文件SELinux上下文
fix_selinux_context() {
    local path="$1"
    local context_type="$2"  # 例如 httpd_sys_content_t
    
    if command -v semanage &>/dev/null; then
        sudo semanage fcontext -a -t "$context_type" "$path"
        sudo restorecon -Rv "$path"
        echo "已修复SELinux上下文: $path ($context_type)"
    fi
}
```

### Firewalld管理

```bash
#!/usr/bin/env bash

# 开放端口
firewall_open_port() {
    local port="$1"
    local protocol="${2:-tcp}"
    
    sudo firewall-cmd --permanent --add-port="${port}/${protocol}"
    sudo firewall-cmd --reload
    
    echo "端口已开放: $port/$protocol"
}

# 检查端口是否开放
firewall_check_port() {
    local port="$1"
    local protocol="${2:-tcp}"
    
    if firewall-cmd --query-port="${port}/${protocol}" &>/dev/null; then
        echo "端口已开放: $port/$protocol"
        return 0
    else
        echo "端口未开放: $port/$protocol"
        return 1
    fi
}
```

---

## 参考资源

### 官方文档

- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Bash Reference Manual](https://tiswww.case.edu/php/chet/bash/bashref.html)

### 权威指南

- [Greg's Wiki - BashGuide](https://mywiki.wooledge.org/BashGuide)
- [Greg's Wiki - BashFAQ](https://mywiki.wooledge.org/BashFAQ)
- [Greg's Wiki - BashPitfalls](https://mywiki.wooledge.org/BashPitfalls)

### 在线教程

- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Academy](https://www.bash.academy/)
- [Learn Bash in Y Minutes](https://learnxinyminutes.com/docs/bash/)

### 工具

- [ShellCheck](https://www.shellcheck.net/) - Bash静态分析工具
- [BATS](https://github.com/bats-core/bats-core) - Bash测试框架
- [Argbash](https://argbash.io/) - Bash参数解析生成器

### 书籍

- "The Linux Command Line" by William Shotts
- "Learning the bash Shell" by Cameron Newham
- "bash Cookbook" by Carl Albing and JP Vossen

---

## 总结

Bash脚本编写是一项需要持续学习和实践的技能。关键要点：

1. **安全第一**：始终使用`set -euo pipefail`，验证输入，避免eval
2. **清晰代码**：使用有意义的变量名，添加注释，保持函数短小
3. **错误处理**：使用trap捕获信号，检查命令返回值
4. **性能考虑**：优先使用内置命令，减少子shell
5. **可维护性**：使用模板，保持一致的代码风格
6. **测试验证**：使用ShellCheck静态检查，使用BATS进行单元测试

随着经验积累，你会逐渐掌握更多高级技巧，如复杂文本处理、性能调优、安全加固等。记住：**实践是最好的老师**，多写代码、多调试是提高Bash脚本能力的唯一途径。
