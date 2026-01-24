# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚀 快速开始

### 项目背景与历史
**重要：** 每次开始新对话前，请按顺序阅读以下文档：

1. **`docs/project-summary.md`** - 完整项目对话总结
   - 核心问题与解决过程
   - 文件修改清单
   - 关键决策和经验总结

2. **`docs/interaction-log.md`** - 详细交互历史
   - 完整的对话记录
   - 每个修改的技术细节
   - 所有涉及文件的变更记录

**这三个文档将帮助您：**

1. **当前文档（CLAUDE.md）**：快速开始指南和项目概述
2. **`docs/project-summary.md`**：完整项目对话总结
3. **`docs/interaction-log.md`**：详细交互历史记录

**具体帮助：**
- 了解已完成的重要修改和解决方案
- 避免重复解决已经处理过的问题
- 保持对话的连续性和一致性
- 掌握完整的项目知识体系

**最新修改（2026-01-24）：**
- ✅ 修复脚本非交互式环境无限循环问题
- ✅ 简化输入处理逻辑，移除所有环境检测
- ✅ 建立交互日志记录规范
- ✅ 创建完整项目对话总结

### 当前状态
- 脚本已修复：移除非交互式检测，始终运行交互式模式
- 文档完善：包含完整的使用手册和交互日志规定
- 架构稳定：支持多用户协作、预设会话、自动创建等功能

---

## 项目概述

Smart Screen Session Manager v2.0 是一个智能的 Screen 会话管理工具，专门用于解决 SSH 登录后会话丢失问题。项目支持多用户协作、简洁提示符、预设会话、自动创建/连接、防重复机制等功能。

## 项目结构

```
smart-screen/
├── smart-screen.sh          # 主脚本文件（核心功能）
├── README.md                 # 完整使用手册
├── LICENSE                   # MIT 开源许可证
├── config/                   # 配置文件目录
│   ├── .screenrc            # Screen 会话配置
│   ├── .screenrc.ps1        # PS1 提示符配置
│   ├── .shellcheckrc        # ShellCheck 代码质量检查配置
│   └── README.md            # 配置文件说明
├── .bmad-core/              # BMad-Method 框架（最近安装）
└── .claude/commands/BMad/   # BMad 命令目录
```

## 核心功能

### 主要特性
- **多用户协作**：支持多个用户同时连接同一个会话，实时共享操作
- **简洁提示符**：显示格式为 `[会话名]用户@主机$`，告别冗长路径
- **预设会话**：9个预设会话（dev、test、prod、db、monitor、backup、log、debug、research）
- **自动创建/连接**：智能检测会话状态，不存在则自动创建
- **防重复机制**：自动检测并清理重复会话
- **一键安装**：自动安装依赖、配置自启动

### 会话映射
```bash
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
```

## 常用命令

### 运行主脚本
```bash
./smart-screen.sh
```

### 基本操作
- `1-9` → 进入对应的预设会话（自动创建/连接）
- `a` → 显示所有活跃会话列表（可选择）
- `q` → 退出脚本

### 管理操作
- `c` → 清理重复会话
- `d` → 删除所有会话（需确认）
- `e` → 编辑脚本（使用 nano）

### 系统管理
- `i` → 自动安装（安装依赖+配置自启动）
- `u` → 自动卸载（删除自启动配置）

### 代码质量检查
```bash
# 语法检查
bash -n smart-screen.sh

# 使用 ShellCheck 进行代码质量检查
shellcheck smart-screen.sh

# 查看所有 Screen 会话
screen -ls

# 手动创建会话
screen -S "会话名称" -d -m bash

# 多用户模式设置
screen -S "会话名称" -X multiuser on
screen -S "会话名称" -X acladd 用户名
```

## 架构设计

### 脚本结构
主脚本 `smart-screen.sh` 包含以下主要函数：

1. **错误处理**
   - `error()` - 标准错误处理
   - `fatal()` - 致命错误处理（带堆栈跟踪）
   - `cleanup()` - 清理操作

2. **会话管理**
   - `show_sessions()` - 显示会话列表
   - `connect_to_session()` - 连接到会话（不存在则创建）
   - `enable_multiuser()` - 检查并启用多用户模式

