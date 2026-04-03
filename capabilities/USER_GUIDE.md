# 🎯 OpenClaw 能力增强系统 - 使用指南

> 把 Claude Code 的优秀设计真正用起来

---

## 📋 已实现功能清单

### ✅ 1. Skill 条件激活
**作用**：根据当前文件类型自动建议相关技能

**脚本**：`capabilities/skill-suggest.sh`

**使用**：
```bash
# 每次开始新任务前先运行，查看建议激活的技能
~/.openclaw/workspace/capabilities/skill-suggest.sh
```

**示例输出**：
```
🔍 分析工作区: /Users/zhoujie/project
📊 检测到 25 个相关文件
🤖 技能建议：
   code-review-assistant       80%
   github                     60%
   notion-skill               40%
✨ 最推荐：code-review-assistant (80%)
💡 使用 /skill activate <name> 激活技能
```

---

### ✅ 2. Tool 安全分级
**作用**：执行危险操作前自动检查，防止误删

**脚本**：`capabilities/tool-check.sh`

**使用**：
```bash
# 执行任何可能危险的操作前检查
~/.openclaw/workspace/capabilities/tool-check.sh "<command>"

# 示例
~/.openclaw/workspace/capabilities/tool-check.sh "rm -rf /tmp/test"
~/.openclaw/workspace/capabilities/tool-check.sh "git push origin main"
```

**分级结果**：
- 🟢 READ - 安全，直接执行
- 🟡 WRITE - 建议确认
- 🔴 DESTRUCTIVE - 必须二次确认

---

### ✅ 3. 权限规则匹配
**作用**：模式匹配命令，自动决定是否需要确认

**脚本**：`capabilities/permission-match.sh`

**使用**：
```bash
# 检查命令是否在白名单/黑名单
~/.openclaw/workspace/capabilities/permission-match.sh "<command>"

# 示例
~/.openclaw/workspace/capabilities/permission-match.sh "git status"     # ALLOW
~/.openclaw/workspace/capabilities/permission-match.sh "rm -rf /"     # DENY
~/.openclaw/workspace/capabilities/permission-match.sh "git push"     # CONFIRM
```

**内置规则**：
- ALLOW: `git status`, `ls`, `cat`, `grep` 等只读操作
- CONFIRM: `git push`, `npm install`, `curl` 等需确认
- DENY: `rm -rf /`, `dd if=* of=/dev/` 等危险操作

---

### ✅ 4. Hook 系统
**作用**：在操作执行前/后插入自定义逻辑

**脚本**：`capabilities/hook-engine.sh`

**使用**：
```bash
# 执行前 Hook
~/.openclaw/workspace/capabilities/hook-engine.sh pre_tool_use <tool> [args]

# 执行后 Hook
~/.openclaw/workspace/capabilities/hook-engine.sh post_tool_use <tool> [args]
```

**内置 Hook**：
- `confirm_destructive` - 危险操作二次确认
- `validate_path` - 路径安全验证
- `log_command` - 命令执行日志

---

## 🚀 日常工作流

### 1. 开始新任务

```bash
# 1. 分析上下文，获取技能建议
~/.openclaw/workspace/capabilities/skill-suggest.sh

# 2. 根据建议激活需要的技能
/skill activate code-review-assistant
```

### 2. 执行危险操作前

```bash
# 1. 检查危险等级
~/.openclaw/workspace/capabilities/tool-check.sh "rm -rf /tmp/old"

# 2. 如果是 DESTRUCTIVE，输入 yes 确认
# 3. 执行操作
```

### 3. 推送代码前

```bash
# 1. 检查权限
~/.openclaw/workspace/capabilities/permission-match.sh "git push origin main"
# → CONFIRM

# 2. 确认后执行
git push origin main
```

---

## ⚙️ 集成到 OpenClaw

### 在 AGENTS.md 中声明使用

```
## Tools

在执行任务前，使用能力增强工具：

1. **开始任务前**：运行 `~/.openclaw/workspace/capabilities/skill-suggest.sh` 获取技能建议
2. **执行命令前**：运行 `capabilities/tool-check.sh` 检查危险等级
3. **权限敏感操作**：运行 `capabilities/permission-match.sh` 确认规则
4. **危险操作**：必须二次确认
```

---

## 📊 验证清单

| 功能 | 脚本 | 验证命令 | 状态 |
|------|------|----------|------|
| Skill 建议 | skill-suggest.sh | `./skill-suggest.sh` | ✅ |
| Tool 检查 | tool-check.sh | `./tool-check.sh "rm -rf /"` | ✅ |
| 权限匹配 | permission-match.sh | `./permission-match.sh "git push"` | ✅ |
| Hook 引擎 | hook-engine.sh | `./hook-engine.sh pre_tool_use exec "ls"` | ✅ |

---

## 🔧 自定义配置

### 添加权限规则

编辑 `capabilities/permission-match.sh` 中的数组：

```bash
# 添加新的确认规则
DEFAULT_CONFIRM+=(
    "docker push"
    "kubectl delete"
)

# 添加新的拒绝规则
DEFAULT_DENY+=(
    "rm -rf /home"
    "kill -9 1"
)
```

### 自定义 Hook

在 `capabilities/hooks/pre_tool_use/` 添加脚本：

```bash
#!/bin/bash
# my_custom_hook.sh
echo "执行前逻辑: $1 $2"
exit 0  # 返回 0 表示继续
```

---

## 📝 快速命令汇总

```bash
# 技能建议
~/.openclaw/workspace/capabilities/skill-suggest.sh

# Tool 安全检查
~/.openclaw/workspace/capabilities/tool-check.sh "<command>"

# 权限匹配
~/.openclaw/workspace/capabilities/permission-match.sh "<command>"

# Hook 执行
~/.openclaw/workspace/capabilities/hook-engine.sh <pre|post>_tool_use <tool> [args]
```

---

_最后更新：2026-04-03_
