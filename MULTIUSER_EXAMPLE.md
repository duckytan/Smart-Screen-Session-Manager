# Screen 多用户会话使用示例

## 场景：Alice 和 Bob 协作开发项目

本示例展示如何使用 screen 的多用户功能，让 Alice 和 Bob 能够同时在同一个 screen 会话中工作。

### 前置条件

- 两个用户：alice 和 bob
- 两个用户都在同一台服务器上
- screen 已启用 multiuser 支持

---

## 示例 1：基本多用户会话

### 步骤 1：Alice 创建共享会话

```bash
# Alice 的操作
# 创建名为 "dev-project" 的会话
screen -S dev-project -d -m

# 进入会话配置模式（如果需要）
# screen -r dev-project

# 启用多用户模式
screen -S dev-project -X multiuser on

# 添加 bob 用户权限
screen -S dev-project -X acladd bob

# 查看会话状态
screen -ls
# 输出：
# There is a screen on:
#   12345.dev-project  (Detached)
```

### 步骤 2：Bob 连接会话

```bash
# Bob 的操作
# 使用用户名/会话名格式连接
screen -S alice/dev-project

# 或者（如果 alice 是当前用户）
# screen -S alice/dev-project
```

### 步骤 3：验证连接

```bash
# Alice 和 Bob 现在都在同一个会话中
# 他们可以看到对方的操作

# 检查会话状态
screen -ls
# 输出：
# There are screens on:
#   12345.dev-project  (Attached)
#   12345.dev-project  (Detached)
```

---

## 示例 2：使用辅助工具

### 使用 multiuser_helper.sh

```bash
# Alice 创建会话
./multiuser_helper.sh create project-dev bob,charlie

# 输出：
# ✓ 会话 'project-dev' 创建成功!
#
# 连接命令:
#   会话所有者: screen -S alice/project-dev
#   其他用户:   screen -S username/project-dev
#
# 权限管理:
#   添加用户:   ./multiuser_helper.sh acl project-dev <username> +rwx
#   移除用户:   ./multiuser_helper.sh acl project-dev <username> -rwx

# Bob 连接会话
./multiuser_helper.sh connect alice project-dev

# Charlie 连接会话
./multiuser_helper.sh connect alice project-dev
```

---

## 示例 3：不同权限级别

### 创建会话并设置不同权限

```bash
# Alice 创建会话
screen -S collaboration-demo -d -m
screen -S collaboration-demo -X multiuser on

# 添加用户并设置不同权限
screen -S collaboration-demo -X acladd bob +rwx    # 完整权限
screen -S collaboration-demo -X acladd charlie +rw # 读写权限
screen -S collaboration-demo -X acladd dave +r     # 只读权限

# 验证权限设置
# Alice 进入会话
screen -r collaboration-demo

# 在会话内按 Ctrl+A，然后输入：
:acl
```

### 权限说明

- **+rwx**：完全权限（可以输入命令、创建窗口、修改配置）
- **+rw**：读写权限（可以输入命令、创建窗口，但不能修改会话配置）
- **+r**：只读权限（只能查看，不能输入命令）

---

## 示例 4：实时协作编程

### 场景：Alice 和 Bob 一起调试代码

```bash
# Alice 创建调试会话
screen -S debug-session -d -m
screen -S debug-session -X multiuser on
screen -S debug-session -X acladd bob

# Alice 进入会话并开始工作
screen -r debug-session

# 在会话中，Alice 和 Bob 都可以：
# - 看到彼此的输入
# - 看到实时的终端输出
# - 一起编辑代码
# - 一起运行命令

# 退出会话
# 按 Ctrl+A 然后按 D
```

---

## 示例 5：教学和演示

### 场景：老师演示操作给学生看

```bash
# 老师（teacher）创建演示会话
screen -S teaching-demo -d -m
screen -S teaching-demo -X multiuser on

# 添加所有学生权限（假设学生用户：student1, student2, student3）
screen -S teaching-demo -X acladd student1 +r
screen -S teaching-demo -X acladd student2 +r
screen -S teaching-demo -X acladd student3 +r

# 所有学生连接只读会话
# student1 连接
screen -S teacher/teaching-demo

# student2 连接
screen -S teacher/teaching-demo

# student3 连接
screen -S teacher/teaching-demo

# 老师开始演示，学生可以实时观看
# 老师按 Ctrl+A 然后按 D 退出会话
# 学生按 Ctrl+C 退出（只读模式）
```