3. **批量操作**
   - `show_all_sessions()` - 显示所有活跃会话
   - `clean_duplicates()` - 清理重复会话
   - `delete_all_sessions()` - 删除所有会话

4. **系统管理**
   - `auto_install()` - 自动安装功能
   - `auto_uninstall()` - 自动卸载功能

### 配置系统

配置文件通过符号链接方式管理：
- `~/.screenrc` → `config/.screenrc`
- `~/.screenrc.ps1` → `config/.screenrc.ps1`
- `~/.shellcheckrc` → `config/.shellcheckrc`

**简洁提示符配置**：
- 格式：`[会话名称] 用户@主机$`
- 通过 `$STY` 环境变量获取当前 Screen 会话名称
- 在 Screen 会话中自动加载

## 核心脚本函数

### 连接会话
```bash
connect_to_session() {
    local session_name="$1"

    # 检查会话是否存在
    if screen -list | grep -q "$session_name"; then
        # 存在则连接
        screen -xR "$session_name"
    else
        # 不存在则创建
        screen -S "$session_name" -d -m bash

        # 启用多用户模式
        screen -S "$session_name" -X multiuser on

        # 连接会话
        screen -xR "$session_name"
    fi
}
```

### 启用多用户模式
```bash
enable_multiuser() {
    local session_name="$1"

    # 启用多用户访问
    screen -S "$session_name" -X multiuser on 2>/dev/null || true

    # 设置权限（可选）
    # screen -S "$session_name" -X acladd 用户名 2>/dev/null || true
}
```

## 自动安装机制

### 安装步骤
1. **依赖检查** - 检测 screen 是否已安装
2. **权限设置** - 设置脚本执行权限
3. **符号链接** - 创建配置文件符号链接
4. **自启动配置** - 修改 `~/.bashrc` 添加自动启动
5. **完成提示** - 显示配置完成信息

### 自启动配置
```bash
# Smart Screen Session Manager Auto Start
if [[ $- == *i* ]] && [[ -z "$SSH_TTY" ]] && [[ -z "$TMUX" ]]; then
    SCRIPT_PATH="/root/smart-screen.sh"
    if [[ -x "$SCRIPT_PATH" ]]; then
        /root/smart-screen.sh
    fi
fi
```

## 开发指南

### 添加新会话
编辑 `smart-screen.sh` 中的 `SESSION_MAP` 数组：
```bash
declare -A SESSION_MAP=(
    [1]="dev-开发环境"
    [2]="test-测试环境"
    # 添加新会话...
    [10]="custom-自定义会话"
)
```

### 自定义提示符
编辑 `config/.screenrc.ps1` 文件：
```bash
# 格式：[会话名称] 用户@主机$
export PS1="\\[\\e]0;[\\$SESSION_NAME] \\u@\\h:\\w\\a\\]\\\\$ "

# 格式：[会话名称] $
export PS1="\\[\\e]0;[\\$SESSION_NAME] \\a\\]\\\\$ "
```

### 代码规范
- 使用 `set -euo pipefail` 启用严格模式
- 变量使用 `readonly` 声明常量
- 错误处理使用 `error()` 和 `fatal()` 函数
- 字符串使用双引号包围
- 使用 ShellCheck 进行代码质量检查

### 颜色和图标定义
```bash
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

readonly ICON_SESSION="📝"
readonly ICON_RUNNING="✅"
readonly ICON_QUIT="👋"
# ... 更多图标定义
```

## 多用户协作

### 创建多用户会话
```bash
# 使用脚本创建
./smart-screen.sh
# 选择 1-9 创建任意预设会话

# 或手动创建
screen -S "会话名" -d -m bash
screen -S "会话名" -X multiuser on
screen -S "会话名" -X acladd alice
screen -S "会话名" -X acladd bob
```

### 多用户连接
```bash
# 多个用户同时连接同一个会话
screen -xR "会话名"
```

## ShellCheck 配置

项目使用 `.shellcheckrc` 进行代码质量检查：
- **严重级别**：error
- **Shell 类型**：bash
- **启用所有检查**：enable=all

常用检查规则：
- SC2034: 变量已声明但未使用
- SC2086: 参数扩展应加引号
- SC2154: 变量已引用但未声明

## BMad-Method 集成

项目已安装 BMad-Method 框架（v4.44.3），提供专业的工作流支持：

