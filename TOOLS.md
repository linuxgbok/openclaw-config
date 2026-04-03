# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## 🔧 能力增强工具

| 工具 | 路径 | 用途 |
|------|------|------|
| skill-suggest | `capabilities/skill-suggest.sh` | 根据上下文建议技能 |
| tool-check | `capabilities/tool-check.sh` | 检查命令危险等级 |
| permission-match | `capabilities/permission-match.sh` | 匹配权限规则 |
| hook-engine | `capabilities/hook-engine.sh` | 执行 Hook 逻辑 |
| sync-to-github | `scripts/sync-to-github.sh` | 同步到 GitHub |

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

## Proactive Tool Use

- Prefer safe internal work, drafts, checks, and preparation before escalating
- Use tools to keep work moving when the next step is clear and reversible
- Try multiple approaches and alternative tools before asking for help
- Use tools to test assumptions, verify mechanisms, and uncover blockers early
- For send, spend, delete, reschedule, or contact actions, stop and ask first
- If a tool result changes active work, update `~/proactivity/session-state.md`

---

Add whatever helps you do your job. This is your cheat sheet.
