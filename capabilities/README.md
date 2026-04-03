# 🎯 OpenClaw 能力增强系统

> 参考 Claude Code 源码实现的能力提升

---

## 目录结构

```
capabilities/
├── README.md                    # 本文件
├── skill-manifest.md           # Skill 条件激活清单
├── skill-suggest.sh            # Skill 建议脚本
├── hook-system.md              # Hook 系统设计
├── hook-engine.sh              # Hook 引擎
├── permission-rules.md          # 权限规则匹配
├── permission-match.sh          # 权限匹配器
├── approved-actions.json        # 已批准操作记录
├── tool-safety.md              # Tool 安全分级
├── tool-check.sh               # Tool 安全检查
├── subagent-lifecycle.md       # Subagent 生命周期
└── hooks/                      # Hook 实现
    ├── pre_tool_use/
    └── post_tool_use/
```

---

## 已实现功能

### 1. Skill 条件激活 ✅
- 文件路径自动匹配
- `/skill suggest` 建议相关技能
- `skill-suggest.sh` 上下文分析

### 2. Tool 安全分级 ✅
- READ / WRITE / DESTRUCTIVE 三级
- 危险操作二次确认
- `tool-check.sh` 自动检查

### 3. Hook 系统 ✅
- pre_tool_use / post_tool_use
- 可扩展的 Hook 架构
- 内置 confirm_destructive 等钩子

### 4. 权限规则匹配 ✅
- Glob pattern 匹配
- allow / deny / confirm / prompt
- `permission-match.sh` 实现

### 5. Subagent 生命周期 ⏳
- 状态机：pending → running → completed/failed/killed
- 输出持久化到磁盘
- 文档已编写，待实现

### 6. MCP 集成 ⏳
- MCP Server 连接管理
- 工具流式加载
- 文档已编写，待配置

### 7. Vim 快捷键 ⏳
- motions / operators 分离
- 文档已编写，待实现

### 8. Ink 终端 UI ⏳
- 自研渲染引擎
- 文档已编写，待实现

---

## 快速开始

### Skill 建议
```bash
~/.openclaw/workspace/capabilities/skill-suggest.sh
```

### Tool 安全检查
```bash
~/.openclaw/workspace/capabilities/tool-check.sh "rm -rf /tmp/test"
```

### 权限匹配
```bash
~/.openclaw/workspace/capabilities/permission-match.sh "git push origin main"
```

---

## 设计参考

- `Tool.ts` - 工具定义 + 安全分类
- `Task.ts` - 任务状态机
- `loadSkillsDir.ts` - Skill 动态加载
- `services/mcp/` - MCP 集成
- `vim/` - Vim 模拟
- `ink/` - 终端 UI

---

_最后更新：2026-04-03_