### 可用代理命令
- `/bmad-orchestrator` - BMad 编排器
- `/dev` - 开发专家
- `/architect` - 架构师
- `/qa` - 质量保证
- `/pm` - 项目经理
- 等等...

### 快速开始
```bash
# 重启 Claude Code 后使用
/BMad:agents:bmad-orchestrator *help
```

## 故障排除

### 常见问题
1. **脚本没有自动启动**
   - 检查是否为交互式 shell：`echo $-` 应包含 `i`
   - 重新加载配置：`source ~/.bashrc`

2. **screen 命令不存在**
   - Ubuntu/Debian: `sudo apt-get install screen`
   - CentOS/RHEL: `sudo yum install screen`

3. **权限问题**
   - 确保脚本有执行权限：`chmod +x /root/smart-screen.sh`
   - 检查 screen 会话权限：`ls -la /run/screen/`

### 测试脚本
README 中提到 `test_screen_manager.sh`，但当前版本尚未实现。

## 更新日志

### v2.0 (当前版本)
- 多用户协作功能
- 简洁提示符
- 菜单版权信息
- 极简项目结构
- 自动权限管理
- 预设9个会话
- 防重复机制
- 一键安装/卸载

### 近期提交
- e51410a refactor: 删除临时安装文件，将一键安装集成到README
- f1e25ea feat: 添加一键安装功能
- cb65bde refactor: 将配置文件移动到规范性的 config/ 目录
- 965c283 docs: 全面更新README.md文档

## 交互日志

### 使用指南

**⚠️ 重要提醒：**
- **启动前必读**：每次启动新的 Claude Code 对话前，必须先阅读 `docs/interaction-log.md`
- **了解背景**：该文档记录了完整的项目历史和所有重要修改
- **保持连续**：通过阅读历史，可以理解当前状态，避免重复工作

**交互日志的价值：**
- 提供完整的修改历史和决策过程
- 记录了所有已解决的问题和方案
- 帮助新对话快速理解项目上下文
- 确保解决方案的一致性和可追溯性

### 日志记录要求

所有用户与 Claude Code 的交互过程必须记录在 `docs/interaction-log.md` 文档中，确保项目开发的透明度和可追溯性。

### 记录内容

**必须记录的信息：**
- **日期时间**：YYYY-MM-DD HH:MM:SS 格式
- **用户输入**：完整的用户请求和问题描述
- **处理过程**：Claude Code 的分析和处理步骤（精简总结）
- **结果输出**：最终的解决方案和输出结果
- **涉及文件**：所有修改或查看的文件路径

### 日志格式

```markdown
# 交互日志 - YYYY-MM-DD

## [时间戳] 主题描述

### 用户输入
```
[完整复制用户的原始输入]
```

### 处理过程
- 步骤1：[精简描述处理方法]
- 步骤2：[精简描述关键决策]
- 步骤3：[精简描述最终方案]

### 结果输出
```
[记录最终结果或输出]
```

### 涉及文件
- `文件路径1` - [修改/查看内容简述]
- `文件路径2` - [修改/查看内容简述]

---
```

### 核心原则
- **精简准确**：用最少的文字总结核心过程，避免冗余
- **完整记录**：用户输入必须逐字记录，不能简化
- **可追溯性**：确保每个问题和解决方案都有明确记录
- **结构化**：严格按照格式要求组织内容

### 示例

```markdown
# 交互日志 - 2026-01-24

## [09:30] 修复脚本非交互式环境无限循环问题

### 用户输入
```
在claude.md里，加入一条规定，使用一个md文档来记录用户和claude code的交互过程。每一次对话过程都记录进去，记录完整的用户输入，把claude code的处理过程和结果，用最精简核心的语言总结。
```

### 处理过程
- 分析需求：在 CLAUDE.md 中添加交互日志规定
- 设计格式：制定结构化的日志模板和记录要求
- 编辑文档：在许可证章节前插入新内容

### 结果输出
✅ 在 CLAUDE.md 中成功添加"交互日志"章节
✅ 制定了详细的日志格式和记录要求
✅ 提供了完整的示例模板

### 涉及文件
- `CLAUDE.md` - 添加交互日志规定章节
```

## 许可证

MIT License - 详见 LICENSE 文件

---

更多信息请参阅 README.md 完整文档。
