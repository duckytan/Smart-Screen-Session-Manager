# 配置文件说明

本目录包含 Smart Screen Session Manager 的所有配置文件。

## 文件列表

### .screenrc
- **作用**: Screen 会话配置文件
- **功能**: 设置简洁提示符、启用多用户模式、配置快捷键
- **安装**: 已自动创建符号链接到 `~/.screenrc`
- **使用**: Screen 程序启动时自动读取

### .screenrc.ps1
- **作用**: PS1 提示符配置文件
- **功能**: 设置简洁提示符格式 `[会话名]用户@主机$`
- **安装**: 已自动创建符号链接到 `~/.screenrc.ps1`
- **使用**: 用户登录 Shell 时通过 `~/.bashrc` 自动加载

### .shellcheckrc
- **作用**: ShellCheck 代码质量检查配置
- **功能**: 定义代码检查规则、错误忽略选项
- **安装**: 已自动创建符号链接到 `~/.shellcheckrc`
- **使用**: 运行 `shellcheck smart-screen.sh` 时自动读取

## 安装说明

这些配置文件已经自动创建符号链接到用户目录，可以直接使用：

```bash
# 检查符号链接
ls -la ~/.screenrc ~/.screenrc.ps1 ~/.shellcheckrc

# 查看配置文件内容
cat ~/.screenrc
cat ~/.screenrc.ps1
cat ~/.shellcheckrc

# 或直接查看 config 目录
cat /root/smart-screen/config/.screenrc
cat /root/smart-screen/config/.screenrc.ps1
cat /root/smart-screen/config/.shellcheckrc
```

## 自定义配置

如需自定义配置，可以：

1. **编辑符号链接指向的文件**（推荐）
   ```bash
   nano ~/.screenrc
   nano ~/.screenrc.ps1
   nano ~/.shellcheckrc
   ```

2. **编辑 config 目录下的源文件**
   ```bash
   nano /root/smart-screen/config/.screenrc
   nano /root/smart-screen/config/.screenrc.ps1
   nano /root/smart-screen/config/.shellcheckrc
   ```

两种方式效果相同，因为符号链接指向同一文件。

## 原理说明

- Screen 会在用户目录查找 `.screenrc` 文件
- Bash 会在用户目录查找 `.screenrc.ps1` 文件
- ShellCheck 会在项目目录和用户目录查找 `.shellcheckrc` 文件

通过符号链接，我们既保持了项目的规范性（配置文件在 `config/` 目录），又满足了各程序的查找需求。
