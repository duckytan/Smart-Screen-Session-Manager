# 🚀 一键安装指南

## 最简单的安装方法

直接在终端中运行以下命令：

```bash
curl -fsSL https://github.com/duckytan/Smart-Screen-Session-Manager/releases/download/2.0test/smart-screen.sh | bash
```

## 其他安装方法

### 方法2: 使用 wget
```bash
wget -qO- https://github.com/duckytan/Smart-Screen-Session-Manager/releases/download/2.0test/smart-screen.sh | bash
```

### 方法3: 下载后手动安装
```bash
# 下载脚本
curl -fsSL -o smart-screen.sh https://github.com/duckytan/Smart-Screen-Session-Manager/releases/download/2.0test/smart-screen.sh

# 设置权限
chmod +x smart-screen.sh

# 运行脚本
./smart-screen.sh
```

### 方法4: 使用完整安装脚本
```bash
# 下载安装脚本
curl -fsSL -o quick-install.sh https://github.com/duckytan/Smart-Screen-Session-Manager/releases/download/2.0test/quick-install.sh

# 运行安装脚本
chmod +x quick-install.sh
./quick-install.sh
```

## 安装后操作

1. 运行脚本：
   ```bash
   ~/smart-screen.sh
   ```

2. 在菜单中选择：
   - **i** - 自动安装（安装依赖 + 配置自启动）
   - **1-9** - 进入预设会话
   - **q** - 退出

## 系统要求

- Linux 系统（Ubuntu、Debian、CentOS、RHEL、Arch Linux）
- 网络连接（访问 GitHub）
- Root 权限（安装 screen 时需要）

## 注意事项

- 安装过程需要网络连接
- 安装 screen 时可能需要 sudo 权限
- 首次运行建议选择 "i" 进行自动安装

## 卸载

如需卸载，编辑 `~/.bashrc` 文件，删除自动启动相关配置。

## 支持

如有问题，请访问：https://github.com/duckytan/Smart-Screen-Session-Manager
