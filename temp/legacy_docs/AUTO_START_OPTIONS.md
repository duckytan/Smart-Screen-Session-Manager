# Smart Screen Session Manager - 自动启动配置方案

## 方案选择指南

您可以根据需求选择以下三种自动启动方案之一：

---

## 方案1：完整功能版（推荐⭐⭐⭐⭐⭐）

### 特点
- ✅ 功能最完整
- ✅ 界面最美观
- ✅ 安全可靠
- ✅ 文档齐全

### 配置方式
```bash
cd /root/smart-screen
./install_auto_start.sh
```

### 登录效果
```
╔════════════════════════════════════════════════════════════╗
║              欢迎使用 Smart Screen Session Manager          ║
╚════════════════════════════════════════════════════════════╝

📋 预设会话：
  1-dev  2-test  3-prod  4-db  5-monitor
  6-backup  7-log  8-debug  9-research

是否启动Screen会话管理器？ [Y/n]:
```

---

## 方案2：简洁改进版

### 特点
- ✅ 逻辑最简洁
- ✅ 启动最快
- ✅ 功能基本够用
- ✅ 适合极简主义者

### 配置代码
将以下代码添加到 `~/.bashrc` 文件末尾：

```bash
# Smart Screen Session Manager - 简洁版自动启动
if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$SMART_SCREEN_STARTED" ]; then
    export SMART_SCREEN_STARTED=1
    [ -x "/root/smart-screen/smart-screen.sh" ] && /root/smart-screen/smart-screen.sh
fi
```

### 配置步骤
```bash
# 1. 编辑 .bashrc
nano ~/.bashrc

# 2. 滚动到文件末尾，粘贴上面的代码
# 3. 保存退出：Ctrl+X → Y → Enter

# 4. 重新加载配置
source ~/.bashrc
```

### 登录效果
直接启动脚本（无提示界面）

---

## 方案3：平衡混合版

### 特点
- ✅ 简洁与美观兼顾
- ✅ 有美化界面
- ✅ 功能完整
- ✅ 最佳平衡

### 配置代码
将以下代码添加到 `~/.bashrc` 文件末尾：

```bash
# Smart Screen Session Manager - 混合版自动启动
if [ -z "$STY" ] && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$SMART_SCREEN_STARTED" ]; then
    export SMART_SCREEN_STARTED=1
    SCRIPT_PATH="/root/smart-screen/smart-screen.sh"

    if [ -x "$SCRIPT_PATH" ]; then
        clear
        echo ""
        echo -e "\033[0;36m╔════════════════════════════════════════════════════════════╗\033[0m"
        echo -e "\033[0;36m║\033[1;37m           Smart Screen Session Manager                    \033[0;36m║\033[0m"
        echo -e "\033[0;36m╚════════════════════════════════════════════════════════════╝\033[0m"
        echo ""
        read -p "是否启动？ [Y/n]: " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]] && exec "$SCRIPT_PATH"
    fi
fi
```

### 配置步骤
```bash
# 1. 编辑 .bashrc
nano ~/.bashrc

# 2. 滚动到文件末尾，粘贴上面的代码
# 3. 保存退出：Ctrl+X → Y → Enter

# 4. 重新加载配置
source ~/.bashrc
```

### 登录效果
```
╔════════════════════════════════════════════════════════════╗
║           Smart Screen Session Manager                    ║
╚════════════════════════════════════════════════════════════╝

是否启动？ [Y/n]:
```

---

## 对比表格

| 特性 | 方案1 完整版 | 方案2 简洁版 | 方案3 混合版 |
|------|-------------|-------------|-------------|
| 环境检测 | ✅ 完整 | ✅ 改进 | ✅ 完整 |
| 防重复启动 | ✅ 环境变量 | ✅ 环境变量 | ✅ 环境变量 |
| 美化界面 | ✅ 完整 | ❌ 无 | ✅ 简化 |
| 启动提示 | ✅ 完整信息 | ❌ 直接启动 | ✅ 简洁提示 |
| 功能性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 简洁性 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 推荐度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 取消自动启动

无论使用哪个方案，取消自动启动的方法都是：

```bash
# 方法1：编辑 .bashrc 删除
nano ~/.bashrc
# 删除自动启动代码块

# 方法2：快速移除
sed -i '/Smart Screen Session Manager/,/^fi$/d' ~/.bashrc

# 重新加载
source ~/.bashrc
```

---

## 验证配置

```bash
# 检查 .bashrc 配置
grep -A 5 "Smart Screen" ~/.bashrc

# 测试脚本
/root/smart-screen/smart-screen.sh

# 断开SSH重新登录测试
```

---

## 最佳实践建议

1. **新用户**：推荐方案1（完整功能版）
2. **老用户**：推荐方案3（平衡混合版）
3. **极简主义者**：推荐方案2（简洁改进版）

---

*最后更新：2026-01-19* | *版本：v2.0*
