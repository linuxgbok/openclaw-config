---
name: tool-safety
description: "工具安全分级：执行危险操作前自动检查和确认。区分 READ/WRITE/DESTRUCTIVE 三级安全等级。"
whenToUse: "当执行任何文件删除、覆盖、系统修改、网络请求等操作时自动触发"
---

# Tool Safety - 工具安全分级

## 安全等级

| 等级 | 标识 | 颜色 | 说明 |
|------|------|------|------|
| 🔴 **DESTRUCTIVE** | `destructive` | 红色 | 删除、覆盖、不可逆操作 |
| 🟡 **WRITE** | `write` | 黄色 | 创建、修改文件/数据库 |
| 🟢 **READ** | `read` | 绿色 | 只读查询、读取 |

---

## 🔴 DESTRUCTIVE - 必须确认

### 文件操作
- `rm -rf` / `trash` - 递归删除
- `mv` 覆盖已有文件
- `echo >` / `tee` - 覆盖文件
- `chmod` - 修改权限

### 系统操作
- `kill -9` - 强制终止进程
- `pkill` - 批量终止
- `shutdown` / `reboot` - 关机重启
- `diskutil` / `dd` - 磁盘操作

### 数据库操作
- `DROP TABLE` / `DROP DATABASE`
- `DELETE FROM` 无 WHERE
- `TRUNCATE`

---

## 🟡 WRITE - 建议确认

### 文件操作
- `touch` / `mkdir` - 创建空文件/目录
- `cp` / `mv` - 复制/移动
- `nano` / `vim` - 编辑文件
- `git push` / `git force-push`

### 网络操作
- `curl` / `wget` - 发送 HTTP 请求
- `ssh` / `scp` - 远程连接
- `rsync` - 同步文件

---

## 🟢 READ - 安全

### 查询操作
- `cat` / `head` / `tail` - 读取文件
- `ls` / `find` / `grep` - 搜索文件
- `git status` / `git log` - 查看状态
- `ps` / `top` / `df` / `du` - 查看系统

### 编译检查
- `make` / `npm build` - 编译（不安装）
- `python -m py_compile` - 语法检查
- `eslint` / `ruff` - 代码检查

---

## 确认流程

### DESTRUCTIVE 必须二次确认
```
⚠️ 危险操作：rm -rf /Users/zhoujie/project
📁 将删除：1,234 个文件
⏰ 操作不可逆

输入 "yes, do it" 确认执行：
```

### WRITE 操作首次确认
```
📝 操作：git push origin main
🌐 目标：github.com/linuxgbok/repo
📋 将推送：5 个 commit

输入 "yes" 确认：
```

---

## 记住选择

相同操作 + 相同目标 → 记住 24 小时

记录位置：`~/.openclaw/workspace/capabilities/approved-actions.json`

---

## 实施清单

执行前检查：
- [ ] 这是 DESTRUCTIVE 操作吗？
- [ ] 是否需要二次确认？
- [ ] 目标文件/目录正确吗？
- [ ] 操作可逆吗？

---

## 自动检查规则

```python
DESTRUCTIVE_PATTERNS = [
    r"rm\s+-rf",
    r"rm\s+-r",
    r"mv\s+.*\s+.*",  # 覆盖
    r">\s*\S+",       # 重定向覆盖
    r"dd\s+",
    r"mkfs",
    r"fdisk",
]

WRITE_PATTERNS = [
    r"git\s+push",
    r"curl\s+.*-X\s+POST",
    r"ssh\s+",
    r"scp\s+",
]

def classify_operation(command: str) -> SafetyLevel:
    for pattern in DESTRUCTIVE_PATTERNS:
        if re.search(pattern, command):
            return SafetyLevel.DESTRUCTIVE
    # ... 类似 WRITE/READ
```