---

## 示例 6：切换用户权限

### 在会话中动态调整权限

```bash
# Alice 进入她的会话
screen -r dev-project

# 在会话内按 Ctrl+A，然后输入以下命令：

# 查看当前权限
:acl

# 移除 bob 的权限
:acldel bob

# 添加新权限
:acladd bob +rw

# 只给特定窗口权限
:aclchg bob -w        # 移除对所有窗口的写入权限
:aclchg bob +w 0      # 给窗口 0 写入权限
```

---

## 示例 7：多窗口协作

### 创建多窗口会话

```bash
# Alice 创建多窗口会话
screen -S multi-window-demo -d -m
screen -S multi-window-demo -X multiuser on
screen -S multi-window-demo -X acladd bob

# Alice 进入会话
screen -r multi-window-demo

# 在会话中创建多个窗口
# 按 Ctrl+A 然后按 C 创建新窗口
# 按 Ctrl+A 然后按 N 切换到下一个窗口
# 按 Ctrl+A 然后按 P 切换到上一个窗口

# Bob 连接会话
screen -S alice/multi-window-demo

# Bob 可以在同一个会话中看到所有窗口
# 他们可以一起在不同窗口中工作
```

---

## 示例 8：故障排除

### 常见问题及解决方案

#### 问题 1：权限被拒绝

```bash
# 症状：Bob 尝试连接时收到 "Permission denied" 错误

# 解决方案：
# Alice 检查并重新添加权限
screen -S dev-project -X acladd bob

# 或者在会话内检查权限
screen -r dev-project
:acl
```

#### 问题 2：无法找到会话

```bash
# 症状：Bob 尝试连接时收到 "No such session" 错误

# 解决方案：
# 确认会话存在
screen -ls

# 使用正确的格式：username/sessionname
screen -S alice/dev-project
```

#### 问题 3：会话被占用

```bash
# 症状：无法连接到会话（已被占用）

# 解决方案：
# 查看会话状态
screen -ls

# 强制分离其他用户（需要权限）
screen -S alice/dev-project -X detach

# 或者请求其他用户退出
```

---

## 示例 9：安全最佳实践

### 设置安全的权限

```bash
# 1. 定期检查权限
screen -r your-session
:acl

# 2. 移除不活跃用户
screen -r your-session
:acldel inactive_user

# 3. 为敏感会话设置严格权限
screen -r sensitive-session
:acladd trusted_user +r

# 4. 使用 ACL 限制特定窗口访问
:aclchg username -w  # 移除对所有窗口的写入权限

# 5. 为不同用户设置不同权限级别
:acladd admin +rwx     # 管理员权限
:acladd developer +rw  # 开发者权限
:acladd viewer +r      # 观察者权限
```

---

## 示例 10：监控和调试

### 监控会话活动

```bash
# 查看所有会话（包括其他用户的）
screen -ls

# 查看特定用户的会话
screen -ls | grep alice

# 在会话中查看活动日志
screen -r dev-project

# 在会话内按 Ctrl+A 然后输入：
:log on      # 启用日志
:log off     # 关闭日志

# 查看日志文件
cat ~/screenlog-0.log
```

---

## 总结

以上示例涵盖了 screen 多用户功能的各种使用场景：

1. **基本协作**：两个或多个用户同时在一个会话中工作
2. **权限管理**：不同用户设置不同权限级别
3. **实时协作**：用于编程、调试和教学
4. **多窗口协作**：在多个窗口中同时工作
5. **安全配置**：确保会话安全
6. **故障排除**：解决常见问题

通过这些示例，你可以根据实际需求灵活使用 screen 的多用户功能，实现高效的协作和共享。

---

**参考命令速查表**

| 命令 | 描述 |
|------|------|
| `screen -S name -d -m` | 创建分离会话 |
| `screen -S name -X multiuser on` | 启用多用户模式 |
| `screen -S name -X acladd user` | 添加用户权限 |
| `screen -S name -X aclchg user +rwx` | 修改用户权限 |
| `screen -S name -X acldel user` | 移除用户权限 |
| `screen -S username/sessionname` | 连接多用户会话 |
| `screen -ls` | 列出所有会话 |
| `:acl` | 在会话内查看权限 |
| `:multiuser on` | 在会话内启用多用户模式 |
