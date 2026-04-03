---
name: hook-system
description: "Hook 系统：在工具执行前/后自动触发钩子。参考 Claude Code 的 hooks 机制。"
whenToUse: "当需要拦截、修改或增强工具行为时使用"
---

# Hook System - 钩子系统

## 概述

Hook 允许在工具执行前/后自动运行自定义逻辑，用于：
- 权限检查
- 参数验证
- 日志记录
- 自动补全
- 安全审计

---

## 支持的 Hook 类型

### pre_tool_use
**工具执行前触发**
- 可修改参数
- 可取消执行
- 可记录审计日志

### post_tool_use
**工具执行后触发**
- 可检查结果
- 可记录执行时间
- 可触发后续操作

---

## Hook 配置文件

```json
{
  "version": "1.0",
  "hooks": {
    "pre_tool_use": {
      "read": ["log_read", "validate_path"],
      "write": ["confirm_write", "backup_file"],
      "exec": ["confirm_destructive", "log_command"]
    },
    "post_tool_use": {
      "read": ["update_stats"],
      "write": ["verify_write", "notify_change"],
      "exec": ["log_result", "notify_complete"]
    }
  }
}
```

---

## 内置 Hooks

### pre_tool_use

| Hook | 适用工具 | 功能 |
|------|----------|------|
| `confirm_destructive` | rm, trash, kill | 二次确认危险操作 |
| `validate_path` | read, edit | 验证路径安全 |
| `check_workspace` | 所有 | 检查工作区边界 |
| `log_command` | exec, bash | 记录命令执行 |

### post_tool_use

| Hook | 适用工具 | 功能 |
|------|----------|------|
| `update_stats` | read, edit | 更新操作统计 |
| `verify_write` | write, edit | 验证写入成功 |
| `notify_change` | write, edit | 通知变更 |
| `log_result` | exec | 记录执行结果 |

---

## 使用方式

### 1. 启用 Hook

在 `~/.openclaw/openclaw.json` 中启用：
```json
{
  "hooks": {
    "enabled": true,
    "pre_tool_use": {
      "exec": ["confirm_destructive"]
    }
  }
}
```

### 2. 自定义 Hook

创建 Hook 文件：
```bash
mkdir -p ~/.openclaw/hooks/pre_tool_use
```

创建 `confirm_destructive.js`：
```javascript
module.exports = {
  name: 'confirm_destructive',
  async pre_tool_use({ tool, args, context }) {
    // 检查是否危险操作
    if (isDestructive(tool, args)) {
      // 返回确认提示
      return {
        type: 'confirm',
        message: `⚠️ 危险操作：${tool}`,
        options: ['yes', 'no']
      }
    }
    // 返回 continue 放行
    return { type: 'continue' }
  }
}
```

---

## Hook 执行流程

```
用户请求
    ↓
pre_tool_use hooks
    ↓ (全部放行)
工具执行
    ↓
post_tool_use hooks
    ↓
返回结果
```

---

## 示例：自动备份

```javascript
// hooks/pre_tool_use/backup_file.js
module.exports = {
  name: 'backup_file',
  async pre_tool_use({ tool, args }) {
    if (tool === 'edit' || tool === 'write') {
      const filePath = args[0]
      await backupFile(filePath)
      console.log(`📦 已备份: ${filePath}`)
    }
    return { type: 'continue' }
  }
}
```

---

## 优先级

Hook 可设置优先级（1-100），数字越小越先执行：
```javascript
module.exports = {
  name: 'check_first',
  priority: 1,
  // ...
}
```

---

_最后更新：2026-04-03_
