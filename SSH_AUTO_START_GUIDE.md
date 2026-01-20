# SSH 自动启动使用指南

## 概述

修改后，SSH 登录后会自动启动 smart-screen 管理器，无需手动确认！

---

## 🎯 修改内容

### 1. 取消询问对话框
- ✅ SSH 登录后自动进入 smart-screen 菜单
- ✅ 无需按 `y` 确认
- ✅ 直接显示预设会话列表

### 2. 自动化安装过程
- ✅ 默认启用强制自动启动
- ✅ 默认启用提示符优化
- ✅ 无需用户手动选择

### 3. 智能多用户功能
- ✅ 自动检测会话状态
- ✅ 自动创建或连接会话
- ✅ 自动启用多用户模式

---

## 🚀 使用方法

### 方式 1：重新安装（推荐）

如果已经安装过，需要重新安装以应用新的自动启动配置：

```bash
# 进入脚本目录
cd /path/to/smart-screen

# 运行安装
./smart-screen.sh
# 选择 i 进行自动安装

# 或者直接运行
bash smart-screen.sh << 'INSTALL_EOF'
i
INSTALL_EOF
```

### 方式 2：手动配置

也可以手动修改 `~/.bashrc` 文件：

```bash
# 添加自动启动配置
cat >> ~/.bashrc << 'AUTO_EOF'

# Smart Screen Auto Start - 强制启动（自动进入菜单）
if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ]; then
    # 自动启动 Smart Screen 管理器
    bash "/path/to/smart-screen.sh"
fi
AUTO_EOF

# 重新加载配置
source ~/.bashrc
```

---

## 📋 安装过程对比

### 修改前

```
SSH登录行为选择：
  [1] 不自动启动（手动输入 'sm' 启动）
  [2] 询问式启动（登录时询问是否启动）
  [3] 强制自动启动（登录后直接启动）

请选择 [1-3]: _

是否要优化 Screen 会话提示符？(显示会话名称)
选择 [y/N]: _
```

### 修改后

```
SSH登录行为：
✓ 启用强制自动启动（登录后直接进入脚本）

配置自动启动...
✓ 自动启动配置完成

提示符优化：
✓ 启用 Screen 会话提示符优化

配置提示符优化...
✓ 提示符优化配置完成
```

---

## 🔧 配置内容

### SSH 自动启动配置

安装后，`~/.bashrc` 文件会包含：

```bash
# Smart Screen Auto Start - 强制启动（自动进入菜单）
if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ]; then
    # 自动启动 Smart Screen 管理器
    bash "/path/to/smart-screen.sh"
fi
```

### 提示符优化配置

自动启用提示符优化，显示会话名称：

```bash
# Smart Screen Prompt - 与 .screenrc 配合的简洁版
if [ -n "$STY" ]; then
    # 提取会话名称，隐藏screen默认提示符
    session_name=$(echo $STY | cut -d'.' -f2)

    # 获取会话的显示名称（中文）
    display_name="$session_name"
    case "$session_name" in
        dev) display_name="dev-开发环境" ;;
        test) display_name="test-测试环境" ;;
        prod) display_name="prod-生产环境" ;;
        db) display_name="db-数据库" ;;
        monitor) display_name="monitor-监控" ;;
        backup) display_name="backup-备份" ;;
        log) display_name="log-日志" ;;
        debug) display_name="debug-调试" ;;
        research) display_name="research-研究" ;;
    esac

    # 设置简洁的提示符格式
    # 格式: [dev-开发环境] 用户@dev$
    export PS1="[$display_name] \u@$session_name\$ "

    # 每次显示提示符时更新终端标题
    update_title() {
        echo -ne "\033]0;[$display_name] \u@$session_name\007"
    }

    # 在每个命令执行后更新标题
    trap 'update_title' DEBUG

    # 立即更新标题
    update_title
fi
```

---

## 💡 使用示例

### 场景 1：正常使用

1. **SSH 登录**：
   ```bash
   ssh user@server
   ```

2. **自动进入菜单**：
   ```
   ╔════════════════════════════════════════════════════════════╗
   ║                Smart Screen Session Manager v2.0           ║
   ╠════════════════════════════════════════════════════════════╣
   ║  智能Screen会话管理器 - 预设会话、自动创建、SSH恢复         ║
   ╚════════════════════════════════════════════════════════════╝

   📋 预设会话：

     [1] 📝 dev-开发环境 (未创建)
     [2] 📝 test-测试环境 (未创建)
     [3] 📝 prod-生产环境 (未创建)
     ...
   ```

3. **选择会话**：
   ```
   请选择操作: 1
   ```

### 场景 2：多用户协作

1. **Alice 创建会话**：
   ```bash
   ssh alice@server
   # 自动进入菜单
   # 选择 1 创建 dev 会话
   ```

2. **Bob 连接会话**：
   ```bash
   ssh bob@server
   # 自动进入菜单
   # 选择 1 连接 dev 会话
   ```

3. **自动启用多用户**：
   ```
   ✅ 会话创建成功!
   📡 多用户连接信息:
     其他用户连接: screen -S alice/dev
   ```

---

## 🔍 故障排除

### 问题 1：SSH 登录后没有自动进入菜单

**原因**：未重新安装或配置

**解决方案**：
```bash
# 重新运行安装
./smart-screen.sh
# 选择 i

# 或手动配置
source ~/.bashrc
```

### 问题 2：提示符没有显示会话名称

**原因**：提示符优化未启用

**解决方案**：
```bash
# 重新运行安装
./smart-screen.sh
# 选择 i

# 或手动添加配置
# 参考上面的配置内容
```

### 问题 3：想要取消自动启动

**解决方案**：
```bash
# 编辑 ~/.bashrc
vi ~/.bashrc

# 注释掉或删除 Smart Screen Auto Start 部分
# # Smart Screen Auto Start - 强制启动（自动进入菜单）
# if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ]; then
#     bash "/path/to/smart-screen.sh"
# fi

# 重新加载配置
source ~/.bashrc
```

---

## 📊 功能对比

| 功能 | 修改前 | 修改后 |
|------|--------|--------|
| **SSH 登录** | 弹出询问对话框 | 自动进入菜单 |
| **安装过程** | 需要手动选择 | 自动配置 |
| **多用户功能** | 需要手动配置 | 自动启用 |
| **提示符优化** | 需要手动选择 | 自动启用 |
| **用户体验** | 需要确认操作 | 无需确认 |

---

## 🎉 总结

**✅ 修改效果**：
- SSH 登录后自动进入 smart-screen 菜单
- 无需手动确认，直接开始使用
- 自动化安装过程，减少操作步骤
- 默认启用所有优化功能

**✅ 用户受益**：
- 更流畅的用户体验
- 减少操作步骤
- 自动化程度更高
- 多用户功能更便捷

**✅ 立即可用**：
- 无需重启服务器
- 重新安装后立即生效
- 所有功能正常

---

*SSH 自动启动配置已完成！登录后自动进入 smart-screen 菜单！🚀*
