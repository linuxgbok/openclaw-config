# Permission Rule Matcher - 权限规则匹配

> 参考 Claude Code 的权限系统，支持 glob/pattern 匹配

---

## 规则格式

```json
{
  "rules": [
    {
      "pattern": "git *",
      "tools": ["Bash", "exec"],
      "action": "allow",
      "reason": "Git 操作安全"
    },
    {
      "pattern": "rm -rf *",
      "tools": ["Bash", "exec"],
      "action": "deny",
      "reason": "危险删除操作"
    },
    {
      "pattern": "curl * -X POST",
      "tools": ["Bash", "exec"],
      "action": "confirm",
      "reason": "HTTP POST 请求"
    }
  ]
}
```

---

## Pattern 语法

| 模式 | 说明 | 示例 |
|------|------|------|
| `*` | 任意字符 | `git *` 匹配 `git push`、`git status` |
| `?` | 单个字符 | `?.txt` 匹配 `a.txt`、`b.txt` |
| `[abc]` | 字符集 | `test[123].py` 匹配 `test1.py`、`test2.py` |
| `[!abc]` | 否定 | `*[!a].py` 排除以 `a` 结尾的 py 文件 |

---

## Action 类型

| Action | 说明 | 行为 |
|--------|------|------|
| `allow` | 允许 | 直接执行，无需确认 |
| `deny` | 拒绝 | 阻止执行，报错 |
| `confirm` | 确认 | 询问后执行 |
| `prompt` | 提示 | 询问用户选择 |

---

## 匹配优先级

1. 最具体的规则优先
2. `deny` 优先于 `allow`
3. 通配符规则优先级较低

---

## 示例规则集

### 安全的只读操作
```json
{
  "pattern": "git status",
  "tools": ["Bash"],
  "action": "allow"
},
{
  "pattern": "git log *",
  "tools": ["Bash"],
  "action": "allow"
},
{
  "pattern": "git diff *",
  "tools": ["Bash"],
  "action": "allow"
}
```

### 需要确认的操作
```json
{
  "pattern": "git push *",
  "tools": ["Bash"],
  "action": "confirm",
  "reason": "将推送到远程仓库"
},
{
  "pattern": "git merge *",
  "tools": ["Bash"],
  "action": "confirm",
  "reason": "合并分支"
}
```

### 危险操作
```json
{
  "pattern": "rm -rf /",
  "tools": ["Bash"],
  "action": "deny",
  "reason": "根目录删除"
},
{
  "pattern": "rm -rf *",
  "tools": ["Bash"],
  "action": "confirm",
  "reason": "递归删除"
}
```

---

## 实现

```javascript
class PermissionMatcher {
  constructor(rules) {
    this.rules = rules.sort((a, b) => {
      // deny 优先
      if (a.action === 'deny' && b.action !== 'deny') return -1
      if (b.action === 'deny' && a.action !== 'deny') return 1
      // 具体规则优先
      return b.pattern.length - a.pattern.length
    })
  }

  match(command) {
    for (const rule of this.rules) {
      if (this.matchPattern(command, rule.pattern)) {
        return rule
      }
    }
    return { action: 'prompt' } // 默认询问
  }

  matchPattern(command, pattern) {
    // 转换为正则
    const regex = new RegExp(
      '^' + pattern
        .replace(/\./g, '\\.')
        .replace(/\*/g, '.*')
        .replace(/\?/g, '.')
      + '$'
    )
    return regex.test(command)
  }
}
```

---

## 使用流程

```
命令执行
    ↓
PermissionMatcher.match(command)
    ↓
找到规则？
  ├─ Yes → 执行对应 action
  │         ├─ allow → 直接执行
  │         ├─ deny → 阻止 + 报错
  │         ├─ confirm → 询问用户
  │         └─ prompt → 通用询问
  │
  └─ No → 默认 prompt（询问用户）
```

---

## 集成

在 `openclaw.json` 中配置：
```json
{
  "permissions": {
    "enabled": true,
    "rulesFile": "~/.openclaw/workspace/capabilities/permission-rules.json",
    "defaultAction": "prompt"
  }
}
```

---

_最后更新：2026-04-03_
