# Smart Screen Session Manager v2.0

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/yourusername/smart-screen)
[![Author](https://img.shields.io/badge/author-Ducky-green.svg)](mailto:ducky@live.com)

**版权所有 © 2026 Ducky | MIT License**

## 📋 项目简介

**Smart Screen Session Manager** 是一个智能的 Screen 会话管理工具，专为解决 SSH 登录后会话丢失问题而设计。它支持多用户协作、简洁提示符、预设会话、自动创建/连接、防重复机制等功能，让您的多任务管理工作更加便捷高效。

## 🎯 核心亮点

- ✨ **真正的多用户协作** - 支持多个用户同时连接同一个会话，实时共享操作
- 🎨 **简洁提示符** - 告别冗长的提示符，只显示必要信息 `[会话名]用户@主机`
- 🚀 **一键安装** - 自动安装依赖、配置自启动，无需手动设置
- 🛡️ **安全可靠** - 完整的权限管理、错误处理和安全机制

## ✨ 核心特性

### 🎯 智能会话管理
- **自动创建/连接**：输入1-9，会话不存在则自动创建，已存在则直接连接
- **预设会话配置**：9个预设会话，满足不同工作场景需求
- **防重复机制**：自动检测并清理重复会话，避免混淆

### 🎨 美化界面
- **彩色输出**：使用颜色和图标增强视觉效果
- **状态显示**：实时显示会话状态（运行中/未创建）
- **友好提示**：详细的操作提示和帮助信息
- **一键安装**：内置自动安装/卸载功能，无需额外脚本

### 🔧 便捷操作
- **一键连接**：预设快捷键，快速进入指定会话
- **批量管理**：清理重复、删除所有等批量操作
- **SSH集成**：支持 SSH 登录自动启动

### 🛡️ 安全可靠
- **权限检查**：确保脚本具有执行权限
- **错误处理**：完善的输入验证和错误提示
- **安全删除**：删除操作需要明确确认

## 🚀 快速开始

### 方式一：使用主脚本自动安装（推荐）

```bash
# 运行主脚本（自动安装）
./smart-screen.sh

# 选择 i 进行自动安装
# 系统会自动：
# 1. 检查并安装 screen
# 2. 设置脚本权限
# 3. 配置自启动
```

**优势：**
- ✅ 在主脚本内完成安装，更便捷
- ✅ 一键完成，无需额外下载安装脚本
- ✅ 界面友好，操作简单

### 方式二：手动安装

#### 1. 安装 screen
```bash
# Ubuntu/Debian
sudo apt-get install screen

# CentOS/RHEL
sudo yum install screen

# Arch Linux
sudo pacman -S screen
```

#### 2. 设置执行权限
```bash
chmod +x smart-screen.sh
```

#### 3. 配置自动启动（可选）
编辑 `~/.bashrc` 文件，添加以下内容：

```bash
# Smart Screen Session Manager Auto Start
if [[ $- == *i* ]] && [[ -z "$SSH_TTY" ]] && [[ -z "$TMUX" ]]; then
    SCRIPT_PATH="/root/smart-screen.sh"
    if [[ -x "$SCRIPT_PATH" ]]; then
        /root/smart-screen.sh
    fi
fi
```

#### 4. 重新加载配置
```bash
source ~/.bashrc
```

## 📖 使用说明

### 预设会话

| 快捷键 | 会话名称 | 用途说明 |
|--------|----------|----------|
| 1 | dev-开发环境 | 代码开发、调试 |
| 2 | test-测试环境 | 功能测试、集成测试 |
| 3 | prod-生产环境 | 生产环境运维 |
| 4 | db-数据库 | 数据库管理、备份 |
| 5 | monitor-监控 | 系统监控、性能分析 |
| 6 | backup-备份 | 数据备份、文件同步 |
| 7 | log-日志 | 日志查看、分析 |
| 8 | debug-调试 | 深度调试、问题排查 |
| 9 | research-研究 | 技术研究、学习 |

## 👥 多用户协作功能

### 真正的多用户协作

Smart Screen Session Manager 支持真正的多用户协作功能，让多个用户可以同时操作同一个会话。

### ✨ 核心优势

- 🔄 **实时共享** - 支持多个用户同时连接同一个会话
- 👀 **实时可见** - 用户的输入和输出对其他用户完全可见
- 🎮 **实时控制** - 多个用户可以同时控制同一个会话
- 🔒 **自动权限** - 自动启用多用户模式，无需手动配置

### 🚀 使用方法

#### 1. 创建多用户会话
```bash
# 方式1: 使用脚本创建
./smart-screen.sh
# 选择 1-9 创建任意预设会话

# 方式2: 手动创建
screen -S "dev-开发环境" -d -m bash
screen -S "dev-开发环境" -X multiuser on
screen -S "dev-开发环境" -X acladd alice
screen -S "dev-开发环境" -X acladd bob
```

#### 2. 多用户连接
```bash
# A用户连接
screen -xR "dev-开发环境"

# B用户连接 (与A用户同时在线)
screen -xR "dev-开发环境"
```

#### 3. 验证协作效果
```bash
# A用户输入
echo "Hello from User A"

# B用户会立即看到
# [dev-开发环境]bob@server$: echo "Hello from User A"
# Hello from User A

# B用户输入
echo "Hello from User B"

# A用户会立即看到
# [dev-开发环境]alice@server$: echo "Hello from User B"
# Hello from User B
```

### 🎯 应用场景

1. **代码协作审查**
   - 多个开发者同时查看代码
   - 实时讨论和编辑
   - 减少沟通成本

2. **远程教学**
   - 老师操作，学生观看
   - 实时演示命令
   - 立即解答问题

3. **团队故障排查**
   - 多个工程师同时诊断
   - 实时分享解决方案
   - 提高效率

4. **实时技术支持**
   - 技术人员远程指导
   - 用户实时看到操作
   - 提高支持质量

### ⚠️ 注意事项

- **协作礼仪**: 通知其他用户将要执行的操作
- **权限管理**: 只授权给需要的用户
- **会话安全**: 敏感操作时注意信息安全

## 🎨 简洁提示符配置

### 告别冗长提示符

Smart Screen Session Manager 提供了简洁的提示符配置，告别冗长的路径和多余信息。

### ✨ 对比效果

**❌ 传统提示符（太长）:**
```
[root@VM-0-8-opencloudos ~]# screen -r dev-开发环境
[screen 0: root@VM-0-8-opencloudos:~] [dev-[dev-开发环境] root@dev-开发环境$ cd /project
[dev-开发环境]root@VM-0-8-opencloudos:/project$
```

**✅ 简洁提示符:**
```
[dev-开发环境]root@VM-0-8-opencloudos$ cd /project
[dev-开发环境]root@VM-0-8-opencloudos$
```

### 🎯 提示符格式

- **格式**: `[会话名称] 用户@主机$`
- **显示信息**:
  - `[会话名称]` - 当前Screen会话名称
  - `用户` - 当前登录用户
  - `主机` - 主机名（短格式）
  - `$` - 命令提示符

### 🚀 自动配置

提示符配置在脚本自动安装时自动完成：

1. **自动创建** `.screenrc.ps1` 文件
2. **自动修改** `~/.bashrc` 添加自动加载
3. **自动设置** `.screenrc` 配置

### 🔧 手动配置

如需手动配置：

```bash
# 运行配置脚本
./setup_screen_prompt.sh

# 或手动编辑
# 1. 编辑 ~/.screenrc.ps1
# 2. 添加到 ~/.bashrc
# 3. 运行 source ~/.bashrc
```

### 🎨 自定义提示符

可以修改 `.screenrc.ps1` 文件自定义提示符格式：

```bash
# 格式：[会话名称] 用户@主机$
export PS1="\\[\\e]0;[\\$SESSION_NAME] \\u@\\h:\\w\\a\\]\\\\$ "

# 格式：[会话名称] $
export PS1="\\[\\e]0;[\\$SESSION_NAME] \\a\\]\\\\$ "

# 格式：[会话名称] 用户@主机:路径$
export PS1="\\[\\e]0;[\\$SESSION_NAME] \\u@\\h:\\w\\a\\]\\\\$ "
```

### 📊 状态栏配置

同时配置了简洁的状态栏显示：

- **位置**: 屏幕底部
- **显示内容**: 会话名称 + 主机名
- **颜色**: 绿色高亮 + 白色文字

### 操作指令

#### 基本操作
- `1-9` → 进入对应的预设会话（自动创建/连接）
- `a` → 显示所有活跃会话列表（可选择）
- `q` → 退出脚本

#### 管理操作
- `c` → 清理重复会话
- `d` → 删除所有会话（需确认）
- `e` → 编辑脚本（使用 nano）

#### 系统管理
- `i` → 自动安装（安装依赖+配置自启动）
- `u` → 自动卸载（删除自启动配置）

### 🚀 自动安装功能

使用菜单中的 `i` 选项即可一键完成所有安装配置：

```bash
# 运行脚本
./smart-screen.sh

# 选择 i 进行自动安装
# 或输入 i
```

**自动安装包含以下步骤：**

1. **依赖检查**
   - 自动检测 screen 是否已安装
   - 未安装时自动安装（支持 apt-get 和 yum）

2. **权限设置**
   - 自动设置脚本执行权限

3. **自启动配置**
   - 检测是否已存在配置
   - 追加或更新 `~/.bashrc` 中的自启动配置
   - 配置SSH登录自动提示

4. **完成提示**
   - 显示详细的配置完成信息
   - 提供后续操作指南

**特性：**
- ✅ **智能检测**：自动检测现有配置，避免重复
- ✅ **自动安装**：支持主流Linux发行版
- ✅ **安全确认**：已存在配置时提示用户选择
- ✅ **彩色界面**：清晰的操作提示和进度反馈

### 🛑 自动卸载功能

使用菜单中的 `u` 选项即可完全卸载自启动配置：

```bash
# 运行脚本
./smart-screen.sh

# 选择 u 进行自动卸载
# 或输入 u
```

**自动卸载包含以下步骤：**

1. **安全确认**
   - 明确提示卸载内容和影响
   - 用户确认后才执行

2. **配置清理**
   - 删除 `~/.bashrc` 中的自启动配置
   - 清理相关环境变量

3. **完成确认**
   - 显示详细的卸载完成信息
   - 说明保留的组件（现有会话不会被删除）

**卸载内容：**
- ❌ 删除 `~/.bashrc` 中的自启动配置
- ❌ 清理 `SMART_SCREEN_STARTED` 环境变量

**卸载后：**
- ✅ 现有会话继续运行，不会被删除
- ✅ 下次登录不会再自动提示
- ✅ 需要手动运行脚本：`./smart-screen.sh`

### 📝 完整安装流程示例

```bash
# 1. 运行主脚本
./smart-screen.sh

# 2. 选择 i 进行自动安装
# 系统会显示安装进度和结果

# 3. 安装完成后断开SSH重新登录
# 或手动运行脚本测试

# 4. 如需卸载，运行脚本选择 u
```

**推荐使用场景：**
- ✅ 新用户首次安装
- ✅ 系统迁移后重新配置
- ✅ 修复配置问题
- ✅ 快速启用/禁用自启动

### Screen 会话操作技巧

- **分离会话**：按 `Ctrl+A` 再按 `D`
- **重新连接**：运行脚本后选择对应会话
- **列出所有会话**：`screen -ls`
- **强制删除会话**：`screen -S <session_name> -X quit`

## 📁 文件说明

### 核心文件
- `smart-screen.sh` - 主脚本文件（会话管理器核心）
- `README.md` - 本文件（完整使用手册）
- `LICENSE` - MIT开源许可证文件
- `.screenrc` - Screen配置文件
- `.screenrc.ps1` - PS1自动加载配置

### 配置文件
- `.shellcheckrc` - ShellCheck代码质量检查配置

### 历史文件（temp/目录）
- `temp/legacy_scripts/` - 历史脚本文件（18个）
- `temp/legacy_docs/` - 历史文档文件（38个）

### 备份文件（bak/目录）
- `screen-selector.sh` - 原版脚本备份
- `screen-selector.sh.bak` - 早期版本备份
- `clean-duplicate-screens.sh` - 重复清理脚本备份

## 🔍 使用场景

### 场景1：开发工作流
```bash
# 登录后运行脚本
/root/smart-screen.sh

# 选择 1 进入开发环境会话
# 在该会话中执行开发任务
# 完成工作后按 Ctrl+A D 分离会话
# 下次登录时重新选择 1 即可恢复之前的操作
```

### 场景2：多环境运维
```bash
# 预设不同环境会话
1 - dev环境（开发）
2 - test环境（测试）
3 - prod环境（生产）
4 - db环境（数据库）

# 快速切换不同环境进行运维操作
```

### 场景3：后台任务监控
```bash
# 5-monitor 会话运行监控系统
# 6-backup 会话运行备份任务
# 7-log 会话实时查看日志

# 所有任务在后台持续运行，不会因SSH断开而终止
```

## ⚙️ 高级配置

### 自定义会话配置

编辑 `smart-screen.sh` 文件中的 `SESSION_MAP` 数组：

```bash
declare -A SESSION_MAP=(
    [1]="dev-开发环境"
    [2]="test-测试环境"
    [3]="prod-生产环境"
    # 添加更多自定义会话...
)
```

### 修改自动启动行为

编辑 `~/.bashrc` 中的自动启动配置，可以：
- 修改提示信息
- 调整启动逻辑
- 添加条件判断

### 使用测试脚本

定期运行测试脚本可以确保系统正常运行：

```bash
# 运行完整测试
./test_screen_manager.sh

# 测试内容包括：
# - screen 安装检查
# - 脚本文件完整性
# - 脚本语法验证
# - screen 基本功能
# - 会话配置检查
```

### 与其他工具集成

#### 与 tmux 共存
```bash
# 检查是否在 tmux 中运行
if [[ -z "$TMUX" ]]; then
    # 仅在非 tmux 环境中启动
    /root/smart-screen.sh
fi
```

#### 与 SSH 别名结合
```bash
# 在 ~/.bashrc 中添加
alias sdev='screen -r dev-开发环境'
alias stest='screen -r test-测试环境'
alias sprod='screen -r prod-生产环境'
```

## ❓ 常见问题

### Q1: 脚本没有自动启动？
**A:**
1. 检查是否为交互式 shell：`echo $-` 应该包含 `i`
2. 重新加载配置：`source ~/.bashrc`
3. 手动测试：`/root/smart-screen.sh`

### Q2: screen 命令不存在？
**A:**
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install screen

# CentOS/RHEL
sudo yum install screen
```

### Q3: 权限问题？
**A:**
```bash
# 确保脚本有执行权限
chmod +x /root/smart-screen.sh

# 检查 screen 会话权限
ls -la /run/screen/
```

### Q4: 如何取消自动启动？
**A:**
编辑 `~/.bashrc` 文件，删除或注释掉自动启动相关的代码。

### Q5: 预设会话不够用？
**A:**
1. 编辑脚本修改 `SESSION_MAP` 数组
2. 使用 `a` 命令查看所有活跃会话并选择
3. 使用 `screen -S <name>` 创建自定义会话

### Q6: 会话意外关闭？
**A:**
1. 检查会话是否真的关闭：`screen -ls`
2. 重新创建会话：运行脚本选择对应数字
3. 查看日志分析原因：`tail -f /var/log/syslog`

### Q7: 如何验证系统是否正常工作？
**A:**
使用测试脚本进行全面检测：
```bash
./test_screen_manager.sh
```
该脚本会自动检查所有组件并生成测试报告。

## 🛠️ 故障排除

### 查看日志
```bash
# 查看安装日志
cat /tmp/smart_screen_install.log

# 查看系统日志
sudo journalctl -u ssh
```

### 重新安装

#### 方法一：使用主脚本（推荐）

```bash
# 卸载旧配置
./smart-screen.sh
# 选择 u 进行自动卸载

# 重新安装
# 再次运行脚本选择 i 进行自动安装
```

#### 方法二：手动清理

```bash
# 清理配置
sed -i '/smart-screen/d' ~/.bashrc

# 重新运行脚本选择 i 进行自动安装
./smart-screen.sh
```

### 测试连接
```bash
# 测试 screen 基本功能
screen -list

# 测试脚本语法
bash -n /root/smart-screen.sh

# 手动运行脚本
./smart-screen.sh
```

## 📝 更新日志

### v2.0 (当前版本)
- ✨ **多用户协作功能** - 支持多个用户同时连接同一个会话，使用 `screen -xR`
- ✨ **简洁提示符** - 告别冗长提示符，只显示必要信息 `[会话名]用户@主机`
- ✨ **菜单版权信息** - 在菜单顶部显示版权和开源协议信息
- ✨ **极简项目结构** - 精简项目结构，只保留6个核心文件
- ✨ **自动权限管理** - 自动启用多用户模式，无需手动配置
- ✨ **专业界面** - 美化菜单界面，添加图标和彩色输出
- ✨ **预设9个会话** - 满足不同工作场景需求
- ✨ **自动创建/连接** - 智能检测会话状态，自动创建或连接
- ✨ **防重复机制** - 自动检测并清理重复会话
- ✨ **一键安装** - 自动安装依赖、配置自启动
- ✨ **完整文档** - README文档、多用户指南、提示符配置等

### v1.3 (原版)
- 基础会话管理功能
- 彩色输出界面
- 手动选择会话

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 报告问题
请在 GitHub Issues 中报告问题，包含：
- 操作系统信息
- 错误信息
- 重现步骤

### 功能建议
欢迎提出新功能建议，包括：
- 使用场景描述
- 预期效果
- 实现方案

## 📄 许可证

本项目采用 **MIT License** 开源协议。

- **作者**: Ducky (ducky@live.com)
- **版权所有**: © 2026 Ducky
- **许可证**: MIT License
- **详细条款**: 请查看 [LICENSE](LICENSE) 文件

### MIT 许可证要点
- ✅ 允许自由使用、修改和分发
- ✅ 允许商业使用
- ✅ 允许私人使用
- ✅ 无传染性（无需开源衍生作品）
- ⚠️ 需要保留版权声明和许可证声明

更多信息请查看 [LICENSE](LICENSE) 文件。

## 🙏 致谢

感谢所有为开源社区做出贡献的开发者！

---

**祝您使用愉快！** 🎉

## 📖 快速索引

| 需求 | 对应文件 | 说明 |
|------|----------|------|
| 🚀 快速开始 | `smart-screen.sh` | 运行主脚本开始使用 |
| 📚 完整使用手册 | `README.md` | 本文档，涵盖所有功能 |
| 📄 开源许可证 | `LICENSE` | MIT许可证全文 |
| ⚙️ Screen配置 | `.screenrc` | Screen会话配置 |
| 🎨 提示符配置 | `.screenrc.ps1` | 简洁提示符配置 |
| 🔍 代码质量 | `.shellcheckrc` | ShellCheck检查配置 |
| 📊 项目总结 | `temp/legacy_docs/` | 查看历史文档目录 |

**如有问题，请查看文档或提交 Issue。**
