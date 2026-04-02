# 🔄 OpenClaw 换机迁移指南

> 通过 Git 备份恢复 OpenClaw 配置，实现无缝迁移

---

## 📋 前提条件

1. **新电脑已安装 OpenClaw**
   ```bash
   # 检查是否安装
   openclaw --version
   
   # 如果没安装，从官网下载
   # https://openclaw.ai
   ```

2. **GitHub 账号 + 已推送的备份仓库**
   - 仓库地址：`https://github.com/linuxgbok/openclaw-config`

3. **Git 已安装**（通常 macOS 自带）

---

## 🚀 迁移步骤

### 方式一：全自动恢复（推荐）

```bash
# 1. 克隆配置仓库
git clone https://github.com/linuxgbok/openclaw-config.git ~/.openclaw/workspace

# 2. 进入工作区
cd ~/.openclaw/workspace

# 3. 恢复配置文件
cp config/openclaw.json ~/.openclaw/
cp config/update-check.json ~/.openclaw/

# 4. 可选：恢复备份脚本（如果有）
cp scripts/* ~/.openclaw/scripts/ 2>/dev/null || true
```

### 方式二：分步恢复

```bash
# 1. 克隆仓库到任意位置
git clone https://github.com/linuxgbok/openclaw-config.git ~/openclaw-backup

# 2. 复制配置文件
cp ~/openclaw-backup/config/openclaw.json ~/.openclaw/
cp ~/openclaw-backup/config/update-check.json ~/.openclaw/

# 3. 复制工作区（记忆、技能等）
cp -r ~/openclaw-backup/* ~/.openclaw/workspace/

# 4. 清理临时目录
rm -rf ~/openclaw-backup

# 5. 重启 OpenClaw Gateway
openclaw gateway restart
```

---

## ✅ 验证恢复

```bash
# 1. 检查配置文件
cat ~/.openclaw/openclaw.json | python3 -c "import json,sys; json.load(sys.stdin); print('✅ JSON 格式正确')"

# 2. 检查 Gateway 状态
openclaw gateway status

# 3. 验证备份脚本
~/.openclaw/scripts/verify-backup.sh

# 4. 测试 Agent 是否正常
openclaw status
```

---

## 📦 迁移后检查清单

| 检查项 | 命令 | 状态 |
|--------|------|------|
| 配置文件 | `cat ~/.openclaw/openclaw.json` | ⬜ |
| Gateway 状态 | `openclaw gateway status` | ⬜ |
| 记忆系统 | `cat ~/.openclaw/workspace/MEMORY.md \| head -20` | ⬜ |
| Skills | `ls ~/.openclaw/workspace/skills/` | ⬜ |
| 备份脚本 | `~/.openclaw/scripts/backup-config.sh --help` | ⬜ |

---

## 🔧 常见问题

### Q1: 迁移后 Agent 不工作？

```bash
# 重启 Gateway
openclaw gateway restart

# 检查日志
tail -100 ~/.openclaw/logs/gateway.log
```

### Q2: 飞书 Bot 不工作了？

检查 `openclaw.json` 里的凭证是否完整迁移，或重新配置：
- Code Bot token
- Exec Bot token
- Webhook URL

### Q3: 备份脚本不存在？

手动恢复：
```bash
mkdir -p ~/.openclaw/scripts
# 从仓库 scripts/ 目录复制
```

### Q4: 记忆文件里有敏感信息？

**迁移前建议清理**：
```bash
# 检查敏感信息
grep -r "token\|password\|secret" ~/.openclaw/workspace/memory/

# 清理后重新推送
git add -A && git commit -m "chore: clean sensitive data"
```

---

## 🔐 安全建议

### 敏感信息处理

OpenClaw 配置可能包含：
- API tokens
- Webhook URLs
- 飞书 Bot 凭证

**推荐做法**：
1. 迁移后手动更新敏感配置
2. 或使用环境变量替代硬编码

```bash
# 示例：使用环境变量
export FEISHU_CODE_BOT_TOKEN="your-token-here"
openclaw gateway restart
```

### 仓库权限控制

- 仓库设为 **Private**（敏感配置）
- 或定期清理 memory 文件中的 token

---

## 📝 快速命令汇总

```bash
# 一键迁移（复制粘贴即可）
git clone https://github.com/linuxgbok/openclaw-config.git ~/ocl-tmp && \
cp ~/ocl-tmp/config/openclaw.json ~/.openclaw/ && \
cp ~/ocl-tmp/config/update-check.json ~/.openclaw/ && \
cp -r ~/ocl-tmp/* ~/.openclaw/workspace/ && \
rm -rf ~/ocl-tmp && \
openclaw gateway restart && \
echo "✅ 迁移完成"
```

---

## 📞 获取帮助

- OpenClaw 文档：https://docs.openclaw.ai
- 社区：https://discord.com/invite/clawd
- GitHub Issues：https://github.com/openclaw/openclaw/issues

---

_最后更新：2026-04-02_
