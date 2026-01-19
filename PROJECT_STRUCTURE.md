# Smart Screen Session Manager - 项目结构

## 📁 当前文件结构

```
smart-screen/
├── smart-screen.sh          # 🎯 主脚本文件（核心）
├── quick_setup.sh          # 🚀 快速安装配置脚本
├── test_screen_manager.sh  # 🧪 功能测试脚本
├── bak/                    # 💾 备份文件目录
│   ├── screen-selector.sh          # 原始版本备份
│   ├── screen-selector.sh.bak      # 早期版本备份
│   └── clean-duplicate-screens.sh  # 重复清理备份
├── README.md               # 📖 主文档 - 完整使用手册
├── AUTO_START_SETUP.md     # ⚙️ 自动启动详细配置指南
├── AUTO_START_OPTIONS.md   # 📋 自动启动方案对比
├── PROJECT_SUMMARY.md      # 📊 项目总结报告
└── PROJECT_STRUCTURE.md   # 📄 项目结构说明
```

## 📝 文件说明

### 🔧 核心脚本文件

- **`smart-screen.sh`** (12KB) - **⭐ 主脚本文件**
  - 智能 Screen 会话管理器核心
  - 预设9个常用会话（dev/test/prod/db/monitor/backup/log/debug/research）
  - 自动创建/连接机制
  - 美化界面（彩色输出+图标）
  - 完整会话管理功能（清理、删除、编辑等）
  - **这是最重要的文件！**

- **`quick_setup.sh`** (7.1KB)
  - 一键安装配置脚本
  - 自动检查依赖、安装screen、配置SSH自动启动
  - 彩色界面，完整错误处理
  - **推荐使用此脚本进行安装**

- **`test_screen_manager.sh`** (11KB)
  - 功能测试脚本
  - 验证screen安装、脚本语法、会话配置
  - 用于故障排除和系统诊断

### 💾 备份目录（bak/）

- **`screen-selector.sh`** - 原始版本脚本备份
- **`screen-selector.sh.bak`** - 早期版本备份
- **`clean-duplicate-screens.sh`** - 重复会话清理脚本备份

### 📚 文档文件

- **`README.md`** (7.4KB) - **主文档**
  - 完整使用手册，新用户必读
  - 包含安装、使用、配置、故障排除
  - 涵盖所有核心功能和操作说明

- **`AUTO_START_SETUP.md`** (5.8KB) - **配置指南**
  - SSH自动启动详细配置方法
  - 包含3种配置方案
  - 完整的故障排除指南
  - 高级用户参考手册

- **`AUTO_START_OPTIONS.md`** (4.9KB) - **方案对比**
  - 3种自动启动方案详细对比
  - 帮助用户根据需求选择最适合的方案
  - 包含优缺点分析和推荐度

- **`PROJECT_SUMMARY.md`** (8.3KB) - **项目总结**
  - 项目完成情况总结
  - 需求实现对照表
  - 技术特性详解
  - 使用场景示例

## 🚀 快速开始

### 推荐安装方式
```bash
cd /root/smart-screen
./quick_setup.sh
```

### 直接使用主脚本
```bash
# 运行主脚本（会话管理器）
./smart-screen.sh

# 或者测试系统
./test_screen_manager.sh
```

## 📊 文件统计

| 分类 | 文件数 | 大小 | 说明 |
|------|--------|------|------|
| **核心脚本** | 1 | ~12KB | 主脚本文件 |
| **安装脚本** | 2 | ~18KB | 安装和测试 |
| **备份文件** | 3 | <1KB | 历史版本备份 |
| **文档文件** | 5 | ~26KB | 完整文档体系 |
| **总计** | **11** | **~56KB** | **功能完整** |

## 💡 使用建议

1. **新用户**：从 `README.md` 开始阅读
2. **安装配置**：运行 `quick_setup.sh`
3. **日常使用**：运行 `./smart-screen.sh`
4. **自定义配置**：参考 `AUTO_START_OPTIONS.md` 选择方案
5. **高级配置**：查看 `AUTO_START_SETUP.md`
6. **故障排除**：运行 `test_screen_manager.sh`

## ✨ 核心特性

### smart-screen.sh 主要功能
- ✅ **预设9个会话** - 覆盖开发、测试、生产、数据库等场景
- ✅ **自动创建/连接** - 输入1-9，不存在则创建，存在则连接
- ✅ **美化界面** - 彩色输出、图标、状态显示
- ✅ **会话管理** - 显示所有会话、清理重复、删除所有
- ✅ **安全操作** - 交互式确认、错误处理

### 快捷键操作
| 快捷键 | 功能 |
|--------|------|
| `1-9` | 进入对应预设会话 |
| `a` | 显示所有活跃会话 |
| `c` | 清理重复会话 |
| `d` | 删除所有会话 |
| `e` | 编辑脚本 |
| `h` | 显示帮助 |
| `q` | 退出 |

## ⚠️ 重要说明

**smart-screen.sh 是项目的核心文件！**
- 这是实际运行会话管理器的脚本
- quick_setup.sh 只是安装/配置脚本
- 所有文档中提到的 `./smart-screen.sh` 都是指这个主脚本

## 📝 更新记录

- **2026-01-19 17:36** - 恢复主脚本文件 smart-screen.sh（曾误删）
- **2026-01-19 17:35** - 恢复备份目录 bak/
- **2026-01-19 17:30** - 初始项目清理

---

*更新时间：2026-01-19* | *状态：✅ 核心文件已恢复*
