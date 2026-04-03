# Subagent Lifecycle Management - 子代理生命周期

> 参考 Claude Code Task.ts 的任务状态管理

---

## 状态机

```
                    ┌─────────┐
         ┌─────────→│ pending │←─────────┐
         │          └────┬────┘          │
         │               │                │
    start()         schedule()        schedule()
         │               │                │
         ↓               ↓                ↓
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │ running  │    │ running │    │ running │
    └────┬────┘    └────┬────┘    └────┬────┘
         │               │                │
         ↓               ↓                ↓
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │completed│    │ failed  │    │ killed  │
    └─────────┘    └─────────┘    └─────────┘
```

---

## 状态定义

| 状态 | 说明 | 可转换到 |
|------|------|----------|
| `pending` | 等待执行 | running, killed |
| `running` | 执行中 | completed, failed, killed |
| `completed` | 成功完成 | (终态) |
| `failed` | 执行失败 | (终态) |
| `killed` | 被终止 | (终态) |

---

## TaskHandle

```typescript
interface TaskHandle {
  taskId: string          // 唯一标识
  status: TaskStatus      // 当前状态
  startedAt?: Date         // 开始时间
  endedAt?: Date          // 结束时间
  outputFile?: string     // 输出文件路径
  abortController?: AbortController  // 中止控制
}
```

---

## 生命周期方法

### spawn()
创建并启动任务
```typescript
function spawn(task: Task, config: TaskConfig): TaskHandle
```

### kill()
终止任务
```typescript
async function kill(taskId: string): Promise<void>
```

### getStatus()
获取状态
```typescript
function getStatus(taskId: string): TaskStatus
```

### waitFor()
等待任务完成
```typescript
async function waitFor(taskId: string, timeout?: number): Promise<TaskResult>
```

---

## 输出持久化

Claude Code 将任务输出写入磁盘，支持：

```typescript
const outputPath = getTaskOutputPath(taskId)
// 输出目录: ~/.openclaw/subagents/{taskId}/output.txt
```

优点：
- 任务结果不丢失
- 可断点续传
- 便于调试

---

## 实现

```bash
# 子代理输出目录
SUBAGENT_OUTPUT_DIR="$HOME/.openclaw/subagents"

# 创建任务
create_task() {
    local task_id="$1"
    local output_file="$SUBAGENT_OUTPUT_DIR/$task_id/output.txt"
    
    mkdir -p "$(dirname $output_file)"
    echo "pending" > "$SUBAGENT_OUTPUT_DIR/$task_id/status"
    
    echo "{\"taskId\": \"$task_id\", \"status\": \"pending\", \"outputFile\": \"$output_file\"}"
}

# 更新状态
update_status() {
    local task_id="$1"
    local status="$2"
    
    echo "$status" > "$SUBAGENT_OUTPUT_DIR/$task_id/status"
}

# 获取状态
get_status() {
    local task_id="$1"
    cat "$SUBAGENT_OUTPUT_DIR/$task_id/status"
}
```

---

## 任务清理

定期清理已完成的任务：

```bash
# 清理超过 7 天的任务
find ~/.openclaw/subagents -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
```

---

## 监控

查看活跃任务：
```bash
ls -la ~/.openclaw/subagents/
```

查看任务输出：
```bash
cat ~/.openclaw/subagents/{task_id}/output.txt
```

---

_最后更新：2026-04-03_
