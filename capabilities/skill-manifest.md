# 🎯 Skill 条件激活清单

> 当匹配到特定文件/项目时，自动启用对应技能

---

## 激活规则

| Skill | 触发条件 (paths) | 说明 |
|-------|-------------------|------|
| `code-review-assistant` | `**/*.py`, `**/*.js`, `**/*.ts`, `**/*.go` | 代码审查 |
| `github` | `.git/`, `**/.github/**` | GitHub 操作 |
| `gitlab-code-review` | `.gitlab-ci.yml`, `**/gitlab/**` | GitLab CI |
| `monitoring` | `**/prometheus/**`, `**/grafana/**`, `**/监控/**` | 监控配置 |
| `code-review-assistant` | `**/test*.py`, `**/*_test.go`, `**/tests/**` | 单元测试 |
| `mermaid-diagram` | `**/*.mmd`, `**/*.puml` | 图表绘制 |
| `context-aware` | `**/*` | 上下文感知（始终可用） |
| `tool-safety` | `**/*` | 安全检查（始终可用） |

---

## 使用方式

### 手动激活
```
/skill code-review-assistant
/skill github pr list
```

### 自动建议
当检测到工作目录包含匹配的文件模式时，自动建议激活。

---

## 实现逻辑

```
1. 读取当前工作目录结构
2. 匹配 paths patterns（gitignore 风格）
3. 返回匹配的 skills 列表
4. 提供激活建议或自动激活
```

---

## Pattern 格式

使用 gitignore 风格：
- `**/*.py` - 任意目录下的 .py 文件
- `src/**` - src 目录下所有文件
- `!test/**` - 排除 test 目录
- `*.config.*` - 所有 config 文件

---

## 优先级

1. **高优先级**：DESTRUCTIVE 操作 → 必须二次确认
2. **中优先级**：WRITE 操作 → 首次确认
3. **低优先级**：READ 操作 → 直接执行

---

_最后更新：2026-04-03_
