# Screen 多用户功能使用说明

## 📖 概述

本项目现在支持 screen 多用户功能，允许多个用户同时访问同一个 screen 会话，实现协作编程、远程调试和实时教学。

## 🚀 快速开始

### 1. 运行测试
```bash
./test_multiuser.sh
```
确保所有测试通过。

### 2. 创建多用户会话
```bash
# 使用辅助工具
./multiuser_helper.sh create dev alice,bob,charlie

# 或手动创建
screen -S dev -d -m
screen -S dev -X multiuser on
screen -S dev -X acladd alice
screen -S dev -X acladd bob
```

### 3. 连接会话
```bash
# 其他用户使用以下格式连接
screen -S username/sessionname

# 示例
screen -S alice/dev  # alice 用户连接
screen -S bob/dev    # bob 用户连接
```

## 📁 文档说明

| 文档 | 描述 |
|------|------|
| `MULTIUSER_SETUP.md` | 详细的配置指南和说明 |
| `MULTIUSER_EXAMPLE.md` | 10+ 个实际使用示例 |
| `MULTIUSER_QUICKSTART.md` | 快速使用指南 |
| `README_MULTIUSER.md` | 本文件（快速说明） |

## 🛠️ 工具说明

| 工具 | 用途 |
|------|------|
| `multiuser_helper.sh` | 辅助管理工具，简化创建和连接会话 |
| `setup_multiuser.sh` | 快速设置向导，一键配置环境 |
| `test_multiuser.sh` | 配置测试工具，验证环境是否正确 |

## 💡 使用示例

### 示例 1：基本协作
```bash
# Alice 创建会话
screen -S project -d -m
screen -S project -X multiuser on
screen -S project -X acladd bob

# Bob 连接
screen -S alice/project
```

### 示例 2：不同权限
```bash
# 完整权限
screen -S dev -X acladd alice +rwx

# 读写权限
screen -S dev -X acladd bob +rw

# 只读权限
screen -S dev -X acladd charlie +r
```

### 示例 3：实时协作编程
```bash
# 创建协作会话
screen -S coding -d -m
screen -S coding -X multiuser on
screen -S coding -X acladd developer1
screen -S coding -X acladd developer2

# 所有开发者连接
screen -S alice/coding  # developer1 连接
screen -S bob/coding    # developer2 连接
```

## 🔐 权限说明

| 权限 | 描述 |
|------|------|
| `+rwx` | 完全权限（可输入命令、创建窗口、修改配置） |
| `+rw` | 读写权限（可输入命令、创建窗口，但不能修改配置） |
| `+r` | 只读权限（只能查看，不能输入命令） |

## 🐛 故障排除

### 权限被拒绝
```bash
# 检查并重新添加权限
screen -S name -X acladd username
```

### 会话不存在
```bash
# 查看所有会话
screen -ls

# 使用正确格式
screen -S username/sessionname
```

### 会话被占用
```bash
# 强制分离
screen -S username/sessionname -X detach
```

## 📚 详细文档

- [详细配置指南](./MULTIUSER_SETUP.md) - 完整的配置说明
- [使用示例](./MULTIUSER_EXAMPLE.md) - 10+ 个实际案例
- [快速指南](./MULTIUSER_QUICKSTART.md) - 简洁的使用说明

## ✨ 总结

Screen 多用户功能已成功配置并测试通过！

**测试结果**：
- ✓ 所有 7 个测试通过
- ✓ screen 支持 multiuser 功能
- ✓ .screenrc 配置正确
- ✓ 会话创建和权限管理正常

**使用场景**：
- 协作编程：团队成员实时查看和操作同一个终端
- 技术支持：支持人员直接访问用户终端进行调试
- 实时教学：展示操作过程给多个观众

**开始使用**：
```bash
# 1. 运行测试
./test_multiuser.sh

# 2. 创建会话
./multiuser_helper.sh create dev alice,bob

# 3. 连接会话
./multiuser_helper.sh connect alice dev
```

---

**参考资源**：
- [GNU Screen 官方文档](https://www.gnu.org/software/screen/)
- [Screen 多用户配置指南](https://aperiodic.net/screen/multiuser)

---

*祝您使用愉快！🚀*
