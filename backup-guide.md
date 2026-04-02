# 📦 OpenClaw 备份恢复指南

## 快速参考

| 操作 | 命令 |
|------|------|
| 备份 | `~/.openclaw/scripts/backup-config.sh [备注]` |
| 验证 | `~/.openclaw/scripts/verify-backup.sh [备份文件]` |
| 恢复 | `~/.openclaw/scripts/restore-config.sh <备份文件>` |
| 紧急恢复 | `~/.openclaw/scripts/emergency-restore.sh` |

---

## 1️⃣ 备份

```bash
# 普通备份
~/.openclaw/scripts/backup-config.sh

# 带备注备份（便于识别）
~/.openclaw/scripts/backup-config.sh "before-major-change"
```

**输出：**
- `~/.openclaw/backup/openclaw-config-<日期>-<备注>.json` - 配置文件
- `~/.openclaw/backup/openclaw-config-<日期>-<备注>.tar.gz` - 完整备份（49MB）
- `~/.openclaw/backup/latest.json` / `latest.tar.gz` - 最新备份软链接

**自动清理：** 保留最近 20 个备份

---

## 2️⃣ 验证

```bash
# 验证 latest 备份
~/.openclaw/scripts/verify-backup.sh

# 验证指定备份
~/.openclaw/scripts/verify-backup.sh ~/.openclaw/backup/openclaw-config-20260402-225511-xxx.tar.gz
```

**验证项目：**
- ✅ gzip 完整性
- ✅ openclaw.json 存在且 JSON 格式正确
- ✅ 与当前配置对比

---

## 3️⃣ 恢复

### 方式一：恢复配置文件
```bash
~/.openclaw/scripts/restore-config.sh <备份文件>
```

### 方式二：紧急恢复（交互式）
```bash
~/.openclaw/scripts/emergency-restore.sh
```
- 显示备份列表（0-9 选择）
- 支持完整 `.tar.gz` 恢复
- 自动停止/启动 Gateway

---

## ⚠️ 强制规则

> **每次修改 `openclaw.json` 前，必须先执行备份！**

```bash
# 正确流程
~/.openclaw/scripts/backup-config.sh "before-change"  # 1. 备份
# ... 修改配置 ...
~/.openclaw/scripts/verify-backup.sh  # 2. 验证新配置正常
# 如果出问题：
~/.openclaw/scripts/restore-config.sh ~/.openclaw/backup/latest.json  # 3. 恢复
```

---

## 📍 备份位置

```
~/.openclaw/backup/
├── openclaw-config-20260402-225511-xxx.json    # 配置备份
├── openclaw-config-20260402-225511-xxx.tar.gz # 完整备份
├── latest.json → # 指向最新配置
└── latest.tar.gz → # 指向最新完整备份
```

---

## ❓ 常见问题

**Q: 备份太大（49MB）？**
A: 正常，包含媒体文件和历史备份

**Q: restore 失败？**
A: 使用 `emergency-restore.sh` 选择完整 `.tar.gz` 恢复

**Q: 如何查看所有备份？**
A: `ls -lt ~/.openclaw/backup/`
