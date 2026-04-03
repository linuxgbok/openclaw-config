---
name: mcp-integration
description: "MCP (Model Context Protocol) 集成：连接外部工具和服务，支持 MCP Servers。"
whenToUse: "当需要连接 GitHub、Slack、数据库等外部服务时使用"
---

# MCP Integration - MCP 集成

## 概述

MCP (Model Context Protocol) 允许 OpenClaw 连接外部工具和服务，类似 Claude Code 的 MCP 集成。

---

## 架构

```
OpenClaw
    ↓ MCP Client
MCP Server (如 GitHub、Slack、PostgreSQL)
    ↓
外部服务 API
```

---

## MCP Server 列表

### 官方服务器
- `github` - GitHub API
- `slack` - Slack 消息
- `postgresql` - PostgreSQL 数据库
- `filesystem` - 文件系统访问
- `memory` - 知识图谱

### 社区服务器
- `mcp-server-everything` - 通用工具
- `fetch` - HTTP 请求
- `brave-search` - 搜索

---

## 配置

在 `openclaw.json` 中添加：

```json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_TOKEN": "your-token"
        }
      },
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem"],
        "args": ["/path/to/allowed/directory"]
      }
    }
  }
}
```

---

## MCP Tools

连接成功后，自动获得以下工具：

### github
- `github_list_repos` - 列出仓库
- `github_create_issue` - 创建 Issue
- `github_get_pr` - 获取 PR 信息

### filesystem
- `filesystem_read_file` - 读取文件
- `filesystem_write_file` - 写入文件
- `filesystem_list_directory` - 列出目录

### postgresql
- `postgresql_query` - 执行 SQL
- `postgresql_list_tables` - 列出表

---

## 使用示例

```
用户: 帮我创建一个 GitHub issue
Agent: 
  → 调用 github_create_issue 工具
  → MCP Server 处理请求
  → 返回 issue 链接
```

---

## 调试

```bash
# 查看 MCP 连接状态
openclaw mcp list

# 测试连接
openclaw mcp test github

# 查看日志
tail -f ~/.openclaw/logs/mcp.log
```

---

## 安全

- MCP 工具访问外部服务需要凭证
- 凭证存储在环境变量或密钥管理中
- 定期轮换 Token

---

_最后更新：2026-04-03_
