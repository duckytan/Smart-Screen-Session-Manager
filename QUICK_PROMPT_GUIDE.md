# Screen 简洁提示符 - 快速指南

## 🎯 问题解决

**原提示符**（太长）：
```
[screen 0: root@VM-0-8-opencloudos:~] [dev-[dev-开发环境] root@dev-开发环境$
```

**新提示符**（简洁）：
```
[dev-开发环境]root@VM-0-8-opencloudos$
```

## 🚀 应用新提示符

### 方法1：重新连接会话（推荐）

```bash
# 1. 退出当前会话
# 按 Ctrl+A D

# 2. 重新连接会话
screen -xR "dev-开发环境"
```

### 方法2：创建新会话

```bash
# 1. 创建新会话
screen -S "dev-开发环境" -d -m bash

# 2. 连接会话
screen -xR "dev-开发环境"
```

## 📋 配置详情

### .screenrc 配置

```bash
# 简洁提示符配置
hardstatus alwayslastline
hardstatus string '%{= kG}[%{G}%S%{g}]%{W} %H %{g}%'
```

### PS1 自动加载

```bash
# ~/.bashrc 自动加载
if [ -f ~/.screenrc.ps1 ]; then
    source ~/.screenrc.ps1
fi
```

## 🎨 提示符格式

### 当前格式
```
[会话名称]用户名@主机名$
```

### 示例
```
[dev-开发环境]root@VM-0-8-opencloudos$
[test-测试环境]alice@server1$
[prod-生产环境]bob@webserver$
```

## 🔧 自定义提示符

### 修改 PS1

编辑 `~/.screenrc.ps1`：

```bash
# 只显示会话名称
export PS1="\[\e]0;[\$SESSION_NAME] \a\]\\$ "

# 显示会话名称和主机
export PS1="\[\e]0;[\$SESSION_NAME] \h\a\]\\$ "

# 显示会话名称、用户和主机
export PS1="\[\e]0;[\$SESSION_NAME] \u@\h\a\]\\$ "
```

### 修改 Hardstatus

编辑 `~/.screenrc`：

```bash
# 只显示会话名称
hardstatus string '%{= kG}[%{G}%S%{g}]%'

# 显示会话名称和主机
hardstatus string '%{= kG}[%{G}%S%{g}]%{W} %H %{g}%'

# 显示会话名称、用户和主机
hardstatus string '%{= kG}[%{G}%S%{g}]%{W} %n@%H %{g}%'
```

## 🎉 效果展示

### 多用户协作场景

```
[dev-开发环境]alice@VM-0-8-opencloudos$ git status
[dev-开发环境]bob@VM-0-8-opencloudos$ git pull
```

### 远程管理场景

```
[monitor-监控]root@production$ htop
[log-日志]admin@server$ tail -f /var/log/syslog
```

## ✅ 优势

1. **简洁明了** - 移除多余信息
2. **保留核心** - 会话、用户、主机
3. **多用户支持** - 协作时清晰识别
4. **完全可自定义** - 随时修改格式

---

**详细文档**：`SCREEN_SIMPLE_PROMPT.md`
**配置脚本**：`setup_screen_prompt.sh`
