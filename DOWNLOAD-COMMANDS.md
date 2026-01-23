# 📥 一键下载指令

## 🚀 Smart Screen Session Manager

### 下载并运行
```bash
curl -fsSL https://raw.githubusercontent.com/duckytan/Smart-Screen-Session-Manager/main/smart-screen.sh -o smart-screen.sh && chmod +x smart-screen.sh && ./smart-screen.sh
```

### 仅下载
```bash
curl -fsSL https://raw.githubusercontent.com/duckytan/Smart-Screen-Session-Manager/main/smart-screen.sh -o smart-screen.sh
```

---

## 🖥️ Server Setup (公开版)

### 下载并运行（需要root）
```bash
curl -fsSL https://raw.githubusercontent.com/duckytan/Smart-Screen-Session-Manager/main/server-setup-public.sh -o server-setup-public.sh && chmod +x server-setup-public.sh && sudo ./server-setup-public.sh
```

### 仅下载
```bash
curl -fsSL https://raw.githubusercontent.com/duckytan/Smart-Screen-Session-Manager/main/server-setup-public.sh -o server-setup-public.sh
```

---

## 🔧 指令说明

| 参数 | 说明 |
|------|------|
| `-f` | 失败时静默（不显示错误） |
| `-s` | 静默模式（不显示进度） |
| `-S` | 显示错误（配合-f使用） |
| `-L` | 跟随重定向 |
| `-o file` | 输出到指定文件 |
| `&&` | 上一个命令成功后才执行下一个 |
| `chmod +x` | 添加执行权限 |
| `sudo` | 以root权限运行（仅server-setup需要） |

---

## ⚠️ 注意事项

1. **仓库地址**：已配置为 `duckytan/Smart-Screen-Session-Manager`
2. **检查内容**：建议先下载检查内容再执行
3. **权限要求**：
   - `smart-screen.sh`：普通用户即可
   - `server-setup-public.sh`：需要root权限（使用sudo）
4. **网络安全**：只从可信的GitHub仓库下载
5. **执行权限**：下载后记得添加执行权限（`chmod +x`）

---

## 🎯 使用步骤

### 步骤1：仓库已创建
✅ 您的GitHub仓库：`https://github.com/duckytan/Smart-Screen-Session-Manager`

### 步骤2：上传脚本
将以下文件上传到仓库的 `main` 分支：
- `smart-screen.sh`
- `server-setup-public.sh`
- `VERSION-INFO.md`
- `DOWNLOAD-COMMANDS.md`

### 步骤3：直接使用
复制下方的指令直接使用，无需修改！

---

## 🛡️ 安全建议

### 验证脚本完整性
```bash
# 下载但不执行
curl -fsSL https://raw.githubusercontent.com/duckytan/Smart-Screen-Session-Manager/main/smart-screen.sh -o smart-screen.sh

# 检查前20行
head -20 smart-screen.sh

# 检查是否有可疑内容
grep -E "(curl.*\|.*wget.*\|eval|exec)" smart-screen.sh

# 添加权限
chmod +x smart-screen.sh

# 执行
./smart-screen.sh
```

### 比较哈希值（高级）
```bash
# 下载脚本
curl -fsSL URL -o script.sh

# 获取官方哈希（如果有提供）
sha256sum script.sh

# 比较哈希值
```

---

## 📞 故障排除

### 问题1：下载失败
```
curl: (7) Failed to connect to raw.githubusercontent.com port 443
```
**解决**：检查网络连接或GitHub仓库是否公开

### 问题2：权限被拒绝
```
Permission denied
```
**解决**：添加执行权限 `chmod +x script.sh`

### 问题3：不是可执行的二进制文件
```
/bin/bash^M: bad interpreter
```
**解决**：Windows换行符问题，使用dos2unix转换
```bash
dos2unix script.sh
chmod +x script.sh
```

### 问题4：sudo需要密码
```
[sudo] password for user:
```
**解决**：确保您有sudo权限，或使用 `su -` 切换到root用户

---

## 🔗 相关链接

- [GitHub Raw文件说明](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-files-from-the-command-line)
- [curl命令详解](https://curl.se/docs/manpage.html)
- [chmod权限说明](https://www.gnu.org/software/coreutils/manual/html_node/chmod-invocation.html)

---

## 📝 更新日志

- v1.0 (2026-01-23): 创建下载指令
