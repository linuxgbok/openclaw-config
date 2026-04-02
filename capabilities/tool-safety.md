# 🔒 Tool 安全分级

> 给工具操作分类，明确危险等级

---

## 危险等级

| 等级 | 标识 | 说明 | 是否需要确认 |
|------|------|------|-------------|
| 🔴 **DESTRUCTIVE** | `isDestructive` | 删除、覆盖、不可逆操作 | **必须确认** |
| 🟡 **WRITE** | `isReadOnly: false` | 创建、修改文件/数据库 | 建议确认 |
| 🟢 **READ** | `isReadOnly: true` | 只读查询、读取 | 不需要 |

---

## DESTRUCTIVE 操作（必须确认）

### 文件操作
- `rm` / `trash` - 删除文件/目录
- `mv` / `cp` - 覆盖文件
- `echo` / `tee` - 覆盖文件内容
- `chmod` - 修改权限

### 系统操作
- `kill` - 终止进程
- `pkill` - 批量终止进程
- `shutdown` / `reboot` - 关机重启
- `diskutil` / `dd` - 磁盘操作

### 危险命令示例
```bash
rm -rf /path           # 递归删除
mv old new             # 覆盖目标
> file                 # 清空文件
kill -9 PID            # 强制终止
```

---

## WRITE 操作（建议确认）

### 文件操作
- `touch` - 创建空文件
- `mkdir` - 创建目录
- `cp` / `mv` - 复制/移动
- `nano` / `vim` - 编辑文件
- `git push` - 推送代码

### 网络操作
- `curl` / `wget` - 发送请求
- `ssh` - 远程连接
- `scp` - 远程复制

---

## READ 操作（安全）

### 查询操作
- `cat` / `head` / `tail` - 读取文件
- `ls` / `find` - 列出文件
- `grep` / `rg` - 搜索内容
- `git status` / `git log` - 查看状态
- `ps` / `top` - 查看进程
- `df` / `du` - 查看磁盘

### 编译/构建
- `make build` / `npm build` - 编译（不安装）
- `python -m py_compile` - 语法检查

---

## 确认规则

### DESTRUCTIVE 必须二次确认
```
⚠️ 危险操作：rm -rf /path
是否确认执行？输入 "yes" 确认：
```

### WRITE 操作首次确认
```
📝 操作：git push origin main
目标：github.com/linuxgbok/repo
是否确认？
```

### 记住选择
- 相同操作 + 相同目标 → 记住选择
- 记录在 `~/.openclaw/workspace/capabilities/approved-actions.json`

---

## 并发安全

| 工具 | `isConcurrencySafe` | 说明 |
|------|---------------------|------|
| `read` | ✅ true | 可并发 |
| `grep` | ✅ true | 可并发 |
| `ls` | ✅ true | 可并发 |
| `write` | ❌ false | 需排队 |
| `edit` | ❌ false | 需排队 |
| `exec` | ❌ false | 需排队 |

---

## 实施检查清单

- [ ] exec 工具 → 检查 isDestructive
- [ ] write 工具 → 检查 isConcurrencySafe
- [ ] rm/trash → 必须确认
- [ ] git push → 建议确认
- [ ] 网络请求 → 确认目标

---

_最后更新：2026-04-02_
