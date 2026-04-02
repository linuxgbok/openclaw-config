---
name: context-aware
description: "上下文感知技能：根据当前工作区文件自动建议或激活相关技能。使用 /skill list 查看所有技能，技能会根据 paths 规则自动匹配当前项目。"
paths:
  - "**/*.py"
  - "**/*.js"
  - "**/*.ts"
  - "**/*.go"
  - "**/*.md"
  - "**/test*/**"
  - "**/*_test.*"
whenToUse: "当需要根据当前项目类型自动调用相关技能时"
---

# Context-Aware Skill Activation

这个技能负责**上下文感知**，根据当前工作区的文件类型自动建议相关技能。

## 工作原理

1. 检测当前目录的文件模式
2. 匹配 `paths` 规则（gitignore 风格）
3. 返回匹配的技能列表

## 使用命令

```bash
# 列出当前上下文建议的技能
/skill suggest

# 列出所有可用技能
/skill list

# 查看特定技能的匹配规则
/skill info <skill-name>
```

## 技能匹配表

| 技能 | 匹配模式 | 触发条件 |
|------|----------|----------|
| `code-review-assistant` | `**/*.py`, `**/*.js`, `**/*.ts`, `**/*.go` | 代码文件 |
| `github` | `.git/`, `**/.github/**` | Git 仓库 |
| `gitlab-code-review` | `.gitlab-ci.yml`, `**/gitlab/**` | GitLab 项目 |
| `monitoring` | `**/prometheus/**`, `**/grafana/**`, `**/监控/**` | 监控配置 |
| `mermaid-diagram` | `**/*.mmd`, `**/*.puml` | 图表文件 |
| `notion-skill` | `**/*.md`, `**/notes/**` | 文档文件 |

## 实现逻辑

```
检测流程：
1. 扫描当前工作目录结构（深度3层）
2. 提取文件扩展名和目录名
3. 匹配 paths patterns（使用 ignore 库）
4. 返回匹配的技能 + 置信度
5. 建议激活或自动激活
```

## 置信度计算

- 精确匹配（文件名）：100%
- 扩展名匹配：80%
- 目录匹配：60%
- 多重匹配：叠加

## 示例

当工作区包含 `src/**/*.py` 时：
```
🤖 建议激活技能：
   • code-review-assistant (95%) - 代码审查
   • monitoring (30%) - 监控（仅当检测到 prometheus/ 目录）
```

---

## 开发指南

如需添加新技能的路径规则，编辑 `~/.openclaw/workspace/capabilities/skill-manifest.md`
